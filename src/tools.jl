"""
    isinside(p::Point,pointlist::AbstractArray{Point,1})

Determine whether `p` is inside `pointlist`.

This function was copied from Luxor.jl. It is an
implementation of an algorithm due to Hormann and Agathos (2001)
"""
function isinside(p::Vec2,
                  pointlist::AbstractArray{Vec2, 1};
                  allowonedge::Bool=false)
    c = false
    @inbounds for counter in 1:length(pointlist)
        q1 = pointlist[counter]
        # if reached last point, set "next point" to first point
        if counter == length(pointlist)
            q2 = pointlist[1]
        else
            q2 = pointlist[counter + 1]
        end
        if q1 == p
            allowonedge || error("VertexException a")
            continue
        end
        if q2.y == p.y
            if q2.x == p.x
                allowonedge || error("VertexException b")
                continue
            elseif (q1.y == p.y) && ((q2.x > p.x) == (q1.x < p.x))
                allowonedge || error("EdgeException")
                continue
            end
        end
        if (q1.y < p.y) != (q2.y < p.y) # crossing
            if q1.x >= p.x
                if q2.x > p.x
                    c = !c
                elseif ((det3p(q1, q2, p) > 0) == (q2.y > q1.y))
                    c = !c
                end
            elseif q2.x > p.x
                if ((det3p(q1, q2, p) > 0) == (q2.y > q1.y))
                    c = !c
                end
            end
        end
    end
    return c
end

function det3p(q1::Vec2, q2::Vec2, p::Vec2)
    (q1.x - p.x) * (q2.y - p.y) - (q2.x - p.x) * (q1.y - p.y)
end

isinside(z::Complex,pointlist::Array{<:Complex,1};kwargs...) =
    isinside(Vec2(z),map(Vec2,pointlist);kwargs...)

"""
    distance(x,y,a,b,c,d)

Return the distance from the point (x,y) to the line
segment with endpoints (a,b) and (c,d)
"""
function distance(x,y,a,b,c,d)
    D = (a-c)^2 + (b-d)^2
    if D == 0
        return hypot(x-a,y-c)
    end
    # using SymPy
    # f = (x-a*t-c*(1-t))^2 + (y-b*t-d*(1-t))^2
    # solve(diff(f,t),t)
    t::Float64 = (-a*c + a*x - b*d + b*y + c^2 - c*x + d^2 - d*y) / D
    if t < 0
        t = 0.0
    elseif t > 1
        t = 1.0
    end
    hypot(x-(a*t+c*(1-t)),y-(b*t+d*(1-t)))
end

function distance(P::Vec2,A::Vec2,B::Vec2)
    return distance(P.x,P.y,A.x,A.y,B.x,B.y)
end

function distance(V::Vec2,path::Array{Vec2,1})
    minimum(distance(V,path[k],path[k+1]) for k=1:length(path)-1)
end

function iswellinside(V::Vec2,
                      pointlist::AbstractArray{Vec2, 1};
                      epsilon=1e-3);
    return distance(V,pointlist) > epsilon && isinside(V,pointlist)
end

# Path concatenation
function *(p::Union{Path3D,Path2D},q::Union{Path3D,Path2D})
    P = typeof(p)
    P ≠ typeof(q) && error("Can't mix 2D and 3D paths")
    k = endof(p.points) - (p.points[end] == q.points[1] ? 1 : 0)
    options = [getfield(p,f) for f in fieldnames(p)[2:end]]
    P(vcat(p.points[1:k],q.points),options...)
end

function axes(P)
    global _DEFAULT_PLOT2D_KWARGS
    D = deepcopy(_DEFAULT_PLOT2D_KWARGS)
    merge!(D,Dict(P.options))
    for s in [:xmin,:xmax,:ymin,:ymax]
        if D[s] == "-infinity"
            D[s] = -Inf
        elseif D[s] == "infinity"
            D[s] = Inf
        end
    end
    if D[:axisarrow] ≠ _DEFAULT_PLOT2D_KWARGS[:axisarrow]
        D[:xaxisarrow] = D[:axisarrow]
        D[:yaxisarrow] = D[:axisarrow]
    end
    bb = boundingbox(P)
    xmin, xmax, ymin, ymax = bb.xmin, bb.xmax, bb.ymin, bb.ymax
    if xmax < 0 xmax = 0 end
    if xmin > 0 xmin = 0 end
    if ymax < 0 ymax = 0 end
    if ymin > 0 ymin = 0 end

    if D[:xmax] <  Inf && xmax < D[:xmax] xmax = D[:xmax] end
    if D[:xmin] > -Inf && xmin > D[:xmin] xmin = D[:xmin] end
    if D[:ymax] <  Inf && ymax < D[:ymax] ymax = D[:ymax] end
    if D[:ymin] > -Inf && ymin < D[:ymin] ymin = D[:ymin] end

    xkwargs = [(:pen,D[:axispen]),(:arrow,D[:xaxisarrow])]
    ykwargs = [(:pen,D[:axispen]),(:arrow,D[:yaxisarrow])]
    width = xmax - xmin; height = ymax - ymin
    border = 0.025
    xmax += border*width; xmin -= border*width
    ymax += border*height; ymin -= border*height

    return [Path2D([xmin 0; xmax 0];xkwargs...),
            Path2D([0 ymin; 0 ymax];ykwargs...)]
end
