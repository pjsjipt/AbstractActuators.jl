module AbstractActuators


export AbstractActuator, AbstractRobot, AbstractCartesianRobot, numaxes 
export move, moveX, moveY, moveZ
export rmove, rmoveX, rmoveY, rmoveZ

export absposition, abspositionX, abspositionY, abspositionZ
export position, positionX, positionY, positionZ

export setreference, setreferenceX, setreferenceY, setreferenceZ
export setabsreference, setabsreferenceX, setabsreferenceY, setabsreferenceZ

export home, homeX, homeY, homeZ
export stopmotion, waituntildone

abstract type AbstractActuator  end
abstract type AbstractRobot <: AbstractActuator end

abstract type AbstractCartesianRobot <: AbstractRobot end

abstract type AbstractExpPoint <: end



"""
`numaxes(dev)`

Return the number of degrees of freedom of the actuator.
"""
numaxes(dev::AbstractActuator) = error("Not implemented!")
numaxes(::Type{<:AbstractRobot}) = error("Not implemented!")


"""
`move(dev)`

Move a Robot.
"""
move(dev::AbstractRobot) = error("Not implemented!")

"""
`moveX(dev)`

Move a Robot along x axis.
"""
moveX(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`moveY(dev)`

Move a Robot along y axis.
"""
moveY(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`moveZ(dev)`

Move a Robot along z axis.
"""
moveZ(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`rmove(dev)`

Move a Robot relative to the current position.
"""
rmove(dev::AbstractRobot) = error("Not implemented!")

"""
`rmoveX(dev)`

Move a Robot relative to the current position along x axis.
"""
rmoveX(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`rmoveY(dev)`

Move a Robot relative to the current position along y axis.
"""
rmoveY(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`rmoveZ(dev)`

Move a Robot relative to the current position along z axis.
"""
rmoveZ(dev::AbstractCartesianRobot) = error("Not implemented!")


"""
`absposition(dev)`

Position of the robot with respect to global reference frame.
"""
absposition(dev::AbstractRobot) = error("Not implemented")

"""
`abspositionX(dev)`

Position of the robot along x axis with respect to global reference frame.
"""
abspositionX(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`abspositionY(dev)`

Position of the robot along y axis with respect to global reference frame.
"""
abspositionY(dev::AbstractCartesianRobot) = error("Not implemented")


"""
`abspositionZ(dev)`

Position of the robot along z axis with respect to global reference frame.
"""
abspositionZ(dev::AbstractCartesianRobot) = error("Not implemented")

import Base

"""
`position(dev)`

Position of the robot with respect to current frame of reference.
"""
Base.position(dev::AbstractRobot) = error("Not implemented")

"""
`positionX(dev)`

Position of the robot along x axis with respect to current frame of reference.
"""
positionX(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`positionY(dev)`

Position of the robot along y axis with respect to current frame of reference.
"""
positionY(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`positionZ(dev)`

Position of the robot along z axis with respect to current frame of reference.
"""
positionZ(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`setreference(dev)`

Set current position as reference.
"""
setreference(dev::AbstractRobot) = error("Not implemented")

"""
`setreferenceX(dev)`

Set current position as reference along x axis.
"""
setreferenceX(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`setreferenceY(dev)`

Set current position as reference along y axis.
"""
setreferenceY(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`setreferenceZ(dev)`

Set current position as reference along z axis.
"""
setreferenceZ(dev::AbstractCartesianRobot) = error("Not implemented")


"""
`setabsreference(dev)`

Return to absolute frame of reference.
"""
setabsreference(dev::AbstractRobot) = error("Not implemented")

"""
`setabsreferenceX(dev)`

Return to absolute frame of reference along x axis.
"""
setabsreferenceX(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`setabsreferenceY(dev)`

Return to absolute frame of reference along y axis.
"""
setabsreferenceY(dev::AbstractCartesianRobot) = error("Not implemented")

"""
`setabsreferenceZ(dev)`

Return to absolute frame of reference along z axis.
"""
setabsreferenceZ(dev::AbstractCartesianRobot) = error("Not implemented")


"""
`home(dev)`

Return home and set the absolute frame of reference.
"""
home(dev::AbstractRobot) = error("Not implemented!")

"""
`homeX(dev)`

Return home on x axis and set the absolute frame of reference on x axis.
"""
homeX(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`homeY(dev)`

Return home on y axis and set the absolute frame of reference on y axis.
"""
homeY(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`homeZ(dev)`

Return home on z axis and set the absolute frame of reference on z axis.
"""
homeZ(dev::AbstractCartesianRobot) = error("Not implemented!")

"""
`stopmotion(dev)`

Stop all motion of the robot. 
"""
stopmotion(dev::AbstractRobot) = error("Not implemented!")

"""
`waituntildone(dev)`

Wait until all asynchronous motions of the robot is done. 
"""
waituntildone(dev::AbstractRobot) = error("Not implemented!")

end
