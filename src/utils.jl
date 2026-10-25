function is_valid(ds::Parquet2.Dataset)
    "geo" in keys(Parquet2.metadata(ds))
end

function geometadata(ds::Parquet2.Dataset)
    json = Parquet2.metadata(ds)["geo"]
    JSON.parse(json, MetaRoot; style=GeoParquetStyle())
end

_wkb(x) = GFT.WellKnownBinary(GFT.Geom(), x)
_wkb(::Missing) = missing

_getwkb(x) = WellKnownGeometry.getwkb(x)
_getwkb(x::GFT.WellKnownBinary) = x
_getwkb(x::Vector{UInt8}) = GFT.WellKnownBinary(GFT.Geom(), x)
