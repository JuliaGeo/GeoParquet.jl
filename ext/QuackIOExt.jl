module QuackIOExt
using QuackIO
using GeoParquet

function GeoParquet.read(::GeoParquet.QuackIODriver, fn::AbstractString; kwargs...)
    df = QuackIO.read_parquet(GeoParquet.DataFrame, fn, kwargs...)

    qstr = """select * from parquet_kv_metadata($(QuackIO.kwarg_val_to_db_incomma(fn))) where key = 'geo'"""
    result = QuackIO.DBInterface.execute(QuackIO.DuckDB.DB(), qstr)
    values = GeoParquet.Tables.columns(result).value
    if length(values) != 1
        @warn "GeoParquet metadata not found in $fn, returning DataFrame without geometry parsing"
        return df
    end
    value = values[1]
    GeoParquet.DataFrames.metadata!(df, "geo", value; style=:note)

    meta = GeoParquet.JSON3.read(value, GeoParquet.MetaRoot)

    for column in keys(meta.columns)
        df[!, column] = GeoParquet.GFT.WellKnownBinary.(Ref(GeoParquet.GFT.Geom()), df[!, column])
    end
    df
end

end
