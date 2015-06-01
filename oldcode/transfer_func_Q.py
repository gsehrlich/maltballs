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
#from scipy.signal import argrelextrema


datdir = ""

datfiles = ("sampledata.txt",)

allQ = []
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

for ii in range(len(datfiles)):
    
    datfile = datfiles[ii]
    cdat = np.loadtxt(datdir+datfile)
    
    cdat[:, 1] = np.power(10, (cdat[:,1]-30)/10)

    '''
    fig2 = plt.figure(2)
    plt.plot(cdat[10:,0], cdat[10:,1])
    plt.show()
    '''
    
    
    init = [1E2, 1, 3E5]
    #init = [0, 0, 0, 0, 0]
    
    coef, cov= sp.optimize.curve_fit(Lorentzian, cdat[10:,0], cdat[10:,1])
    print coef
    hw = coef[1]
    print hw
    omega_0 = coef[2]
    print cov
    
    ##### find x value that corresponds to half max on left and right half
    allQ.append(Q_fac(hw, omega_0))
    allQ_std.append(2*omega_0*np.sqrt(cov[1][1])/(hw**2))
    #all_noise_omega.append(coef[2])
    #all_noise.append(noise(1/Q_fac(hw, omega_0), coef[2]))
    
    fig1 = plt.figure(1)
    plt.plot(cdat[10:,0], cdat[10:,1])
    plt.plot(cdat[:,0], Lorentzian(cdat[:,0], coef[0], coef[1], coef[2]))
    plt.plot(cdat[:,0], Lorentzian(cdat[:,0], 1E2, 1.038E4, 2.8238E5))
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Power")
    plt.show()



for kk in range(len(allQ)):
    
    print allQ[kk], allQ_std[kk]
    print (1/R)*(L/C)**.5
    print omega_0*2*math.pi*L/R

