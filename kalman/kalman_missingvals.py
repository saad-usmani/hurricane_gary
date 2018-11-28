from pykalman import KalmanFilter
import numpy as np
import matplotlib.pyplot as plt
from numpy import ma

# enable or disable missing observations
use_mask = 1

# reading data (quick and dirty)
Time=[]
X=[]

for line in open('data/dataset_01.csv'):
    f1, f2  = line.split(';')
    Time.append(float(f1))
    X.append(float(f2))

if (use_mask):
    X = ma.asarray(X)
    X[300:500] = ma.masked

# Filter Configuration

# time step
dt = Time[2] - Time[1]

# transition_matrix  
F = [[1,  dt,   0.5*dt*dt], 
     [0,   1,          dt],
     [0,   0,           1]]  

# observation_matrix   
H = [1, 0, 0]

# transition_covariance 
Q = [[   1,     0,     0], 
     [   0,  1e-4,     0],
     [   0,     0,  1e-6]] 

# observation_covariance 
R = [0.04] # max error = 0.6m

# initial_state_mean
X0 = [0,
      0,
      0]

# initial_state_covariance
P0 = [[ 10,    0,   0], 
      [  0,    1,   0],
      [  0,    0,   1]]

n_timesteps = len(Time)
n_dim_state = 3

filtered_state_means = np.zeros((n_timesteps, n_dim_state))
filtered_state_covariances = np.zeros((n_timesteps, n_dim_state, n_dim_state))

# Kalman-Filter initialization
kf = KalmanFilter(transition_matrices = F, 
                  observation_matrices = H, 
                  transition_covariance = Q, 
                  observation_covariance = R, 
                  initial_state_mean = X0, 
                  initial_state_covariance = P0)


# iterative estimation for each new measurement
for t in range(n_timesteps):
    if t == 0:
        filtered_state_means[t] = X0
        filtered_state_covariances[t] = P0
    else:
        filtered_state_means[t], filtered_state_covariances[t] = (
        kf.filter_update(
            filtered_state_means[t-1],
            filtered_state_covariances[t-1],
            observation = X[t])
        )

position_sigma = np.sqrt(filtered_state_covariances[:, 0, 0]);        

# plot of the resulted trajectory        
plt.plot(Time, filtered_state_means[:, 0], "g-", label="Filtered position", markersize=1)
plt.plot(Time, filtered_state_means[:, 0] + position_sigma, "r--", label="+ sigma", markersize=1)
plt.plot(Time, filtered_state_means[:, 0] - position_sigma, "r--", label="- sigma", markersize=1)
plt.grid()
plt.legend(loc="upper left")
plt.xlabel("Time (s)")
plt.ylabel("Position (m)")
plt.show()      