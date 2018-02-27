
abstract type Transform end

function otherargs(P)
    return [(k,getfield(P,k)) for k in fieldnames(typeof(P))]
end

struct Shift2D <: Transform
    x::Real
    y::Real
end
Shift(x,y) = Shift2D(x,y)
*(S::Shift2D,V::Vec2) = Vec2(V.x + S.x, V.y + S.y)

struct Scale2D <: Transform
    x::Real
    y::Real
end
Scale(x,y) = Scale2D(x,y)
Scale(x) = Scale(x,x)
*(S::Scale2D,V::Vec2) = Vec2(V.x * S.x, V.y * S.y)
*(S::Scale2D,C::Circle2D) =
        Circle(S*C.center,S.x*C.radius;otherargs(C)[3:end]...)

*(S::Transform,P::Point2D) = Point(S*P.P;otherargs(P)[2:end]...)
*(S::Transform,P::Path2D) =
        Path([S*v for v in P.points];otherargs(P)[2:end]...)
*(S::Transform,P::Polygon2D) =
        Polygon([S*v for v in P.points];otherargs(P)[2:end]...)
*(S::Transform,C::Circle2D) =
        Circle(S*C.center,C.radius;otherargs(C)[3:end]...)

*(S::Transform,P::Plot2D) = Plot2D([S*e for e in P.elements],P.options)
