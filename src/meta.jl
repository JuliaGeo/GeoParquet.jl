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

# For compatibility with old files
MetaRoot{T}(version::Nothing, primary_column, columns) where T<:MetaColumn = MetaRoot(; version=versionstring(T), primary_column, columns)
versionstring(::Type{MetaColumnv0_1}) = "0.1.0"
versionstring(::Type{MetaColumnv0_2}) = "0.2.0"
versionstring(::Type{MetaColumnv0_3}) = "0.3.0"
versionstring(::Type{MetaColumnv0_4}) = "0.4.0"
versionstring(::Type{MetaColumnv1_0}) = "1.0.0"
versionstring(::Type{MetaColumnv1_1}) = "1.1.0"

struct Wrapper{NT}
    nt::NT
end
Wrapper() = Wrapper((var"1.1.0"=MetaRoot{MetaColumnv1_1}, var"1.0.0"=MetaRoot{MetaColumnv1_0}, var"0.4.0"=MetaRoot{MetaColumnv0_4}, var"0.3.0"=MetaRoot{MetaColumnv0_3}, var"0.2.0"=MetaRoot{MetaColumnv0_2}, var"0.1.0"=MetaRoot{MetaColumnv0_1}))

# Default to latest version
function Base.getindex(w::Wrapper, key::Symbol)
    haskey(w.nt, key) && return w.nt[key]
    stringkey = string(key)
    # Handle cases like `1.0.0-beta.1`
    if length(stringkey) > 5
        stripkey = Symbol(stringkey[1:5])
        haskey(w.nt, stripkey) && return w.nt[stripkey]
    end
    MetaRoot{MetaColumnv1_0}
end
Base.length(w::Wrapper) = length(w.nt)

# Some old files use "schema_version" instead of "version"
struct VersionWrapper end
function Base.:(==)(x, ::VersionWrapper)
    x == :version || x == :schema_version
end

StructTypes.StructType(::Type{MetaRoot}) = StructTypes.AbstractType()
StructTypes.StructType(::Type{MetaRoot{T}}) where T<:MetaColumn = StructTypes.Struct()
StructTypes.subtypekey(::Type{MetaRoot}) = VersionWrapper()
StructTypes.subtypes(::Type{MetaRoot}) = Wrapper()
StructTypes.StructType(::Type{MetaColumnv0_1}) = StructTypes.Struct()
StructTypes.StructType(::Type{MetaColumnv0_2}) = StructTypes.Struct()
StructTypes.StructType(::Type{MetaColumnv0_3}) = StructTypes.Struct()
StructTypes.StructType(::Type{MetaColumnv0_4}) = StructTypes.Struct()
StructTypes.StructType(::Type{MetaColumnv1_0}) = StructTypes.Struct()
StructTypes.StructType(::Type{MetaColumnv1_1}) = StructTypes.Struct()
StructTypes.StructType(::Type{GFT.WellKnownText2{GFT.CRS}}) = StructTypes.StringType()
StructTypes.StructType(::Type{GFT.ProjJSON}) = StructTypes.DictType()
StructTypes.construct(::Type{GFT.ProjJSON}, x::Dict; kw...) = GFT.ProjJSON(x)
StructTypes.construct(::Type{GFT.WellKnownText2{GFT.CRS}}, x::String; kw...) = GFT.WellKnownText2{GFT.CRS}(GFT.CRS(), x)
StructTypes.omitempties(::Type{<:MetaColumn}) = true

Base.pairs(p::GFT.ProjJSON) = pairs(p.val)
GFT.ProjJSON(input::Dict{Symbol,<:Any}) = GFT.ProjJSON(todict(input))

Parquet2.parqtype(::Type{GFT.WellKnownBinary{GFT.Geom,Vector{UInt8}}}) = Parquet2.ParqByteArray()
Parquet2.parqtype(::Type{GFT.WellKnownBinary{GFT.Geom,Base.CodeUnits{UInt8,String}}}) = Parquet2.ParqByteArray()

Base.length(A::GFT.WellKnownBinary) = Base.length(A.val)
Base.write(io::IOBuffer, A::GFT.WellKnownBinary{GFT.Geom,Vector{UInt8}}) = Base.write(io, A.val)
Base.write(io::IOBuffer, A::GFT.WellKnownBinary{GFT.Geom,Base.CodeUnits{UInt8,String}}) = Base.write(io, A.val)
