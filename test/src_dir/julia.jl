module SampleOperations

export ∂x, ∂y, @binary, @multiary
export Δx, Δy, Ax, Ay, volume

using Base: @propagate_inbounds

import Foobar.BoundaryConditions: fill_halo_regions!

#####
##### Regex
regex = r"\bhello\b"
string = "this is not a comment"
ismatch = occursin(regex, "hello world")

abstract type AbstractOperation{LX, LY, LZ, G, T} <: AbstractField{LX, LY, LZ, G, T, 3} end
const AF = AbstractField # used in unary_operations.jl, binary_operations.jl, etc

function Base.axes(f::AbstractOperation)
    if idx === (:, : ,:)
        return Base.OneTo.(size(f))
    else
        return Tuple(idx[i] isa Colon ? Base.OneTo(size(f, i)) : idx[i] for i = 1:3)
    end
end

@inline fill_halo_regions!(::AbstractOperation, args...; kwargs...) = nothing
architecture(a::AbstractOperation) = architecture(a.grid)

"""
    at(loc, abstract_operation)
multline string literal
"""
at(loc, f) = f # fallback

include("barfoo.jl")

# Make some operators!
#
# Some operators:
import Base: sqrt, sin, cos, exp, tanh, abs, -, +, /, ^, *

@unary sqrt sin cos exp tanh abs
@unary -
@unary +

@binary /
@binary ^

#=
Some multiline
comment here
=#

atan(1 #=inline comment=#,0)

# Another multiline
# comment here
import Base: *

end # module
