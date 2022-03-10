module AbstractActuators

using AbstractDAQs


export devname
export AbstractActuator, AbstractRobot, AbstractCartesianRobot, numaxes 
export moveto
export move, moveX, moveY, moveZ
export rmove, rmoveX, rmoveY, rmoveZ
export axesnames

export absposition, abspositionX, abspositionY, abspositionZ
export devposition, positionX, positionY, positionZ

export setreference, setreferenceX, setreferenceY, setreferenceZ
export setabsreference, setabsreferenceX, setabsreferenceY, setabsreferenceZ

export home, homeX, homeY, homeZ
export stopmotion, waituntildone

export TestRobot1d, TestRobot


"Abstract base type for actuators"
abstract type AbstractActuator <: AbstractDAQs.AbstractDevice end

"Abstract base type for Robots"
abstract type AbstractRobot <: AbstractActuator end

"Abstract base type for cartesian robots"
abstract type AbstractCartesianRobot <: AbstractRobot end

    

include("move_interface.jl")
include("actuatorset.jl")
include("experimentmatrix.jl")
include("manualactuator.jl")
include("testdevices.jl")
include("hdf5io.jl")
end
