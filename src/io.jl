"""
    write(ofn, t, columns=(:geom), crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing; kwargs...)

Write a dataframe with a geometry column to a Parquet file. Keyword arguments are passed to Parquet2 writefile method.
The geometry column should be a `Vector{GeoFormat.WellKnownBinary}`.
You can construct one with WellKnownGeometry for geometries that support GeoInterface.
"""
function write(ofn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath}, df, geocolumns=(:geom,), crs::Union{GFT.ProjJSON,Nothing}=nothing, bbox::Union{Nothing,Vector{Float64}}=nothing; kwargs...)

    columns = Dict{String,Any}()
    tcols = Tables.columns(df)

    for column in geocolumns
        column in Tables.columnnames(df) || error("Geometry column $column not found in table")
        data = Tables.getcolumn(tcols, column)
        GI.isgeometry(data[1]) || error("Geometry in $column must support the GeoInterface")
        types = unique(typeof.(GI.geomtrait.(data)))
        gtypes = getindex.(Ref(geowkb), types)
        mc = MetaColumn(geometry_type=gtypes, bbox=bbox, crs=crs)
        columns[String(column)] = mc
    end

    md = Dict("geo" => JSON3.write(GeoParquet.MetaRoot(columns=columns, primary_column=String(geocolumns[1]))))
    Parquet2.writefile(ofn, df, metadata=md, compression_codec=:zstd, kwargs...)
    ofn
end


"""
    read(fn; kwargs...)

Read a GeoParquet file. Kwargs are passed to the Parquet2.Dataset constructor.
"""
function read(fn::Union{AbstractString,Parquet2.FilePathsBase.AbstractPath,Parquet2.FileManager}; kwargs...)
    ds = Parquet2.Dataset(fn, kwargs...)
    is_valid(ds) || error("Not a valid GeoParquet file")
    meta = geometadata(ds)
    df = DataFrame(ds; copycols=false)
    for column in keys(meta.columns)
        df[!, column] = GFT.WellKnownBinary.(Ref(GFT.Geom()), df[!, column])
    end
    df
end
