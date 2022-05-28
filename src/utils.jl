function is_valid(ds)
    nothing
end

function geometadata(ds)
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
