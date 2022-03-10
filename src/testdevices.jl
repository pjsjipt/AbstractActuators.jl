

mutable struct TestRobot1d <: AbstractRobot
    "Device name"
    devname::String
    "Position"
    x::Float64
    "Reference Position"
    xᵣ::Float64
    "Name of the axis"
    axis::String
    "Time that the program should sleep for each move"
    Δt::Float64
end

"""
`TestRobot1d(devname, axis="θ";dt=0.0)`

Creates a test robot with a single degree of freedom. Useful for testing the
interfaces and simulating experiments.

 * `devname`: a string with the device name
 * `axis`: a string with the name of the axis
 * `dt`: number of seconds that the program should wait before moving on. Useful to simulate an actual system that is not instantaneous.

This test actuator tries to simulate the wind tunnel turntable so that it has
a position and a reference that can be changed.
"""
TestRobot1d(devname, axis="θ";dt=0.0) = TestRobot1d(devname, 0.0, 0.0, axis, dt)

"""
`move(dev::TestRobot1d, x; a=false, r=false, sync=true)`

Move the test robot to a new position. 
It tries to emulate the `WMesaP` interface.
"""
function move(dev::TestRobot1d, x; a=false, r=false, sync=true)
    if r
        dev.x += x
    elseif a
        dev.x = x
    else
        dev.x = x + dev.xᵣ
    end

    sync && sleep(dev.Δt)

    p = dev.x - dev.xᵣ
    println("Movement: θ = $p")
end


numaxes(dev::TestRobot1d) = 1
axesnames(dev::TestRobot1d) = [dev.axis]

moveto(dev::TestRobot1d, x) = move(dev, x[1]; a=false, r=false, sync=true)

rmove(dev::TestRobot1d, x; sync=true) = move(dev, x, r=true, sync=sync)
devposition(dev::TestRobot1d) = dev.x - dev.xᵣ
absposition(dev::TestRobot1d) = dev.x

setreference(dev::TestRobot1d, x=0) = (dev.xᵣ = dev.x - x)
setabsreference(dev::TestRobot1d) = (dev.xᵣ = 0)


waituntildone(dev::TestRobot1d) = sleep(dev.Δt)
stopmotion(dev::TestRobot1d) = sleep(dev.Δt/5)






mutable struct TestRobot <: AbstractCartesianRobot
    devname::String
    n::Int
    x::Vector{Float64}
    xr::Vector{Float64}
    axes::Vector{String}
    axidx::Dict{String,Int}
    Δt::Float64
end

"""
`TestRobot(devname, axes=["x", "y", "z"]; dt=0.0)`

Creates a cartesian robot with several axes. It tries to emulate the interface
used by the wind tunnel's cartesian robot (see the `RoboSimples` package at
<https://github.com/pjsjipt/RoboSimples.jl>).
"""
function TestRobot(devname, axes=["x", "y", "z"]; dt=0.0)
    n = length(axes)
    axidx = Dict{String,Int}()
    axes = axes[1:n]
    for (i, ax) in enumerate(axes)
        axidx[ax] = i
    end
    
    TestRobot(devname, n, zeros(n), zeros(n), axes, axidx, dt)
end

numaxes(dev::TestRobot) = dev.n
axesnames(dev::TestRobot) = dev.axes

function move(dev::TestRobot, ax::Integer, mm; r=false)
    if r
        dev.x[ax] += mm
    else
        dev.x[ax] = mm
    end
    sleep(dev.Δt)
    println("Position: $ax -> $(dev.axes[ax]) = $(dev.x[ax])")
end

move(dev::TestRobot, ax, mm; r=false) =
    move(dev, dev.axidx[string(ax)], mm; r=r)


function move(dev::TestRobot, axes::AbstractVector,
                                x::AbstractVector; r=false)
    ndof = length(axes)

    for i in 1:ndof
        move(dev, axes[i], x[i]; r=r)
    end
    return
end

moveto(dev::TestRobot, x::AbstractVector) = move(dev, dev.axes, x, r=false)

moveX(dev::TestRobot, mm) = move(dev, mm, dev.axidx["x"]; r=false)
moveY(dev::TestRobot, mm) = move(dev, mm, dev.axidx["y"]; r=false)
moveZ(dev::TestRobot, mm) = move(dev, mm, dev.axidx["z"]; r=false)

rmoveX(dev::TestRobot, mm) = move(dev, mm, dev.axidx["x"]; r=true)
rmoveY(dev::TestRobot, mm) = move(dev, mm, dev.axidx["y"]; r=true)
rmoveZ(dev::TestRobot, mm) = move(dev, mm, dev.axidx["z"]; r=true)

devposition(dev::TestRobot, ax) = dev.x[dev.axidx[string(ax)]]
devposition(dev::TestRobot, ax::Integer) = dev.x[ax]

devposition(dev::TestRobot, axes::AbstractVector) = dev.x[axes]

function devposition(dev::TestRobot)
    pos = Dict{String,Float64}()

    for i in 1:numaxes(dev)
        pos[dev.axes[i]] = dev.x[i]
    end
    return pos
end

positionX(dev::TestRobot) = devposition(dev, "x")
positionY(dev::TestRobot) = devposition(dev, "y")
positionZ(dev::TestRobot) = devposition(dev, "z")

setreference(dev::TestRobot, ax::Integer, mm=0) = dev.x[ax] = mm
setreference(dev::TestRobot, ax, mm=0) = dev.x[dev.axidx[string(ax)]] = mm

function setreference(dev::TestRobot, ax::AbstractVector, mm=0)
    nax = length(ax)
    if length(mm) == 1
        mm = fill(mm[1], nax)
    end

    for i in 1:nax
        setreference(dev, ax[i], mm[i])
    end
    
end

setreferenceX(dev::TestRobot, mm=0) = dev.x[dev.axidx["x"]] = mm
setreferenceY(dev::TestRobot, mm=0) = dev.x[dev.axidx["y"]] = mm
setreferenceZ(dev::TestRobot, mm=0) = dev.x[dev.axidx["z"]] = mm


