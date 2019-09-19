
# Isolines

```@example
using AsyPlots # hide
isolines(0.0:0.1:10, 0.0:0.1:10, (x,y) -> 1 - (x^2 - y^2)/10)
save("isolines.svg",ans) # hide
nothing # hide
```

![](isolines.svg)

```@example
using AsyPlots # hide
isolines(0.0:0.1:10, 0.0:0.1:10, (x,y) -> 1 - (x^2 - y^2)/10, lift = true)
save("isolines-lift.svg",ans) # hide
nothing # hide
```

![](isolines-lift.svg)

```@docs
isolines
```