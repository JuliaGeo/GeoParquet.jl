using Parquet2
using GeoParquet
using DataFrames
using Downloads
using Test
using ArchGDAL
using JSON3
import GeoFormatTypes as GFT

for url in (
    "https://github.com/opengeospatial/geoparquet/raw/v0.4.0/examples/example.parquet",
    "https://storage.googleapis.com/open-geodata/linz-examples/nz-buildings-outlines.parquet"
)
    fn = joinpath("data", basename(url))
    isfile(fn) || @info "Downloading " * Downloads.download(url, fn)
end

@testset "GeoParquet.jl" begin
    # Write your tests here.

    @testset "Reading" begin
        fn = "data/example.parquet"
        ds = Parquet2.Dataset(fn)
        meta = GeoParquet.geometadata(ds)
        @test meta.version == "0.4.0"
        @test meta.columns["geometry"].bbox[end] ≈ 83.6451

        ds = Parquet2.Dataset("data/nz-buildings-outlines.parquet")
        # this file is still at 0.1.0, using "schema_version", breaking our code
        # @info Parquet2.metadata(ds)["geo"]
        # meta = GeoParquet.geometadata(ds)
        # @info meta
        # @test meta.version == "0.3.0"
        # @test meta.columns["geometry"].bbox[end] ≈ 6190596.9

        df = GeoParquet.read(fn)
        @test nrow(df) === 5
        @test df.geometry[1] isa GFT.WellKnownBinary

        @test_throws Exception GeoParquet.read(fn, columns=(:geom,))
    end

    @testset "Writing" begin
        geom = ArchGDAL.createpoint.([[1, 2], [1, 2]])
        wkb = ArchGDAL.toWKB.(geom)
        df = DataFrame(test="test", value=rand(2), geometry=wkb)
        fn = "data/write.parquet"
        GeoParquet.write(fn, df, (:geometry,))
        df = GeoParquet.read(fn)
        df.test[1] == "test"

        fn = "data/example.parquet"
        df = GeoParquet.read(fn)
        GeoParquet.write("data/example_copy.parquet", df, (:geometry,))
    end
end
