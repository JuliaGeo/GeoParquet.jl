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
using PrecompileTools: @setup_workload, @compile_workload
using Dates: Date, DateTime

include("meta.jl")
include("utils.jl")
include("io.jl")
include("geointerface.jl")
include("precompile.jl")

end
