
const IT = Interpolations

function pairs(curve::Contour.Curve2)
    collect(zip(Contour.coordinates(curve)...))
end

function LinearInterpolation(xs,ys,A)
    itp = IT.interpolate(A, IT.BSpline(IT.Linear(IT.OnGrid())))
    IT.scale(itp, xs, ys)
end

function CubicInterpolation(xs,ys,A)
    itp = IT.interpolate(A, IT.BSpline(IT.Cubic(IT.Line(IT.OnGrid()))))
    IT.scale(itp, xs, ys)
end

const _DEFAULT_ISOLINE_KWARGS =
    OrderedDict(:colors => ["MidnightBlue",
                            "LightSeaGreen",
                            "Gold",
                            "Tomato"],
                :lift => false, 
                :interpolation => :cubic)

"""
    isolines(xs, ys, zs; lift = false, interpolation = :cubic)    
    
Plot the contour lines of the function whose values are represented
by the array (or function) `zs`. If `lift` is true, plot in 3D.
    
# Examples
```julia-repl
julia> isolines(0:10, 0:10, (x,y) -> (100 - x^2 + y^2)/10, lift = true)
"""
function isolines(args...;kwargs...)
    D = deepcopy(_DEFAULT_ISOLINE_KWARGS)
    merge!(D,Dict(kwargs))
    isolinekwargs, penkwargs = splitkwargs(kwargs,_DEFAULT_ISOLINE_KWARGS)
    grlist = GraphicElement[]
    if length(args) ≥ 3 && args[3] isa Function
        args = (args[1], 
                args[2], 
                float([args[3](x,y) for x in args[1], y in args[2]]))
    end
    C = Contour.contours(args...)
    m, M = extrema([Contour.level(cl) for cl in Contour.levels(C)])
    if D[:lift] 
        if D[:interpolation] == :linear
            interp = LinearInterpolation(args[1:3]...)
        elseif D[:interpolation] == :cubic
            interp = CubicInterpolation(args[1:3]...)
        else
            error("`interpolation` should be either :cubic or :linear")
        end
    end
    for cl in Contour.levels(C)
        L = Contour.level(cl)
        for line in Contour.lines(cl)
            pairs(line)
            pts = (D[:lift] ? 
                   [(x,y,interp(x,y)) for (x,y) in pairs(line)] :
                   pairs(line))
            push!(grlist,
                  Path(pts; pen =
                       Pen(color=AsyPlots.cmap(NamedColor.(D[:colors]),
                                               (L-m)/(M-m));penkwargs...)))
        end
    end
    Plot(grlist)
end
