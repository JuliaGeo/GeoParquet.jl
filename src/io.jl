abstract type Driver end
struct Parquet2Driver <: Driver end
struct QuackIODriver <: Driver end

"""
    write(ofn, t; geometrycolumn=GI.geometrycolumns(t), crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing, kwargs...)

Write a table with geometry columns to a Parquet file. Returns `ofn` on success.
`geometrycolumn` is a Symbol or a Tuple of Symbols, of which the first is the primary geometry column.
Other keyword arguments are passed to the Parquet2 `writefile` method.
The geometry columns should be a `Vector{GeoFormat.WellKnownBinary}` or their elements should support GeoInterface.
You can construct one with WellKnownGeometry for geometries that support GeoInterface.
"""
function write(ofn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath}, df; geometrycolumn=GI.geometrycolumns(df), crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing, kwargs...)

    # Tables.istable(df) || throw(ArgumentError("`df` must be a table"))

    columns = Dict{String,Any}()
    tcols = Tables.columns(df)

    # For on the fly conversion to WKB
    ndf = DataFrame(df; copycols=false)
    # Replacing columns below drops non-note metadata, so collect it first
    metadata = Dict{String,String}(k => string(v) for (k, v) in DataAPI.metadata(ndf))
    column_metadata = Dict(col => Dict{String,String}(k => string(v) for (k, v) in kv) for (col, kv) in DataAPI.colmetadata(ndf))

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
        mc = MetaColumnv1_0(geometry_types=gtypes, bbox=bbox, crs=crs)
        columns[String(column)] = mc
    end

    metadata["geo"] = JSON.json(GeoParquet.MetaRoot{MetaColumnv1_0}(columns=columns, primary_column=String(first(geometrycolumns))); style=GeoParquetStyle())

    kw = Dict{Symbol,Any}(kwargs)
    get!(kw, :compression_codec, :zstd)
    Parquet2.writefile(ofn, ndf; metadata, column_metadata, pairs(kw)...)
    return ofn
end

function write(ofn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath}, df, geocolumns, crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing; kwargs...)
    Base.depwarn("`GeoParquet.write(ofn, df, geocolumns, crs, bbox)` is deprecated, use `GeoParquet.write(ofn, df; geometrycolumn, crs, bbox)` instead.", :write)
    write(ofn, df; geometrycolumn=something(geocolumns, GI.geometrycolumns(df)), crs, bbox, kwargs...)
end

"""
    read(fn; kwargs...)::DataFrame

Read a GeoParquet file as DataFrame. Kwargs are passed to the Parquet2.Dataset constructor.
"""
function read(::Driver, fn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath,Parquet2.FileManager}; kwargs...)
    ds = try
        Parquet2.Dataset(fn; kwargs...)
    catch e
        # FieldError was added in Julia 1.12, earlier versions throw an ErrorException
        is_field_error = @static isdefined(Base, :FieldError) ? e isa FieldError : (e isa ErrorException && occursin("has no field", e.msg))
        if is_field_error
            error("Parquet2 can't read this file (see https://gitlab.com/ExpandingMan/Parquet2.jl/-/issues/55), try `import QuackIO` and rerun instead.")
        else
            rethrow(e)
        end
    end
    df = DataFrame(ds; copycols=false)
    if !is_valid(ds)
        @warn "GeoParquet metadata not found in $fn, returning DataFrame without geometry parsing"
        return df
    end
    meta = geometadata(ds)

    original_metadata = metadata(df)
    original_colmetadata = colmetadata(df)
    for (columnname, column) in pairs(meta.columns)
        if column.encoding == "WKB"
            df[!, columnname] = GFT.WellKnownBinary.(Ref(GFT.Geom()), df[!, columnname])
        else
            @warn "Unsupported geometry encoding: $(column.encoding) for column $columnname, returning raw data"
        end
    end
    for (k, v) in original_metadata
        metadata!(df, k, v)
    end
    for (k, v) in original_colmetadata
        for (vk, vv) in v
            colmetadata!(df, k, vk, vv)
        end
    end
    # set GeoInterface metadata
    metadata!(df, "GEOINTERFACE:geometrycolumns", Tuple(Symbol.(keys(meta.columns))), style=:note)
    crs = meta.columns[meta.primary_column].crs
    if !isnothing(crs)
        metadata!(df, "GEOINTERFACE:crs", crs, style=:note)
    end
    df
end

# Default to QuackIODriver if available, otherwise fallback to Parquet2Driver
read(fn::AbstractString; driver=nothing, kwargs...) = read(QuackIODriver(), fn; kwargs...)
