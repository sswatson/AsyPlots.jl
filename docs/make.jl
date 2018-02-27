
using Documenter, Juno, AsyPlots

makedocs(
    modules = [AsyPlots],
    format = :html,
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
    julia="0.6",
    deps=nothing,
    make=nothing
)
