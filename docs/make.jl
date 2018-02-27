
using Documenter, Juno, AsyPlots

makedocs(
    modules = [AsyPlots],
    format = :html,
    sitename = "AsyPlots.jl",
    doctest = false,
    strict = false,
    pages = Any[
        "Home" => "index.md",
        "Manual" => [
            "man/overview.md",
            "man/asy2d.md",
            "man/asy3d.md",
            "man/pens.md",
            "man/defaults.md",
            "man/settings.md",
            "man/animate.md",
            "man/graphing.md"
            ],
        "Examples" => [
            "examples/examples2d.md",
            "examples/examples3d.md"
        ]
    ]
)
