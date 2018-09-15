
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
                 rate=10)
    bb = boundingbox(map(boundingbox,plots))
    e = ceil(Integer,log10(length(plots)))+1
    N = 10^e
    tempdir = mktempdir()
    ProgressMeter.@showprogress for (i,P) in enumerate(plots)
        framename = "$tempdir/frame$(string(N+i-1)[2:end]).png"
        save(framename,P,bbox=bb)
    end
    run(`ffmpeg -r $rate -i $tempdir/frame%0$(e)d.png -pix_fmt yuv420p $tempdir/mymovie.mp4`)
    if filename ≠ ""
        cp("$tempdir/mymovie.mp4",filename;force=true)
    else
        try
            if Sys.isapple()
                run(`open $tempdir/mymovie.mp4`)
            elseif Sys.islinux() || Sys.isbsd()
                run(`xdg-open $tempdir/mymovie.mp4`)
            elseif Sys.iswindows()
                run(`start $tempdir/mymovie.mp4`)
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
