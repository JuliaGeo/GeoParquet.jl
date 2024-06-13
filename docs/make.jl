using GeoParquet
using Documenter

DocMeta.setdocmeta!(GeoParquet, :DocTestSetup, :(using GeoParquet); recursive=true)

makedocs(;
    modules=[GeoParquet],
    authors="Maarten Pronk <git@evetion.nl> and contributors",
    repo="https://github.com/JuliaGeo/GeoParquet.jl/blob/{commit}{path}#{line}",
    sitename="GeoParquet.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://juliageo.github.io/GeoParquet.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaGeo/GeoParquet.jl",
    devbranch="main",
    push_preview = true,
)
