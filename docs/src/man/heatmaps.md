
# Heatmaps

```@docs
PixelMap
heatmap
```

```@example
using AsyPlots # hide
heatmap(1:10, 1:10, (x,y) -> x^2 + y^2, smooth = true)
save("heatmap.png", ans) # hide
nothing # hide
```

![fgf](heatmap.png)