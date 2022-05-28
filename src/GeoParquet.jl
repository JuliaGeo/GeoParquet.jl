module GeoParquet

using Parquet2
using StructTypes
using GeoFormatTypes
using GeoInterface
import StructTypes
import JSON3

include("meta.jl")
include("utils.jl")

# precompile(Parquet2.Dataset, (String,))
# precompile(Parquet2.Dataset, (Parquet2.FilePathsBase.PosixPath,))
# precompile(Parquet2.FileManager, (Parquet2.FilePathsBase.PosixPath, Parquet2.VectorFetcher))
# precompile(Parquet2.Dataset, (Parquet2.FileManager{Parquet2.FilePathsBase.PosixPath,Parquet2.VectorFetcher},))
# precompile(DataFrame, (Parquet2.FileManager{Parquet2.FilePathsBase.PosixPath,Parquet2.VectorFetcher},))

# function __init__()
# Parquet2.Dataset(jinpath(@__DIR__, "../test/data/example.parquet"))
# end

end
