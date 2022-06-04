module GeoParquet

using Parquet2
using StructTypes
import GeoFormatTypes as GFT
import GeoInterface as GI
import StructTypes
import JSON3
using DataFrames
using Extents
using WellKnownGeometry

include("meta.jl")
include("utils.jl")
include("io.jl")
include("geointerface.jl")

end
