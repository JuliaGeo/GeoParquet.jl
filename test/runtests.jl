using Parquet2
using GeoParquet
using DataFrames
using Downloads
using Test
using ArchGDAL
using JSON3
import GeoFormatTypes as GFT

for url in (
    "https://github.com/opengeospatial/geoparquet/raw/v1.0.0/examples/example.parquet",
    "https://storage.googleapis.com/open-geodata/linz-examples/nz-buildings-outlines.parquet"
)
    fn = joinpath("data", basename(url))
    isfile(fn) || @info "Downloading " * Downloads.download(url, fn)
end

@testset "GeoParquet.jl" begin

    @testset "Reading" begin
        fn = "data/example.parquet"
        ds = Parquet2.Dataset(fn)
        meta = GeoParquet.geometadata(ds)
        @test meta.version == "1.0.0"
        @test meta.version == "1.0.0"
        @test meta.columns["geometry"].bbox[end] ≈ 83.6451
        @test meta.columns["geometry"].geometry_types == ["Polygon", "MultiPolygon"]

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
    @testset "Reading QuackIO" begin
        using QuackIO
        fn = "data/example.parquet"
        ds = Parquet2.Dataset(fn)
        meta = GeoParquet.geometadata(ds)
        @test meta.version == "1.0.0"
        @test meta.version == "1.0.0"
        @test meta.columns["geometry"].bbox[end] ≈ 83.6451
        @test meta.columns["geometry"].geometry_types == ["Polygon", "MultiPolygon"]

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

        # Transparently convert columns to WKB
        fn = "data/writec.parquet"
        df = DataFrame(test="test", value=rand(2), geom=geom)
        GeoParquet.write(fn, df)
        ndf = GeoParquet.read(fn)
        df.geom != ndf.geom  # original is not mutated

        fn = "data/example.parquet"
        df = GeoParquet.read(fn)
        GeoParquet.write("data/example_copy.parquet", df, (:geometry,))

        fn = "data/example.parquet"
        df = GeoParquet.read(fn)
        GeoParquet.write("data/example_copy.parquet", df, (:geometry,), compression_codec=:snappy, npages=2)
    end

    @testset "Parquet2 FilePath" begin
        df = DataFrame(a=UInt16.(1:10), b=Int8.(1:10))
        Parquet2.writefile("data/test.parquet", df)
        mv("data/test.parquet", "data/test2.parquet", force=true)
        ds = Parquet2.Dataset("data/test2.parquet")
        df = DataFrame(ds)
        close(ds)
        @test df.a[1] == 1
        @test df.b[end] == 10
        @test df.a[1] isa UInt16
        @test df.b[end] isa Int8
    end
end
