
using Documenter, Juno, AsyPlots

makedocs(
    modules = [AsyPlots],
    format = Documenter.HTML(),
    sitename = "AsyPlots.jl",
    doctest = false,
    strict = false,
    checkdocs = :none,
    pages = Any[
        "Home" => "index.md",
        "Manual" => [
            "man/overview.md",
            "man/asy2d.md",
            "man/asy3d.md",
            "man/pens.md",
	    "man/heatmaps.md",
	    "man/isolines.md",
            "man/graphing.md",
            "man/output.md",
            "man/settings.md",
            "man/defaults.md",
            "man/animate.md"
            ],
        "Examples" => [
            "examples/examples2d.md",
            "examples/examples3d.md"
        ]
    ]
)

deploydocs(
    repo="github.com/sswatson/AsyPlots.jl.git",
    target="build",
    deps=nothing,
    make=nothing
)
