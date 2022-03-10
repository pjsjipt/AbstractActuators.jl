
export ManualActuator

"""
`AbstractManualActuator`

An abstract interface to actuators with manual input.
"""
abstract type AbstractManualActuator <: AbstractActuator end

mutable struct ManualActuator{MSG} <: AbstractManualActuator
    devname::String
    "Name variable commanded by `ManualActuator`"
    var::String
    "Present value of the actuator"
    val::Float64
    "Minimum value of `val`"
    minval::Float64
    "Maximum value of `val`"
    maxval::Float64
    "Interface to be used to actually wait for user input"
    interface::MSG
    "Time in seconds to wait after user presses ENTER"
    nsec::Float64
end
    

"""
`TermMSG`

Simple interface using `stdin` to get input from user
"""
struct TermMSG
    msg::String
    confirm::Bool
    TermMSG(msg="", confirm=true) = new(msg, confirm)
end

function (tmsg::TermMSG)(dev::T, x) where {T<:AbstractManualActuator}
    println(tmsg.msg)
    print("Set $(dev.devname) = $x and press ENTER to continue...")
    readline()
    
    if tmsg.confirm
        print("If ready, press ENTER to start...")
        readline()
    end
        
end


"""
`ManualActuator(devname, var, val, interf; minval=Inf, maxval=Inf, nsec=0.0)`

`ManualActuator(devname, var, val; minval=Inf, maxval=Inf, nsec=0.0)`

Creates a manual actuator. A manual actuator is an actuator that is not
automated. The operator should manually operate it.

This interface basically explicitly asks the operator to operate the actuator
and waits until the operator says it can go on. 

The issue here is the interface. The [`TermMSG`](@ref) uses the terminal to 
show information and get input from the operator. Other interfaces such as
different types of GUI could be implemented.

The only requirement is that the object of type `MSG` should be callable with 
two arguments: 

 * The `ManualActuator` itself
 * The position that the actuator should go to.

This function will get input from the user to do this.


"""
function ManualActuator(devname, var, val, interf::MSG; minval=-Inf,
                        maxval=Inf, nsec=0.0) where {MSG}
    ManualActuator{MSG}(devname, var, val, minval, maxval, interf, nsec)
end

ManualActuator(devname, var, val=0; minval=-Inf, maxval=Inf, nsec=0.0) =
    ManualActuator(devname, var, val, TermMSG(); minval=minval, maxval=maxval, nsec=nsec)

numaxes(dev::ManualActuator) = 1
axesnames(dev::ManualActuator) = [dev.var]

function move(dev::ManualActuator{T}, x) where{T}

    if x < dev.minval || x > dev.maxval
        throw(DomainError(x, "Outside valid range ($(dev.minval), $(dev.maxval))"))
    end
    dev.interface(dev, x)
    dev.val = x
    sleep(dev.nsec)
    return
    
end

moveto(dev::ManualActuator{T}, x) where{T} = move(dev, x[1])
devposition(dev::ManualActuator) = dev.val

