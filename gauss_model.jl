module gauss_model

# Provide the functionality to model Gaussians as test cases
using constants


export imageGauss, FTGauss

# Realistic Gaussian will have scale dimensions (fatter in x direction)
const s_x = 1.2 * arcsec # [radians]
const s_y = 1.0 * arcsec # [radians]

const pre = 1. / (2pi * sqrt(det(Float64[s_x^2 0 ;
0  s_y^2])))

# Given two arrays of l and m coordinates, fill an array of the Gaussian image following the MATLAB convention.
# Modified to take sigma as a parameter. Later, this should be modified to take
# amplitude and mean vector, which will translate to a phase shift
# p0 is a vector of sigma in units of arcseconds
function imageGauss(ll::Vector{Float64}, mm::Vector{Float64}, p::Vector{Float64})
    nx = length(ll)
    ny = length(mm)
    img = Array(Float64, ny, nx)
    Sigma = Diagonal((p * arcsec).^2) #Convert from arcsec to radians
    pre = 1. / (2pi * sqrt(det(Sigma)))
    for i=1:nx
        for j=1:ny
            R = Float64[ll[i], mm[j]]
            img[j, i] = pre * exp(-0.5 * (R' * (Sigma\R))[1])
        end
    end
    return img
end

# Given u and v coordinates in [kλ], evaluate the analytic FT of the
# aforementioned Gaussian
# N.B. Here Sigma refers to the (same) covariance matrix in the *image* domain
# always return a complex value
function FTGauss(uu::Float64, vv::Float64, p::Vector{Float64})
    uu = uu .* 1e3 #[λ]
    vv = vv .* 1e3 #[λ]
    R = Float64[uu, vv]
    Sigma = Diagonal((p * arcsec).^2) #Convert from arcsec to radians
    return exp(-2 * (pi^2) * (R' * Sigma * R)[1]) + 0.im
    # in this case, Sigma serves as the inverse
end

# Given two arrays of u and v coordinates in [kλ], fill an array with the
# analytic FT of aforementioned Gaussian evaluated at every pairwise (u,v) pair
function FTGauss(uu::Vector{Float64}, vv::Vector{Float64})
    nu = length(uu)
    nv = length(vv)
    img = Array(Complex128, nv, nu)
    for i=1:nu
        for j=1:nv
            img[j, i] = FTGauss(uu[i], vv[j])
        end
    end
    return img
end


end # Module