

"""
    histogram(data::Vector;
              bincount=30,
              bins=range(minimum(data),stop=maximum(data),length=bincount),
              xlabel="",
              ylabel="",
              title="",
              pen=Pen(color=NamedColor("MidnightBlue"),opacity=0.3))

Make a histogram of `data`
"""
function histogram(data::Vector;
                   bincount=30,
                   bins=range(minimum(data),stop=maximum(data),length=bincount),
                   xlabel="",
                   ylabel="",
                   title="",
                   pen=Pen(color=NamedColor("MidnightBlue"),opacity=0.3))
    w = length(bins)-1
    tallies = zeros(Int64,w)
    for x in data
        tallies[min(w,floor(Integer,(x - bins[1])÷step(bins))+1)] += 1
    end
    axes = RawString("""
           xaxis($(enclosequote(xlabel)),BottomTop,LeftTicks);
           yaxis($(enclosequote(ylabel)),LeftRight,RightTicks);
           """)
    titlelist = GraphicElement[]
    if title ≠ ""
        push!(titlelist,
            Label(title,(mean([bins[1],bins[end]]),1.05*maximum(tallies)),fontsize=16))
    end
    Plot([[box(bins[i],0,bins[i+1],tallies[i];
              fillpen=pen) for i=1:w];
              [axes];titlelist];
              ignoreaspect=true)
end

"""
    piechart(labels,frequencies; title="")

- `labels`: a vector of strings
- `frequencies`: a vector of `Real`s

Return a piechart with each sector i labeled `labels[i]`
and having central angle proportional to `frequencies[i]`
"""
function piechart(labels,frequencies; title="")
    if length(labels) ≠ length(frequencies)
        error("Labels and frequencies should have the same length")
    end
    angles = [[0];cumsum(2π*frequencies/sum(frequencies))]
    fontsizes = [min(12,round(Integer;digits=50*(angles[i+1]-angles[i]))) for i=1:length(angles)-1]
    Random.seed!(1)
    sectors = [sector(1,angles[i],angles[i+1];
                      fillpen=Pen(color=ColorTypes.RGB(rand(),rand(),rand()),opacity=0.4))
               for i=1:length(angles)-1]
    text = [Label("$(labels[i]) ($(string(frequencies[i])))",(1+fontsizes[i]/60)*cis(mean([angles[i],angles[i+1]]));
                  fontsize=fontsizes[i]) for i=1:length(angles)-1]
    if title == ""
        return Plot(sectors) + Plot(text;width=512)
    else
        return Plot(sectors) + Plot(text) + Plot(Label(title,(0,1.4));width=512)
    end
end

function sector(r,θ1,θ2;kwargs...)
    arc = [r*cis(θ) for θ=linspace(θ1,θ2,500)[2:end-1]]
    vee = [r*cis(θ2),0,r*cis(θ1)]
    Polygon(vcat(arc,vee);kwargs...)
end
