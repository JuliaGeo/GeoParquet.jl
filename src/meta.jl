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

const wkt2 = GFT.WellKnownText2{GFT.CRS}(GFT.CRS(), """GEOGCRS["WGS 84",ENSEMBLE["World Geodetic System 1984 ensemble",MEMBER["World Geodetic System 1984 (Transit)"],MEMBER["World Geodetic System 1984 (G730)"],MEMBER["World Geodetic System 1984 (G873)"],MEMBER["World Geodetic System 1984 (G1150)"],MEMBER["World Geodetic System 1984 (G1674)"],MEMBER["World Geodetic System 1984 (G1762)"],MEMBER["World Geodetic System 1984 (G2139)"],ELLIPSOID["WGS 84",6378137,298.257223563],ENSEMBLEACCURACY[2.0]],CS[ellipsoidal,2],AXIS["geodetic latitude (Lat)",north],AXIS["geodetic longitude (Lon)",east],UNIT["degree",0.0174532925199433],USAGE[SCOPE["Horizontal component of 3D system."],AREA["World."],BBOX[-90,-180,90,180]],ID["EPSG",4326]]""")

abstract type MetaColumn end

Base.@kwdef struct MetaColumnv1_1 <: MetaColumn
    encoding::String = "WKB"  # required, can be WKB|point|linestring|polygon|multipoint|multilinestring|multipolygon
    geometry_types::Vector{String} = ["Point"]  # required, can be (GeometryCollection|(Multi)?(Point|LineString|Polygon))( Z)?
    crs::Union{Nothing,GFT.ProjJSON} = GFT.ProjJSON(projjson)
    orientation::Union{Nothing,String} = "counterclockwise"
    edges::Union{Nothing,String} = "planar"  # or "spherical"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
    epoch::Union{Nothing,Float64} = nothing
end

Base.@kwdef struct MetaColumnv1_0 <: MetaColumn
    encoding::String = "WKB"  # required, can be WKB|point|linestring|polygon|multipoint|multilinestring|multipolygon
    geometry_types::Vector{String} = ["Point"]  # required, can be (GeometryCollection|(Multi)?(Point|LineString|Polygon))( Z)?
    crs::Union{Nothing,GFT.ProjJSON} = GFT.ProjJSON(projjson)
    orientation::Union{Nothing,String} = "counterclockwise"
    edges::Union{Nothing,String} = "planar"  # or "spherical"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
    epoch::Union{Nothing,Float64} = nothing
end

Base.@kwdef struct MetaColumnv0_4 <: MetaColumn
    encoding::String = "WKB"  # required
    geometry_type::Union{String,Vector{String}} = ["Point"]
    crs::Union{Nothing,GFT.ProjJSON} = GFT.ProjJSON(projjson)
    orientation::Union{Nothing,String} = "counterclockwise"
    edges::Union{Nothing,String} = "planar"  # or "spherical"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
    epoch::Union{Nothing,Float64} = nothing
end

Base.@kwdef struct MetaColumnv0_3 <: MetaColumn
    encoding::String = "WKB"  # required
    geometry_type::Union{String,Vector{String}} = ["Point"]
    crs::Union{Nothing,GFT.WellKnownText2{GFT.CRS}} = wkt2
    orientation::Union{Nothing,String} = "counterclockwise"
    edges::Union{Nothing,String} = "planar"  # or "spherical"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
    epoch::Union{Nothing,Float64} = nothing
end

Base.@kwdef struct MetaColumnv0_2 <: MetaColumn
    encoding::String = "WKB"  # required
    geometry_type::Union{String,Vector{String}} = ["Point"]
    crs::Union{Nothing,GFT.WellKnownText2{GFT.CRS}} = wkt2
    orientation::Union{Nothing,String} = "counterclockwise"
    edges::Union{Nothing,String} = "planar"  # or "spherical"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
    epoch::Union{Nothing,Float64} = nothing
end

Base.@kwdef struct MetaColumnv0_1 <: MetaColumn
    encoding::String = "WKB"  # required
    crs::Union{Nothing,GFT.WellKnownText2{GFT.CRS}} = wkt2
    edges::Union{Nothing,String} = "planar"  # or "spherical"
    bbox::Union{Nothing,Vector{Float64}} = [-180.0, -90.0, 180.0, 90.0]  # minx, miny, maxx, maxy
end

Base.@kwdef struct MetaRoot{T<:MetaColumn}
    version::String = "1.1.0"
    primary_column::String = "geometry"
    columns::Dict{String,T} = Dict("geometry" => T())
end

# For compatibility with old files, which use "schema_version" instead of "version"
StructUtils.fielddefaults(::StructUtils.StructStyle, ::Type{MetaRoot{T}}) where T<:MetaColumn = (version=versionstring(T),)
versionstring(::Type{MetaColumnv0_1}) = "0.1.0"
versionstring(::Type{MetaColumnv0_2}) = "0.2.0"
versionstring(::Type{MetaColumnv0_3}) = "0.3.0"
versionstring(::Type{MetaColumnv0_4}) = "0.4.0"
versionstring(::Type{MetaColumnv1_0}) = "1.0.0"
versionstring(::Type{MetaColumnv1_1}) = "1.1.0"

const metaroots = Dict(versionstring(T) => MetaRoot{T} for T in (MetaColumnv0_1, MetaColumnv0_2, MetaColumnv0_3, MetaColumnv0_4, MetaColumnv1_0, MetaColumnv1_1))

# Handle cases like `1.0.0-beta.1`, default to 1.0.0
JSON.@choosetype MetaRoot x -> begin
    version = get(x, :version, nothing)
    isnothing(version) && (version = get(x, :schema_version, nothing))
    isnothing(version) && return MetaRoot{MetaColumnv1_0}
    get(metaroots, first(version[], 5), MetaRoot{MetaColumnv1_0})
end

# Style to pass to JSON.parse and JSON.json, so the GeoFormatTypes overloads below don't apply globally
struct GeoParquetStyle <: JSON.JSONStyle end

StructUtils.structlike(::GeoParquetStyle, ::Type{GFT.ProjJSON}) = false
StructUtils.structlike(::GeoParquetStyle, ::Type{GFT.WellKnownText2{GFT.CRS}}) = false
JSON.lift(::GeoParquetStyle, ::Type{GFT.ProjJSON}, x::JSON.Object) = GFT.ProjJSON(Dict{String,Any}(x))
JSON.lift(::GeoParquetStyle, ::Type{GFT.WellKnownText2{GFT.CRS}}, x::AbstractString) = GFT.WellKnownText2{GFT.CRS}(GFT.CRS(), x)
JSON.lower(::GeoParquetStyle, x::GFT.ProjJSON) = x.val isa String ? JSON.JSONText(x.val) : x.val
JSON.lower(::GeoParquetStyle, x::GFT.WellKnownText2{GFT.CRS}) = x.val
JSON.omit_null(::Type{<:MetaColumn}) = true
JSON.omit_empty(::Type{<:MetaColumn}) = true

Parquet2.parqtype(::Type{GFT.WellKnownBinary{GFT.Geom,Vector{UInt8}}}) = Parquet2.ParqByteArray()
Parquet2.parqtype(::Type{GFT.WellKnownBinary{GFT.Geom,Base.CodeUnits{UInt8,String}}}) = Parquet2.ParqByteArray()

Base.length(A::GFT.WellKnownBinary) = Base.length(A.val)
Base.write(io::IOBuffer, A::GFT.WellKnownBinary{GFT.Geom,Vector{UInt8}}) = Base.write(io, A.val)
Base.write(io::IOBuffer, A::GFT.WellKnownBinary{GFT.Geom,Base.CodeUnits{UInt8,String}}) = Base.write(io, A.val)
