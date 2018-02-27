
function check_asy_present()
    global _HAVE_ASY
    if ~_HAVE_ASY
        error("3D Output not available with Cairo backend")
    end
end

extension(f) = split(f,'.')[end]
sans_extension(f) = join(split(f,'.')[1:end-1],'.')

"""
    save(filename::AbstractString,
         P::Union{Plot2D,Plot3D};
         runasy=true,
         forcepdf=false)

Save Asymptote figure. If `filename` has extension `.asy`, then
an asy file is saved together with any auxiliary data files.

If `filename` has extension `.pdf`, `.svg` or `.png`, then
only the resulting image file is saved to the location `filename`
"""
function save(filename::AbstractString,
              P::Union{Plot2D,Plot3D};
              runasy=true,
              forcepdf=false,
              bbox=false)
    global _BACKEND
    if ~any(endswith(filename,ext) for ext in (".asy",".pdf",".svg",".png"))
        error("Extension should be asy, pdf, svg, or png")
    end
    if _BACKEND == "asy"
        if endswith(filename,".asy")
            check_asy_present()
            if forcepdf
                Q = deepcopy(P)
                filter!(p -> first(p) ≠ :pdf, Q.options)
                push!(Q.options,(:pdf,true))
            else
                Q = P
            end
            if ~(bbox == false)
                Q += Plot(box(bbox.xmin,bb.max,bb.ymin,bb.ymax;other=invisible))
            end
            S = AsyString(Q)
            write(filename,S.str)
            directory = dirname(filename)
            if directory == ""
                directory = "."
            end
            for (k,v) in S.data
                writecsv("$directory/$k",v)
            end
            if runasy
                originaldir = pwd()
                try
                    cd(directory)
                    run(`asy $(basename(filename))`)
                finally
                    cd(originaldir)
                end
            end
        else
            tempdir = mktempdir()
            asyfile = "$tempdir/myplot.asy"
            pdffile = "$tempdir/myplot.pdf"
            runasy = ~endswith(filename,".asy")
            save(asyfile,P;runasy=runasy,forcepdf=true)
            if endswith(filename,".asy")
                mv(asyfile,filename,remove_destination=true)
            elseif endswith(filename,".pdf")
                mv(pdffile,filename,remove_destination=true)
            elseif endswith(filename,".png")
                global _DEFAULT_WIDTH
                D = Dict(P.options)
                width = :width in keys(D) ? D[:width] : _DEFAULT_WIDTH
                base = sans_extension(filename)
                run(`pdftoppm -png -r $width -singlefile $pdffile $base`)
            elseif endswith(filename,".svg")
                run(`pdf2svg $tempdir/myplot.pdf $filename`)
            end
        end
    else
        if isa(P,Plot3D)
            error("3D output not supported with Cairo backend")
        end
        D = Dict(P.options)
        border = (:border in keys(D) ? D[:border]
                        : _DEFAULT_PLOT2D_KWARGS[:border])
        bufferdata = bytes(P;format=Symbol(extension(filename)),
                             bbox=bbox,
                             border=border)
        write(filename,bufferdata)
    end
end

save(S::GraphicElement;kwargs...) = save(Plot([S],kwargs))

Base.mimewritable(::MIME"image/svg+xml",P::Plot2D) = true
Base.mimewritable(::MIME"image/png", P::Plot2D) = true

function Base.show(io::IO, ::MIME"image/svg+xml", P::Plot2D)
    global _BACKEND
    if _BACKEND == "asy"
        directory = mktempdir()
        filename = "$directory/myplot.svg"
        save(filename, P)
        write(io, read("$directory/myplot.svg"))
    else
        D = Dict(P.options)
        border = (:border in keys(D) ? D[:border]
                        : _DEFAULT_PLOT2D_KWARGS[:border])
        write(io,bytes(P;format=:svg,border=border))
    end
end

function Base.show(io::IO, ::MIME"image/png", P::Plot2D)
    global _BACKEND
    if _BACKEND == "asy"
        directory = mktempdir()
        filename = "$directory/myplot.png"
        save(filename, P)
        write(io, read("$directory/myplot.png"))
    elseif _BACKEND == "cairo"
        D = Dict(P.options)
        border = (:border in keys(D) ? D[:border]
                        : _DEFAULT_PLOT2D_KWARGS[:border])
        write(io,bytes(P;format=:png,border=border))
    end
end

function Base.show(io::IO, ::MIME"image/svg+xml", P::Plot3D)
    global _HAVE_ASY
    if ~_HAVE_ASY
        l = length(P.elements)
        show(io,"""Plot3D(<$(l)element$(l == 1 ? "" : "s")>)""")
        return
    end
    tempdir = mktempdir()
    filename = "$tempdir/myplot.svg"
    save(filename, P)
    write(io, read("$tempdir/myplot.svg"))
end

function Base.show(io::IO, ::MIME"image/png", P::Plot3D)
    global _HAVE_ASY
    if ~_HAVE_ASY
        l = length(P.elements)
        show(io,"""Plot3D(<$(l)element$(l == 1 ? "" : "s")>)""")
        return
    end
    tempdir = mktempdir()
    filename = "$tempdir/myplot.png"
    save(filename, P)
    write(io, read("$tempdir/myplot.png"))
end

_is_ijulia() = isdefined(Main, :IJulia) && Main.IJulia.inited
_is_juno()   = isdefined(Main, :Juno) && Main.Juno.isactive()

function Base.show(io::IO,::MIME"text/plain",P::Plot)
    global _SHOW_PLOTS
    if _SHOW_PLOTS && !_is_ijulia() && !_is_juno() && isdefined(Base, :active_repl)
        tempdir = mktempdir()
        filename = "$tempdir/myplot.pdf"
        save(filename,P)
        try
            if is_apple()
                run(`open $filename`)
            elseif is_linux() || is_bsd()
                run(`xdg-open $filename`)
            elseif is_windows()
                run(`start $filename`)
            end
        catch e
            error(string(
            "Failed to show the generated pdf.",
            "Run `showplots(false)` to stop trying to show pdfs.\n",
                "Error: "), sprint(Base.showerror, e))
        end
    else
        n = length(P.elements)
        s = n == 1 ? "" : "s"
        print(io,"$(split(typeof(P),".")[end])(<$n elements>)")
    end
end

Requires.@require Juno begin

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
            D = Dict(P.options)
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

Requires.@require Contour begin
    function Path2D(curve::Contour.Curve2{Float64};kwargs...)
        cv = curve.vertices
        return Path2D(hcat(Float64[cv[k][1] for k=1:length(cv)],
                           Float64[cv[k][2] for k=1:length(cv)]);kwargs...)
    end
end
