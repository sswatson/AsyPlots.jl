var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#AsyPlots.jl-1",
    "page": "Home",
    "title": "AsyPlots.jl",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Introduction-1",
    "page": "Home",
    "title": "Introduction",
    "category": "section",
    "text": "AsyPlots is a Julia package for creating figures in Asymptote. Asymptote is a mature language for technical drawing in two and three dimensions. This package provides access to2D vector graphics and high-quality, ray-traced 3D graphics\nLaTeX-rendered labels in 2D and 3D\nAn OpenGL renderer for interacting with 3D figures\nEasily customizable colors and arrows\nConvenience functions for line graphs and surface plots, with less of a time-to-first-plot penalty than some other packages\nAn environment designed for working directly with graphics primitives (points, paths, polygons, circles, parametric surfaces) in natural coordinates\nin-line plotting in IJulia and Juno\'s plot pane\nOptions to save output as asy, eps, pdf, svg, or png\nAn alternative Cairo backend, for speed"
},

{
    "location": "index.html#Installation-1",
    "page": "Home",
    "title": "Installation",
    "category": "section",
    "text": "AsyPlots requires Asymptote, which you might already have as a part of your TeX installation (run asy --version from the command line to check). If you want to use the Cairo backend, install Cairo.jl via Pkg.add(Cairo)."
},

{
    "location": "index.html#Examples-1",
    "page": "Home",
    "title": "Examples",
    "category": "section",
    "text": "using AsyPlots\nn = 250; srand(1)\nA = [(x,y) == (0,0) ? 0 : 1/(x^2+y^2) for x=0:n-1,y=0:n-1]\nB = randn(n,n)\nsave(\"fgf.png\",plot(real(fft(A.*B));width=400)) # hide\nplot(real(fft(A.*B)))\nnothing # hide(Image: fgf)using AsyPlots # hide\nn = 100000; srand(2) # hide\nx = cumsum(rand(-1:1,n))\ny = cumsum(rand(-1:1,n))\nsave(\"rw.svg\",Plot(Path(x,y;color=\"White\"),   # hide\n      bgcolor=\"Black\", width=512,                 # hide\n      axispen=\"Red\",axes=true,axisarrow=Arrow())) # hide\nPlot(Path(x,y;color=\"White\"),\n     bgcolor=\"Black\",\n     axispen=\"Red\",\n     axes=true,\n     axisarrow=Arrow())\nnothing # hide(Image: fgf)"
},

{
    "location": "man/overview.html#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "man/overview.html#Overview-1",
    "page": "Overview",
    "title": "Overview",
    "category": "section",
    "text": ""
},

{
    "location": "man/overview.html#Primitives-1",
    "page": "Overview",
    "title": "Primitives",
    "category": "section",
    "text": "A figure in AsyPlots consists of a list of graphics primitives wrapped in a Plot. The primitives are Point, Path, Polygon, Circle, Label, and Surface.using AsyPlots #\nL = [Path([-1 -1; 1 2]),\n     Point(0,0),\n     Circle((0,0),1),\n     Label(\"A\",(1,1)),\n     Polygon([2+im,3+im,1+2im])]\nPlot(L)\nsave(\"polygon.svg\",ans) # hide(Image: )"
},

{
    "location": "man/overview.html#Drawing-options-1",
    "page": "Overview",
    "title": "Drawing options",
    "category": "section",
    "text": "Drawing instructions for each primitive may be supplied via keyword arguments. Properties like color, opacity, line width, and font size are packaged in a Pen object. A Path may also be given an Arrow.using AsyPlots # hide\nL = [Path([-1 -1; 1 2],pen=Pen(color=\"Purple\",linewidth=3),arrow=Arrow(12)),\n     Point(0,0,pen=Pen(color=\"DarkRed\",linewidth=3)),\n     Circle((0,0),1,fillpen=Pen(color=\"Blue\",opacity=0.4)),\n     Label(\"A\",(1,1),pen=Pen(fontsize=14)),\n     Polygon([2+im,3+im,1+2im],pen=NoPen(),fillpen=Pen(color=\"MidnightBlue\"))]\nPlot(L)\nsave(\"example2.svg\",ans) # hide(Image: )Keyword arguments to Pen may be given directly to the underlying primitive, in which case they are automatically wrapped into a Pen object:using AsyPlots # hide\nPoint(0,0,color=\"Green\",linewidth=2).penOptions applicable to the whole figure can be specified as keyword arguments to  Plot.Plot(L,axes=true,axisarrow=Arrow(),bgcolor=\"gray\",width=250)\nsave(\"example3.svg\",ans) # hide(Image: )"
},

{
    "location": "man/overview.html#plot-1",
    "page": "Overview",
    "title": "plot",
    "category": "section",
    "text": "A convenience function plot is available for graphing arrays without having to work directly with graphics primitives. Keyword arguments are separated according to whether they are appropriate for the Plot or the Path/Surface object.using AsyPlots # hide\nsrand(3) # hide\ny = cumsum(cumsum(randn(1000)))\nplot(y,pen=Pen(color=\"DarkRed\"),axisarrow=Arrow())\nsave(\"red_random_walk.svg\",ans) # hide\nnothing # hide(Image: )using AsyPlots # hide\nusing LaTeXStrings\nsrand(1) # hide\nz = randn(5,5)\nplot(z,xmax=4.5,ymax=4.5,xlabel=L\"$x$\",ylabel=L\"$y$\",width=250)\nsave(\"surfplot.svg\",ans) # hide(Image: )interactive(P::Plot3D) opens a window for 3D graphic manipulationinteractive(plot(randn(5,5)))"
},

{
    "location": "man/asy2d.html#",
    "page": "2D Plots",
    "title": "2D Plots",
    "category": "page",
    "text": ""
},

{
    "location": "man/asy2d.html#AsyPlots.Point2D",
    "page": "2D Plots",
    "title": "AsyPlots.Point2D",
    "category": "type",
    "text": "Point2D(x::Real,y::Real; label=\"\",pen=Pen())\nPoint2D(P; label=\"\",pen=Pen())\n\nA graphics primitive representing a two-dimensional point.\n\nP may be a 2-tuple of real numbers, a Vec2, or a Complex\n\nExamples\n\njulia> Point2D(3,-1;pen=\"DarkGreen\")\nPoint2D(3,-1;pen=DarkGreen)\n\n\n\n"
},

{
    "location": "man/asy2d.html#AsyPlots.Path2D",
    "page": "2D Plots",
    "title": "AsyPlots.Path2D",
    "category": "type",
    "text": "Path2D(points;label=\"\",pen=Pen(),arrow=NoArrow(),spline=false)\nPath2D(x,y;label=\"\",pen=Pen(),arrow=NoArrow(),spline=false)\n\nA graphics primitive representing a two-dimensional path\n\npoints may be an Array of Vec2s, an Array of 2-tuples, or an n  2 Array. Alternatively, iterables of coordinates may be supplied separately as x and y\n\nExamples\n\njulia> Path2D([(0,0),(1,0),(1,1)];pen=\"MidnightBlue\")\nPath2D(<3 points>;pen=MidnightBlue)\n\n\n\n"
},

{
    "location": "man/asy2d.html#AsyPlots.Circle2D",
    "page": "2D Plots",
    "title": "AsyPlots.Circle2D",
    "category": "type",
    "text": "Circle2D(center,radius; pen::Pen,fillpen::Pen)\n\nA graphics primitive representing a circle in the plane\n\ncenter may be a Vec2 or a 2-tuple of Reals or a Complex\n\nExamples\n\njulia> Circle2D((0,0),1;pen=\"LightBlue\",fillpen=\"red\")\nCircle2D((0,0),1;pen=LightBlue,fillpen=red)\n\n\n\n"
},

{
    "location": "man/asy2d.html#AsyPlots.Polygon2D",
    "page": "2D Plots",
    "title": "AsyPlots.Polygon2D",
    "category": "type",
    "text": "Polygon2D(points;pen=Pen(),\n                 fillpen=Pen(color=\"white\"),\n                 spline=false)\n\nA graphics primitive representing a two-dimensional polygon\n\npoints may be an Array of Vec2s, an Array of 2-tuples, or an n  2 Array. Alternatively, iterables of coordinates may be supplied separately as x and y\n\nExamples\n\njulia> Polygon2D([(0,0),(1,0),(1,1)];pen=\"MidnightBlue\")\nPolygon2D(<3 points>;pen=MidnightBlue)\n\n\n\n"
},

{
    "location": "man/asy2d.html#AsyPlots.RawString",
    "page": "2D Plots",
    "title": "AsyPlots.RawString",
    "category": "type",
    "text": "RawString(s::AbstractString)\n\nContainer for directly inserting Asymptote drawing commands\n\nExamples\n\njulia> Plot([Circle((0,0),1),RawString2D(\"draw((0,0)--dir(20));\")])\n\n\n\n"
},

{
    "location": "man/asy2d.html#D-Plots-1",
    "page": "2D Plots",
    "title": "2D Plots",
    "category": "section",
    "text": "Each of the following 2D graphics primitives has an alternative constructor without the 2D at the end.Point2D\nPath2D\nCircle2D\nPolygon2D\nRawString"
},

{
    "location": "man/asy3d.html#",
    "page": "3D Plots",
    "title": "3D Plots",
    "category": "page",
    "text": ""
},

{
    "location": "man/asy3d.html#AsyPlots.Point3D",
    "page": "3D Plots",
    "title": "AsyPlots.Point3D",
    "category": "type",
    "text": "Point3D(x::Real,y::Real,z::Real; label=\"\",pen=Pen())\nPoint3D(P; label=\"\",pen=Pen())\n\nA graphics primitive representing a three-dimensional point.\n\nP may be a 3-tuple of real numbers or a Vec3\n\nExamples\n\njulia> Point3D(0,4,5;pen=\"DarkGreen\")\n\n\n\n"
},

{
    "location": "man/asy3d.html#AsyPlots.Path3D",
    "page": "3D Plots",
    "title": "AsyPlots.Path3D",
    "category": "type",
    "text": "Path3D(points;label=\"\",pen=Pen(),arrow=\"\",spline=false)\n\nA graphics primitive representing a two-dimensional path\n\npoints may be an Array of Vec3s or an Array of 3-tuples. Alternatively, iterables of coordinates may be supplied separately as x and y\n\nExamples\n\njulia> Path3D([(0,0),(1,0),(1,1)];pen=\"MidnightBlue\")\n\n\n\n"
},

{
    "location": "man/asy3d.html#AsyPlots.Polygon3D",
    "page": "3D Plots",
    "title": "AsyPlots.Polygon3D",
    "category": "type",
    "text": "Polygon3D(points;pen=Pen(),\n                 fillpen=Pen(color=\"white\"),\n                 spline=false)\n\nA graphics primitive representing a three-dimensional polygon\n\npoints may be an Array of Vec3s or an Array of 3-tuples.\n\nExamples\n\njulia> Polygon3D([(0,0,0),(1,0,0),(1,1,0)];pen=\"MidnightBlue\")\n\n\n\n"
},

{
    "location": "man/asy3d.html#AsyPlots.Surface",
    "page": "3D Plots",
    "title": "AsyPlots.Surface",
    "category": "type",
    "text": "Surface(x::Array{<:Real},\n        y::Array{<:Real},\n        z::Array{<:Real,2};\n        options)\nSurface(z::Array{<:Real},2)\n\nA graphics primitive representing a surface in three dimensions x and y may be one- or two-dimensional arrays\n\nThe surface passes through the points     [x[i,j],y[i,j],z[i,j] for i=1:size(z,1),j=1:size(z,2)]\n\nThe options are\n\ncolors: A vector of color names, for coloring\nspline: whether to draw a smooth or piecewise smooth surface\nsurfacepen: a pen for drawing the surface\nmeshpen: a pen for drawing the grid lines on the surface\nclip: either false or a boolean array of the same dimensions         as x, y, and z, specifying patches to exclude\n\n\n\n"
},

{
    "location": "man/asy3d.html#D-Plots-1",
    "page": "3D Plots",
    "title": "3D Plots",
    "category": "section",
    "text": "Each graphics primitive ending in 3D has an alternative constructor with the 3D part dropped.Point3D\nPath3D\nPolygon3D\nSurface"
},

{
    "location": "man/pens.html#",
    "page": "Pens and Arrows",
    "title": "Pens and Arrows",
    "category": "page",
    "text": ""
},

{
    "location": "man/pens.html#Pens-and-Arrows-1",
    "page": "Pens and Arrows",
    "title": "Pens and Arrows",
    "category": "section",
    "text": ""
},

{
    "location": "man/pens.html#AsyPlots.NamedColor",
    "page": "Pens and Arrows",
    "title": "AsyPlots.NamedColor",
    "category": "type",
    "text": "NamedColor(name::String,color::RGB)\n\nA named ColorTypes.RGB\n\nExamples\n\njulia> NamedColor(\"DarkGreen\")\nNamedColor(\"DarkGreen\",(0.0, 0.39, 0.0))\n\n\n\n"
},

{
    "location": "man/pens.html#AsyPlots.Pen",
    "page": "Pens and Arrows",
    "title": "AsyPlots.Pen",
    "category": "type",
    "text": "Pen(color::NamedColor,\n    opacity::Real,\n    linewidth::Real,\n    other::String)\n\nStore drawing properties\n\nExamples\n\njulia> Pen(color=\"DarkGreen\",opacity=0.5)\nPen(color=DarkGreen,opacity=0.5)\n\n\n\n"
},

{
    "location": "man/pens.html#Pens-1",
    "page": "Pens and Arrows",
    "title": "Pens",
    "category": "section",
    "text": "Colors are stored in a NamedColor.NamedColorThe second argument may be omitted, in which case Colors.parse is used to map the specified string to an appropriate RGB triple. The RGB triple is used for the Cairo backend, while only the name is passed to Asymptote (unless name == \"\", in which case the RGB triple is used). Both Asymptote and Colors.jl will correctly handle the X11 named colors.Options for plotting (color, line width, opacity, and font size) are specified using a Pen object.PenThe function NoPen() returns a pen which specifies no drawing. This may be used, for example, as the fillpen for a polygon which should not be filled in."
},

{
    "location": "man/pens.html#AsyPlots.Arrow",
    "page": "Pens and Arrows",
    "title": "AsyPlots.Arrow",
    "category": "type",
    "text": "Arrow(name::AbstractString,\n      size::Real,\n      position::Real)\n\nStore instructions for drawing an arrow\n\nposition is an element of [0,1] which indicates how far along the path the arrow should be drawn\n\nNoArrow() returns a no-arrow instruction, while Arrow3() gives an arrow suitable for 3D paths\n\n\n\n"
},

{
    "location": "man/pens.html#Arrows-1",
    "page": "Pens and Arrows",
    "title": "Arrows",
    "category": "section",
    "text": "Each Path2D or Path3D object has an arrow field for specifying how an arrow should be drawn on the path. A default arrow in 2D/3D can be created using Arrow()/Arrow3(). Arrow"
},

{
    "location": "man/graphing.html#",
    "page": "Graphing Functions",
    "title": "Graphing Functions",
    "category": "page",
    "text": ""
},

{
    "location": "man/graphing.html#AsyPlots.plot",
    "page": "Graphing Functions",
    "title": "AsyPlots.plot",
    "category": "function",
    "text": "plot(x,y;kwargs...)\nplot(y;kwargs...)\n\nReturn a graph of the path with x and y values given by x and y\n\nx defaults to 0:length(y)-1. kwargs are applied to the Path2D object representing the line or to the containing Plot2D, as appropriate\n\nplot(xs::Vector{<:Vector{<:Real}},\n     ys::Vector{<:Vector{<:Real}};\n     kwargs...)\n\nMultiple line graphs in the same figure\n\nplot(x,y,z;kwargs...)\nplot(z::Array{<:Real,2};kwargs...)\n\nA graph of the surface with x, y, and z values x, y, and z\n\nx defaults to [i-1 for i=1:size(z,1),j=1:size(z,2)] and y defaults to [j-1 for i=1:size(z,1),j=1:size(z,2)]\n\nExamples\n\nplot(cumsum(randn(100)))\nplot(rand(5,5))\n\n\n\n"
},

{
    "location": "man/graphing.html#Graphing-Functions-1",
    "page": "Graphing Functions",
    "title": "Graphing Functions",
    "category": "section",
    "text": "plotusing AsyPlots # hide\nplot(x->sin(2π*x),(0,1),linewidth=2,axisarrow=Arrow())\nsave(\"sineplot.svg\",ans) # hide(Image: )using AsyPlots # hide\nplot((x,y)->exp(-x^2-y^2),(-2,2),(-2,2),xmax=2.5,ymax=2.5,zmax=1.1)\nsave(\"gaussianplot.svg\",ans) # hide(Image: )using AsyPlots # hide\nusing SymPy\n@vars x y\nplot(x*y*sin(x*y/4),(x,0,2π),(y,0,2π))\nsave(\"wave.svg\",plot(x*y*sin(x*y/4),(x,0,2π),(y,0,2π),width=250)) # hide(Image: )"
},

{
    "location": "man/output.html#",
    "page": "Output",
    "title": "Output",
    "category": "page",
    "text": ""
},

{
    "location": "man/output.html#AsyPlots.save",
    "page": "Output",
    "title": "AsyPlots.save",
    "category": "function",
    "text": "save(filename::AbstractString,\n     P::Union{Plot2D,Plot3D};\n     runasy=true,\n     forcepdf=false)\n\nSave Asymptote figure. If filename has extension .asy, then an asy file is saved together with any auxiliary data files.\n\nIf filename has extension .pdf, .svg or .png, then only the resulting image file is saved to the location filename\n\n\n\n"
},

{
    "location": "man/output.html#Output-1",
    "page": "Output",
    "title": "Output",
    "category": "section",
    "text": "save"
},

{
    "location": "man/settings.html#",
    "page": "Settings",
    "title": "Settings",
    "category": "page",
    "text": ""
},

{
    "location": "man/settings.html#AsyPlots.asy",
    "page": "Settings",
    "title": "AsyPlots.asy",
    "category": "function",
    "text": "asy()\n\nSet the backend to Asymptote\n\n\n\n"
},

{
    "location": "man/settings.html#AsyPlots.cairo",
    "page": "Settings",
    "title": "AsyPlots.cairo",
    "category": "function",
    "text": "cairo()\n\nSet the backend to Cairo\n\n\n\n"
},

{
    "location": "man/settings.html#AsyPlots.junosvg",
    "page": "Settings",
    "title": "AsyPlots.junosvg",
    "category": "function",
    "text": "junosvg()\n\nSet the default output format for the Juno plot pane to svg\n\n\n\n"
},

{
    "location": "man/settings.html#AsyPlots.junopng",
    "page": "Settings",
    "title": "AsyPlots.junopng",
    "category": "function",
    "text": "junopng()\n\nSet the default output format for the Juno plot pane to png\n\n\n\n"
},

{
    "location": "man/settings.html#AsyPlots.fitwidth",
    "page": "Settings",
    "title": "AsyPlots.fitwidth",
    "category": "function",
    "text": "fitwidth()\n\nSet the figures appearing in the Juno plot pane to match its width\n\n\n\n"
},

{
    "location": "man/settings.html#AsyPlots.fitheight",
    "page": "Settings",
    "title": "AsyPlots.fitheight",
    "category": "function",
    "text": "fitheight()\n\nSet the figures appearing in the Juno plot pane to match its height\n\n\n\n"
},

{
    "location": "man/settings.html#Settings-1",
    "page": "Settings",
    "title": "Settings",
    "category": "section",
    "text": "asy\ncairo\njunosvg\njunopng\nfitwidth\nfitheight"
},

{
    "location": "man/defaults.html#",
    "page": "Default Options",
    "title": "Default Options",
    "category": "page",
    "text": ""
},

{
    "location": "man/defaults.html#Default-Options-1",
    "page": "Default Options",
    "title": "Default Options",
    "category": "section",
    "text": "This page collects the default options for all this package\'s basic types.using AsyPlots # hide\nAsyPlots._DEFAULT_PEN_ARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_ARROW_KWARGSusing AsyPlots # hide\nENV[\"LINES\"] = 100 # hide\nAsyPlots._DEFAULT_PLOT2D_KWARGSusing AsyPlots # hide\nENV[\"LINES\"] = 100 # hide\nAsyPlots._DEFAULT_PLOT3D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_POINT2D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_PATH2D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_CIRCLE2D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_POLYGON2D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_POINT3D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_PATH3D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_SURFACE_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_LABEL2D_KWARGSusing AsyPlots # hide\nAsyPlots._DEFAULT_LABEL3D_KWARGS"
},

{
    "location": "man/animate.html#",
    "page": "Animation",
    "title": "Animation",
    "category": "page",
    "text": ""
},

{
    "location": "man/animate.html#AsyPlots.animate",
    "page": "Animation",
    "title": "AsyPlots.animate",
    "category": "function",
    "text": "animate(filename::AbstractString,\n        plots::Vector{Plot2D};\n        rate=10)\n\nanimate(plots::Vector{Plot2D};rate=10)\n\nMake an .mp4 video from plots, with frame rate rate\n\nIf \"filename\" is given, the movie file will be stored there. Otherwise, the movie will be opened.\n\nExample\n\nX = cumsum(randn(100000))\nY = cumsum(randn(100000))\nplots = [Plot(Path(X[1:t],Y[1:t])) for t=10:10:10000]\nanimate(plots)\n\n\n\n"
},

{
    "location": "man/animate.html#Animation-1",
    "page": "Animation",
    "title": "Animation",
    "category": "section",
    "text": "animate"
},

{
    "location": "examples/examples2d.html#",
    "page": "2D Examples",
    "title": "2D Examples",
    "category": "page",
    "text": ""
},

{
    "location": "examples/examples2d.html#D-Examples-1",
    "page": "2D Examples",
    "title": "2D Examples",
    "category": "section",
    "text": "Eigenvalues of a 1000 × 1000 random matrixusing AsyPlots # hide\nPlot(map(Point,eigvals(randn(1000,1000))))\nsave(\"eigs.svg\",ans) # hide(Image: )using AsyPlots # hide\nrandcolor() = rand(Bool) ? \"Blue\" : \"Yellow\"\nL = Polygon2D[]\nfor i=1:100\n  for j=1:100\n    push!(L,box(i,j,i+1,j+1;\n                fillpen=Pen(color=randcolor()),\n                pen=NoPen()))\n  end\nend\ncairo() \nP = Plot(L;border=0)\nasy() # hide\nsave(\"perc.svg\",P) # hide(Image: )"
},

{
    "location": "examples/examples3d.html#",
    "page": "3D Examples",
    "title": "3D Examples",
    "category": "page",
    "text": ""
},

{
    "location": "examples/examples3d.html#D-Examples-1",
    "page": "3D Examples",
    "title": "3D Examples",
    "category": "section",
    "text": "using AsyPlots # hide\nrvals = linspace(0,2,40)\nthetavals = linspace(0,2π,40)\n\nf(x,y) = 5*(x^2+y^2)*exp(-x^2-y^2)\n\nxv = [r*cos(θ) for r=rvals,θ=thetavals]\nyv = [r*sin(θ) for r=rvals,θ=thetavals]\nzv = [f(r*cos(θ),r*sin(θ)) for r=rvals,θ=thetavals]\n\nPlot(Surface(xv,yv,zv,meshpen=Pen(color=0.1*NamedColor(1,1,1),linewidth=0.3),\n                      surfacepen=Pen(opacity=0.8)),\n     camera=(4,2,5),\n     xmax=2.2,\n     ymax=2.2)\nsave(\"hat.svg\",ans) # hide(Image: )using AsyPlots # hide\nr(u) = 2-cos(u);\nx(u,v) = 3*cos(u)*(1+sin(u))+r(u)*cos(v)*(u < pi ? cos(u) : -1)\ny(u,v) = 8*sin(u)+(u < pi ? r(u)*sin(u)*cos(v) : 0)\nz(u,v) = r(u)*sin(v)\nU = linspace(0,2π,60)\nV = linspace(0,2π,30)\nsp = Pen(opacity=0.9)\nc = [\"LightBlue\",\"MidnightBlue\",\"LightBlue\"]\nmp = Pen(color=0.2*NamedColor(1,1,1),linewidth=0.3)\nPlot(Surface([x(u,v) for u=U,v=V],\n             [y(u,v) for u=U,v=V],\n             [z(u,v) for u=U,v=V],surfacepen=sp,meshpen=mp,colors=c),\n             axes=false,camera=(10,-15,8))\nsave(\"klein.svg\",ans) # hide(Image: )"
},

]}
