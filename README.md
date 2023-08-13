# GeoParquet

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/GeoParquet.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/GeoParquet.jl/dev)
[![Build Status](https://github.com/JuliaGeo/GeoParquet.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGeo/GeoParquet.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaGeo/GeoParquet.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaGeo/GeoParquet.jl)

Adding *geospatial data* to Parquet. Follows the [GeoParquet](https://github.com/opengeospatial/geoparquet) `v0.4` spec.

## Usage

Reading geoparquet files can be done with `read`.

```julia
julia> import GeoParquet as GP

julia> url = "https://github.com/opengeospatial/geoparquet/raw/v0.4.0/examples/example.parquet"
julia> fn = download(url)
julia> df = GP.read(fn)
5×6 DataFrame
 Row │ pop_est    continent      name                      iso_a3   gdp_md_est    geometry
     │ Int64?     String?        String?                   String?  Float64?      WellKnow…
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │    920938  Oceania        Fiji                      FJI        8374.0      WellKnownBinary{Geom, Vector{UIn…
   2 │  53950935  Africa         Tanzania                  TZA      150600.0      WellKnownBinary{Geom, Vector{UIn…
   3 │    603253  Africa         W. Sahara                 ESH         906.5      WellKnownBinary{Geom, Vector{UIn…
   4 │  35623680  North America  Canada                    CAN           1.674e6  WellKnownBinary{Geom, Vector{UIn…
   5 │ 326625791  North America  United States of America  USA           1.856e7  WellKnownBinary{Geom, Vector{UIn…
```

Writing requires Table like input with geometry columns that are `WellKnownBinary` from GeoFormatTypes.

```julia
julia> GeoParquet.write("test.parquet", df, (:geometry,))
test.parquet
```

## Features not yet implemented
- [ ] Strict schema and version support
- [ ] GeoInterface FeatureCollection implementation
- [ ] Better access to metadata in `read`
- [ ] Lazy read option
- [ ] Easier support for ProjJSON
