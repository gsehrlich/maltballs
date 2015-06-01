from pylab import *

def denom(omega, R, L, C):
	return R**2 + (omega*L - 1/omega/C)**2

def rlcc_gain(f, R, L, C, Cft):
	omega = f*2*pi
	d = denom(omega, R, L, C)
	print denom
	num  = R**2 + (Cft*omega*d - omega*L + 1/omega/C)**2
	print num
	return num/d**2