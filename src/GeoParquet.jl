module GeoParquet

using Parquet2
import GeoFormatTypes as GFT
import GeoInterface as GI
import JSON
import JSON: StructUtils
using DataFrames
using Extents
using WellKnownGeometry
using DataAPI

include("meta.jl")
include("utils.jl")
include("io.jl")
include("geointerface.jl")

end
