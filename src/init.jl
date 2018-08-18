function __init__()

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
