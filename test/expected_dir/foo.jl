julia	code	using Pkg
julia	code	Pkg.add("Calculus")
julia	blank	
julia	comment	#=this is a comment
julia	comment	this is also a comment=#
julia	blank	
julia	comment	# function to calculate the volume of a sphere
julia	code	function sphere_vol(r)
julia	comment	  # julia allows Unicode names
julia	comment	  # (in UTF-8 encoding)
julia	comment	  # so either "pi" or the symbol π can be used
julia	code	  return 4/3*pi*r^3
julia	code	end
julia	blank	
julia	code	function quadratic2(a::Float64, b::Float64, c::Float64)
julia	comment	  #=
julia	comment	  unlike other languages 2a is equivalent to 2*a
julia	comment	    a^2 is used instead of a**2 or pow(a,2)
julia	comment	  =#
julia	code	  sqr_term = sqrt(b^2-4a*c)
julia	code	end
