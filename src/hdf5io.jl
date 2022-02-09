export saveactuatorconfig, saveexperimentmatrix

using HDF5


function saveactuatorconfig(h5, dev::AbstractActuator, idx=1)

    dtype = string(typeof(dev))
    dname = devname(dev)
    g = create_group(h5, dname)
    g["type"] = dtype
    g["axes"] = [string(a) for a in axesnames(dev)]
    g["idx"] = idx
    return
end


function saveexperimentmatrix(h5, pts::ExperimentMatrix, name="points")

    dtype = string(typeof(pts))
    g = create_group(h5, name)
    g["points"] = pts.pts
    g["params"] = matrixparams(pts)
    return
end

numstring(x, n=3) = string(10^n+x)[2:end]
function saveexperimentmatrix(h5, pts::CartesianExperimentMatrix, name="points")
    dtype = string(typeof(pts))
    g = create_group(h5, name)
    g["points"] = pts.pts
    params = matrixparams(pts)
    g["params"] = params
    nparams = length(params)
    g["nparams"] = nparams

    for i in 1:nparams
        nn = numstring(i, 4)
        g[nn] = pts.axes[i]
        attributes(g[nn])["param"] = params[i]
    end

    return

end

function saveexperimentmatrix(h5, pts::ExperimentMatrixProduct, name="points")
    dtype = string(typeof(pts))
    g = create_group(h5, name)
    g["points"] = experimentpoints(pts)
    params = matrixparams(pts)
    g["params"] = params
    nparams = length(params)
    g["nparams"] = nparams

    npoints = length(pts.points)
    g["npoints"] = npoints
    for i in 1:npoints
        nn = numstring(i, 4)
        saveexperimentmatrix(g, pts.points[i], nn)
    end

    return

end


        
    
    
    
    
