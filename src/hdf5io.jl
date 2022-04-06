export saveactuatorconfig, saveexperimentmatrix

using HDF5

"""
`saveactuatorconfig(h5, dev::AbstractActuator)`

Saves an actuator configuration to a HDF5 file.
"""
function saveactuatorconfig(h5, dev::AbstractActuator)

    dtype = string(typeof(dev))
    dname = devname(dev)
    h5[dname] = [string(a) for a in axesnames(dev)]
    attributes(h5[dname])["devtype"] = dtype
    return
end

function saveactuatorconfig(h5, devs::AbstractVector{<:AbstractActuator})
    for actuator in devs
        saveactuatorconfig(h5, actuator)
    end
    return
end

"""
`saveactuatorconfig(h5, devs::ActuatorSet)`

Saves an [`ActuatorSet`](@ref) configuration to a HDF5 file. It basically 
saves the configuration of each individual actuator in the set.
"""
function saveactuatorconfig(h5, devs::ActuatorSet)

    dtype = string(typeof(devs))
    dname = devname(devs)
    axes = axesnames(devs)
    g = create_group(h5, dname)
    attributes(g)["axes"] = axes
    attributes(g)["type"] = dtype
    for actuator in devs.actuators
        saveactuatorconfig(g, actuator)
    end
    
    return

end

"""
`saveexperimentmatrix(h5, pts::ExperimentMatrix, name="points")`

Saves the experimental matrix points to an HDF5 file.
"""
function saveexperimentmatrix(h5, pts::ExperimentMatrix, name="points")

    params = matrixparams(pts)
    dtype = string(typeof(pts))
    nparams = length(params)
    g = create_group(h5, name)

    g["points"] = pts.pts
    attributes(g)["type"] = dtype
    attributes(g)["params"] = params
    attributes(g)["nparams"] = nparams
    
    return
end

"""
`saveexperimentmatrix(h5, pts::CartesianExperimentMatrix, name="points")`

Saves the `CartesianExperimentMatrix` points to an HDF5 file. This specific
method is useful when the points is the cartesian product of several axis
and you want to know each axis besides the coordinates of every point.
"""
function saveexperimentmatrix(h5, pts::CartesianExperimentMatrix, name="points")

    dtype = "CartesianExperimentMatrix"
    params = matrixparams(pts)
    nparams = length(params)

    g = create_group(h5, name)

    g["points"] = pts.pts
    
    attributes(g)["params"] = params
    attributes(g)["nparams"] = params
    attributes(g)["type"] = dtype
    
    for i in 1:nparams
        nn = numstring(i, 4)
        g[nn] = pts.axes[i]
        attributes(g[nn])["param"] = params[i]
    end

    return

end

function saveexperimentmatrix(h5, pts::ExperimentMatrixProduct, name="points")

    dtype = "ExperimentMatrixProduct"
    params = matrixparams(pts)
    nparams = length(params)

    g = create_group(h5, name)

    g["points"] = experimentpoints(pts)
    g["params"] = params
    g["nparams"] = nparams

    attributes(g)["params"] = params
    attributes(g)["nparams"] = params
    attributes(g)["type"] = dtype
    npoints = length(pts.points)
    attributes(g)["npoints"] = npoints
    for i in 1:npoints
        nn = numstring(i, 4)
        saveexperimentmatrix(g, pts.points[i], nn)
    end

    return

end


        
    
    
    
    
