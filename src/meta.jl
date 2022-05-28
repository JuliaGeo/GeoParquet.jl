const projjson = Dict{String,Any}(
    "\$schema" => "https=>//proj.org/schemas/v0.4/projjson.schema.json",
    "type" => "GeographicCRS",
    "name" => "WGS 84 longitude-latitude",
    "datum" => Dict(
        "type" => "GeodeticReferenceFrame",
        "name" => "World Geodetic System 1984",
        "ellipsoid" => Dict(
            "name" => "WGS 84",
            "semi_major_axis" => 6378137,
            "inverse_flattening" => 298.257223563
        )
    ),
    "coordinate_system" => Dict(
        "subtype" => "ellipsoidal",
        "axis" => [Dict(
                "name" => "Geodetic longitude",
                "abbreviation" => "Lon",
                "direction" => "east",
                "unit" => "degree"
            ),
            Dict(
                "name" => "Geodetic latitude",
                "abbreviation" => "Lat",
                "direction" => "north",
                "unit" => "degree"
            )
        ]
    ),
    "id" => Dict(
        "authority" => "OGC",
        "code" => "CRS84"
    )
)

Base.@kwdef mutable struct MetaColumn
    encoding::String = "WKB"
    geometry_type::Union{String,Vector{String}} = ["Point"]
    crs::Union{Nothing,GeoFormatTypes.WellKnownText2{GeoFormatTypes.CRS}} = GeoFormatTypes.WellKnownText2(GeoFormatTypes.CRS(), """GEOGCRS["WGS 84 (CRS84)",ENSEMBLE["World Geodetic System 1984 ensemble",MEMBER["World Geodetic System 1984 (Transit)"],MEMBER["World Geodetic System 1984 (G730)"],MEMBER["World Geodetic System 1984 (G873)"],MEMBER["World Geodetic System 1984 (G1150)"],MEMBER["World Geodetic System 1984 (G1674)"],MEMBER["World Geodetic System 1984 (G1762)"],MEMBER["World Geodetic System 1984 (G2139)"],ELLIPSOID["WGS 84",6378137,298.257223563],ENSEMBLEACCURACY[2.0]],CS[ellipsoidal,2],AXIS["geodetic longitude (Lon)",east],AXIS["geodetic latitude (Lat)",north],UNIT["degree",0.0174532925199433],USAGE[SCOPE["Not known."],AREA["World."],BBOX[-90,-180,90,180]],ID["OGC","CRS84"]]""")
    edges::Union{Nothing,String} = "planar"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
    epoch::Union{Nothing,Float64} = nothing
    orientation::Union{Nothing,String} = nothing
end

Base.@kwdef mutable struct MetaRoot
    version::String = "0.3.0"
    primary_column::String = "geometry"
    columns::Dict{String,MetaColumn} = Dict("geometry" => MetaColumn())
end

StructTypes.StructType(::Type{MetaColumn}) = StructTypes.Struct()
StructTypes.StructType(::Type{MetaRoot}) = StructTypes.Struct()
StructTypes.StructType(::Type{GeoFormatTypes.WellKnownText2{GeoFormatTypes.CRS}}) = StructTypes.StringType()

GeoFormatTypes.WellKnownText2{GeoFormatTypes.CRS}(s) = GeoFormatTypes.WellKnownText2{GeoFormatTypes.CRS}(GeoFormatTypes.CRS(), s)
