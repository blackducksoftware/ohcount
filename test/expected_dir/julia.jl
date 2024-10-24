julia	code	module SampleOperations
julia	blank	
julia	code	export ∂x, ∂y, @binary, @multiary
julia	code	export Δx, Δy, Ax, Ay, volume
julia	blank	
julia	code	using Base: @propagate_inbounds
julia	blank	
julia	code	import Foobar.BoundaryConditions: fill_halo_regions!
julia	blank	
julia	comment	#####
julia	comment	##### Regex
julia	code	regex = r"\bhello\b"
julia	code	string = "this is not a comment"
julia	code	ismatch = occursin(regex, "hello world")
julia	blank	
julia	code	abstract type AbstractOperation{LX, LY, LZ, G, T} <: AbstractField{LX, LY, LZ, G, T, 3} end
julia	code	const AF = AbstractField # used in unary_operations.jl, binary_operations.jl, etc
julia	blank	
julia	code	function Base.axes(f::AbstractOperation)
julia	code	    if idx === (:, : ,:)
julia	code	        return Base.OneTo.(size(f))
julia	code	    else
julia	code	        return Tuple(idx[i] isa Colon ? Base.OneTo(size(f, i)) : idx[i] for i = 1:3)
julia	code	    end
julia	code	end
julia	blank	
julia	code	@inline fill_halo_regions!(::AbstractOperation, args...; kwargs...) = nothing
julia	code	architecture(a::AbstractOperation) = architecture(a.grid)
julia	blank	
julia	comment	"""
julia	comment	    at(loc, abstract_operation)
julia	comment	multline string literal
julia	comment	"""
julia	code	at(loc, f) = f # fallback
julia	blank	
julia	code	include("barfoo.jl")
julia	blank	
julia	comment	# Make some operators!
julia	comment	#
julia	comment	# Some operators:
julia	code	import Base: sqrt, sin, cos, exp, tanh, abs, -, +, /, ^, *
julia	blank	
julia	code	@unary sqrt sin cos exp tanh abs
julia	code	@unary -
julia	code	@unary +
julia	blank	
julia	code	@binary /
julia	code	@binary ^
julia	blank	
julia	comment	#=
julia	comment	Some multiline
julia	comment	comment here
julia	comment	=#
julia	blank	
julia	code	atan(1 #=inline comment=#,0)
julia	blank	
julia	comment	# Another multiline
julia	comment	# comment here
julia	code	import Base: *
julia	blank	
julia	code	end # module
