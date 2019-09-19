
"""
    animate(filename::AbstractString,
            plots::Vector{Plot2D};
            rate=10)

    animate(plots::Vector{Plot2D};rate=10)

Make an `.mp4` video from `plots`, with frame rate `rate`

If "filename" is given, the movie file will be stored there.
Otherwise, the movie will be opened.

# Example
```julia
X = cumsum(randn(100000))
Y = cumsum(randn(100000))
plots = [Plot(Path(X[1:t],Y[1:t])) for t=10:10:10000]
animate(plots)
```
"""
function animate(filename::AbstractString,
                 plots::Vector{Plot2D};
                 rate=6,
                 density=400,
                 quality=100,
                 loop=1, 
                 format=:gif)
    bb = boundingbox(map(boundingbox,plots))
    e = ceil(Integer,log10(length(plots)))+1
    N = 10^e
    tempdir = mktempdir()
    framenames = []
    ProgressMeter.@showprogress for (i,P) in enumerate(plots)
        ext = format == :gif ? "pdf" : "png"
        framename = "$tempdir/frame$(string(N+i-1)[2:end]).$ext"
        push!(framenames,framename)
        save(framename,P,bbox=bb)
    end
    if format == :mp4
        clipname = "mymovie.mp4"
        run(`ffmpeg -r $rate -i $tempdir/frame%0$(e)d.png -pix_fmt yuv420p $tempdir/$clipname`)
    elseif format == :gif
        clipname = "myanimated.gif"
        run(`convert -delay $rate -density $density -quality $quality -loop $loop $framenames $tempdir/$clipname`)
    else
        error("available formats are :mp4 and :gif")
    end
    if filename ≠ ""
        cp("$tempdir/$clipname",filename;force=true)
    else
        try
            if Sys.isapple()
                run(`open $tempdir/$clipname`)
            elseif Sys.islinux() || Sys.isbsd()
                run(`xdg-open $tempdir/$clipname`)
            elseif Sys.iswindows()
                run(`start $tempdir/$clipname`)
            end
        catch e
            error(string(
            "Failed to open the movie file.",
                "Error: "), sprint(Base.showerror, e))
        end
    end
end

animate(plots::Vector{Plot2D};kwargs...) =
                                animate("",plots;kwargs...)
