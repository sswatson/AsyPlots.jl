
function process_pen_kwargs(kwargs)
    global _DEFAULT_PEN_ARGS
    D = OrderedDict{Symbol,Any}(kwargs)
    penkwargs = Any[]
    for k in keys(_DEFAULT_PEN_ARGS)
        if k in keys(D)
            push!(penkwargs,(k,pop!(D,k)))
        end
    end
    if length(penkwargs) > 0 && :pen in keys(D)
        error("Both pen and $penkwargs keyword arguments found")
    end
    if length(penkwargs) > 0
        D[:pen] = Pen(;penkwargs...)
    end
    collect(D)
end

function kwargstring(P,D::OrderedDict;semicolon=true)
    result = filterjoin([(x=getfield(P,s);
                    x == D[s] ? "" : "$(string(s))=$(string(x))")
                    for s in keys(D)]...)
    (result == "" ? "" : """$(semicolon ? ";" : "")$result""")
end

function updatedvals(defOptions::OrderedDict,newOptions)
    newOptionsDict = Dict(newOptions)
    for (k,v) in newOptionsDict
        if ~(k in keys(defOptions))
            error("Unknown option $k")
        end
    end
    D = deepcopy(defOptions)
    merge!(D,newOptionsDict)
    values(D)
end

"""
    splitkwargs(pooled_kwargs,options_to_separate)

Split a pooled list of keyword arguments into kwargs
in `options_to_separate` and the rest
"""
function splitkwargs(pooled_kwargs,options_to_separate)
    remaining_kwargs = Dict(pooled_kwargs)
    separated_kwargs = Dict{Symbol,Any}()
    for (s,v) in remaining_kwargs
        if s in keys(options_to_separate)
            separated_kwargs[s] = pop!(remaining_kwargs,s)
        end
    end
    map(collect,(separated_kwargs,remaining_kwargs))
end


"""
    filterjoin(args...)

Concatenate nonempty string representations of `args`,
separated by commas
"""
filterjoin(args...) = join(Iterators.filter(s->length(s)>0,map(string,args)),",")

"""
    enclosequote(s)

Enclose `s` in quotation marks, unless it starts
with "Label"
"""
enclosequote(s) = startswith(s,"Label") ? s : "\"$s\""

