
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
*(S::Transform,L::Label2D) =
        Label(L.s,S*L.location;otherargs(L)[3:end]...)

*(S::Transform,P::Plot2D) = Plot2D([S*e for e in P.elements],P.options)

struct TransformComposition <: Transform
    transforms::Vector{<:Transform}
end

*(S::TransformComposition, T::TransformComposition) =
    TransformComposition([S.transforms;T.transforms])

*(S::Transform,T::TransformComposition) =
    TransformComposition([S;T.transforms])

*(S::TransformComposition, T::Transform) =
    TransformComposition([S.transforms;T])

*(S::Transform,T::Transform) = TransformComposition([S,T])

*(T::TransformComposition, P::Plot2D) =
    foldr(*,[T.transforms;P])

*(T::TransformComposition, P::GraphicElement2D) =
    foldr(*,[T.transforms;P])


function fitsquare(P::Plot2D,ignoreaspect)
    bbox = AsyPlots.boundingbox(P)
    w,h = bbox.xmax-bbox.xmin, bbox.ymax-bbox.ymin
    S = ignoreaspect ? Scale(1/w,1/h) : Scale(1/w)
    S*(Shift(-bbox.xmin,-bbox.ymin)*P)
end

fitsquare(P::Plot2D;ignoreaspect=false) = fitsquare(P,ignoreaspect)

function layout(V::Vector{Plot2D};cols=isqrt(length(V)),
                                  ignoreaspect=false,
                                  margin=0.05,
                                  hmargin=margin,
                                  vmargin=margin)
    U = fitsquare.(V,false)
    push!(U[end].options,(:width,
            floor(Integer,(1+hmargin)*cols*Statistics.mean(
                       merge(_DEFAULT_PLOT2D_KWARGS,
                             Dict(P.options))[:width] for P in U))))
    sum([Shift(mod(i-1,cols)*(1+hmargin),
                    -(i-1)÷cols*(1+vmargin))*P for (i,P) in enumerate(U)])
end
