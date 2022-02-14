export AbstractPositioner,  movenext!, moveto, movetopoint!
export PositionerGrid, ExperimentMatrix, testpoint, setpoint!, restartpoints!
export incpoint!, pointidx
export AbstractExperimentMatrix, CartesianExperimentMatrix, ExperimentMatrixProduct
export TestPositioner, numaxes, numparams, numpoints, experimentpoints
export Positioner1d, PositionerNd
export matrixparams, checkconsistency



abstract type AbstractExperimentMatrix end


mutable struct ExperimentMatrix <: AbstractExperimentMatrix
    "Index of current point"
    idx::Int
    "Name of parameters that characterize the point"
    params::Vector{String}
    "Set of positions in the test matrix"
    pts::Matrix{Float64}
end


"""
`ExperimentMatrix(params, pts)`
`ExperimentMatrix(;kw...)`

Defines a sequence of predefined points that characterize an experiment.

The points are defined by a `Matrix{Float64}` where each column corresponds to a 
parameter (degree of freedom) of the system. Each row characterizes a specific point.

## Arguments

 * `params` Vector/tuple containing the names of the parameters that define the position. It will be converted to a string.
 * `pts` Matrix that contains the points. Each column corresponds to a variable and each row to a single point.
 * `kw...` Keyword arguments where the names of the keywords correspond to the variables and the values to the possible positions. The length of each keyword argument should be the same or 1. If its 1, it will be repeated.

"""
function ExperimentMatrix(params, pts::AbstractMatrix{Float64})
    
    npars = size(pts, 2)
    nvals = size(pts, 1)
    
    length(params) != npars && thrown(ArgumentError("Wrong number of variable names!"))
    
    testpts = zeros(Float64, nvals, npars)
    for i in 1:npars
        for k in 1:nvals
            testpts[k,i] = pts[k,i]
        end
    end
    params1 = [string(v) for v in params]
    return ExperimentMatrix(0, params1, testpts)

end

function ExperimentMatrix(;kw...) 

    params = [string(k) for k in keys(kw)]
    nvals = maximum(length(v) for (k,v) in kw)

    testpts = zeros(Float64, nvals, length(keys(kw)))

    ivar = 1
    for (k,v) in kw
        if length(v) == 1
            for i in 1:nvals
                testpts[i,ivar] = Float64(v[1])
            end
        elseif length(v) != nvals
            throw(ArgumentError("All arguments lengths should be the same or 1!"))
        else
            for i in 1:nvals
                testpts[i,ivar] = Float64(v[i])
            end
        end
        ivar += 1
    end
    return ExperimentMatrix(0, params, testpts)
    
end


"""
`matrixparams(pts)`

Returns the names of the parameters.
"""
matrixparams(pts::AbstractExperimentMatrix) = pts.params

numparams(M::ExperimentMatrix) = length(M.params)

"""
`numpoints(pts)`

Returns the number of points in a test matrix.
"""
numpoints(pts::ExperimentMatrix) = size(pts.pts,1)

"""
`testpoint(pts, i)`

Return a vector containing the coordinates of the i-th test point.
"""
testpoint(pts::ExperimentMatrix, i) = pts.pts[i,:]

"""
`incpoint!(pts)`

Set the index of the current test point to 1
"""
incpoint!(pts::AbstractExperimentMatrix) = pts.idx += 1

"""
`setpoint!(pts, idx)`

Set the index of the next experiment point to `idx`.
Remember that the next point is `idx+1`!
"""
setpoint!(pts::AbstractExperimentMatrix, idx=1) = pts.idx = idx-1

restartpoints!(pts::AbstractExperimentMatrix) = pts.idx = 0

"""
`pointidx(move)`

Return the index of the current position during the experiment.
"""
pointidx(pts::AbstractExperimentMatrix) = pts.idx

experimentpoints(pts::ExperimentMatrix) = pts.pts

mutable struct CartesianExperimentMatrix <: AbstractExperimentMatrix
    idx::Int
    params::Vector{String}
    axes::Vector{Vector{Float64}}
    pts::Matrix{Float64}
end

"""
`cartesianprod(x::Vector{Vector{T}})`
`cartesianprod(x...)`

Performs a cartesian product between vectors

"""
function cartesianprod(x::Vector{Vector{T}}) where {T}

    npars = length(x)
    n = length.(x)
    ntot = prod(n)
    pts = zeros(T, ntot, npars)
    strd = zeros(Int, npars)
    strd[1] = 1
    for i in 2:npars
        strd[i] = strd[i-1] * n[i-1]
    end

    for i in 1:npars # Each variable corresponds to a column
        xi = x[i] # Select the variable
        Ni = n[i]
        Si = strd[i]
        cnt = 1
        Nr = ntot ÷ (Ni*Si)
        for k in 1:Nr
            for j in 1:Ni
                for l in 1:Si
                    pts[cnt,i] = xi[j]
                    cnt += 1
                end
            end
        end

    end

    return pts
end
cartesianprod(x1...) = cartesianprod([collect(y) for y in x1])

"""
`CartesianExperimentMatrix(;kw...)`

Creates a test matrix that is a cartesian product  of independent parameters.
This is useful if the test should be executed on a regular grid, x, y for example.
In this grid, the length of x is n₁ and the length of y is n₂. The number of points
in the test is therefore nx⋅ny.

The first parameters run faster:

```julia
pts = CartesianMatrix(x=1:3, y=5:5:25)
```

In this case, 
The points of the test matrix are

| x  | y  |
|----|----|
| x₁ | y₁ |
| x₂ | y₁ |
| ⋮  | ⋮  |
| xₙ₁| y₁ |
| x₁ | y₂ |
| x₂ | y₂ |
| ⋮  | ⋮  |
| xₙ₁| yₙ₂|


"""
function CartesianExperimentMatrix(;kw...)
    params = string.(collect(keys(kw)))
    axes = Vector{Float64}[]
    npars = length(params)
    for (k, v) in kw
        push!(axes, [Float64(x) for x in v])
    end
    pts = cartesianprod(axes)
    return CartesianExperimentMatrix(0, params, axes, pts)
end

numpoints(pts::CartesianExperimentMatrix) = size(pts.pts, 1)
numparams(pts::CartesianExperimentMatrix) = length(pts.params)
testpoint(pts::CartesianExperimentMatrix, i) = pts.pts[i,:]
experimentpoints(pts::CartesianExperimentMatrix) = pts.pts


    
mutable struct ExperimentMatrixProduct <: AbstractExperimentMatrix
    idx::Int
    points::Vector{AbstractExperimentMatrix}
    ptsidx::Matrix{Int}
    ExperimentMatrixProduct(idx::Int, points::Vector{AbstractExperimentMatrix}, ptsidx::Matrix{Int}) = new(idx, points, ptsidx)
end



"""
`ExperimentMatrixProduct(pts...)`


Cartesian produc between different AbstractExperimentMatrix objects.
"""
function ExperimentMatrixProduct(points::AbstractVector{<:AbstractExperimentMatrix})
    points = AbstractExperimentMatrix[p for p in points]
    
    n = numpoints.(points)
    nmats = length(points)
    ii = Vector{Int}[]

    for i in 1:nmats
        push!(ii, collect(1:n[i]))
    end
    ptsidx = cartesianprod(ii)

    return ExperimentMatrixProduct(0, points, ptsidx)
end
function ExperimentMatrixProduct(pts...)
    points = AbstractExperimentMatrix[p for p in pts]
    return ExperimentMatrixProduct(points)
end

    

numpoints(pts::ExperimentMatrixProduct) = size(pts.ptsidx,1)
numparams(pts::ExperimentMatrixProduct) = sum(numparams.(pts.points))
matrixparams(pts::ExperimentMatrixProduct) = vcat([matrixparams(p) for p in pts.points]...)


function testpoint(pts::ExperimentMatrixProduct, i)
    x = Float64[]

    for (k,p) in enumerate(pts.points)
        ki = pts.ptsidx[i,k]
        append!(x, testpoint(p, ki))
    end
    return x
    
end

function experimentpoints(pts::ExperimentMatrixProduct)
    npts = numpoints(pts)

    nparams = numparams(pts)
    points = zeros(npts, nparams)

    for i in 1:npts
        points[i,:] .= testpoint(pts, i)
    end
    return points
end

"""
`m1*m2`

Cartesian product between two `TestMatrices`. Used to combine different test matrices into 
a single one. 

The cartesian product is built so that the object on the right hand side of the 
multiplication runs faster. 

## Examples

```julia-repl
julia> M1 = ExperimentMatrix(;x=1:3, y=100:100:300)
ExperimentMatrix(0, ["x", "y"], [1.0 100.0; 2.0 200.0; 3.0 300.0])

julia> M2 = ExperimentMatrix(z=1:4)
ExperimentMatrix(0, ["z"], [1.0; 2.0; 3.0; 4.0;;])

julia> M = M1*M2
ExperimentMatrix(0, ["x", "y", "z"], [1.0 100.0 1.0; 1.0 100.0 2.0; … ; 3.0 300.0 3.0; 3.0 300.0 4.0])

julia> numaxes(M1)
2

julia> numaxes(M2)
1

julia> numaxes(M)
3
```
"""
*(m1::AbstractExperimentMatrix, m2::AbstractExperimentMatrix) =
    ExperimentMatrixProduct(m1, m2)
    





"""
`movenext!(move, points)`

Move to the next point in `ExperimentMatrix`.

If the function reached the end of the points, the function returns `false` 
and does nothing. Othwerwise, it returns `true`.
"""
function movenext!(actuator::AbstractActuator, points::AbstractExperimentMatrix) 
    idx = pointidx(points)
    idx == numpoints(points) && return false
    p = testpoint(points, idx+1)
    moveto(actuator, p)
    incpoint!(points)
    return true
end

function movenext!(actuators::AbstractVector{<:AbstractActuator},
                   points::ExperimentMatrixProduct)
    
    idx = pointidx(points)
    ndev = size(points.ptsidx,2) # Number of devices

    idx == numpoints(points) && return false # Over!
    
    # Only move the coordinates that need to move:
    if idx == 0
        for k in ndev:-1:1
            moveto(actuators[k], testpoint(points.points[k], 1))
        end
    else
        for k in ndev:-1:1
            iold = points.ptsidx[idx,k]
            inew = points.ptsidx[idx+1,k]
            if iold != inew
                moveto(actuators[k], testpoint(points.points[k], inew))
            end
        end
    end
    incpoint!(points)

    return true
end

movenext!(actuators::ActuatorSet, points::ExperimentMatrixProduct) =
    movenext!(actuators.actuators, points)

function axesnames(acts::Union{Tuple,AbstractVector})
    axes = String[]

    for actuator in acts
        append!(axes, axesnames(actuator))
    end
    return axes
end


"""
`movetopoint!(move, points)`

Move to the next point in `ExperimentMatrix`.
"""
function movetopoint!(actuator::AbstractActuator, points::ExperimentMatrix, idx=1) 
    moveto(actuator, testpoint(points,idx))
    setpoint!(points, idx)
end


function movetopoint!(actuators::AbstractVector{<:AbstractActuator},
                      points::ExperimentMatrixProduct, idx=1)
    
    ndev = size(points.ptsidx,2) # Number of devices
    for k in 1:ndev
        moveto(actuators[k], testpoint(points.points[k], idx))
    end
end

movetopoint!(actuators::ActuatorSet, points::ExperimentMatrixProduct, idx=1) =
    movetopoint!(actuators.actuators, points, idx)

checkconsistency(actuators, points) = axesnames(actuators) == matrixparams(points)

