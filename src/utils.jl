function is_valid(ds::Parquet2.Dataset)
    "geo" in keys(Parquet2.metadata(ds))
end

function geometadata(ds::Parquet2.Dataset)
    json = Parquet2.metadata(ds)["geo"]
    JSON3.read(json, MetaRoot)
end

"""Adapted from `copy` in JSON3, but with String keys instead of Symbols."""
function todict(obj::JSON3.Object)
    dict = Dict{String,Any}()
    for (k, v) in obj
        dict[String(k)] = v isa JSON3.Object || v isa Array ? todict(v) : v
    end
    return dict
end

function todict(obj::Dict{Symbol,Any})
    dict = Dict{String,Any}()
    for (k, v) in obj
        dict[String(k)] = v
    end
    return dict
end

_getwkb(x) = WellKnownGeometry.getwkb(x)
_getwkb(x::GFT.WellKnownBinary) = x
_getwkb(x::Vector{UInt8}) = GFT.WellKnownBinary(GFT.Geom(), x)
