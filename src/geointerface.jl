const geowkb = Dict{DataType,String}(
    GI.PointTrait => "Point",
    GI.LineStringTrait => "LineString",
    GI.PolygonTrait => "Polygon",
    GI.MultiPointTrait => "MultiPoint",
    GI.MultiLineStringTrait => "MultiLineString",
    GI.MultiPolygonTrait => "MultiPolygon",
    GI.GeometryCollectionTrait => "GeometryCollection",
)
