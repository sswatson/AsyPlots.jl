
function check_asy_present()
    global _HAVE_ASY
    if !_HAVE_ASY
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
    if !any(endswith(filename,ext) for ext in (".asy",".pdf",".svg",".png"))
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
            if bbox ≠ false
                Q += Plot(box(bbox.xmin,bb.max,bb.ymin,bb.ymax;other=invisible))
            end
            S = AsyString(Q)
            write(filename,S.str)
            directory = dirname(filename)
            if directory == ""
                directory = "."
            end
            for (k,v) in S.data
                DelimitedFiles.writedlm("$directory/$k",v,',')
            end
            if runasy
                originaldir = pwd()
                try
                    cd(directory)
                    run(`asy -nosafe $(basename(filename))`)
                finally
                    cd(originaldir)
                end
            end
        else
            tempdir = mktempdir()
            asyfile = "$tempdir/myplot.asy"
            pdffile = "$tempdir/myplot.pdf"
            runasy = !endswith(filename,".asy")
            save(asyfile,P;runasy=runasy,forcepdf=true)
            if endswith(filename,".asy")
                mv(asyfile,filename,force=true)
            elseif endswith(filename,".pdf")
                mv(pdffile,filename,force=true)
            elseif endswith(filename,".png")
                global _DEFAULT_WIDTH
                D = Dict{Symbol,Any}(P.options)
                width = :width in keys(D) ? D[:width] : _DEFAULT_WIDTH
                base = sans_extension(filename)
                run(`pdftoppm -png -scale-to-x $width -scale-to-y
                                        -1 -singlefile $pdffile $base`)
            elseif endswith(filename,".svg")
                run(`pdf2svg $tempdir/myplot.pdf $filename`)
            end
        end
    else
        if isa(P,Plot3D)
            error("3D output not supported with Cairo backend")
        end
        D = Dict{Symbol,Any}(P.options)
        border = (:border in keys(D) ? D[:border]
                        : _DEFAULT_PLOT2D_KWARGS[:border])
        bufferdata = bytes(P;format=Symbol(extension(filename)),
                             bbox=bbox,
                             border=border)
        write(filename,bufferdata)
    end
end

save(S::GraphicElement;kwargs...) = save(Plot([S],kwargs))

function save(P::Union{Plot2D,Plot3D},
              filename::AbstractString; kwargs...)
    @warn "file name should be the first argument to save"
    save(filename, P; kwargs...)
end

_SHOW_PLOTS = true
function showplots(b::Bool)
    global _SHOW_PLOTS
    _SHOW_PLOTS = b
    """Plot display turned $(b ? "on" : "off")"""
end

Base.showable(::MIME"image/svg+xml",P::Plot2D) = true
Base.showable(::MIME"image/svg+xml",P::Plot3D) = false
Base.showable(::MIME"image/png",P::Plot2D) = true

function png()
    @eval Base.showable(::MIME"image/svg+xml",P::Plot2D) = false
    @eval Base.showable(::MIME"image/svg+xml",P::Plot3D) = false
    "Turning svg display off"
end

function svg()
    @eval Base.showable(::MIME"image/svg+xml",P::Plot2D) = true
    @eval Base.showable(::MIME"image/svg+xml",P::Plot3D) = true
    "Turning svg display on"
end

function Base.show(io::IO, ::MIME"image/svg+xml", P::Plot2D)
    if length(P.elements) == 0
        return nothing
    end
    global _BACKEND
    if _BACKEND == "asy"
        directory = mktempdir()
        filename = "$directory/myplot.svg"
        save(filename, P)
        write(io, read("$directory/myplot.svg"))
    else
        D = Dict{Symbol,Any}(P.options)
        border = (:border in keys(D) ? D[:border]
                        : _DEFAULT_PLOT2D_KWARGS[:border])
        write(io,bytes(P;format=:svg,border=border))
    end
end

function Base.show(io::IO, ::MIME"image/png", P::Plot2D)
    if length(P.elements) == 0
        return nothing
    end
    global _BACKEND
    if _BACKEND == "asy"
        directory = mktempdir()
        filename = "$directory/myplot.png"
        save(filename, P)
        write(io, read("$directory/myplot.png"))
    elseif _BACKEND == "cairo"
        D = Dict{Symbol,Any}(P.options)
        border = (:border in keys(D) ? D[:border]
                        : _DEFAULT_PLOT2D_KWARGS[:border])
        write(io,bytes(P;format=:png,border=border))
    end
end


function Base.show(io::IO, ::MIME"image/svg+xml", P::Plot3D)
    if length(P.elements) == 0
        return
    end
    global _HAVE_ASY
    if !_HAVE_ASY
        l = length(P.elements)
        show(io,"""Plot3D(<$(l)element$(l == 1 ? "" : "s")>)""")
        return
    end
    tempdir = mktempdir()
    filename = "$tempdir/myplot.svg"
    save(filename, P)
    write(io,read(filename))
    write("/Users/sswatson/Desktop/otherstuff.svg",read(filename))
end


function Base.show(io::IO, ::MIME"image/png", P::Plot3D)
    if length(P.elements) == 0
        return nothing
    end
    global _HAVE_ASY
    if !_HAVE_ASY
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
    if length(P.elements) == 0
        return nothing
    end
    global _SHOW_PLOTS
    if _SHOW_PLOTS && !_is_ijulia() && !_is_juno() && isdefined(Base, :active_repl)
        tempdir = mktempdir()
        filename = "$tempdir/myplot.pdf"
        save(filename,P)
        try
            if Sys.isapple()
                run(`open $filename`)
            elseif Sys.islinux() || is_bsd()
                run(`xdg-open $filename`)
            elseif Sys.iswindows()
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
        print(io,"$(split(string(typeof(P)),".")[end])(<$n elements>)")
    end
end


