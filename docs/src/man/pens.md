
# Pens and Arrows

## Pens

Colors are stored in a `NamedColor`.

```@docs
NamedColor
```

The second argument may be omitted, in which case `Colors.parse` is used to map the specified string to an appropriate RGB triple. The `RGB` triple is used for the Cairo backend, while only the `name` is passed to Asymptote (unless `name == ""`, in which case the RGB triple is used). Both Asymptote and `Colors.jl` will correctly handle the [X11 named colors](https://en.wikipedia.org/wiki/X11_color_names).

Options for plotting (color, line width, opacity, and font size) are specified using a `Pen` object.

```@docs
Pen
```

The function `NoPen()` returns a pen which specifies no drawing. This may be used, for example, as the `fillpen` for a polygon which should not be filled in.

# Arrows

Each `Path2D` or `Path3D` object has an `arrow` field for specifying how an arrow should be drawn on the path. A default arrow in 2D/3D can be created using `Arrow()`/`Arrow3()`. 

```@docs
Arrow
```
