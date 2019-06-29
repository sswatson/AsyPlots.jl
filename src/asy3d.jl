
abstract type GraphicElement3D <: GraphicElement end

#--- 3D POINTS -----------------------------------------
#-------------------------------------------------------
struct Vec3
    x::Real
    y::Real
    z::Real
end

Vec3(t::Tuple{<:Real,<:Real,<:Real}) = Vec3(t...)

string(v::Vec3) = "($(v.x),$(v.y),$(v.z))"

"""
    Point3D(x::Real,y::Real,z::Real; label="",pen=Pen())
    Point3D(P; label="",pen=Pen())

A graphics primitive representing a three-dimensional point.

`P` may be a 3-tuple of real numbers or a `Vec3`

# Examples
```julia-repl
julia> Point3D(0,4,5;pen="DarkGreen")
```
"""
struct Point3D <: GraphicElement3D
    P::Vec3
    label::AbstractString
    pen::Pen
end

const _DEFAULT_POINT3D_KWARGS =
    OrderedDict(
        :label=>"",
        :pen=>Pen()
    )

Point3D(v::Vec3;kwargs...) =
    Point3D(v,updatedvals(_DEFAULT_POINT3D_KWARGS,
                            process_pen_kwargs(kwargs))...)

Point3D(x::Real,y::Real,z::Real;kwargs...) =
                            Point3D(Vec3(x,y,z);kwargs...)

Point(x::Real,y::Real,z::Real;kwargs...) =
                            Point3D(x,y,z;kwargs...)

function AsyString(point::Point3D)
    label = point.label == "" ? "" : "L=$(enclosequote(point.label))"
    AsyString("""
    dot($(filterjoin(label,point.P,point.pen)));
    """)
end

function Base.show(P::Point3D)
    kwargs = kwargstring(P,_DEFAULT_POINT3D_KWARGS)
    print(io,"Point3D($(P.P.x),$(P.P.y),$(P.P.z)$kwargs)")
end

#--- 3D PATHS ------------------------------------------
#-------------------------------------------------------

"""
    Path3D(points;label="",pen=Pen(),arrow="",spline=false)

A graphics primitive representing a two-dimensional path

`points` may be an Array of `Vec3`s or an Array of 3-tuples.
Alternatively, iterables of coordinates may be supplied
separately as `x` and `y`

# Examples
```julia-repl
julia> Path3D([(0,0),(1,0),(1,1)];pen="MidnightBlue")
```
"""
struct Path3D <: GraphicElement3D
    points::Array{Vec3,1}
    label::AbstractString
    pen::Pen
    arrow::Arrow
    spline::Bool
end

const _DEFAULT_PATH3D_KWARGS =
    OrderedDict(
        :label => "",
        :pen => Pen(),
        :arrow => NoArrow(),
        :spline => false
    )

Path3D(points::Array{Vec3,1};kwargs...) =
    Path3D(points,updatedvals(_DEFAULT_PATH3D_KWARGS,
                                    process_pen_kwargs(kwargs))...)

Path3D(points::Array{<:Tuple{<:Real,<:Real,<:Real},1};kwargs...) =
                                Path3D(map(Vec3,points);kwargs...)

Path(points::Array{<:Tuple{<:Real,<:Real,<:Real},1};kwargs...) =
                                Path3D(map(Vec3,points);kwargs...)

Path3D(coords::Array{<:Real,2};kwargs...) =
            Path3D([Vec3(coords[i,:]...) for i=1:size(coords,1)];kwargs...)

function AsyString(P::Path3D)
    label = P.label == "" ? "" : "L=$(enclosequote(P.label))"
    pathname = "p{IDENTIFIER}"
    coords = vcat([[p.x p.y p.z] for p in P.points]...)
    spline = P.spline ? ".." : "--"
    arrow = P.arrow.name == "None" ? "" : "arrow=$(P.arrow)"
    if length(P.points) > 10
        AsyString("""
        file pathdata = input("path{IDENTIFIER}.csv");
        real[][] A = pathdata.csv().dimension(0,3);
        close(pathdata);
        guide3 $pathname;
        for(int i=0; i<A.length; ++i){
            $pathname = $pathname $spline (A[i][0],A[i][1],A[i][2]);
        }
        draw($(filterjoin(label,pathname,P.pen,arrow)));
        """,
        Dict("path{IDENTIFIER}.csv"=>coords))
    else
        AsyString("""
        path3 $pathname = $(join([string(p) for p in P.points],spline));
        draw($(filterjoin(label,pathname,P.pen,arrow)));
        """)
    end
end

function Base.show(io::IO,P::Path3D)
    l = length(P.points)
    s = l ≠ 1 ? "s" : ""
    kwargs = kwargstring(P,_DEFAULT_PATH3D_KWARGS)
    print(io,"""
    Path3D(<$l point$s>$kwargs)
    """)
end

#--- Surfaces ------------------------------------------
#-------------------------------------------------------

"""
    Surface(x::Array{<:Real},
            y::Array{<:Real},
            z::Array{<:Real,2};
            options)
    Surface(z::Array{<:Real},2)

A graphics primitive representing a surface in three dimensions
`x` and `y` may be one- or two-dimensional arrays

The surface passes through the points
    [x[i,j],y[i,j],z[i,j] for i=1:size(z,1),j=1:size(z,2)]

The options are
- `colors`: A vector of color names, for coloring
- `spline`: whether to draw a smooth or piecewise smooth surface
- `surfacepen`: a pen for drawing the surface
- `meshpen`: a pen for drawing the grid lines on the surface
- `clip`: either `false` or a boolean array of the same dimensions
          as `x`, `y`, and `z`, specifying patches to exclude
"""
struct Surface <: GraphicElement3D
    x::Array{<:Real,2}
    y::Array{<:Real,2}
    z::Array{<:Real,2}
    colors::Union{Vector,Array{Pen,2}}
    spline::Bool
    surfacepen::Pen
    meshpen::Pen
    clip # either false or an Array{Bool,2} of the same size as z
end

const _DEFAULT_SURFACE_KWARGS =
    OrderedDict(
         :colors => ["MidnightBlue",
                     "LightSeaGreen",
                     "Yellow",
                     "Tomato"],
         :spline => true,
         :surfacepen => Pen(),
         :meshpen => Pen(),
         :clip => false)

function Surface(x::Array{<:Real,2},
                 y::Array{<:Real,2},
                 z::Array{<:Real,2};kwargs...)
    Surface(x,y,z,updatedvals(_DEFAULT_SURFACE_KWARGS,kwargs)...)
end

function Surface(z::Array{<:Real,2};kwargs...)
    x = [i-1 for i=1:size(z,1),j=1:size(z,2)]
    y = [j-1 for i=1:size(z,1),j=1:size(z,2)]
    Surface(x,y,z;kwargs...)
end

function Surface(x::Union{Array{<:Real,1},AbstractRange},
                 y::Union{Array{<:Real,1},AbstractRange},
                 z::Array{<:Real,2};kwargs...)
    xtwo = [xi for xi=x,yi=y]
    ytwo = [yi for xi=x,yi=y]
    Surface(xtwo,ytwo,z;kwargs...)
end

function AsyString(S::Surface)
    r(P::Pen) = Float64(P.color.color.r)
    g(P::Pen) = Float64(P.color.color.g)
    b(P::Pen) = Float64(P.color.color.b)
    o(P::Pen) = Float64(P.opacity)
    asyData = Dict()
    for w in (:x,:y,:z)
        asyData[string(w)*"{IDENTIFIER}.csv"] = getfield(S,w)
    end
    D = Dict(k => getfield(S,k) for k in keys(_DEFAULT_SURFACE_KWARGS))
    spline = D[:spline] ? ",usplinetype=Spline,vsplinetype=Spline" : ""
    surfacepen = isdefault(D[:surfacepen]) ? "" : "surfacepen=$(D[:surfacepen])"
    meshpen = isdefault(D[:meshpen]) ? "" : "meshpen=$(D[:meshpen])"

    surfacepenmod = """
    p[i] += $(D[:surfacepen]);
    """
    if isdefault(D[:surfacepen])
        surfacepenmod = ""
    end

    safepaste(s) = length(s) > 1000 ? error("Misspecified colors") : s

    if isa(D[:colors],Array{Pen,2})
        merge!(asyData,Dict(
            "red{IDENTIFIER}.csv"=>r.(D[:colors]),
            "green{IDENTIFIER}.csv"=>g.(D[:colors]),
            "blue{IDENTIFIER}.csv"=>b.(D[:colors]),
            "alpha{IDENTIFIER}.csv"=>o.(D[:colors])))
        colorasy = """
        int m = $(size(D[:colors],1));
        int n = $(size(D[:colors],2));
        file reds = input("red{IDENTIFIER}.csv");
        real[][] redvalues = reds.csv().dimension(m,n);
        close(reds);
        file blues = input("blue{IDENTIFIER}.csv");
        real[][] bluevalues = blues.csv().dimension(m,n);
        close(blues);
        file greens = input("green{IDENTIFIER}.csv");
        real[][] greenvalues = greens.csv().dimension(m,n);
        close(greens);
        file alphas = input("alpha{IDENTIFIER}.csv");
        real[][] alphavalues = alphas.csv().dimension(m,n);
        close(alphas);

        pen[][] pixels = new pen[m][n];
        for(int i=0;i<m;++i){
          for(int j=0;j<n;++j){
              pixels[i][j] = (rgb(redvalues[i][j],
                                  greenvalues[i][j],
                                  bluevalues[i][j]) +
                                  opacity(alphavalues[i][j]));
          }
        }

        pen[][] patchpens = new pen[(m-1)*(n-1)][4];

        int splineoffset = $(D[:spline] ? 1 : 0); 

        for(int i=0; i<m-1; ++i){
          for(int j=0; j<n-1; ++j){
            patchpens[(n-1)*i+j][0] = pixels[i][j];
            patchpens[(n-1)*i+j][1] = pixels[i+splineoffset][j];
            patchpens[(n-1)*i+j][2] = pixels[i+splineoffset][j+splineoffset];
            patchpens[(n-1)*i+j][3] = pixels[i][j+splineoffset];
          }
        }

        s.colors(patchpens);

        """
    else
        surfacepenmodloop = surfacepenmod == "" ? "" :
            """
            for(int i=0; i<p.length-1; ++i) {
                p[i] += $surfacepenmod; 
            }
            """
        colorasy = """
        pen[] p = {$(safepaste((join(D[:colors],','))))};

        $surfacepenmodloop
    
        s.colors(palette(s.map(zpart),Gradient(100 ... p)));
        """
    end

    if D[:clip] ≠ false
        if (!isa(D[:clip],AbstractArray{<:Any,2})
            || size(D[:clip]) ≠ size(S.z))
            error("clip misspecified")
        end
        clipfile = """
        file condfile = input("cond{IDENTIFIER}.csv");
        int[][] cond = condfile.csv().dimension(m,n);
        close(condfile);
        """
        clipfunction = """
        bool cond(pair t) {
            int i = round(t.x);
            int j = round(t.y);
            return cond[i][j] == 0 ? false : true;
        }
        """
        cliparg = ",cond=cond"
        asyData["cond{IDENTIFIER}.csv"] =
                    convert(Array{Int64,2},D[:clip])
    else
        clipfile = ""
        clipfunction = ""
        cliparg = ""
    end

    AsyString("""
    int m = $(size(S.z,1));
    int n = $(size(S.z,2));

    file xdata = input("x{IDENTIFIER}.csv");
    real[][] x = xdata.csv().dimension(m,n);
    close(xdata);

    file ydata = input("y{IDENTIFIER}.csv");
    real[][] y = ydata.csv().dimension(m,n);
    close(ydata);

    file zdata = input("z{IDENTIFIER}.csv");
    real[][] z = zdata.csv().dimension(m,n);
    close(zdata);

    $clipfile

    triple f(pair t) {
      int i=round(t.x);
      int j=round(t.y);
      return (x[i][j],y[i][j],z[i][j]);
    }

    $clipfunction

    surface s = surface(f,(0,0),(m-1,n-1),
                            nu=m-1,nv=n-1$spline$cliparg);

    $colorasy

    draw($(filterjoin("s",surfacepen,meshpen,
                "render(merge=true)","light=nolight")));""",
    asyData)
end

function Base.show(io::IO,S::Surface)
    kwargs = kwargstring(S,_DEFAULT_SURFACE_KWARGS)
    print(io,"Surface(<$(size(S.z,1))×$(size(S.z,2))>$kwargs)")
end

#--- 3D POLYGONS -----------------------------------------
#---------------------------------------------------------

"""
    Polygon3D(points;pen=Pen(),
                     fillpen=Pen(color="white"),
                     spline=false)

A graphics primitive representing a three-dimensional polygon

`points` may be an Array of `Vec3`s or an Array of 3-tuples.

# Examples
```julia-repl
julia> Polygon3D([(0,0,0),(1,0,0),(1,1,0)];pen="MidnightBlue")
```
"""
struct Polygon3D <: GraphicElement3D
    points::Array{Vec3,1}
    pen::Pen
    fillpen::Pen
    spline::Bool
end

const _DEFAULT_POLYGON3D_KWARGS =
    OrderedDict(
        :pen => Pen(),
        :fillpen => Pen(color="white"),
        :spline => false
    )

Polygon3D(points::Array{Vec3,1};kwargs...) =
    Polygon3D(points,updatedvals(_DEFAULT_POLYGON3D_KWARGS,kwargs)...)

Polygon(points::Array{Vec3,1};kwargs...) = Polygon3D(points;kwargs...)

Polygon3D(points::Array{<:Tuple{<:Real,<:Real,<:Real},1};kwargs...) =
                                Polygon3D(map(Vec3,points);kwargs...)

Polygon3D(coords::Array{<:Real,2};kwargs...) =
            Polygon3D([Vec3(coords[i,:]...) for i=1:size(coords,1)];kwargs...)

Polygon3D(points::Array{<:RealOrComplex,1};kwargs...) =
                        Polygon3D(map(Vec3,points);kwargs...)

function Polygon(P::Path3D;kwargs...)
    lastindex = endof(P.points) - (P.points[1] == P.points[end] ? 1 : 0)
    Polygon(P.points[1:lastindex];kwargs...)
end

function AsyString(P::Polygon3D)
    pathname = "p{IDENTIFIER}"
    coords = vcat([[p.x p.y p.z] for p in P.points]...)
    spline = P.spline ? ".." : "--"
    surface = "surface($pathname)"
    if length(P.points) > 10
        AsyString("""
        file pathdata = input("path{IDENTIFIER}.csv");
        real[][] A = pathdata.csv().dimension(0,3);
        close(pathdata);
        guide3 $pathname;
        for(int i=0; i<A.length; ++i){
            $pathname = $pathname $spline (A[i][0],A[i][1],A[i][2]);
        }
        $pathname = $pathname $spline cycle;
        draw($(filterjoin(surface,P.fillpen,P.pen)));
        """,
        Dict("path{IDENTIFIER}.csv"=>coords))
    else
        AsyString("""
        path3 $pathname = $(join([string(p) for p in P.points],spline))--cycle;
        draw($(filterjoin(surface,P.fillpen,P.pen)));
        """)
    end
end

function Base.show(io::IO,P::Polygon3D)
    l = length(P.points)
    s = l ≠ 1 ? "s" : ""
    kwargs = kwargstring(P,_DEFAULT_POLYGON3D_KWARGS)
    print(io,"""
    Polygon3D(<$l point$s>$kwargs)
    """)
end

#--- 3D LABELS ----------------------------------------
#------------------------------------------------------

struct Label3D <: GraphicElement3D
    s::AbstractString
    location::Vec3
    pen::Pen
end

const _DEFAULT_LABEL3D_KWARGS =
    OrderedDict(
        :pen => Pen()
    )

Label3D(s::AbstractString,v::Vec3;kwargs...) =
    Label3D(s,v,updatedvals(_DEFAULT_LABEL3D_KWARGS,
                                process_pen_kwargs(kwargs))...)
Label(s::AbstractString,v::Vec3;kwargs...) = Label3D(s,v;kwargs...)
Label3D(s::AbstractString,
        P::Tuple{<:Real,<:Real,<:Real};kwargs...) =
                                        Label3D(s,Vec3(P);kwargs...)
Label(s::AbstractString,P::Tuple{<:Real,<:Real,<:Real};kwargs...) =
                                             Label3D(s,P;kwargs...)
Label3D(s,x::Real,y::Real;kwargs...) =
                Label3D(s,Vec3(x,y);kwargs...)
Label(s::AbstractString,x::Real,y::Real,z::Real;kwargs...) = Label3D(s,x,y;kwargs...)

function AsyString(L::Union{Label2D,Label3D})
    pen = isdefault(L.pen) ? "" : ",p=$(string(L.pen))"
    rotation = (isa(L,Label3D) || L.rotation == 0.0) ? "" : "rotate($(L.rotation))*"
    AsyString("label($rotation$(enclosequote(L.s)),$(string(L.location))$pen);")
end

function Base.show(io::IO,L::Label3D)
    kwargs = kwargstring(L,_DEFAULT_LABEL3D_KWARGS)
    P = L.location
    print(io,"Label3D($(enclosequote(L.s)),($(P.x),$(P.y),$(P.z))$kwargs)")
end

#--- 3D Plots ------------------------------------------
#-------------------------------------------------------

"""
    Plot3D(elements::Array{<:GraphicElement2D,1},
           options::Array{Any,1})

A container for a list of graphics primitives to draw,
together with drawing options

# Examples
```julia-repl
julia> Plot(Path([0 0 0; 1 1 1]),Path([0 0 0; 0 0 1]))
```
"""
struct Plot3D <: Plot
    elements::Array{<:GraphicElement,1}
    options::Array{Any,1}
end

+(G::GraphicElement, H::GraphicElement) = Plot([G,H])
+(P::Plot,G::GraphicElement) = P + Plot(G)
+(G::GraphicElement,P) = P + G

Plot3D() = Plot3D(GraphicElement[],[])

function Plot3D(elements::Array{<:GraphicElement};kwargs...)
    Plot3D(elements,collect(kwargs))
end

Plot3D(element::GraphicElement;kwargs...) = Plot3D([element];kwargs...)

function Plot(elements...;kwargs...)
    if length(elements) == 0
        Plot(GraphicElement[])
    end
    e = elements[1]
    if length(elements) > 1 || isa(e,GraphicElement)
        return Plot(collect(elements);kwargs...)
    end
    if isa(e,Vector{<:GraphicElement})
        if all(isa(g,Union{GraphicElement2D,RawString}) for g in e)
            return Plot2D(e;kwargs...)
        else
            return Plot3D(e;kwargs...)
        end
    else
        error("Argument to Plot should be a Vector{<:GraphicElement}")
    end
end

const _DEFAULT_PLOT3D_KWARGS =
    OrderedDict(
         :axes => true,
         :pdf => false,
         :render => 4,
         :xlabel => "",
         :ylabel => "",
         :zlabel => "",
         :packages => ["mathpazo"],
         :xmin => "-infinity",
         :xmax => "infinity",
         :ymin => "-infinity",
         :ymax => "infinity",
         :zmin => "-infinity",
         :zmax => "infinity",
         :xticks => "NoTicks3",
         :yticks => "NoTicks3",
         :zticks => "NoTicks3",
         :arrow => Arrow3(),
         :camera => nothing,
         :up => nothing, 
         :projection => "perspective",
         :bgcolor => NamedColor("white"),
         :width => _DEFAULT_WIDTH,
         :ignoreaspect => false)

function AsyString(P::Plot3D)
    global _DEFAULT_PLOT3D_KWARGS
    D = copy(_DEFAULT_PLOT3D_KWARGS)
    for k in keys(Dict(P.options))
        if !(k in keys(D))
            error("Unknown Plot3D option $k")
        end
    end
    merge!(D,Dict(P.options))
    for s in [:xmin,:xmax,:ymin,:ymax,:zmin,:zmax]
        if isa(D[s],Real)
            D[s] = string(D[s])
        end
    end
    if isa(D[:bgcolor],AbstractString)
        D[:bgcolor] = NamedColor(D[:bgcolor])
    end
    if D[:axes]
        axesstring = """
        xaxis3(  L   = $(enclosequote(D[:xlabel])),
               arrow = $(D[:arrow]),
               xmin  = $(D[:xmin]),
               xmax  = $(D[:xmax]),
               ticks = $(D[:xticks]));
        yaxis3(  L   = $(enclosequote(D[:ylabel])),
               arrow = $(D[:arrow]),
               ymin  = $(D[:ymin]),
               ymax  = $(D[:ymax]),
               ticks = $(D[:yticks]));
        zaxis3(  L   = $(enclosequote(D[:zlabel])),
               arrow = $(D[:arrow]),
               zmin  = $(D[:zmin]),
               zmax  = $(D[:zmax]),
               ticks = $(D[:zticks]));
        """
    else
        axesstring = ""
    end
    
    if occursin("(",D[:projection])
        currentprojection = D[:projection]
    elseif D[:camera] != nothing
        a,b,c = D[:camera]
        up = isa(D[:up],Nothing) ? "" : "up=$(D[:up])"
        currentprojection = "$(D[:projection])($(filterjoin(a,b,c,up)));"
    else
        currentprojection = "$(D[:projection])(M.x+(M.x-m.x),M.y+0.25*(M.y-m.y),M.z+0.5*(M.z-m.z));"
    end

    bgcolor = "currentlight.background = $(string(D[:bgcolor]));"

    ignoreaspect = D[:ignoreaspect] ? ",IgnoreAspect" : ""
    pdfstring = """
    settings.outformat = "pdf";
    settings.render = $(D[:render]);
    """
    pdf = D[:pdf] ? pdfstring : ""
    packages = join("usepackage($(enclosequote(s)));"
                                    for s in D[:packages])
    shipout = D[:pdf] ? "shipout(bbox(3.0,invisible));" : ""

    asystrings = map(AsyString,P.elements)
    drawingcommands = join(replace(s.str,"{IDENTIFIER}"=>string(j))
                                for (j,s) in enumerate(asystrings))

    data = [A.data for A in asystrings]
    merged_data = merge([Dict(replace(k,"{IDENTIFIER}"=>j) => v
                for (k,v) in D) for (j,D) in enumerate(data)]...)

    AsyString("""
    import graph3;
    import palette;
    import x11colors;

    $packages

    $pdf

    size3($(D[:width])$ignoreaspect);

    $bgcolor

    $drawingcommands

    $axesstring

    triple M = currentpicture.userMax();
    triple m = currentpicture.userMin();
    currentprojection = $currentprojection
    $shipout
    """,
    merged_data)
end

function +(P::Plot3D,Q::Plot3D)
    global _DEFAULT_PLOT2D_KWARGS
    elements = vcat(P.elements,Q.elements)
    options = copy(_DEFAULT_PLOT3D_KWARGS)
    merge!(options,Dict(P.options))
    merge!(options,Dict(Q.options))
    return Plot3D(elements,collect(options))
end

#--- OUTPUT --------------------------------------------
#-------------------------------------------------------

function plot(z::Array{<:Real,2};kwargs...)
    global _DEFAULT_SURFACE_KWARGS
    surfkwargs, plotkwargs = splitkwargs(kwargs,_DEFAULT_SURFACE_KWARGS)
    Plot3D(Surface(z;surfkwargs...);ignoreaspect=true,plotkwargs...)
end

function plot(x,y,z::Array{<:Real,2};kwargs...)
    global _DEFAULT_SURFACE_KWARGS
    surfkwargs, plotkwargs = splitkwargs(kwargs,_DEFAULT_SURFACE_KWARGS)
    Plot3D(Surface(x,y,z;surfkwargs...);ignoreaspect=true,plotkwargs...)
end

function plot(f::Function,
              a::Real,
              b::Real,
              c::Real,
              d::Real;
              m::Integer=100,
              n::Integer=100,
              kwargs...)
    x = range(a,stop=b,length=m)
    y = range(c,stop=d,length=n)
    plot(x,y,[f(p,q) for p=x,q=y];kwargs...)
end

plot(f::Function,x::Tuple{<:Real,<:Real},y::Tuple{<:Real,<:Real};kwargs...) =
    plot(f,x...,y...;kwargs...)

function interactive(P::Plot3D;kwargs...)
    check_asy_present()
    Q = deepcopy(P)
    filter!(p -> first(p) ≠ :pdf, Q.options)
    push!(Q.options,(:pdf,false))
    for (k,v) in kwargs
        filter!(p -> first(p) ≠ k, Q.options)
        push!(Q.options,(k,v))
    end
    directory = mktempdir()
    filename = "$directory/myplot.asy"
    save(filename,Q;runasy=false)
    originaldir = pwd()
    cd(directory)
    run(`asy -V myplot.asy`)
    cd(originaldir)
end

interactive(S::GraphicElement3D;kwargs...) =
        interactive(Plot3D([S],kwargs))

interactive(z::Array{<:Real,2};kwargs...) = interactive(plot(z;kwargs...))
