
struct BoundingBox
    xmin::Real
    xmax::Real
    ymin::Real
    ymax::Real
end

const colorplaces = [:r,:g,:b]
import Base.iterate
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
    k = max(1,findlast(isclip,P.elements))
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

function addtocontext!(cr::Cairo.CairoContext,
                       Pl::Plot2D,
                       P::Path2D,
                       bb::BoundingBox)
    Cairo.set_line_width(cr,lwcorrect(P.pen.linewidth))
    Cairo.move_to(cr,P.points[1].x,P.points[1].y);
    for i=2:length(P.points)-1
        Cairo.line_to(cr,P.points[i].x,P.points[i].y);
    end
    if P.arrow.name ≠ "None"
        arrowlength = 0.005*P.arrow.size
        p = arrowlength/abs(P.points[end-1]-P.points[end])
        lastpoint = p*(P.points[end-1]) + (1-p)*P.points[end]
        Cairo.line_to(cr,lastpoint.x,lastpoint.y)
    else
        Cairo.line_to(cr,P.points[end].x,P.points[end].y)
    end
    Cairo.set_source_rgba(cr,P.pen.color...,P.pen.opacity)
    Cairo.stroke(cr)
    if P.arrow.name ≠ "None"
        addtocontext!(cr,arrowhead(P,bb),bb)
    end
end

function addtocontext!(cr::Cairo.CairoContext,
                       Pl::Plot2D,
                       P::Polygon2D,
                       bb::BoundingBox)
    if is_no_pen(P.fillpen) && is_no_pen(P.pen) && !P.clip
        return nothing
    end
    if P.clip
        Cairo.move_to(cr,P.points[1].x,P.points[1].y);
        for i=2:length(P.points)
            Cairo.line_to(cr,P.points[i].x,P.points[i].y);
        end
        Cairo.move_to(cr,bb.xmin,bb.ymin)
        if counterclockwise(P)
            Cairo.line_to(cr,bb.xmin,bb.ymax)
            Cairo.line_to(cr,bb.xmax,bb.ymax)
            Cairo.line_to(cr,bb.xmax,bb.ymin)
        else
            Cairo.line_to(cr,bb.xmax,bb.ymin)
            Cairo.line_to(cr,bb.xmax,bb.ymax)
            Cairo.line_to(cr,bb.xmin,bb.ymax)
        end
        Cairo.close_path(cr)
        Cairo.set_source_rgba(cr,Dict(Pl.options)[:bgcolor].color...,1)
        Cairo.fill(cr)
    end
    Cairo.set_line_width(cr,lwcorrect(P.pen.linewidth))
    Cairo.move_to(cr,P.points[1].x,P.points[1].y);
    for i=2:length(P.points)
        Cairo.line_to(cr,P.points[i].x,P.points[i].y);
    end
    Cairo.close_path(cr)
    if ~is_no_pen(P.fillpen)
        Cairo.set_source_rgba(cr,P.fillpen.color...,P.fillpen.opacity)
        if ~is_no_pen(P.pen)
            Cairo.fill_preserve(cr)
        else
            Cairo.fill(cr)
        end
    end
    if ~is_no_pen(P.pen)
        Cairo.set_source_rgba(cr,P.pen.color...,P.pen.opacity)
        Cairo.stroke(cr)
    end
end

function addtocontext!(cr::Cairo.CairoContext,
                       Pl::Plot2D,
                       c::Circle2D,
                       bb::BoundingBox)
    if c.clip
        Cairo.arc(cr, c.center.x, c.center.y, c.radius, 0, 2*pi)
        Cairo.move_to(cr,bb.xmin,bb.ymin)
        Cairo.line_to(cr,bb.xmin,bb.ymax)
        Cairo.line_to(cr,bb.xmax,bb.ymax)
        Cairo.line_to(cr,bb.xmax,bb.ymin)
        Cairo.close_path(cr)
        Cairo.set_source_rgba(cr,Dict(Pl.options)[:bgcolor].color...,1)
        Cairo.fill(cr)
    end

    Cairo.set_line_width(cr,lwcorrect(c.pen.linewidth))
    Cairo.arc(cr, c.center.x, c.center.y, c.radius, 0, 2*pi)

    if c.fillpen.other ≠ "NoPen"
        Cairo.set_source_rgba(cr,c.fillpen.color...,c.fillpen.opacity)
        Cairo.fill_preserve(cr)
    end

    Cairo.set_source_rgba(cr,c.pen.color...,c.pen.opacity)
    Cairo.stroke(cr)
end

function addtocontext!(cr::Cairo.CairoContext,
                       Pl::Plot2D,
                       p::Point2D,
                       bb::BoundingBox)
    m = min(bb.xmax-bb.xmin,bb.ymax-bb.ymin)
    lw = p.pen.linewidth == 0 ? 3 : p.pen.linewidth
    Cairo.arc(cr,p.P.x,p.P.y,0.003*m*lw,0,2π)
    Cairo.set_source_rgb(cr,p.pen.color...)
    Cairo.fill(cr)
end

function addtocontext!(cr::Cairo.CairoContext,
                       Pl::Plot2D,
                       L::Label2D,
                       bb::BoundingBox)
    Cairo.save(cr)
    m = min(bb.xmax-bb.xmin,bb.ymax-bb.ymin)
    Cairo.set_font_size(cr,2.5e-3*m*L.pen.fontsize)
    Cairo.set_source_rgb(cr,L.pen.color...)
    x_bearing, y_bearing, width, height =
                        Cairo.text_extents(cr,L.s)
    Cairo.move_to(cr,L.location.x - width/2 - x_bearing,
                     L.location.y + height/2 + y_bearing)
    Cairo.scale(cr,1,-1)
    Cairo.show_text(cr,L.s)
    Cairo.stroke(cr)
    Cairo.restore(cr)
end

function addtocontext!(cr::Cairo.CairoContext,
                       Pl::Plot2D,
                       P::PixelMap,
                       bb::BoundingBox)
    m,n = size(P.pixels)
    a,b = P.lowerleft
    c,d = P.upperright
    for i=0:m-1
        for j=0:n-1
            Cairo.rectangle(cr,a+(c-a)*i/m,b+(d-b)*j/n,(c-a)/m,(d-b)/n)
            Cairo.set_source_rgba(cr,P.pixels[i+1,j+1].color...,P.alpha[i+1,j+1])
            Cairo.fill(cr)
        end
    end
end

function bytes(P::Plot2D;format=:png,bbox=false,border=3)
    global _DEFAULT_PLOT2D_KWARGS
    D = Dict{Symbol,Any}(P.options)
    if :axes in keys(D) && D[:axes]
        P = Plot2D([axes(P);P.elements],P.options)
    end
    if :bgcolor in keys(D) && isa(D[:bgcolor],AbstractString)
        D[:bgcolor] = NamedColor(D[:bgcolor])
    end
    width = :width in keys(D) ? D[:width] : _DEFAULT_WIDTH
    border_fraction = 3*border/width
    bb = boundingbox(P,border=border_fraction)
    if ~(bbox == false)
        bb = boundingbox([bb,bbox])
    end
    asp_ratio = aspectratio(bb)
    # height should be even, for ffmpeg:
    height = 2*round(Int,(2*asp_ratio)\width)
    bufferdata = UInt8[]
    iobuffer = IOBuffer(bufferdata,true,true)
    if format == :png
        surface = Cairo.CairoARGBSurface(width,height)
    elseif format == :pdf
        surface = Cairo.CairoPDFSurface(iobuffer,width,height)
    elseif format == :eps
        surface = Cairo.CairoEPSSurface(iobuffer,width,height)
    elseif format == :svg
        surface = Cairo.CairoSVGSurface(iobuffer,width,height)
    else
        error("format should be png, pdf, eps, or svg")
    end
    context = Cairo.CairoContext(surface)
    Cairo.scale(context,width/(bb.xmax-bb.xmin),-height/(bb.ymax-bb.ymin))
    Cairo.translate(context,-bb.xmin,-bb.ymax)
    if :bgcolor in keys(D)
        Cairo.set_source_rgb(context,D[:bgcolor].color...)
    else
        Cairo.set_source_rgb(context,1,1,1)
    end
    Cairo.paint(context)
    Cairo.set_line_width(context,1)
    Cairo.set_line_join(context, Cairo.Cairo.CAIRO_LINE_JOIN_ROUND)
    for e in P.elements
        addtocontext!(context,P,e,bb)
    end
    if format == :png
        Cairo.write_to_png(surface,iobuffer)
    end
    Cairo.finish(surface)
    Cairo.destroy(surface)
    return bufferdata
end
