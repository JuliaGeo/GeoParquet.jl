module QuackIOExt
using QuackIO
using GeoParquet

function GeoParquet.read(::GeoParquet.QuackIODriver, fn::AbstractString; kwargs...)
    df = QuackIO.read_parquet(GeoParquet.DataFrame, fn; kwargs...)

    db = QuackIO.DuckDB.DB()
    file = QuackIO.kwarg_val_to_db_incomma(fn)
    qstr = """select * from parquet_kv_metadata($file) where key = 'geo'"""
    result = QuackIO.DBInterface.execute(db, qstr)
    values = GeoParquet.Tables.columns(result).value
    length(values) == 1 || return read_parquet_types!(df, fn, db, file)
    value = values[1]
    GeoParquet.DataFrames.metadata!(df, "geo", value; style=:note)

    meta = GeoParquet.JSON.parse(value, GeoParquet.MetaRoot; style=GeoParquet.GeoParquetStyle())

    for (columnname, column) in pairs(meta.columns)
        if column.encoding == "WKB"
            df[!, columnname] = GeoParquet._wkb.(df[!, columnname])
        else
            @warn "Unsupported geometry encoding: $(column.encoding) for column $columnname, returning raw data"
        end
    end
    GeoParquet.set_geointerface_metadata!(df, meta)
end

# Without `geo` metadata, the geometry columns and crs come from Parquet's GEOMETRY and GEOGRAPHY types
function read_parquet_types!(df, fn, db, file)
    columns = Symbol[]
    crs = nothing
    for row in QuackIO.DBInterface.execute(db, "select name, logical_type from parquet_schema($file)")
        m = match(r"^Geo(?:metry|graphy)Type\(crs=(.*?)(?:, algorithm=[^,()]*)?\)$"s, coalesce(row.logical_type, ""))
        isnothing(m) && continue
        df[!, row.name] = GeoParquet._wkb.(df[!, row.name])
        isempty(columns) && (crs = parse_crs(String(m[1]), db, file))
        push!(columns, Symbol(row.name))
    end
    if isempty(columns)
        @warn "GeoParquet metadata not found in $fn, returning DataFrame without geometry parsing"
        return df
    end
    GeoParquet.set_geointerface_metadata!(df, Tuple(columns), crs)
end

# The crs of a Parquet GEOMETRY or GEOGRAPHY type, as shown by DuckDB's parquet_schema
function parse_crs(crs, db, file)
    crs == "<null>" && return GeoParquet.GFT.ProjJSON(GeoParquet.projjson)  # no crs means OGC:CRS84
    crs == "srid:0" && return nothing  # unknown
    if startswith(crs, "projjson:")  # PROJJSON stored under this key in the file's metadata
        key = QuackIO.kwarg_val_to_db_incomma(chopprefix(crs, "projjson:"))
        values = GeoParquet.Tables.columns(QuackIO.DBInterface.execute(db, "select value from parquet_kv_metadata($file) where key = $key")).value
        isempty(values) || (crs = String(copy(values[1])))
    end
    startswith(crs, "{") && return GeoParquet.GFT.ProjJSON(Dict{String,Any}(GeoParquet.JSON.parse(crs)))
    crs == "OGC:CRS84" && return GeoParquet.GFT.ProjJSON(GeoParquet.projjson)
    m = match(r"^(?:EPSG|srid):(\d+)$", crs)
    isnothing(m) || return GeoParquet.GFT.EPSG(parse(Int, m[1]))
    occursin(r"^[A-Z]+\[", crs) && return GeoParquet.GFT.WellKnownText2(GeoParquet.GFT.CRS(), crs)
    @warn "Unsupported crs $crs, returning no crs"
    return nothing
end

using PrecompileTools: @compile_workload
@compile_workload begin
    mktempdir() do dir
        fn = joinpath(dir, "precompile.parquet")
        df = GeoParquet.DataFrame(int=1:2, float=[1.0, 2.0], string=["a", "b"], geometry=[GeoParquet.GI.Point(1.0, 2.0), GeoParquet.GI.Point(3.0, 4.0)])
        GeoParquet.write(fn, df)
        GeoParquet.read(GeoParquet.QuackIODriver(), fn)
    end
end

end
