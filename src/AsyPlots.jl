__precompile__(true)

module AsyPlots

import ColorTypes,
       Colors,
       Requires,
       Cairo,
       ProgressMeter

import DataStructures: OrderedDict

import Base: show, print, string, convert, complex, abs,
             start, next, done,
             +, *, -, ==

export Point, Point2D, Point3D,
       Path, Path2D, Path3D,
       Circle2D, Circle,
       Polygon2D, Polygon3D, Polygon, box, 
       Label2D, Label3D, Label,
       RawString,
       Surface,
       Plot, Plot2D, Plot3D,
       GraphicElement, GraphicElement2D, GraphicElement3D,
       NamedColor, Pen, NoPen, Arrow, Arrow3, NoArrow,
       Shift, Shift2D, Scale, Scale2D,
       defaultcolor, isdefault,
       isinside, iswellinside,
       asy, cairo,
       plot,
       interactive,
       save,
       junosvg, junopng,
       fitwidth, fitheight,
       animate,
       piechart

abstract type Plot end
abstract type GraphicElement end
abstract type GraphicString end

struct AsyString
    str::String
    data::Dict
end

_BACKEND = "asy"
_DEFAULT_WIDTH = 512

function defaultwidth(n::Integer)
    global _DEFAULT_WIDTH
    _DEFAULT_WIDTH = n
    "Default image width set to $n"
end

"""
    asy()

Set the backend to Asymptote
"""
function asy()
    global _BACKEND
    _BACKEND = "asy"
    "Backend set to Asymptote"
end

"""
    cairo()

Set the backend to Cairo
"""
function cairo()
    global _BACKEND
    _BACKEND = "cairo"
    "Backend set to Cairo"
end

_HAVE_ASY = try success(`asy -version`); catch; false; end

if ~_HAVE_ASY
    println("asy not found, using Cairo backend")
    cairo()
end

AsyString(s::AbstractString) = AsyString(s,Dict())

RealOrComplex = Union{Real,Complex}

include("util.jl")
include("pens_and_arrows.jl")
include("asy2d.jl")
include("asy3d.jl")
include("cairo.jl")
include("output.jl")
include("transformations.jl")
include("tools.jl")
include("animate.jl")
include("stats.jl") 

end # module
