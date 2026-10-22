@setup_workload begin
    ring = [(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 0.0)]
    geometries = [
        GI.Point(1.0, 2.0),
        GI.LineString([(0.0, 0.0), (1.0, 1.0)]),
        GI.Polygon([ring]),
        GI.MultiPoint([(0.0, 0.0), (1.0, 1.0)]),
        GI.MultiLineString([[(0.0, 0.0), (1.0, 1.0)]]),
        GI.MultiPolygon([[ring]]),
    ]
    n = length(geometries)
    df = DataFrame(
        int=1:n, int32=Int32.(1:n), float=rand(n), float32=rand(Float32, n), bool=isodd.(1:n),
        string=string.(1:n), missings=[missing; 2:n], missingstrings=[missing; string.(2:n)],
        date=fill(Date(2020), n), datetime=fill(DateTime(2020), n),
        geometry=geometries,
    )
    @compile_workload begin
        mktempdir() do dir
            fn = joinpath(dir, "precompile.parquet")
            write(fn, df)
            rdf = read(fn)
            write(joinpath(dir, "precompile_wkb.parquet"), rdf)
        end
    end
end
