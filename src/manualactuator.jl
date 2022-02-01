
export ManualActuator

"""
`AbstractManualActuator`

An abstract interface to actuators with manual input.
"""
abstract type AbstractManualActuator end

mutable struct ManualActuator{MSG} <: AbstractActuator
    "Name variable commanded by `ManualActuator`"
    var::String
    "Present value of the actuator"
    val::Float64
    "Message presented to the user"
    msg::String
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
end

"""
`ManualActuator(var, val, interf, msg="", minval=Inf, maxval=Inf, nsec=0.0)`

`ManualActuator(var, val, msg="", minval=Inf, maxval=Inf, nsec=0.0)`

Creates a manual actuator.

"""
function ManualActuator(var, val, interf::MSG; msg="", minval=Inf,
                        maxval=Inf, nsec=0.0) where {MSG}
    ManualActuator{MSG}(var, val, msg, minval, maxval, interf, nsec)
end

ManualActuator(var, val; msg="", minval=Inf, maxval=Inf, nsec=0.0) =
    ManualActuator(var, val, TermMSG(); msg=msg,
                   minval=minval, maxval=maxval, nsec=nsec)

function move(dev::ManualActuator{TermMSG}, x) where{MSG}

    if x < dev.minval || x > dev.maxval
        throw(DomainError(x, "Outside valid range ($(dev.minval), $(dev.maxval))"))
    end
    
    print("$(dev.msg) $(dev.var) = $x ")
    readline(stdin)
    print("Ok?")
    readline(stdin)
    sleep(dev.nsec)

    return
    
end

position(dev::ManualActuator) = dev.val

