

# Graphing Functions

```@docs
plot
```

```@example
using AsyPlots # hide 
plot(x->sin(2π*x),(0,1),linewidth=2,axisarrow=Arrow())
```

```@example
using AsyPlots # hide 
plot((x,y)->exp(-x^2-y^2),(-2,2),(-2,2),xmax=2.5,ymax=2.5,zmax=1.5)
```

```@example
using AsyPlots # hide 
using SymPy
@vars x y
plot(x*y*sin(x*y/4),(x,0,2π),(y,0,2π))
```
