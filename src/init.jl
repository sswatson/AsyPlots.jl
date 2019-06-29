function __init__()
    
    Requires.@require Cairo="159f3aea-2a34-519c-b102-8c37f9878175" begin
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
                addtocontext!(cr,Pl,arrowhead(P,bb),bb)
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
                Cairo.set_source_rgba(cr,(:bgcolor in keys(Dict(Pl.options)) ?
                                      Dict(Pl.options)[:bgcolor].color :
                                      _DEFAULT_PLOT2D_KWARGS[:bgcolor].color)...,1)
                Cairo.fill(cr)
            end
            Cairo.set_line_width(cr,lwcorrect(P.pen.linewidth))
            Cairo.move_to(cr,P.points[1].x,P.points[1].y);
            for i=2:length(P.points)
                Cairo.line_to(cr,P.points[i].x,P.points[i].y);
            end
            Cairo.close_path(cr)
            if !is_no_pen(P.fillpen)
                Cairo.set_source_rgba(cr,P.fillpen.color...,P.fillpen.opacity)
                if !is_no_pen(P.pen)
                    Cairo.fill_preserve(cr)
                else
                    Cairo.fill(cr)
                end
            end
            if !is_no_pen(P.pen)
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
            if !(bbox == false)
                bb = boundingbox([bb,bbox])
            end
            asp_ratio = aspectratio(bb)
            # height should be even, for ffmpeg:
            height = 2*round(Int,2*asp_ratio\width)
            bufferdata = UInt8[]
            iobuffer = IOBuffer(bufferdata,read=true,write=true)
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

    end

    Requires.@require SymPy="24249f21-da20-56a4-8eb1-6a02cf4ae2e6" begin
        function plot(S::SymPy.Sym,
                      t::Tuple{SymPy.Sym,U,V} where U<:Real where V<:Real;
                      kwargs...)
            plot(SymPy.lambdify(S,t[1:1]),t[2],t[3];kwargs...)
        end
        
        function plot(L::Vector,
                      t::Tuple{SymPy.Sym,U,V} where U<:Real where V<:Real;
                      kwargs...)
            plot([SymPy.lambdify(e,t[1:1]) for e in L],t[2],t[3];kwargs...)
        end
        
        function plot(L::Vector,x::SymPy.Sym,a::Real,b::Real;kwargs...)
            plot(L,(x,a,b);kwargs...)
        end

        SR = Union{Real,SymPy.Sym}

        plot(S::SymPy.Sym,
             a::SR,
             b::SR,
             c::SR,
             d::SR;
             kwargs...)  =
                 plot(SymPy.lambdify(S),map(SymPy.N,(a,b,c,d))...;kwargs...)
        
        plot(S::SymPy.Sym,
             x::Tuple{<:SR,<:SR},
             y::Tuple{<:SR,<:SR};kwargs...) = plot(f,x...,y...;kwargs...)
        
        plot(S::SymPy.Sym,
             x::Tuple{SymPy.Sym,<:SR,<:SR},
             y::Tuple{SymPy.Sym,<:SR,<:SR};kwargs...) =
                 plot(SymPy.lambdify(S,[x[1],y[1]]),x[2:end]...,y[2:end]...;kwargs...)

    end
    
    Requires.@require Juno="e5e0dc1b-0480-54bc-9374-aad01c23163d" begin
        
        _JUNO_ASY_FORMAT = "svg"
        _JUNO_CAIRO_FORMAT = "png"
        _FIT_DIMENSION = "height"

        """
            fitheight()

        Set the figures appearing in the Juno plot
        pane to match its height
        """
        fitheight() = (global _FIT_DIMENSION; _FIT_DIMENSION = "height")
        """
            fitwidth()

        Set the figures appearing in the Juno plot
        pane to match its width
        """
        fitwidth() = (global _FIT_DIMENSION; _FIT_DIMENSION = "width")

        """
            junosvg()

        Set the default output format for the Juno
        plot pane to svg
        """
        function junosvg()
            global _JUNO_ASY_FORMAT
            global _JUNO_CAIRO_FORMAT
            _JUNO_ASY_FORMAT = "svg"
            _JUNO_CAIRO_FORMAT = "svg"
        end
        """
            junopng()

        Set the default output format for the Juno
        plot pane to png
        """
        function junopng()
            global _JUNO_ASY_FORMAT
            global _JUNO_CAIRO_FORMAT
            _JUNO_ASY_FORMAT = "png"
            _JUNO_CAIRO_FORMAT = "png"
        end

        """
            junodefault()

        Reset the default output formats for the Juno
        plot pane
        """
        function junodefault()
            global _JUNO_ASY_FORMAT
            global _JUNO_CAIRO_FORMAT
            _JUNO_ASY_FORMAT = "svg"
            _JUNO_CAIRO_FORMAT = "png"
        end

        import Hiccup, Media
        Media.media(Plot2D,Media.Plot)
        Media.media(Plot3D,Media.Plot)

        function Juno.render(pane::Juno.PlotPane,P::Plot2D)
            global _BACKEND
            global _JUNO_ASY_FORMAT
            global _JUNO_CAIRO_FORMAT
            global _FIT_DIMENSION
            tempdir = mktempdir()
            w,h = Juno.plotsize()
            fitdim = _FIT_DIMENSION
            dimarg = (Symbol(fitdim) => (fitdim == "height" ? h : w),)
            if _BACKEND == "asy"
                filename = "$tempdir/myplot.$_JUNO_ASY_FORMAT"
                save(filename,P)
                D = Dict{Symbol,Any}(P.options)
                Juno.render(pane,Hiccup.div(
                    style="text-align:center",
                    Hiccup.img(src="$tempdir/myplot.$_JUNO_ASY_FORMAT";
                               dimarg...)))
            else
                save("$tempdir/myplot.$_JUNO_CAIRO_FORMAT",P)
                Juno.render(pane,Hiccup.div(
                    style="text-align:center",
                    Hiccup.img(src="$tempdir/myplot.$_JUNO_CAIRO_FORMAT";
                               dimarg...)))
            end
        end

        function Juno.render(pane::Juno.PlotPane,P::Plot3D)
            global _BACKEND
            if _BACKEND == "cairo"
                return
            end
            w,h = Juno.plotsize()
            tempdir = mktempdir()
            filename = "$tempdir/myplot.png"
            save(filename,P)
            Juno.render(pane,Hiccup.div(style="text-align:center",
                                        Hiccup.img(height=h,src="$tempdir/myplot.png")))
        end
    end
end
