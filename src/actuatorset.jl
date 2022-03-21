

export ActuatorSet

mutable struct ActuatorSet{ActuatorList} <: AbstractActuator
    devname::String
    actuators::ActuatorList
end

"""
`ActuatorSet(dname, acts::ActuatorList)`

Create a meta actuator from individual actuators.
"""
function ActuatorSet(dname, acts::ActuatorList) where {ActuatorList}
    return ActuatorSet(dname, actuators)
end

function ActuatorSet(dname, acts...)

    return ActuatorSet(dname, acts)
end

    
import Base.*

*(a1::AbstractActuator, a2::AbstractActuator) = ActuatorSet("actuators", (a1, a2))

"Number of axes (degrees of freedom) of the actuator set"
numaxes(actuators::ActuatorSet) = sum(numaxes(act) for act in actuators.actuators)

"Return the axes names of the `ActuatorSet`"
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

"Get the actuators to `move` to a point given by the components of x"
function moveto(actuators::ActuatorSet, x)

    naxes = 0

    for act in actuators.actuators
        nx = numaxes(act)
        moveto(act, x[naxes+1:naxes+nx])
        naxes += nx
    end
    return
    
end

        
