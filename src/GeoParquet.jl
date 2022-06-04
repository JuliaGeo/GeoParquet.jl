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

# precompile(Parquet2.Dataset, (String,))
# precompile(Parquet2.Dataset, (Parquet2.FilePathsBase.PosixPath,))
# precompile(Parquet2.FileManager, (Parquet2.FilePathsBase.PosixPath, Parquet2.VectorFetcher))
# precompile(Parquet2.Dataset, (Parquet2.FileManager{Parquet2.FilePathsBase.PosixPath,Parquet2.VectorFetcher},))
# precompile(DataFrame, (Parquet2.FileManager{Parquet2.FilePathsBase.PosixPath,Parquet2.VectorFetcher},))

# function __init__()
# Parquet2.Dataset(jinpath(@__DIR__, "../test/data/example.parquet"))
# end

end
