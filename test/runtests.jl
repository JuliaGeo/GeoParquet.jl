using GeoParquet
using Parquet2
using Downloads
using Test

@testset "GeoParquet.jl" begin
    # Write your tests here.

    url = "https://github.com/opengeospatial/geoparquet/raw/v0.2.0/examples/example.parquet"
    fn = Downloads.download(url)
    ds = Parquet2.Dataset(fn)

end
