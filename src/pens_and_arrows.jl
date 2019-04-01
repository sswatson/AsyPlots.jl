"""
    NamedColor(name::String,color::RGB)

A named `ColorTypes.RGB`

# Examples

```julia-repl
julia> NamedColor("DarkGreen")
NamedColor("DarkGreen",(0.0, 0.39, 0.0))
```
"""
struct NamedColor
    name::String
    color::ColorTypes.RGB
end

NamedColor(;name="",color=ColorTypes.RGB(0,0,0)) =
                                NamedColor(name,color)

NamedColor(S::String) = NamedColor(name=S,color=parse(Colors.Colorant,S))
NamedColor(C::ColorTypes.RGB) = NamedColor(color=C)
function NamedColor(S::String,C::Tuple{<:Real,<:Real,<:Real})
    NamedColor(S,ColorTypes.RGB(C...))
end

function NamedColor(C::Tuple{<:Real,<:Real,<:Real})
    NamedColor("",ColorTypes.RGB(C...))
end

NamedColor(r::Real,g::Real,b::Real) = NamedColor((r,g,b))

softblue = NamedColor(0.92,0.95,0.99);
softred = NamedColor(0.99, 0.92, 0.91);
softyellow = NamedColor(0.98, 0.98, 0.9);
softgreen = NamedColor(0.96, 0.995, 0.98);

function *(k::Real,C::NamedColor)
    NamedColor("",ColorTypes.RGB(k*C.color.r,k*C.color.g,k*C.color.b))
end
dot(k::Real,C::NamedColor) = k*C
zero(::Type{NamedColor}) = NamedColor(0,0,0)
/(C::NamedColor,r::Real) = 1/r*C
function +(C::NamedColor,D::NamedColor)
    NamedColor("",ColorTypes.RGB(C.color.r + D.color.r,
                                 C.color.g + D.color.g,
                                 C.color.b + D.color.b))
end

function ==(C::NamedColor,D::NamedColor)
    C.name == D.name && C.color == D.color
end

function Base.show(io::IO,NC::NamedColor)
    t = map(x->round(Float64(x);digits=2),(NC.color.r,NC.color.g,NC.color.b))
    print(io,"""NamedColor("$(NC.name)",$t)""")
end

defaultcolor() = NamedColor(name="default")

"""
    Pen(color::NamedColor,
        opacity::Real,
        linewidth::Real,
        other::String)

Store drawing properties

# Examples

```julia-repl
julia> Pen(color="DarkGreen",opacity=0.5)
Pen(color=DarkGreen,opacity=0.5)
```
"""
struct Pen
    color::NamedColor
    opacity::Real
    linewidth::Real
    fontsize::Real
    other::String
end

const _DEFAULT_PEN_ARGS =
    OrderedDict(
        :color => defaultcolor(),
        :opacity => 1,
        :linewidth => 0,
        :fontsize => 12,
        :other => ""
    )

Pen(;kwargs...) = Pen(updatedvals(_DEFAULT_PEN_ARGS,kwargs)...)

NoPen() = Pen(other="NoPen")

==(P::Pen,Q::Pen) = all(getfield(P,k)==getfield(Q,k)
                                for k in keys(_DEFAULT_PEN_ARGS))

convert(::Type{NamedColor},name::AbstractString) = NamedColor(name)
convert(::Type{NamedColor},color::ColorTypes.RGB) = NamedColor(;color=color)
convert(::Type{Pen},string::AbstractString) = Pen(;other=string)
convert(::Type{Pen},color::NamedColor) = Pen(color=color)

function Base.show(io::IO,P::Pen)
    kwargs = kwargstring(P,_DEFAULT_PEN_ARGS,semicolon=false)
    print(io,"Pen($kwargs)")
end

isdefault(P::Pen) = (P == Pen())
isdefault(S::AbstractString) = (S == "")

"""
    Arrow(name::AbstractString,
          size::Real,
          position::Real)

Store instructions for drawing an arrow

`position` is an element of [0,1] which indicates
how far along the path the arrow should be drawn

NoArrow() returns a no-arrow instruction, while
Arrow3() gives an arrow suitable for 3D paths
"""
struct Arrow
    name::AbstractString
    size::Real
    position::Real
end

const _DEFAULT_ARROW_KWARGS =
    OrderedDict(
        :name => "Arrow",
        :size => 7.5,
        :position => 1
    )

function Arrow(;kwargs...)
    return Arrow(updatedvals(_DEFAULT_ARROW_KWARGS,kwargs)...)
end

function Arrow3(;kwargs...)
    D = deepcopy(_DEFAULT_ARROW_KWARGS)
    merge!(D,Dict(kwargs))
    merge!(D,Dict(:name => "Arrow3"))
    return Arrow(values(D)...)
end

NoArrow() = Arrow(;name="None")
Arrow(n) = Arrow(size=n)
Arrow3(n) = Arrow3(size=n)
Arrows(;kwargs...) = Arrow(name="Arrows";kwargs...)

==(A::Arrow,B::Arrow) = all(getfield(A,k) == getfield(B,k)
                                    for k in fieldnames(Arrow))

function AsyString(A::Arrow)
    position = A.position == 1 ? "" : "position=$(A.position)"
    if A.name == "None"
        return "None"
    elseif A.size ≠ 7.5
        return "$(A.name)($(filterjoin(A.size,position)))"
    else
        return "$(A.name)($position)"
    end
end

function string(A::Arrow)
    if A.name == "None"
        return "NoArrow()"
    else
        return AsyString(A)
    end
end
print(io::IO,A::Arrow) = print(io,string(A))
show(io::IO,A::Arrow) = print(io,string(A))

function string(C::NamedColor)
    if C.name ≠ "default" && C.name ≠ ""
        return C.name
    elseif C.name == "default"
        return ""
    else
        colorvals = [Float64(getfield(C.color,s)) for s in [:r,:g,:b]]
        return """rgb($(join(map(string,colorvals),",")))"""
    end
end
print(io::IO,C::NamedColor) = print(io,string(C))

function string(P::Pen)
    color = string(P.color)
    opacity = P.opacity == 1 ? "" : "opacity($(P.opacity))"
    linewidth = P.linewidth == 0 ? "" : "linewidth($(P.linewidth))"
    fontsize = P.fontsize == 12 ? "" : "fontsize($(P.fontsize))"
    other = P.other
    join(filter(x->x≠"",[color,opacity,linewidth,fontsize,other]),"+")
end
print(io::IO,P::Pen) = print(io,string(P))

function Ticks(major::Union{Vector,AbstractRange},minor::Union{Vector,AbstractRange,Nothing};beginlabel=true,endlabel=true)
    majorticks = "Ticks=new real[] {$(join(major,","))}"
    minorticks = isa(minor,Nothing) ? "" : "ticks=new real[] {$(join(minor,","))}"
    bl = beginlabel ? "" : "beginlabel=false"
    el = endlabel ? "" : "endlabel=false"
    args = filterjoin(majorticks,minorticks,bl,el)
    "Ticks($args)"
end

function Ticks(major::Union{Vector,AbstractRange};kwargs...)
    Ticks(major,nothing;kwargs...)
end
