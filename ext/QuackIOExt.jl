module QuackIOExt
using QuackIO
using GeoParquet

function GeoParquet.read(::GeoParquet.QuackIODriver, fn::AbstractString; kwargs...)
    df = QuackIO.read_parquet(GeoParquet.DataFrame, fn; kwargs...)

    qstr = """select * from parquet_kv_metadata($(QuackIO.kwarg_val_to_db_incomma(fn))) where key = 'geo'"""
    result = QuackIO.DBInterface.execute(QuackIO.DuckDB.DB(), qstr)
    values = GeoParquet.Tables.columns(result).value
    if length(values) != 1
        @warn "GeoParquet metadata not found in $fn, returning DataFrame without geometry parsing"
        return df
    end
    value = values[1]
    GeoParquet.DataFrames.metadata!(df, "geo", value; style=:note)

    meta = GeoParquet.JSON.parse(value, GeoParquet.MetaRoot; style=GeoParquet.GeoParquetStyle())

    for (columnname, column) in pairs(meta.columns)
        if column.encoding == "WKB"
            df[!, columnname] = GeoParquet.GFT.WellKnownBinary.(Ref(GeoParquet.GFT.Geom()), df[!, columnname])
        else
            @warn "Unsupported geometry encoding: $(column.encoding) for column $columnname, returning raw data"
        end
    end
    df
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
