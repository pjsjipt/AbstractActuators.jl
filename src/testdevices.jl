

mutable struct TestRobot1d <: AbstractRobot
    θ::Float64
    θᵣ::Float64
    Δt::Float64
end

TestRobot1d(;dt=1.0) = TestRobot1d(0.0, 0.0, dt)

function move(dev::TestRobot1d, deg; a=false, r=false, sync=true)
    if r
        dev.θ += deg
    elseif a
        dev.θ = deg
    else
        dev.θ = deg + dev.θᵣ
    end

    sync && sleep(dev.Δt)

    p = dev.θ - dev.θᵣ
    println("Movement: θ = $p")
end

rmove(dev::TestRobot1d, deg; sync=true) = move(dev, deg, r=true, sync=sync)
position(dev::TestRobot1d) = dev.θ - dev.θᵣ
absposition(dev::TestRobot1d) = dev.θ

setreference(dev::TestRobot1d, deg=0) = (dev.θᵣ = dev.θ - deg)
setabsreference(dev::TestRobot1d) = (dev.θᵣ = 0)


waituntildone(dev::TestRobot1d) = sleep(dev.Δt)
stopmotion(dev::TestRobot1d) = sleep(dev.Δt/5)






mutable struct TestRobot3d <: AbstractCartesianRobot
    n::Int
    x::Vector{Float64}
    xr::Vector{Float64}
    axes::Vector{String}
    axidx::Dict{String,Int}
    Δt::Float64
end

function TestRobot3d(n=3; axes=["x", "y", "z", "w"], dt=1.0)
    axidx = Dict{String,Int}()
    axes = axes[1:n]
    for (i, ax) in enumerate(axes)
        axidx[ax] = i
    end
    
    TestRobot3d(n, zeros(n), zeros(n), axes, axidx, dt)
end

numaxes(dev::TestRobot3d) = dev.n

function move(dev::TestRobot3d, ax::Integer, mm; r=false)
    if r
        dev.x[ax] += mm
    else
        dev.x[ax] = mm
    end
    sleep(dev.Δt)
    println("Position: $ax -> $(dev.axes[ax]) = $(dev.x[ax])")
end

move(dev::TestRobot3d, ax, mm; r=false) =
    move(dev, dev.axidx[string(ax)], mm; r=r)
    

function move(dev::TestRobot3d, axes::AbstractVector,
                                x::AbstractVector; r=false)
    ndof = length(axes)

    for i in 1:ndof
        move(dev, axes[i], x[i]; r=r)
    end
    return
end

moveX(dev::TestRobot3d, mm) = move(dev, mm, dev.axidx["x"]; r=false)
moveY(dev::TestRobot3d, mm) = move(dev, mm, dev.axidx["y"]; r=false)
moveZ(dev::TestRobot3d, mm) = move(dev, mm, dev.axidx["z"]; r=false)

rmoveX(dev::TestRobot3d, mm) = move(dev, mm, dev.axidx["x"]; r=true)
rmoveY(dev::TestRobot3d, mm) = move(dev, mm, dev.axidx["y"]; r=true)
rmoveZ(dev::TestRobot3d, mm) = move(dev, mm, dev.axidx["z"]; r=true)

position(dev::TestRobot3d, ax) = dev.x[dev.axidx[string(ax)]]
position(dev::TestRobot3d, ax::Integer) = dev.x[ax]

position(dev::TestRobot3d, axes::AbstractVector) = dev.x[axes]

function position(dev::TestRobot3d)
    pos = Dict{String,Float64}()

    for i in 1:numaxes(dev)
        pos[dev.axes[i]] = dev.x[i]
    end
    return pos
end

positionX(dev::TestRobot3d) = position(dev, "x")
positionY(dev::TestRobot3d) = position(dev, "y")
positionZ(dev::TestRobot3d) = position(dev, "z")

setreference(dev::TestRobot3d, ax::Integer, mm=0) = dev.x[ax] = mm
setreference(dev::TestRobot3d, ax, mm=0) = dev.x[dev.axidx[string(ax)]] = mm

function setreference(dev::TestRobot3d, ax::AbstractVector, mm=0)
    nax = length(ax)
    if length(mm) == 1
        mm = fill(mm[1], nax)
    end

    for i in 1:nax
        setreference(dev, ax[i], mm[i])
    end
    
end

setreferenceX(dev::TestRobot3d, mm=0) = dev.x[dev.axidx["x"]] = mm
setreferenceY(dev::TestRobot3d, mm=0) = dev.x[dev.axidx["y"]] = mm
setreferenceZ(dev::TestRobot3d, mm=0) = dev.x[dev.axidx["z"]] = mm


