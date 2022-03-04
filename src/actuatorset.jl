

export ActuatorSet

mutable struct ActuatorSet{ActuatorList} <: AbstractActuator
    devname::String
    actuators::ActuatorList
end

function ActuatorSet(dname, acts::ActuatorList) where {ActuatorList}
    return ActuatorSet(dname, actuators)
end

function ActuatorSet(dname, acts...)

    return ActuatorSet(dname, acts)
end

    
import Base.*

*(a1::AbstractActuator, a2::AbstractActuator) = ActuatorSet("actuators", (a1, a2))

numaxes(actuators::ActuatorSet) = sum(numaxes(act) for act in actuators.actuators)

function axesnames(actuators::ActuatorSet)

    nn = String[]

    for act in actuators.actuators
        axes = axesnames(act)
        for ax in axes
            push!(nn, ax)
        end
    end
    return nn
end

function moveto(actuators::ActuatorSet, x)

    naxes = 0

    for act in actuators.actuators
        nx = numaxes(act)
        moveto(act, x[naxes+1:naxes+nx])
        naxes += nx
    end
    return
    
end

        