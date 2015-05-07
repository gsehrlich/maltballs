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
from scipy.signal import argrelextrema


datdir = "/Users/marielu/Documents/Stanford/Physics_108/"

datfiles = ("sampledata.txt",)

allQ = []
allQ_std = []
all_noise = []
all_noise_omega = []
omega_0 = 398
k_b = 1.381E-23


def Q_fac (hw, omega_0):
    return omega_0/hw

def Lorentzian (x, A, B, x0, m, C):
    return A/(B**2+(x-x0)**2)

def noise(phi, omega):
    return (4*k_b*T*(omega_0**2)*phi)/(omega*(((omega_0**2)-m*(omega**2))**2+(omega_0**2)*(phi**2)))

for ii in range(len(datfiles)):
    
    datfile = datfiles[ii]
    cdat = np.loadtxt(datdir+datfile)
    
    init = [.0006, .8, 398, .00001, 0.001]
    
    coef, cov= sp.optimize.curve_fit(Lorentzian, cdat[:,0], cdat[:,1], init)
    #print coef
    hw = 2*coef[1]
    print cov
    
    ##### find x value that corresponds to half max on left and right half
    allQ.append(Q_fac(hw, omega_0))
    allQ_std.append(2*omega_0*np.sqrt(cov[1][1])/(hw**2))
    all_noise_omega.append(coef[2])
    all_noise.append(noise(1/Q_fac(hw, omega_0), coef[2]))
    
    fig = plt.figure(1)
    plt.plot(cdat[:,0], cdat[:,1])
    plt.plot(cdat[:,0], Lorentzian(cdat[:,0], coef[0], coef[1], coef[2], coef[3], coef[4]))
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Power")
    plt.show()



for kk in range(len(allQ)):
    
    print allQ[kk], allQ_std[kk]




