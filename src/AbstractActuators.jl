module AbstractActuators

import AbstractDAQs


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



abstract type AbstractActuator <: AbstractDAQs.AbstractDevice end
abstract type AbstractRobot <: AbstractActuator end

abstract type AbstractCartesianRobot <: AbstractRobot end

    

include("move_interface.jl")
include("experimentmatrix.jl")
include("manualactuator.jl")
include("testdevices.jl")

end
