module AbstractMover


export AbstractMoverDev, numaxes 
export move, moveX, moveY, moveZ
export rmove, rmoveX, rmoveY, rmoveZ

export absposition, abspositionX, abspositionY, abspositionZ
export position, positionX, positionY, positionZ

export setreference, setreferenceX, setreferenceY, setreferenceZ
export setabsreference, setabsreferenceX, setabsreferenceY, setabsreferenceZ

export home, homeX, homeY, homeZ
export stopmotion, waituntildone


abstract type AbstractMoverDev end

numaxes(dev::AbstractMoverDev) = error("Not implemented!")
numaxes(::Type{<:AbstractMoverDev}) = error("Not implemented!")



move(dev::AbstractMoverDev) = error("Not implemented!")

moveX(dev::AbstractMoverDev) = error("Not implemented!")
moveY(dev::AbstractMoverDev) = error("Not implemented!")
moveZ(dev::AbstractMoverDev) = error("Not implemented!")

rmove(dev::AbstractMoverDev) = error("Not implemented!")

rmoveX(dev::AbstractMoverDev) = error("Not implemented!")
rmoveY(dev::AbstractMoverDev) = error("Not implemented!")
rmoveZ(dev::AbstractMoverDev) = error("Not implemented!")

absposition(dev::AbstractMoverDev) = error("Not implemented")
abspositionX(dev::AbstractMoverDev) = error("Not implemented")
abspositionY(dev::AbstractMoverDev) = error("Not implemented")
abspositionZ(dev::AbstractMoverDev) = error("Not implemented")

import Base
Base.position(dev::AbstractMoverDev) = error("Not implemented")

positionX(dev::AbstractMoverDev) = error("Not implemented")
positionY(dev::AbstractMoverDev) = error("Not implemented")
positionZ(dev::AbstractMoverDev) = error("Not implemented")

setreference(dev::AbstractMoverDev) = error("Not implemented")

setreferenceX(dev::AbstractMoverDev) = error("Not implemented")
setreferenceY(dev::AbstractMoverDev) = error("Not implemented")
setreferenceZ(dev::AbstractMoverDev) = error("Not implemented")

setabsreference(dev::AbstractMoverDev) = error("Not implemented")

setabsreferenceX(dev::AbstractMoverDev) = error("Not implemented")
setabsreferenceY(dev::AbstractMoverDev) = error("Not implemented")
setabsreferenceZ(dev::AbstractMoverDev) = error("Not implemented")


home(dev::AbstractMoverDev) = error("Not implemented!")

homeX(dev::AbstractMoverDev) = error("Not implemented!")
homeY(dev::AbstractMoverDev) = error("Not implemented!")
homeZ(dev::AbstractMoverDev) = error("Not implemented!")

stopmotion(dev::AbstractMoverDev) = error("Not implemented!")

waituntildone(dev::AbstractMoverDev) = error("Not implemented!")

end
