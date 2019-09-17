
const _DEFAULT_PICTURE_KWARGS =
    OrderedDict(
        :clip => nothing
    )

struct Picture <: GraphicElement2D
    elements::Array{<:GraphicElement,1}
    options::Array{Any,1}
end

Picture(;kwargs...) = Picture(GraphicElement[],kwargs...)

Picture(elements::Array{<:GraphicElement,1};kwargs...) =
        Picture(elements,collect(kwargs))

Picture(element::GraphicElement;kwargs...) = Picture([element];kwargs...)

function Picture(P::Picture;kwargs...)
    Picture(P.elements,updatedvals(
                    _DEFAULT_PICTURE_KWARGS,kwargs))
end

