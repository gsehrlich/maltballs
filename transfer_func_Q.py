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

dir1 = ("data/run2/30hz_osc/")
dir2 = ("data/run2/30hz_ref/")
dir3 = ("data/run2/10hz_osc/")
dir4 = ("data/run2/10hz_ref/")


k_b = 1.381E-23
T = 300
m = 0
init = [1E-5, 1E-1, 2.318E5]
dt = 3600 #sec that run_loop will call this.

def Q_fac (hw, omega_0):
    return omega_0/abs(hw)

def Lorentzian (x, A, B, x0):
    return A/((B)**2+(x-x0)**2)

def noise(phi, omega):
    return (4*k_b*T*(omega_0**2)*phi)/(omega*(((omega_0**2)-m*(omega**2))**2+(omega_0**2)*(phi**2)))


def get_Q(directory_gain, directory_ref, init):

    alltemp = []
    allQ = []
    allfreq = []
##### GET GAIN DATA
    files_gain = os.listdir(directory_gain)
    
    length = len(files_gain)
##### GET REF DATA
    files_ref = os.listdir(directory_ref)

    for i in range(length): #for each file in the gain directory take off ref data and get Q
        filename_gain = files_gain[i]
        filename_ref = files_ref[i]
        

#####LOAD GAIN DATA
        if (filename_gain[0] == '.'): #ignore funky files
            continue
        
        fp = open(directory_gain+filename_gain)
        t_begin = 0
        t_end = 0
        for i, line in enumerate(fp):
            i+=1
            if i == 8:
                t_begin = np.float(line[2:])
            elif i == 10:
                t_end = np.float(line[2:])
            elif i > 10:
                    break
        fp.close()
        
        t_avg = (t_begin+t_end)/2
        alltemp.append(t_avg)
        file_gain = np.loadtxt(directory_gain+filename_gain)
        freq_gain = file_gain[:,0]
        data_gain = file_gain[:,1]
        '''fig5 = plt.figure(5)
            plt.plot(freq, data)
            plt.show()'''
        data_gain = np.power(10, (data_gain-30)/10)
        
        
        
##### LOAD REF DATA
        if (filename_ref[0] == '.'):
            continue
        file_ref = np.loadtxt(directory_ref+filename_ref)
        data_ref = file_ref[:,1]
        data_ref = np.power(10, (data_ref-30)/10)


##### SUBTRACT REF DATA FROM GAIN DATA
        data_total = data_gain-data_ref

        '''fig2 = plt.figure(2)
        plt.plot(freq_gain, data_gain, 'b')
        plt.plot(freq_gain, data_ref, 'g')
        plt.plot(freq_gain, data_total, 'r')
        plt.show()'''
        
##### CURVE FIT DATA
        coef, cov= sp.optimize.curve_fit(Lorentzian, freq_gain, data_total, init)
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
    
        '''fig1 = plt.figure(1)
        plt.plot(freq_gain, data_total)
        plt.plot(freq_gain, Lorentzian(freq_gain, coef[0], coef[1], coef[2]))
        plt.xlabel("Frequency (Hz)")
        plt.ylabel("Power")
        plt.show()'''
        init = coef
    return allQ, allfreq, alltemp


q_list_30, freq_list_30, alltemp_30 = get_Q(dir1, dir2, init)
q_list_10, freq_list_10, alltemp_10 = get_Q(dir3, dir4, init)
total_freq_30 = zip(alltemp_30, freq_list_30)
total_q_30 = zip(alltemp_30, q_list_30)
total_freq_10 = zip(alltemp_10, freq_list_10)
total_q_10 = zip(alltemp_10, q_list_10)


file1 = open("data/run2/Q_list_30Hz", 'w')
file1.writelines(["%e\t%e\n" % item for item in total_q_30])

file2 = open("data/run2/Q_list_10Hz", 'w')
file2.writelines(["%e\t%e\n" % item for item in total_q_10])

file3 = open("data/run2/freq_list_30Hz", 'w')
file3.writelines(["%e\t%e\n" % item for item in total_freq_30])

file4 = open("data/run2/freq_list_10Hz", 'w')
file4.writelines(["%e\t%e\n" % item for item in total_freq_10])

file1.close()
file2.close()
file3.close()
file4.close()
'''fig10 = plt.figure(10)
plt.plot(freq_list_30, '*b')
fig11 = plt.figure(11)
plt.plot(q_list_30, 'ob')
fig12 = plt.figure(12)
plt.plot(freq_list_10, '*r')
fig13 = plt.figure(13)
plt.plot(q_list_10, 'or')
plt.show()'''



'''for kk in range(len(allQ)):
    
    print allQ[kk]#, allQ_std[kk]
    print (1/R)*(L/C)**.5
    print omega_0*2*math.pi*L/R'''

