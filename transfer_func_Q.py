"""
    Created on Wed May 6, 2015
    
    @author: mlu
http://demonstrations.wolfram.com/ResonanceLineshapesOfADrivenDampedHarmonicOscillator/


"""

import math
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import cmath as cmath
from scipy import signal
import os
#from scipy.signal import argrelextrema


datdir = ""

datfiles = ("sampledata.txt",)
os.chdir("/Users/marielu/Documents/Stanford/Physics_108/maltballs/data/Run1/Good/")

n = len(os.listdir('.'))



allQ = []
allfreq = []
allQ_std = []
all_noise = []
all_noise_omega = []
k_b = 1.381E-23
T = 300
m = 0

L = 1.07E-3
R = 996.0
C = 3.16E-10


def Q_fac (hw, omega_0):
    return omega_0/abs(hw)

def Lorentzian (x, A, B, x0):
    return A/((B)**2+(x-x0)**2)

def noise(phi, omega):
    return (4*k_b*T*(omega_0**2)*phi)/(omega*(((omega_0**2)-m*(omega**2))**2+(omega_0**2)*(phi**2)))

init = [1E-5, 1E-1, 2.318E5]
for filename in os.listdir('.'):
    if (filename[0] == '.'):
        continue
    #datfile = datfiles[ii]
    #print filename
    file = np.loadtxt(filename)
    freq = file[:,0]
    data = file[:,1]
    fig5 = plt.figure(5)
    plt.plot(freq, data)
    plt.show()
    data = np.power(10, (data-30)/10)


    fig2 = plt.figure(2)
    plt.plot(freq[100:220], data[100:220])
    plt.show()

    
    
    coef, cov= sp.optimize.curve_fit(Lorentzian, freq[100: 220], data[100: 220], init)
    #print coef
    hw = coef[1]
    omega_0 = coef[2]
    
    ##### find x value that corresponds to half max on left and right half
    #print Q_fac(hw, omega_0)
    allQ.append(Q_fac(hw, omega_0))
    allfreq.append(omega_0)
    #allQ_std.append(2*omega_0*np.sqrt(cov[1][1])/(hw**2))
    #all_noise_omega.append(coef[2])
    #all_noise.append(noise(1/Q_fac(hw, omega_0), coef[2]))
    
    fig1 = plt.figure(1)
    plt.plot(freq[100:300], data[100:300])
    plt.plot(freq, Lorentzian(freq, coef[0], coef[1], coef[2]))
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Power")
    plt.show()
    init = coef


fig3 = plt.figure(3)
plt.plot(allQ)
fig4 = plt.figure(4)
plt.plot(allfreq)
plt.show()



'''for kk in range(len(allQ)):
    
    print allQ[kk]#, allQ_std[kk]
    print (1/R)*(L/C)**.5
    print omega_0*2*math.pi*L/R'''

