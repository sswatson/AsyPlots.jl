
struct BoundingBox
    xmin::Real
    xmax::Real
    ymin::Real
    ymax::Real
end

const colorplaces = [:r,:g,:b]

iterate(c::ColorTypes.RGB) = (getfield(c,first(colorplaces)),2)
iterate(c::ColorTypes.RGB,i) = i > 3 ? nothing : (getfield(c,colorplaces[i]),i+1)

iterate(c::NamedColor) = iterate(c.color)
iterate(c::NamedColor,i) = iterate(c.color,i)

+(P::Vec2,Q::Vec2) = Vec2(P.x+Q.x,P.y+Q.y)
-(Q::Vec2) = Vec2(-Q.x,-Q.y)
-(P::Vec2,Q::Vec2) = P + (-Q)
*(c::Real,P::Vec2) = Vec2(c*P.x,c*P.y)

function boundingbox(path::Union{Path2D,Polygon2D})
    # Coordinates are returned in the order xmin, xmax, ymax, ymin
    return BoundingBox(minimum(pt.x for pt in path.points),
                       maximum(pt.x for pt in path.points),
                       minimum(pt.y for pt in path.points),
                       maximum(pt.y for pt in path.points))
end

function boundingbox(c::Circle2D)
    return BoundingBox(c.center.x - c.radius,
                       c.center.x + c.radius,
                       c.center.y - c.radius,
                       c.center.y + c.radius)
end

function boundingbox(p::Point2D)
    return BoundingBox(p.P.x,p.P.x,p.P.y,p.P.y)
end

function boundingbox(A::Array{BoundingBox,1};border=0.05)
    a = minimum(bb.xmin for bb in A)
    b = maximum(bb.xmax for bb in A)
    c = maximum(bb.ymax for bb in A)
    d = minimum(bb.ymin for bb in A)
    if a == b || c == d
        error("Bounding box has empty interior")
    end
    margin = border*min(b-a,c-d)
    return BoundingBox(a - margin,
                       b + margin,
                       d - margin,
                       c + margin)
end

function isclip(G::GraphicElement)
    if isa(G,Circle2D) || isa(G,Polygon2D)
        G.clip
    else
        false
    end
end

function boundingbox(P::Plot2D;kwargs...)
    k = something(findlast(isclip,P.elements),1)
    boundingbox(map(boundingbox,P.elements[k:end]);kwargs...)
end

function boundingbox(P::PixelMap)
    BoundingBox(P.lowerleft[1],P.upperright[1],
                P.lowerleft[2],P.upperright[2])
end

function aspectratio(bb::BoundingBox)
    return (bb.xmax - bb.xmin)/(bb.ymax - bb.ymin)
end

function boundingbox(L::Label2D)
    return BoundingBox(L.location.x,
                       L.location.x,
                       L.location.y,
                       L.location.y)
end


lwcorrect(x) = x == 0 ? 0.7 : x

function arrowhead(P::Path2D,bb::BoundingBox)
    A,B = P.points[end-1:end]
    z = (B-A).x + im*((B-A).y)
    θ = angle(z)
    ψ = 16π/180
    l = 5e-3*P.arrow.size*min(bb.xmax-bb.xmin,bb.ymax-bb.ymin)
    arrowloc = P.arrow.position
    tip = A + arrowloc*(B-A)
    C = tip-l*Vec2(cos(θ+ψ),sin(θ+ψ))
    D = tip-l*Vec2(cos(θ-ψ),sin(θ-ψ))
    return Polygon2D([tip,C,D,tip],
                      pen=NoPen(),
                      fillpen=P.pen)
end

# Note: more Cairo functionality moved to __init__ function in init.jl
