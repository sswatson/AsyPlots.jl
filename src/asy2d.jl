
abstract type GraphicElement2D <: GraphicElement end

#--- 2D POINTS -----------------------------------------
#-------------------------------------------------------

struct Vec2{T<:Real}
    x::T
    y::T
end

Vec2(x::Real,y::Real) = Vec2(promote(x,y)...)
Vec2(t::Tuple{<:Real,<:Real}) = Vec2(t...)
Vec2(z::Complex) = Vec2(reim(z)...)
complex(V::Vec2) = V.x + im*V.y
abs(V::Vec2) = hypot(V.x,V.y)

string(v::Vec2) = "($(v.x),$(v.y))"

import Base.convert
convert(::Type{Vector},V::Vec2) = [V.x,V.y]

import LinearAlgebra.×
×(V::Vec2,W::Vec2) = V.x*W.y - W.x*V.y

"""
    Point2D(x::Real,y::Real; label="",pen=Pen())
    Point2D(P; label="",pen=Pen())

A graphics primitive representing a two-dimensional point.

`P` may be a 2-tuple of real numbers, a `Vec2`, or a `Complex`

# Examples
```julia-repl
julia> Point2D(3,-1;pen="DarkGreen")
Point2D(3,-1;pen=DarkGreen)
```
"""
struct Point2D <: GraphicElement2D
    P::Vec2
    label::AbstractString
    pen::Pen
end

"""
    Point(x::Real,y::Real;kwargs...)
    Point(x::Real,y::Real,z::Real;kwargs...)
    Point(P;kwargs...)

Return a Point2D or Point3D object, as appropriate

# Examples
```julia-repl
julia> Point(1,2;pen=Pen(opacity=0.5))
Point2D(1,2;pen=opacity(0.5))
```
"""
function Point end

const _DEFAULT_POINT2D_KWARGS =
    OrderedDict(
        :label => "",
        :pen => Pen()
    )

Point2D(v::Vec2;kwargs...) =
    Point2D(v,updatedvals(_DEFAULT_POINT2D_KWARGS,
                                process_pen_kwargs(kwargs))...)
Point(v::Vec2;kwargs...) = Point2D(v;kwargs...)
Point2D(P::Tuple{<:Real,<:Real};kwargs...) = Point2D(Vec2(P);kwargs...)
Point(P::Tuple{<:Real,<:Real};kwargs...) = Point2D(P;kwargs...)
Point2D(x::Real,y::Real;kwargs...) =
                Point2D(Vec2(x,y);kwargs...)
Point(x::Real,y::Real;kwargs...) = Point2D(x,y;kwargs...)
Point2D(z::Union{Real,Complex};kwargs...) = Point2D(reim(z)...;kwargs...)
Point(z::Union{Real,Complex};kwargs...) = Point2D(z;kwargs...)

function AsyString(P::Point2D)
    label = P.label == "" ? "" : "L=$(enclosequote(P.label)),"
    pen = isdefault(P.pen) ? "" : ",p=$(string(P.pen))"
    AsyString("""
    dot($label$(string(P.P))$pen);
    """)
end

function Base.show(io::IO,P::Point2D)
    kwargs = kwargstring(P,_DEFAULT_POINT2D_KWARGS)
    print(io,"Point2D($(P.P.x),$(P.P.y)$kwargs)")
end

#--- 2D PATHS -----------------------------------------
#------------------------------------------------------

"""
    Path2D(points;label="",pen=Pen(),arrow=NoArrow(),spline=false)
    Path2D(x,y;label="",pen=Pen(),arrow=NoArrow(),spline=false)

A graphics primitive representing a two-dimensional path

`points` may be an Array of `Vec2`s, an Array of 2-tuples,
or an ``n × 2`` Array. Alternatively, iterables of coordinates
may be supplied separately as `x` and `y`

# Examples
```julia-repl
julia> Path2D([(0,0),(1,0),(1,1)];pen="MidnightBlue")
Path2D(<3 points>;pen=MidnightBlue)
```
"""
struct Path2D <: GraphicElement2D
    points::Array{<:Vec2,1}
    label::AbstractString
    pen::Pen
    arrow::Arrow
    spline::Bool
end


"""
    Path(A;kwargs)

Return a Path2D or Path3D object, as appropriate

# Examples
```julia-repl
julia> Path([1 2; 3 4])
Path2D(<2 points>)
```
"""
function Path end

const _DEFAULT_PATH2D_KWARGS =
    OrderedDict(
          :label=>"",
          :pen=>Pen(),
          :arrow=>NoArrow(),
          :spline=>false)

Path2D(points::Array{<:Vec2,1};kwargs...) =
        Path2D(points,updatedvals(_DEFAULT_PATH2D_KWARGS,
                                process_pen_kwargs(kwargs))...)

Path(points::Array{<:Vec2,1};kwargs...) = Path2D(points;kwargs...)

Path2D(points::Array{<:Tuple{<:Real,<:Real},1};kwargs...) =
                                Path2D(map(Vec2,points);kwargs...)

Path(points::Array{<:Tuple{<:Real,<:Real},1};kwargs...) =
                                    Path2D(map(Vec2,points);kwargs...)

Path2D(coords::Array{<:Real,2};kwargs...) =
            Path2D([Vec2(coords[i,:]...) for i=1:size(coords,1)];kwargs...)

Path2D(points::Array{<:RealOrComplex,1};kwargs...) =
                        Path2D(map(Vec2,points);kwargs...)

Path2D(x,y;kwargs...) = Path2D(collect(zip(x,y));kwargs...)

Path(points::Array{<:RealOrComplex,1};kwargs...) =
                                Path2D(map(Vec2,points);kwargs...)

Path(x,y;kwargs...) = Path2D(x,y;kwargs...)

function Path(coords::Array{<:Real,2};kwargs...)
    if size(coords,2) == 2
        Path2D(coords;kwargs...)
    else
        Path3D(coords;kwargs...)
    end
end

function AsyString(path::Path2D)
    label = path.label == "" ? "" : "L=$(enclosequote(path.label))"
    pathname = "p{IDENTIFIER}"
    coords = vcat([[p.x p.y] for p in path.points]...)
    spline = path.spline ? ".." : "--"
    arrow = path.arrow == NoArrow() ? "" : AsyString(path.arrow)
    if length(path.points) > 10
        AsyString("""
        file pathdata = input("path{IDENTIFIER}.csv");
        real[][] A = pathdata.csv().dimension(0,2);
        close(pathdata);
        guide $pathname;
        for(int i=0; i<A.length; ++i){
            $pathname = $pathname $spline (A[i][0],A[i][1]);
        }
        draw($(filterjoin(label,pathname,path.pen,arrow)));
        """,
        Dict("path{IDENTIFIER}.csv"=>coords))
    else
        AsyString("""
        path $pathname = $(join([string(p) for p in path.points],spline));
        draw($(filterjoin(label,pathname,path.pen,arrow)));
        """)
    end
end

function Base.show(io::IO,P::Path2D)
    l = length(P.points)
    s = l ≠ 1 ? "s" : ""
    kwargs = kwargstring(P,_DEFAULT_PATH2D_KWARGS)
    print(io,"""
    Path2D(<$l point$s>$kwargs)""")
end

import Base.map
function Base.map(f::Function,P::Path2D)
    Path(map(f,P.points);label=P.label,
                         pen=P.pen,
                         arrow=P.arrow,
                         spline=P.spline)
end

#--- 2D CIRCLES ---------------------------------------
#------------------------------------------------------

"""
    Circle2D(center,radius; pen::Pen,fillpen::Pen)

A graphics primitive representing a circle in the plane

`center` may be a `Vec2` or a 2-tuple of `Real`s or a
`Complex`

# Examples
```julia-repl
julia> Circle2D((0,0),1;pen="LightBlue",fillpen="red")
Circle2D((0,0),1;pen=LightBlue,fillpen=red)
```
"""
struct Circle2D <: GraphicElement2D
    center::Vec2
    radius::Real
    pen::Pen
    fillpen::Pen
    clip::Bool
end

const _DEFAULT_CIRCLE2D_KWARGS =
    OrderedDict(
        :pen=>Pen(),
        :fillpen=>NoPen(),
        :clip=>false
    )

function Circle2D(center::Vec2,
                  radius::Real;kwargs...)
    Circle2D(center,radius,updatedvals(_DEFAULT_CIRCLE2D_KWARGS,
                                    process_pen_kwargs(kwargs))...)
end

Circle(center::Vec2,radius::Real;kwargs...) =
                            Circle2D(center,radius;kwargs...)

function Circle2D(x::Real,y::Real,radius::Real;kwargs...)
    Circle2D(Vec2(x,y),radius;kwargs...)
end

Circle2D(z::RealOrComplex,radius::Real;kwargs...) =
    Circle2D(Vec2(z),radius;kwargs...)

Circle(z::RealOrComplex,radius::Real;kwargs...) =
            Circle2D(z,radius;kwargs...)

Circle2D(center::Tuple{<:Real,<:Real},radius::Real;kwargs...) =
    Circle2D(Vec2(center),radius;kwargs...)

Circle(center::Tuple{<:Real,<:Real},radius::Real;kwargs...) =
    Circle2D(Vec2(center),radius;kwargs...)

is_no_pen(P::Pen) = P.other == "NoPen"

function AsyString(C::Circle2D)
    if is_no_pen(C.pen) && is_no_pen(C.fillpen)
        return AsyString("")
    elseif is_no_pen(C.fillpen)
        drawcommand = "draw"
        penname = "p"
    elseif is_no_pen(C.pen)
        drawcommand = "fill"
        fillname = "p"
    else
        drawcommand = "filldraw"
        fillname = "fillpen"
        penname = "drawpen"
    end
    fillpen = is_no_pen(C.fillpen) ? "" : "$fillname=$(C.fillpen)"
    drawpen = (is_no_pen(C.pen) || isdefault(C.pen)) ? "" : "$penname=$(C.pen)"
    center = string(C.center)
    circle = "circle($center,$(C.radius))"
    if C.clip
        clipstatement = "clip($circle);\n"
    else
        clipstatement = ""
    end
    AsyString("""
    $clipstatement$drawcommand($(filterjoin(circle,fillpen,drawpen)));
    """)
end

function Base.show(io::IO,C::Circle2D)
    kwargs = kwargstring(C,_DEFAULT_CIRCLE2D_KWARGS)
    print(io,"""
    Circle2D(($(C.center.x),$(C.center.y)),$(C.radius)$kwargs)""")
end

#--- 2D POLYGONS -----------------------------------------
#------------------------------------------------------

"""
    Polygon2D(points;pen=Pen(),
                     fillpen=Pen(color="white"),
                     spline=false)

A graphics primitive representing a two-dimensional polygon

`points` may be an Array of `Vec2`s, an Array of 2-tuples,
or an ``n × 2`` Array. Alternatively, iterables of coordinates
may be supplied separately as `x` and `y`

# Examples
```julia-repl
julia> Polygon2D([(0,0),(1,0),(1,1)];pen="MidnightBlue")
Polygon2D(<3 points>;pen=MidnightBlue)
```
"""
struct Polygon2D <: GraphicElement2D
    points::Array{<:Vec2,1}
    pen::Pen
    fillpen::Pen
    spline::Bool
    clip::Bool
end

const _DEFAULT_POLYGON2D_KWARGS =
    OrderedDict(
        :pen=>Pen(),
        :fillpen=>NoPen(),
        :spline=>false,
        :clip=>false,
    )

Polygon2D(points::Array{<:Vec2,1};kwargs...) =
       Polygon2D(points,updatedvals(_DEFAULT_POLYGON2D_KWARGS,
                                            process_pen_kwargs(kwargs))...)

Polygon(points::Array{<:Vec2,1};kwargs...) = Polygon2D(points;kwargs...)

Polygon(points::Array{<:Tuple{<:Real,<:Real},1};kwargs...) = Polygon2D(points;kwargs...)

Polygon2D(points::Array{<:Tuple{<:Real,<:Real},1};kwargs...) =
                                Polygon2D(map(Vec2,points);kwargs...)

Polygon2D(coords::Array{<:Real,2};kwargs...) =
            Polygon2D([Vec2(coords[i,:]...) for i=1:size(coords,1)];kwargs...)

Polygon2D(points::Array{<:RealOrComplex,1};kwargs...) =
                        Polygon2D(map(Vec2,points);kwargs...)

Polygon(points::Array{<:RealOrComplex,1};kwargs...) =
                      Polygon2D(map(Vec2,points);kwargs...)

function counterclockwise(P::Polygon2D)
    v = P.points
    sum(p×q for (p,q) in zip(v,vcat(v[2:end],v[1:1]))) > 0
end

function Polygon(P::Path2D;kwargs...)
    lastindex = endof(P.points) - (P.points[1] == P.points[end] ? 1 : 0)
    Polygon(P.points[1:lastindex];kwargs...)
end

function box(a,b,c,d;kwargs...)
    Polygon([a b; c b; c d; a d];kwargs...)
end

"""
    Polygon(points;kwargs...)

Return a `Polygon2D` or a `Polygon3D` as appropriate

`points` may be an array of `Vec2`s or `Complex`es,
or an ``n × 2`` array of `Real`s

# Examples
```julia-repl
julia> Polygon([im,0,1])
Polygon2D(<3 points>)
```
"""
function Polygon(coords::Array{<:Real,2};kwargs...)
    if size(coords,2) == 2
        Polygon2D(coords;kwargs...)
    else
        Polygon3D(coords;kwargs...)
    end
end

function AsyString(P::Polygon2D)
    if is_no_pen(P.pen) && is_no_pen(P.fillpen)
        return AsyString("")
    elseif is_no_pen(P.fillpen)
        drawcommand = "draw"
        penname = "p"
    elseif is_no_pen(P.pen)
        drawcommand = "fill"
        fillname = "p"
    else
        drawcommand = "filldraw"
        fillname = "fillpen"
        penname = "drawpen"
    end
    fillpen = P.fillpen.other == "NoPen" ? "" : "$fillname=$(P.fillpen)"
    drawpen = (is_no_pen(P.pen) || isdefault(P.pen)) ? "" : "$penname=$(P.pen)"
    pathname = "p{IDENTIFIER}"
    coords = vcat([[p.x p.y] for p in P.points]...)
    spline = P.spline ? ".." : "--"
    if P.clip
        clipstatement = "clip($pathname);\n"
    else
        clipstatement = ""
    end
    if length(P.points) > 10
        AsyString("""
        file pathdata = input("path{IDENTIFIER}.csv");
        real[][] A = pathdata.csv().dimension(0,2);
        close(pathdata);
        guide $pathname;
        for(int i=0; i<A.length; ++i){
            $pathname = $pathname $spline (A[i][0],A[i][1]);
        }
        $pathname = $pathname $spline cycle;
        $clipstatement$drawcommand($(filterjoin(pathname,fillpen,drawpen)));
        """,
        Dict("path{IDENTIFIER}.csv"=>coords))
    else
        AsyString("""
        path $pathname = $(join([string(p) for p in P.points],spline))--cycle;
        $clipstatement$drawcommand($(filterjoin(pathname,fillpen,drawpen)));
        """)
    end
end

function Base.show(io::IO,P::Polygon2D)
    l = length(P.points)
    s = l ≠ 1 ? "s" : ""
    kwargs = kwargstring(P,_DEFAULT_POLYGON2D_KWARGS)
    print(io,"""
    Polygon2D(<$l point$s>$kwargs)""")
end

#--- GRAPHIC STRINGS ----------------------------------
#------------------------------------------------------

"""
    RawString(s::AbstractString)

Container for directly inserting Asymptote drawing
commands

# Examples
```julia-repl
julia> Plot([Circle((0,0),1),RawString2D("draw((0,0)--dir(20));")])
```
"""
struct RawString <: GraphicString
    s::AbstractString
end

function AsyString(S::RawString)
    AsyString(S.s)
end

function Base.show(io::IO,S::RawString)
    print(io,"RawString($(enclosequote(S.s)))")
end

struct Label2D <: GraphicElement2D
    s::AbstractString
    location::Vec2
    pen::Pen
    rotation::Float64
end

const _DEFAULT_LABEL2D_KWARGS =
    OrderedDict(
        :pen => Pen(),
        :rotation => 0.0
    )

Label2D(s::AbstractString,v::Vec2;kwargs...) =
    Label2D(s,v,updatedvals(_DEFAULT_LABEL2D_KWARGS,
                                process_pen_kwargs(kwargs))...)
Label(s::AbstractString,v::Vec2;kwargs...) = Label2D(s,v;kwargs...)
Label2D(s::AbstractString,
        P::Tuple{<:Real,<:Real};kwargs...) =
                                        Label2D(s,Vec2(P);kwargs...)
Label(s::AbstractString,P::Tuple{<:Real,<:Real};kwargs...) =
                                            Label2D(s,P;kwargs...)
Label2D(s,x::Real,y::Real;kwargs...) =
                Label2D(s,Vec2(x,y);kwargs...)
Label(s::AbstractString,x::Real,y::Real;kwargs...) = Label2D(s,x,y;kwargs...)
Label2D(s::AbstractString,z::Union{Real,Complex};kwargs...) =
                                            Label2D(s,reim(z)...;kwargs...)
Label(s::AbstractString,z::Union{Real,Complex};kwargs...) = Label2D(s,z;kwargs...)

function Base.show(io::IO,L::Label2D)
    kwargs = kwargstring(L,_DEFAULT_LABEL2D_KWARGS)
    print(io,"Label2D($(enclosequote(L.s)),($(L.location.x),$(L.location.y))$kwargs)")
end

#--- Pixel Maps ---------------------------------------

struct PixelMap <: GraphicElement2D
    pixels::Array{NamedColor,2}
    alpha::Array{<:Real,2}
    lowerleft::Tuple{Real,Real}
    upperright::Tuple{Real,Real}
    smooth::Bool
    antialias::Bool
end

const _DEFAULT_PIXELMAP_KWARGS =
    OrderedDict(
        :smooth => false,
        :antialias => false
    )

function PixelMap(pixels::Array{NamedColor,2},
                  lowerleft::Tuple{Real,Real},
                  upperright::Tuple{Real,Real};kwargs...)
    PixelMap(pixels,ones(size(pixels)...),lowerleft,upperright;kwargs...)
end

function PixelMap(pixels::Array{NamedColor,2},
                  alpha::Array{<:Real,2},
                  lowerleft::Tuple{Real,Real},
                  upperright::Tuple{Real,Real};
                  kwargs...)
    PixelMap(pixels,alpha,lowerleft,upperright,
                updatedvals(_DEFAULT_PIXELMAP_KWARGS,kwargs)...)
end

function Base.show(io::IO,P::PixelMap)
    m,n = size(P.pixels)
    a,b = P.lowerleft
    c,d = P.upperright
    print(io,"PixelMap(<$(m)×$(n)>,[$a,$c]×[$b,$d])")
end

function AsyString(P::PixelMap)
    r(N::NamedColor) = Float64(N.color.r)
    g(N::NamedColor) = Float64(N.color.g)
    b(N::NamedColor) = Float64(N.color.b)

    imagecommands = if P.smooth
        """
        pen[][] pixels = new pen[m][n];
        for(int i=0;i<m;++i){
          for(int j=0;j<n;++j){
              pixels[i][j] = (rgb(redvalues[i][j],
                                  greenvalues[i][j],
                                  bluevalues[i][j]) +
                                  opacity(alphavalues[i][j]));
          }
        }

        image(pixels,$(P.lowerleft),$(P.upperright),antialias=$(P.antialias));
        """
    else
        """
        for(int i=0;i<m;++i){
          for(int j=0;j<n;++j){
            if (alphavalues[i][j] > 0) {
              fill(box((a+i/m*(c-a),b+j/n*(d-b)),
                       (a+(i+1)/m*(c-a),b+(j+1)/n*(d-b))),
                       p=rgb(redvalues[i][j],
                               greenvalues[i][j],
                               bluevalues[i][j])+
                               opacity(alphavalues[i][j]));
            }
          }
        }
        """
    end
    AsyString("""
    int m = $(size(P.pixels,1));
    int n = $(size(P.pixels,2));
    file reds = input("red{IDENTIFIER}.csv");
    real[][] redvalues = reds.csv().dimension(m,n);
    close(reds);
    file blues = input("blue{IDENTIFIER}.csv");
    real[][] bluevalues = blues.csv().dimension(m,n);
    close(reds);
    file greens = input("green{IDENTIFIER}.csv");
    real[][] greenvalues = greens.csv().dimension(m,n);
    close(reds);
    file alphas = input("alpha{IDENTIFIER}.csv");
    real[][] alphavalues = alphas.csv().dimension(m,n);
    close(alphas);

    real a = $(Float64(P.lowerleft[1]));
    real b = $(Float64(P.lowerleft[2]));
    real c = $(Float64(P.upperright[1]));
    real d = $(Float64(P.upperright[2]));

    $imagecommands

    """,
    Dict("red{IDENTIFIER}.csv"=>r.(P.pixels),
         "green{IDENTIFIER}.csv"=>g.(P.pixels),
         "blue{IDENTIFIER}.csv"=>b.(P.pixels),
         "alpha{IDENTIFIER}.csv"=>P.alpha))
end


const _DEFAULT_HEATMAP_KWARGS =
    OrderedDict(
         :colors => ["MidnightBlue",
                     "LightSeaGreen",
                     "Yellow",
                     "Tomato"]
    )

function heatmap(A::Array{<:Real,2};
                 colors=NamedColor.(_DEFAULT_HEATMAP_KWARGS[:colors]),
                 kwargs...)
    heatmap(A,(0,0),size(A);colors=colors,kwargs...)
end

function heatmap(A::Array{<:Real,2},
                 lowerleft::Tuple{Real,Real},
                 upperright::Tuple{Real,Real};
                 colors=NamedColor.(_DEFAULT_HEATMAP_KWARGS[:colors]),
                 kwargs...)
    m,M = extrema(A)
    C = [cmap(colors,(A[i,j]-m)/(M-m)) for i=1:size(A,1),j=1:size(A,2)]
    if :alpha in keys(kwargs)
        alpha = kwargs[:alpha] 
        kwargs = [(a,b) for (a,b) in kwargs if a ≠ :alpha]
        PixelMap(C,alpha,lowerleft,upperright;kwargs...)
    else
        PixelMap(C,lowerleft,upperright;kwargs...)
    end
end

function cmap(colors::Array{NamedColor,1},r::Real)
    fpart, ipart = modf(1 + r*(length(colors)-1))
    if fpart == 0
        colors[Int(ipart)]
    else
        (1-fpart) * colors[Int(ipart)] + fpart * colors[Int(ipart)+1]
    end
end

#------------------------------------------------------

#--- 2D PLOTS -----------------------------------------
#------------------------------------------------------


"""
    Plot2D(elements::Array{<:GraphicElement,1},
           options::Array{Any,1})

A container for a list of graphics primitives to draw,
together with drawing options

# Examples
```julia-repl
julia> Plot([Path([0 0; 1 1]),Polygon([exp(2*pi*im*k/5) for k=1:5])])
```
"""
struct Plot2D <: Plot
    elements::Array{<:GraphicElement,1}
    options::Array{Any,1}
end

Plot2D(;kwargs...) = Plot2D(GraphicElement[],kwargs...)

Plot2D(elements::Array{<:GraphicElement,1};kwargs...) =
        Plot2D(elements,collect(kwargs))

Plot2D(element::GraphicElement;kwargs...) = Plot2D([element];kwargs...)

function Plot2D(P::Plot2D;kwargs...)
    Plot2D(P.elements,updatedvals(
                    _DEFAULT_PLOT2D_KWARGS,kwargs))
end

Plot(P::Plot2D;kwargs...) = Plot2D(P;kwargs...)

const _DEFAULT_PLOT2D_KWARGS =
    OrderedDict(
         :axes => false,
         :axispen => Pen(),
         :xaxisarrow => NoArrow(),
         :yaxisarrow => NoArrow(),
         :axisarrow => NoArrow(),
         :xlabel => "",
         :ylabel => "",
         :packages => ["mathpazo"],
         :xmin => "-infinity",
         :xmax => "infinity",
         :ymin => "-infinity",
         :ymax => "infinity",
         :xticks => "NoTicks",
         :yticks => "NoTicks",
         :ticks => "NoTicks",
         :ignoreaspect => false,
         :width => _DEFAULT_WIDTH,
         :height => "", 
         :bgcolor => NamedColor("white"),
         :bgfill => true, 
         :border => 3,
         :pdf => true)

function AsyString(P::Plot2D)
    global _DEFAULT_PLOT2D_KWARGS
    D = deepcopy(_DEFAULT_PLOT2D_KWARGS)
    for k in keys(Dict(P.options))
        if !(k in keys(D))
            error("Unknown Plot2D option $k")
        end
    end
    merge!(D,Dict(P.options))
    for s in [:xmin,:xmax,:ymin,:ymax]
        if isa(D[s],Real)
            D[s] = string(D[s])
        end
    end
    if isa(D[:bgcolor],AbstractString)
        D[:bgcolor] = NamedColor(D[:bgcolor])
    end
    if isa(D[:axispen],AbstractString) || isa(D[:axispen],NamedColor)
        D[:axispen] = convert(Pen,D[:axispen])
    end
    if D[:axisarrow] ≠ _DEFAULT_PLOT2D_KWARGS[:axisarrow]
        D[:xaxisarrow] = D[:axisarrow]
        D[:yaxisarrow] = D[:axisarrow]
    end
    if D[:ticks] ≠ _DEFAULT_PLOT2D_KWARGS[:ticks]
        D[:xticks] = D[:ticks]
        D[:yticks] = D[:ticks]
    end
    pen = (is_no_pen(D[:axispen]) || isdefault(D[:axispen]) ?
                "" :
                """\n$(" "^9)p   = $(D[:axispen]),""")
    if D[:axes]
        axesstring = """
        xaxis(   L   = $(enclosequote(D[:xlabel])),
               arrow = $(AsyString(D[:xaxisarrow])),
               xmin  = $(D[:xmin]),
               xmax  = $(D[:xmax]),$pen
               ticks = $(D[:xticks]));
        yaxis(   L   = $(enclosequote(D[:ylabel])),
               arrow = $(AsyString(D[:yaxisarrow])),
               ymin  = $(D[:ymin]),
               ymax  = $(D[:ymax]),$pen
               ticks = $(D[:yticks]));
        """
    else
        axesstring = ""
    end

    shipout = D[:bgfill] ? "shipout(bbox(FillDraw($(D[:border]),fillpen=$(string(D[:bgcolor])),drawpen=invisible)));" : 
        "shipout(bbox($(D[:border]),invisible));"

    pdf = D[:pdf] ? "settings.outformat=\"pdf\";" : ""
    ignoreaspect = D[:ignoreaspect] ? "IgnoreAspect" : ""
    packages = join("usepackage($(enclosequote(s)));"
                                    for s in D[:packages])

    asystrings = map(AsyString,P.elements)
    drawingcommands = join(replace(s.str,"{IDENTIFIER}"=>string(j))
                                for (j,s) in enumerate(asystrings))

    data = [A.data for A in asystrings]
    merged_data = merge([Dict(replace(k,"{IDENTIFIER}"=>j) => v
                for (k,v) in D) for (j,D) in enumerate(data)]...)

    AsyString("""
    import x11colors;
    import graph;
    import palette;

    $pdf

    $packages

    size($(filterjoin(D[:width],D[:height],ignoreaspect)));

    $drawingcommands

    $axesstring

    $shipout 
    """,
    merged_data)
end

function +(P::Plot2D,Q::Plot2D)
    global _DEFAULT_PLOT2D_KWARGS
    elements = vcat(P.elements,Q.elements)
    options = copy(_DEFAULT_PLOT2D_KWARGS)
    merge!(options,Dict(P.options))
    merge!(options,Dict(Q.options))
    Plot2D(elements,collect(options))
end

# Convenience functions for plotting -------------------

const blue, red, green = [Colors.parse(Colors.Colorant,c) for
                                c in ("MidnightBlue","DarkRed","SeaGreen")]

"""
    plot(x,y;kwargs...)
    plot(y;kwargs...)

Return a graph of the path with ``x`` and ``y`` values
given by `x` and `y`

`x` defaults to `0:length(y)-1`. `kwargs` are applied to
the `Path2D` object representing the line or to the
containing `Plot2D`, as appropriate

    plot(xs::Vector{<:Vector{<:Real}},
         ys::Vector{<:Vector{<:Real}};
         kwargs...)

Multiple line graphs in the same figure

    plot(x,y,z;kwargs...)
    plot(z::Array{<:Real,2};kwargs...)

A graph of the surface with ``x``, ``y``, and ``z``
values `x`, `y`, and `z`

`x` defaults to `[i-1 for i=1:size(z,1),j=1:size(z,2)]` and
`y` defaults to `[j-1 for i=1:size(z,1),j=1:size(z,2)]`

# Examples
```julia-repl
plot(cumsum(randn(100)))
plot(rand(5,5))
```
"""
function plot(xs::Vector{<:Vector{<:Real}},
              ys::Vector{<:Vector{<:Real}};
              colors=Colors.distinguishable_colors(length(xs),
                        [blue,red,green],
                        lchoices=range(50,stop=100,length=15),
                        cchoices=range(50,stop=100,length=15),
                        hchoices=range(170,stop=340,length=15)),
              kwargs...)
    if length(xs) ≠ length(ys)
      error("List of x vectors and list of y vectors
             should have the same length")
    end
    global _DEFAULT_PATH2D_KWARGS
    pathkwargs, plotkwargs = splitkwargs(process_pen_kwargs(kwargs),
                                                _DEFAULT_PATH2D_KWARGS)
    penkwarg = [(a,b) for (a,b) in pathkwargs if a == :pen]
    if length(penkwarg) > 0
        ps = [[penkwarg[1]] for c in colors]
    else
        ps = [[(:pen,Pen(color=c,linewidth=1.5))] for c in colors]
    end
    if :ticks in keys(kwargs)
        xticks = kwargs[:ticks]
        yticks = kwargs[:ticks]
    else
        xticks = (:xticks in keys(kwargs)) ? kwargs[:xticks] : "Ticks(OmitTick(0))"
        yticks = (:yticks in keys(kwargs)) ? kwargs[:yticks] : "Ticks(OmitTick(0))"
    end
    Plot2D([Path2D(x,y;p...,pathkwargs...) for (x,y,p) in zip(xs,ys,ps)];
                   ignoreaspect=true,
                   axes=true,
                   xticks=xticks, 
                   yticks=yticks, 
                   plotkwargs...)
end

function plot(x,ys::Vector{<:Array{<:Real,1}};kwargs...)
    plot(fill(collect(x),length(ys)),ys;kwargs...)
end

function plot(ys::Vector{<:Array{<:Real,1}};kwargs...)
    @assert length(Set(map(length,ys))) == 1
    plot(collect(1:length(ys[1])),ys;kwargs...)
end

function plot(x::Union{Vector{<:Real},UnitRange},
              y::Union{Vector{<:Real},UnitRange};kwargs...)
    plot([collect(x)],[collect(y)];kwargs...)
end

function plot(y::Array{<:Real,1};kwargs...)
    plot(collect(0:length(y)-1),y;kwargs...)
end

function plot(fs,
              a::Real,
              b::Real;
              n::Integer=100,
              kwargs...)
    x = range(a,stop=b,length=n)
    plot(collect(x),[f.(x) for f in fs];kwargs...)
end

function plot(f::Function,a::Real,b::Real;kwargs...)
    plot([f],a,b;kwargs...)
end

function plot(f_or_fs,t::Tuple{<:Real,<:Real};kwargs...)
    plot(f_or_fs,t...;kwargs...)
end

