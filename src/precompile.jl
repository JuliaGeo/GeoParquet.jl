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
    df = DataFrame(int=1:n, float=rand(n), string=string.(1:n), geometry=geometries)
    @compile_workload begin
        mktempdir() do dir
            fn = joinpath(dir, "precompile.parquet")
            write(fn, df)
            read(fn)
        end
    end
end
