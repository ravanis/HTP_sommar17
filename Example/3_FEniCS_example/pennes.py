# coding: latin-1
import sys
import h5py

from dolfin import *
import numpy as np

# Load in .mat parameter
# The optional input argument 'degree' is FEniCS internal interpolation type.
# The loaded data will additionally be fit with trilinear interpolation.
def load_data(filename, degree=0):
    
    # Load the .mat file
    f = h5py.File(filename, "r")
    data = np.array(f.items()[0][1], dtype=float)
    f.close()

    # Load the intepolation c++ code
    f = open('TheGreatInterpolator.cpp', "r")
    code = f.read()
    f.close()

    # Amend axis ordering to match layout in memory
    size = tuple(reversed(np.shape(data)))

    # Add c++ code to FEniCS
    P = Expression(code, degree=degree)

    # Add parameters about the data
    P.stridex  = size[0]
    P.stridexy = size[0]*size[1]
    P.sizex = size[0]
    P.sizey = size[1]
    P.sizez = size[2]
    P.sidelen = 1.0/1000

    # As the last step, add the data
    P.set_data(data)
    return P

# Load mesh
print("Reading and unpacking mesh...")
mesh = Mesh('../2_Prep_FEniCS_results/mesh.xml')

# Define material properties
# -------------------------
# T_b:      blood temperature [K relative body temp]
# P:        power loss density [W/m^3]
# k_tis:    thermal conductivity [W/(m K)]
# w_c_b:    volumetric perfusion times blood heat capacity [W/(m^3 K)]
# alpha:    boundary heat transfer constant [W/(m^2 K)]
# T_out_ht  alpha times ambient temperature [W/(m^2)]

print('Importing material properties...')
T_b = Constant(0.0) # Blood temperature relative body temp
P        = load_data("../2_Prep_FEniCS_results/P.mat")
k_tis    = load_data("../2_Prep_FEniCS_results/thermal_cond.mat")
w_c_b    = load_data("../2_Prep_FEniCS_results/perfusion_heatcapacity.mat")
alpha    = load_data("../2_Prep_FEniCS_results/bnd_heat_transfer.mat", 0)
T_out_ht = load_data("../2_Prep_FEniCS_results/bnd_temp_times_ht.mat", 0)

#-----------------------
Tmax= 8  # 0 = 37C
Tmin=7.5   # 0 = 37C
scale= 1
maxIter=60
#-----------------------

with open("../2_Prep_FEniCS_results/amplitudes.txt") as file:
    amplitudes = []
    for line in file:
        amplitudes.append(line.rstrip().split(","))

with open("../2_Prep_FEniCS_results/ampLimit.txt") as file:
    ampLimit = []
    for line in file:
        ampLimit.append(line.rstrip().split(","))

print("Done loading.")

#Change type of data
al=ampLimit[0][0]
ampLimit=int(float(al))
maxAmpl=max(amplitudes)
maxAmp=int(maxAmpl[0][0])
maxAmp=int(float(maxAmp))

# Define solution space to be continuous piecewise linear
V = FunctionSpace(mesh, "CG", 1)
u = TrialFunction(V)
v = TestFunction(V)

scaleTot=scale;
nbrIter=0;
T=0
done=False

while ((np.max(T)<Tmin or np.max(T)>Tmax) and nbrIter<maxIter):
    
    #If amplitude is too high, maxAmp is set to amlitude limit
    if (maxAmp>ampLimit and np.max(T)<Tmax):
        nbrIter= nbrIter+1
        scaleAmp=(ampLimit/maxAmp)**2
        maxAmp=ampLimit
        scaleTot=scaleTot*(scaleAmp)
        P=P*scaleAmp
    
        V = FunctionSpace(mesh, "CG", 1)
        u = TrialFunction(V)
        v = TestFunction(V)
        # Variation formulation of Pennes heat equation
        a = v*u*alpha*ds + k_tis*inner(grad(u), grad(v))*dx + w_c_b*v*u*dx
        L = T_out_ht*v*ds + P*v*dx # + w_c_b*T_b*v*dx not needed due to T_b = 0
        
        u = Function(V)
        solve(a == L, u, solver_parameters={'linear_solver':'gmres'}) #gmres is fast
        T =u.vector().array()
        print "Tmax:"
        print np.max(T)
        print "Scale:"
        print scaleTot
        done = True # exit loop
    
    elif (maxAmp<=ampLimit):
        nbrIter= nbrIter+1
        V = FunctionSpace(mesh, "CG", 1)
        u = TrialFunction(V)
        v = TestFunction(V)
        # Variation formulation of Pennes heat equation
        a = v*u*alpha*ds + k_tis*inner(grad(u), grad(v))*dx + w_c_b*v*u*dx
        L = T_out_ht*v*ds + P*v*dx # + w_c_b*T_b*v*dx not needed due to T_b = 0
        u = Function(V)
        solve(a == L, u, solver_parameters={'linear_solver':'gmres'}) #gmres is fast
    
        #Use T to find the scale for P and maxAmp (increase T)
        if(np.max(T)<Tmin):
            if(np.max(T)<0.4*Tmin):
                P=P*(1.5*scale)
                scaleTot=scaleTot*1.5*scale
                maxAmp=sqrt(1.5*scale)*maxAmp
            elif (np.max(T)>=0.4*Tmin and np.max(T)<0.8*Tmin):
                P=P*(1.3*scale)
                scaleTot=scaleTot*1.3*scale
                maxAmp=sqrt(1.3*scale)*maxAmp
            elif (np.max(T)>=0.8*Tmin):
                P=P*1.05*scale
                scaleTot=1.05*scaleTot*scale
                maxAmp=sqrt(1.05*scale)*maxAmp
        #Use T to find the scale for P and maxAmp (decrease T)
        if(np.max(T)>Tmax):
            if(np.max(T)>1.4*Tmax):
                P=P*(0.5*scale)
                scaleTot=scaleTot*(0.5*scale)
                maxAmp=sqrt(0.5*scale)*maxAmp
            elif(np.max(T)>1.2*Tmax and np.max(T)<=1.4*Tmax):
                P=P*(0.65*scale)
                scaleTot=scaleTot*(0.65*scale)
                maxAmp=sqrt(0.65*scale)*maxAmp
            elif (np.max(T)<=1.2*Tmax):
                P=P*(0.8*scale)
                scaleTot=scaleTot*(0.8*scale)
                maxAmp=sqrt(0.8*scale)*maxAmp

        T =u.vector().array()
    
    print "Tmax:"
    print np.max(T)
    print "Scale:"
    print scaleTot
    print "MaxAmp:"
    print maxAmp

    if(done):
        break

# Last step
if ((np.max(T)>Tmin and np.max(T)<Tmax and maxAmp<=ampLimit) or maxAmp==ampLimit):
    # Plot solution and mesh
    plot(u)
    plot(mesh)
    
    # Dump solution to file in VTK format         Pvd is used for Paraview, not needed in MATLAB
    #file = File("../3_FEniCS_results/temperature.pvd")
    #u.rename('Temperature','ThisIsSomeString')
    #file << u

    # Save data in a format readable by matlab
    Coords = mesh.coordinates()
    Cells  = mesh.cells()

    f = h5py.File('../3_FEniCS_results/temperature.h5','w')

    f.create_dataset(name='Temp', data=T)
    f.create_dataset(name='P',    data=Coords)
    f.create_dataset(name='T',    data=Cells)
    # Need a dof(degree of freedom)-map to permutate Temp
    f.create_dataset(name='Map',  data=dof_to_vertex_map(V))

    f.close()
    
    #Scale amplitudes and save in a new file
    amplitudeVec=[]
    fileAmp=open('../3_FEniCS_results/scaledAmplitudes.txt','w')
    for x in amplitudes:
        a=float(x[0])
        a=(round(a*100))*sqrt(scaleTot)/100
        amplitudeVec.append(a)
        fileAmp.write(str(a) + " ")

    fileAmp.close()

    #Print parameters
    print "Tmax:"
    print np.max(T)
    print "Scale:"
    print scaleTot
    print "Nbr of iterations:"
    print nbrIter
    print "MaxAmp:"
    print maxAmp

else:
   print "Not enough iterations"

