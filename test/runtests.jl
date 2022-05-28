using Parquet2
using GeoParquet
using DataFrames
using Downloads
using Test
using ArchGDAL
using JSON3

for url in (
    "https://github.com/opengeospatial/geoparquet/raw/v0.3.0/examples/example.parquet",
    "https://storage.googleapis.com/open-geodata/linz-examples/nz-buildings-outlines.parquet"
)
    fn = joinpath("data", basename(url))
    isfile(fn) || @info "Downloading " * Downloads.download(url, fn)
end

@testset "GeoParquet.jl" begin
    # Write your tests here.

    @testset "Reading" begin
        ds = Parquet2.Dataset("data/example.parquet")
        meta = GeoParquet.geometadata(ds)
        @test meta.version == "0.3.0"
        @test meta.columns["geometry"].bbox[end] ≈ 83.6451
        df = DataFrame(ds; copycols=false)
        ArchGDAL.fromWKB.(df.geometry)
        @test nrow(ds) === 5

        # Write the same data again
        md = Dict("geo" => JSON3.write(GeoParquet.MetaRoot()))
        testfn = "data/example-copy.parquet"
        Parquet2.writefile(testfn, df; metadata=md, compression_codec=:zstd)

        ds = Parquet2.Dataset("data/nz-buildings-outlines.parquet")

        # this file is still at 0.1.0, using "schema_version", breaking our code
        # @info Parquet2.metadata(ds)["geo"]
        # meta = GeoParquet.geometadata(ds)
        # @info meta
        # @test meta.version == "0.3.0"
        # @test meta.columns["geometry"].bbox[end] ≈ 6190596.9

        df = DataFrame(ds; copycols=false)
        ArchGDAL.fromWKB.(df.geometry)
        @test nrow(ds) === 3320498

        # Write the same data again
        md = Dict("geo" => JSON3.write(GeoParquet.MetaRoot()))
        testfn = "data/nz-buildings-outlines-copy.parquet"
        Parquet2.writefile(testfn, df; metadata=md, compression_codec=:zstd)

    end

    @testset "Writing" begin
        geom = ArchGDAL.createpoint.([[1, 2], [1, 2]])
        wkb = ArchGDAL.toWKB.(geom)
        df = DataFrame(test="test", value=rand(2), geometry=wkb)
        mdg = GeoParquet.todict(JSON3.read(JSON3.write(GeoParquet.MetaRoot())))

        testfn = "data/write.parquet"
        md = Dict("geo" => JSON3.write(GeoParquet.MetaRoot()))
        Parquet2.writefile(testfn, df; metadata=md, compression_codec=:zstd)

        @time ds = Parquet2.Dataset(testfn)
        meta = GeoParquet.geometadata(ds)

        @time ndf = DataFrame(ds; copycols=false)
        ngeom = ArchGDAL.fromWKB.(ndf.geometry)
        @test ndf == df
    end
end
