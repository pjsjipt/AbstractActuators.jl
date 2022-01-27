export AbstractPositioner, setinitpos!, movenext!, moveto, movetopoint!
export PositionerGrid, TestMatrix, testpoint, setpoint!, incpoint!, pointidx
export TestPositioner, numdof, numpoints
export Positioner1d, PositionerNd

"""
`AbstractPositioner`

An abstract type that creates an interface for setting up an experimental point.

In this package, an experimental point is a given configuration of the experiment
where measurements are made. 

As an example, imagine we are carrying out an experiment
where a probe makes measurements at different positions 
specified by a [`TestMatrix`](@ref) object.
A concrete instance of an `AbstractPositioner` will handle moving
the probe to the next position.
"""
abstract type AbstractPositioner end






mutable struct TestMatrix
    "Index of current point"
    idx::Int
    "Name of variables that characterize the point"
    vars::Vector{String}
    "Set of positions in the test matrix"
    pts::Matrix{Float64}
end


"""
`TestMatrix(vars, pts)`
`TestMatrix(;kw...)`

Defines a sequence of predefined points that characterize an experiment.

The points are defined by a `Matrix{Float64}` where each column corresponds to a 
variable or degree of freedom of the system. Each row characterizes a specific point.

## Arguments

 * `vars` Vector/tuple containing the names of the variables that define the position. It will be converted to a string.
 * `pts` Matrix that contains the points. Each column corresponds to a variable and each row to a single point.
 * `kw...` Keyword arguments where the names of the keywords correspond to the variables and the values to the possible positions. The length of each keyword argument should be the same or 1. If its 1, it will be repeated.

"""
function TestMatrix(vars, pts::AbstractMatrix{Float64})
    
    nvars = size(pts, 2)
    nvals = size(pts, 1)
    
    length(vars) != nvars && thrown(ArgumentError("Wrong number of variable names!"))
    
    testpts = zeros(Float64, nvals, nvars)
    for i in 1:nvars
        for k in 1:nvals
            testpts[k,i] = pts[k,i]
        end
    end
    vars1 = [string(v) for v in vars]
    return TestMatrix(0, vars1, testpts)

end

function TestMatrix(;kw...) 

    vars = [string(k) for k in keys(kw)]
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
    return TestMatrix(0, vars, testpts)
    
end
    

"""
`testpoint(pts, i)`

Return a vector containing the coordinates of the i-th test point.
"""
testpoint(pts::TestMatrix, i) = pts.pts[i,:]

"""
`incpoint!(pts)`

Set the index of the current test point to 1
"""
incpoint!(pts::TestMatrix) = pts.idx += 1

"""
`setpoint!(pts, idx)`

Set the index of the current test point to `idx`
"""
setpoint!(pts::TestMatrix, idx=1) = pts.idx = idx

"""
`pointidx(move)`

Return the index of the current position during the experiment.
"""
pointidx(pts::TestMatrix) = pts.idx

numpoints(pts::TestMatrix) = size(pts,1)
"""
Returns the number of variables or degrees of freedome that an `AbstractPositioner` or
`TestMatrix` object has.
"""
function numdof end



import Base.*

"""
`m1*m2`

Cartesian product between two `TestMatrices`. Used to combine different test matrices into 
a single one. 

The cartesian product is built so that the object on the right hand side of the 
multiplication runs faster. 

## Examples

```julia-repl
julia> M1 = TestMatrix(;x=1:3, y=100:100:300)
TestMatrix(0, ["x", "y"], [1.0 100.0; 2.0 200.0; 3.0 300.0])

julia> M2 = TestMatrix(z=1:4)
TestMatrix(0, ["z"], [1.0; 2.0; 3.0; 4.0;;])

julia> M = M1*M2
TestMatrix(0, ["x", "y", "z"], [1.0 100.0 1.0; 1.0 100.0 2.0; … ; 3.0 300.0 3.0; 3.0 300.0 4.0])

julia> numdof(M1)
2

julia> numdof(M2)
1

julia> numdof(M)
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
function *(m1::TestMatrix, m2::TestMatrix)

    # Variables must be different in each TestMatrix
    if length(intersect(m1.vars, m2.vars)) != 0
        throw(ArgumentError("No repeated variables in TestMatrix allowed"))
    end

    vars = vcat(m1.vars, m2.vars)
    
    nv1 = length(m1.vars)
    nv2 = length(m2.vars)

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
    return TestMatrix(vars, pts)

end

numdof(M::TestMatrix) = length(M.vars)

"""
`setinitpos!(move, points)`

Go to initial position of the [`TestMatrix`](@ref) where an experiment should start.
"""
setinitpos!(move::AbstractPositioner, points::TestMatrix) =
    movetopoint!(move, points, 1)


"""
`movenext!(move, points)`

Move to the next point in `TestMatrix`.
"""
function movenext!(move::AbstractPositioner, points::TestMatrix) 
    idx = pointidx(points)
    p = testpoint(points, idx+1)
    moveto(move, p)
    incpoint!(points)
end

"""
`movetopoint!(move, points)`

Move to the next point in `TestMatrix`.
"""
function movetopoint!(move::AbstractPositioner, points::TestMatrix, idx=1) 
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

numdof(move::PositionerGrid, i) = i==1 ? numdof(move.move1) : numdof(move.move2)

numdof(move::PositionerGrid) = numdof(move, 1) + numdof(move, 2)


*(move1::T1, move2::T2) where {T1<:AbstractPositioner,T2<:AbstractPositioner} =
    PositionerGrid{T1,T2}(move1, move2)

    

function setinitpos!(move::PositionerGrid, points::TestMatrix)

    n1 = numdof(move.move1)
    n2 = numdof(move.move2)
    

    x = testpoint(points, 1)

    x1 = x[1:n1]
    x2 = x[n1+1:end]

    moveto(move.move1, x1)
    moveto(move.move2, x2)

    setpoint!(points, 1)
    
end
function moveto(move::PositionerGrid, x::AbstractVector{<:Real})
    
    x1 = Float64.(x[1:numdof(move,1)])
    x2 = Float64.(x[numdof(move,1)+1:end])

    moveto(move.move1, x1)
    moveto(move.move2, x2)
end

mutable struct TestPositioner <:AbstractPositioner
    "Variables (dof) of the test positioner"
    vars::Vector{String}
    "Current position of the test positioner"
    x::Vector{Float64}
    TestPositioner(vars::Vector{String}, x::Vector{Float64}) = new(vars, x)
end
numdof(move::TestPositioner) = length(move.vars)

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
    vars = [string(x) for x in v]
    n = length(vars)
    x = zeros(n)
    return TestPositioner(vars, zeros(n))
end

function TestPositioner(vars::AbstractVector)
    v = [string(v) for v in vars]
    x = zeros(length(v))
    return TestPositioner(v, x)
end

function moveto(move::TestPositioner, x)
    length(x) != numdof(move) && error("Wrong number of arguments")
        
    move.x .= x
    print("Moved to ")

    N = length(x)
    c = "("
    for i in 1:N
        print("$c$(move.vars[i])")
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




struct Positioner1d{T<:AbstractActuator} <: AbstractPositioner
    dev::T
end

numdof(m::Positioner1d) = 1
moveto(m::Positioner1d, x) = move(m, x[1])

struct PositionerNd{T<:AbstractCartesianRobot} <: AbstractPositioner
    dev::T
    axes::Vector{Int}
end

numdof(m::PositionerNd) = length(m.axes)
    
function moveto(m::PositionerNd, x::AbstractVector{<:Real})

    x1 = x[m.axes]

    move(m.dev, m.axes, x1)
end


    



