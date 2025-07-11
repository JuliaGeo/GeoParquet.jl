abstract type Driver end
struct Parquet2Driver <: Driver end
struct QuackIODriver <: Driver end

"""
    write(ofn, t; geometrycolumn::Symbol, crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing; kwargs...)

Write a dataframe with a geometry column to a Parquet file. Returns `ofn` on succes. Keyword arguments are passed to Parquet2 writefile method.
The geometry column should be a `Vector{GeoFormat.WellKnownBinary}` or its elements should support GeoInterface.
You can construct one with WellKnownGeometry for geometries that support GeoInterface.
"""
function write(ofn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath}, df, geocolumns=nothing, crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing; geometrycolumn = nothing, kwargs...)

    if isnothing(geometrycolumn)
        if isnothing(geocolumns)
            # the happy path, everything is fine
            geometrycolumn = GI.geometrycolumns(df)
        else # the user has provided something to geocolumns
            Base.depwarn("The `geocolumns` positional argument to `GeoParquet.write` is deprecated, please use the `geometrycolumn` keyword argument instead.", :var"GeoParquet.write")
            geometrycolumn = geocolumns
        end
    elseif !isnothing(geocolumns)
        error("""
            It looks like you invoked `GeoParquet.write` with three arguments, but also
            provided a `geometrycolumns` keyword argument.

            The third positional argument in this method, `geocolumns`, is deprecated.  
            Please pass geometry column information as a Symbol or Tuple of Symbols to 
            the `geometrycolumn` keyword argument instead, such that you only have two
            positional arguments as input.
        """)
    end
        
    # Tables.istable(df) || throw(ArgumentError("`df` must be a table"))

    columns = Dict{String,Any}()
    tcols = Tables.columns(df)

    # For on the fly conversion to WKB
    ndf = DataFrame(df; copycols=false)

    geometrycolumns = if geometrycolumn isa Tuple || geometrycolumn isa Vector
        geometrycolumn
    else
        (geometrycolumn,)
    end

    for column in geometrycolumns
        column in Tables.columnnames(tcols) || error("Geometry column $column not found in table")
        data = Tables.getcolumn(tcols, column)
        GI.isgeometry(first(data)) || error("Geometry in $column must support the GeoInterface")
        T = eltype(data)
        if !(T <: GFT.WellKnownBinary) || !(T <: AbstractVector{UInt8})
            ndf[!, column] = _getwkb.(data)
        end
        types = typeof.(unique(GI.geomtrait.(data)))
        gtypes = getindex.((geowkb,), types)
        mc = MetaColumn(geometry_types=gtypes, bbox=bbox, crs=crs)
        columns[String(column)] = mc
    end

    md = Dict("geo" => JSON3.write(GeoParquet.MetaRoot(columns=columns, primary_column=String(first(geometrycolumn)))))

    kw = Dict{Symbol,Any}(kwargs)
    get!(kw, :compression_codec, :zstd)
    Parquet2.writefile(ofn, ndf; metadata=md, pairs(kw)...)
    return ofn
end

"""
    read(fn; kwargs...)::DataFrame

Read a GeoParquet file as DataFrame. Kwargs are passed to the Parquet2.Dataset constructor.
"""
function read(::Parquet2Driver, fn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath,Parquet2.FileManager}; kwargs...)
    ds = Parquet2.Dataset(fn, kwargs...)
    is_valid(ds) || error("Not a valid GeoParquet file")
    meta = geometadata(ds)
    df = DataFrame(ds; copycols=false)
    for column in keys(meta.columns)
        df[!, column] = GFT.WellKnownBinary.(Ref(GFT.Geom()), df[!, column])
    end
    # set GeoInterface metadata
    metadata!(df, "GEOINTERFACE:geometrycolumns", Tuple(Symbol.(keys(meta.columns))), style=:note)
    crs = meta.columns[meta.primary_column].crs
    if !isnothing(crs)
        metadata!(df, "GEOINTERFACE:crs", crs, style=:note)
    end
    df
end

function read(fn::AbstractString; driver=nothing, kwargs...)
    ext = Base.get_extension(GeoParquet, :QuackIOExt)
    driver = isnothing(ext) ? Parquet2Driver() : QuackIODriver()
    read(driver, fn; kwargs...)
end
