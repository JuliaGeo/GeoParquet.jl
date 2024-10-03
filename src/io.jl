"""
    write(ofn, t, columns=(:geom), crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing; kwargs...)

Write a dataframe with a geometry column to a Parquet file. Returns `ofn` on succes. Keyword arguments are passed to Parquet2 writefile method.
The geometry column should be a `Vector{GeoFormat.WellKnownBinary}` or its elements should support GeoInterface.
You can construct one with WellKnownGeometry for geometries that support GeoInterface.
"""
function write(ofn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath}, df, geocolumns=(:geom,), crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing; kwargs...)

    # Tables.istable(df) || throw(ArgumentError("`df` must be a table"))

    columns = Dict{String,Any}()
    tcols = Tables.columns(df)

    # For on the fly conversion to WKB
    ndf = DataFrame(df; copycols=false)

    for column in geocolumns
        column in Tables.columnnames(tcols) || error("Geometry column $column not found in table")
        data = Tables.getcolumn(tcols, column)
        GI.isgeometry(first(data)) || error("Geometry in $column must support the GeoInterface")
        T = eltype(data)
        if !(T <: GFT.WellKnownBinary) || !(T <: AbstractVector{UInt8})
            ndf[!, column] = _getwkb.(data)
        end
        types = unique(typeof.(GI.geomtrait.(data)))
        gtypes = getindex.(Ref(geowkb), types)
        mc = MetaColumn(geometry_types=gtypes, bbox=bbox, crs=crs)
        columns[String(column)] = mc
    end

    md = Dict("geo" => JSON3.write(GeoParquet.MetaRoot(columns=columns, primary_column=String(geocolumns[1]))))

    kw = Dict{Symbol,Any}(kwargs)
    get!(kw, :compression_codec, :zstd)
    Parquet2.writefile(ofn, ndf; metadata=md, pairs(kw)...)
    ofn
end


"""
    read(fn; kwargs...)::DataFrame

Read a GeoParquet file as DataFrame. Kwargs are passed to the Parquet2.Dataset constructor.
"""
function read(fn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath,Parquet2.FileManager}; kwargs...)
    ds = Parquet2.Dataset(fn, kwargs...)
    is_valid(ds) || error("Not a valid GeoParquet file")
    meta = geometadata(ds)
    df = DataFrame(ds; copycols=false)
    for column in keys(meta.columns)
        df[!, column] = GFT.WellKnownBinary.(Ref(GFT.Geom()), df[!, column])
    end
    mc = meta.columns[meta.primary_column]
    if !isnothing(mc.crs)
        metadata!(df, "GEOINTERFACE:crs", mc.crs)
    end
    df
end
