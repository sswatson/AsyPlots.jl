

# Graphing Functions

```@docs
plot
```

```@example
using AsyPlots # hide
plot(x->sin(2π*x),(0,1),linewidth=2,axisarrow=Arrow())
save("sineplot.svg",ans) # hide
nothing # hide
```

![](sineplot.svg)

```@example
using AsyPlots # hide
plot((x,y)->exp(-x^2-y^2),(-2,2),(-2,2),xmax=2.5,ymax=2.5,zmax=1.1)
save("gaussianplot.svg",ans) # hide
nothing # hide
```

![](gaussianplot.svg)

```@example
using AsyPlots # hide
using SymPy
@vars x y
plot(x*y*sin(x*y/4),(x,0,2π),(y,0,2π))
save("wave.svg",plot(x*y*sin(x*y/4),(x,0,2π),(y,0,2π),width=250)) # hide
nothing # hide
```

![](wave.svg)
