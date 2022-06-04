GI.isgeometry(geom::GFT.WellKnownBinary{GFT.Geom,Vector{UInt8}})::Bool = true

const geowkb = Dict{DataType,String}(
    GI.PointTrait => "Point",
    GI.LineStringTrait => "LineString",
    GI.PolygonTrait => "Polygon",
    GI.MultiPointTrait => "MultiPoint",
    GI.MultiLineStringTrait => "MultiLineString",
    GI.MultiPolygonTrait => "MultiPolygon",
    GI.GeometryCollectionTrait => "GeometryCollection",
)
