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
    crs::Union{Nothing,GFT.ProjJSON} = GFT.ProjJSON(projjson)
    edges::Union{Nothing,String} = "planar"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
    epoch::Union{Nothing,Float64} = nothing
    orientation::Union{Nothing,String} = nothing
end

Base.@kwdef mutable struct MetaRoot
    version::String = "0.4.0"
    primary_column::String = "geometry"
    columns::Dict{String,MetaColumn} = Dict("geometry" => MetaColumn())
end

StructTypes.StructType(::Type{MetaColumn}) = StructTypes.Struct()
StructTypes.StructType(::Type{MetaRoot}) = StructTypes.Struct()
StructTypes.StructType(::Type{GFT.WellKnownText2{GFT.CRS}}) = StructTypes.StringType()
StructTypes.StructType(::Type{GFT.ProjJSON}) = StructTypes.DictType()
StructTypes.construct(::Type{GFT.ProjJSON}, x::Dict; kw...) = GFT.ProjJSON(x)

# Base.keys(p::GFT.ProjJSON) = keys(p.val)
# Base.values(p::GFT.ProjJSON) = values(p.val)
Base.pairs(p::GFT.ProjJSON) = pairs(p.val)
GFT.ProjJSON(input::Dict{Symbol,<:Any}) = GFT.ProjJSON(todict(input))

Parquet2.default_determine_type(::Vector{GFT.WellKnownBinary{GFT.Geom,Vector{UInt8}}}) = Parquet2.ParqByteArray()
Base.length(A::GFT.WellKnownBinary) = Base.length(A.val)
Base.write(io::IOBuffer, A::GFT.WellKnownBinary{GFT.Geom,Vector{UInt8}}) = Base.write(io, A.val)
