using Pkg
Pkg.add("Calculus")

#=this is a comment
this is also a comment=#

# function to calculate the volume of a sphere
function sphere_vol(r)
  # julia allows Unicode names
  # (in UTF-8 encoding)
  # so either "pi" or the symbol π can be used
  return 4/3*pi*r^3
end

function quadratic2(a::Float64, b::Float64, c::Float64)
  #=
  unlike other languages 2a is equivalent to 2*a
    a^2 is used instead of a**2 or pow(a,2)
  =#
  sqr_term = sqrt(b^2-4a*c)
end
