export AbstractPositioner, setinitpos!, movenext!, moveto, movetopoint!
export PositionerGrid, ExperimentMatrix, testpoint, setpoint!, incpoint!, pointidx
export CartesianExperimentMatrix, ExperimentMatrixProduct
export TestPositioner, numaxes, numpoints
export Positioner1d, PositionerNd
export matrixparams
"""
`AbstractPositioner`

An abstract type that creates an interface for setting up an experimental point.

In this package, an experimental point is a given configuration of the experiment
where measurements are made. 

As an example, imagine we are carrying out an experiment
where a probe makes measurements at different positions 
specified by a [`ExperimentMatrix`](@ref) object.
A concrete instance of an `AbstractPositioner` will handle moving
the probe to the next position.
"""
abstract type AbstractPositioner end



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
matrixparams(pts::ExperimentMatrix) = pts.params


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

Set the index of the current test point to `idx`
"""
setpoint!(pts::AbstractExperimentMatrix, idx=1) = pts.idx = idx

"""
`pointidx(move)`

Return the index of the current position during the experiment.
"""
pointidx(pts::AbstractExperimentMatrix) = pts.idx



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
numaxes(pts::CartesianExperimentMatrix) = length(pts.params)
testpoint(pts::CartesianExperimentMatrix, i) = pts.pts[i,:]


    
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
function ExperimentMatrixProduct(pts...)
    points = [p for p in pts]
    n = numpoints.(points)
    nmats = length(points)
    ii = Vector{Int}[]

    for i in 1:nmats
        push!(ii, collect(1:n[i]))
    end
    ptsidx = cartesianprod(ii)

    return ExperimentMatrixProduct(0, points, ptsidx)
end

numpoints(pts::ExperimentMatrixProduct) = size(pts.ptsidx,1)
numaxes(pts::ExperimentMatrixProduct) = sum(numaxes.(pts.points))
function matrixparams(pts::ExperimentMatrixProduct)
    params = String[]

    for p in pts.points
        append!(params, matrixparams(p))
    end
    return params
end

function testpoint(pts::ExperimentMatrixProduct, i)
    x = Float64[]

    for (k,p) in enumerate(pts.points)
        ki = pts.ptsidx[i,k]
        append!(x, testpoint(p, ki))
    end
    return x
    
end

                
import Base.*

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

julia> M.pts
12×3 Matrix{Float64}:
 1.0  100.0  1.0
 1.0  100.0  2.0
 1.0  100.0  3.0
 1.0  100.0  4.0
 2.0  200.0  1.0
 2.0  200.0  2.0
 2.0  200.0  3.0
 2.0  200.0  4.0
 3.0  300.0  1.0
 3.0  300.0  2.0
 3.0  300.0  3.0
 3.0  300.0  4.0
```
"""
function *(m1::ExperimentMatrix, m2::ExperimentMatrix)

    # Variables must be different in each ExperimentMatrix
    if length(intersect(m1.params, m2.params)) != 0
        throw(ArgumentError("No repeated variables in ExperimentMatrix allowed"))
    end

    params = vcat(m1.params, m2.params)
    
    nv1 = length(m1.params)
    nv2 = length(m2.params)

    n1 = size(m1.pts,1)
    n2 = size(m2.pts,1)

    
    n = n1 * n2
    nv = nv1 + nv2
    pts = zeros(Float64, n, nv)

    row = 1
    for i in 1:n1
        pi = m1.pts[i,:]
        for k in 1:n2
            pk = m2.pts[k,:]
            pts[row, :] = vcat(pi, pk)
            row += 1
        end
    end
    return ExperimentMatrix(params, pts)

end

numaxes(M::ExperimentMatrix) = length(M.params)

"""
`setinitpos!(move, points)`

Go to initial position of the [`ExperimentMatrix`](@ref) where an experiment should start.
"""
setinitpos!(move::AbstractPositioner, points::AbstractExperimentMatrix) =
    movetopoint!(move, points, 1)


"""
`movenext!(move, points)`

Move to the next point in `ExperimentMatrix`.

If the function reached the end of the points, the function returns `false` 
and does nothing. Othwerwise, it returns `true`.
"""
function movenext!(move::AbstractPositioner, points::AbstractExperimentMatrix) 
    idx = pointidx(points)
    idx == numpoints(points) && return false
    p = testpoint(points, idx+1)
    moveto(move, p)
    incpoint!(points)
    return true
end

"""
`movetopoint!(move, points)`

Move to the next point in `ExperimentMatrix`.
"""
function movetopoint!(move::AbstractPositioner, points::ExperimentMatrix, idx=1) 
    moveto(move, testpoint(points,idx))
    setpoint!(points, idx)
end

"""
`moveto(move, x)`

Move to an arbitrary point. The point is specified by vector `x`. 

"""
function moveto end


"""
`PositionerGrid(move1, move2)`

Creates a new [`AbstractPositioner`](@ref) object from two independent ones.

## Examples
```julia-repl
julia> move1 = TestPositioner("x", "y")
TestPositioner(["x", "y"], [0.0, 0.0])

julia> move2 = TestPositioner("z")
TestPositioner(["z"], [0.0])

julia> move = move1 * move2
PositionerGrid{TestPositioner, TestPositioner}(TestPositioner(["x", "y"], [0.0, 0.0]), TestPositioner(["z"], [0.0]))

julia> moveto(move, [1,2,3])
Moved to (x, y) =  (1.0 , 2.0)
Moved to (z) =  (3.0)

julia> setinitpos!(move, M)
Moved to (x, y) =  (1.0 , 100.0)
Moved to (z) =  (1.0)
1

julia> movenext!(move, M)
Moved to (x, y) =  (1.0 , 100.0)
Moved to (z) =  (2.0)
2

```
"""
struct PositionerGrid{T1<:AbstractPositioner,T2<:AbstractPositioner} <:AbstractPositioner
    move1::T1
    move2::T2
   
    function PositionerGrid{T1,T2}(move1::T1, move2::T2) where
        {T1<:AbstractPositioner,T2<:AbstractPositioner}
        return new(move1, move2)
    end
    
end

numaxes(move::PositionerGrid, i) = i==1 ? numaxes(move.move1) : numaxes(move.move2)

numaxes(move::PositionerGrid) = numaxes(move, 1) + numaxes(move, 2)


*(move1::T1, move2::T2) where {T1<:AbstractPositioner,T2<:AbstractPositioner} =
    PositionerGrid{T1,T2}(move1, move2)

    

function setinitpos!(move::PositionerGrid, points::ExperimentMatrix)

    n1 = numaxes(move.move1)
    n2 = numaxes(move.move2)
    

    x = testpoint(points, 1)

    x1 = x[1:n1]
    x2 = x[n1+1:end]

    moveto(move.move1, x1)
    moveto(move.move2, x2)

    setpoint!(points, 1)
    
end
function moveto(move::PositionerGrid, x::AbstractVector{<:Real})
    
    x1 = Float64.(x[1:numaxes(move,1)])
    x2 = Float64.(x[numaxes(move,1)+1:end])

    moveto(move.move1, x1)
    moveto(move.move2, x2)
end

mutable struct TestPositioner <:AbstractPositioner
    "Variables (dof) of the test positioner"
    params::Vector{String}
    "Current position of the test positioner"
    x::Vector{Float64}
    TestPositioner(params::Vector{String}, x::Vector{Float64}) = new(params, x)
end
numaxes(move::TestPositioner) = length(move.params)

"""
`TestPositioner("x", "y", "z", ...)
`TestPositioner(:x, :y, :z, ...)`
`TestPositioner(["x", "y", "z", ...])`

Creates an [`AbstractPositioner`](@ref) that can be used for testing purposes.
The number of variables on the arguments list or the unique vector determine 
the number of degrees of freedom of the system.

##
"""
function TestPositioner(v...)
    params = [string(x) for x in v]
    n = length(params)
    x = zeros(n)
    return TestPositioner(params, zeros(n))
end

function TestPositioner(params::AbstractVector)
    v = [string(v) for v in params]
    x = zeros(length(v))
    return TestPositioner(v, x)
end

function moveto(move::TestPositioner, x)
    length(x) != numaxes(move) && error("Wrong number of arguments")
        
    move.x .= x
    print("Moved to ")

    N = length(x)
    c = "("
    for i in 1:N
        print("$c$(move.params[i])")
        c = ", "
    end
    print(") = ")
    c = "("
    for i in 1:N
        print(" $c$(x[i])")
        c = ", "
    end
    println(")")
end



"""
`Positioner1d(dev::AbstractActuator)`

Implements an `AbstractPositioner` object using the generic interface for systems
with 1 degree of freedom.
"""
struct Positioner1d{T<:AbstractActuator} <: AbstractPositioner
    dev::T
end

numaxes(m::Positioner1d) = 1
moveto(m::Positioner1d, x) = move(m.dev, x[1])

struct PositionerNd{T<:AbstractCartesianRobot} <: AbstractPositioner
    dev::T
    axes::Vector{Int}
    function PositionerNd(dev::T, axes::AbstractVector{<:Integer}) where {T<:AbstractCartesianRobot}
        return new{T}(dev, [Int(ax) for ax in axes])
    end
    
end
numaxes(m::PositionerNd) = length(m.axes)
    
function moveto(m::PositionerNd, x::AbstractVector{<:Real})

    x1 = x[m.axes]

    move(m.dev, m.axes, x1)
end


    



