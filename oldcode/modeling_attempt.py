# coding: utf-8
freq, gain = loadtxt('data/2015-05-23 15.56.30', unpack=True)
freq, backg = loadtxt('data/2015-05-23 15.56.55', unpack=True)
plot(freq, gain-backg);show()
signal = gain - backg
from scipy.optimize import curve_fit
get_ipython().magic(u'pinfo curve_fit')
import rlccgain as g
def fn(f, p):
    return g.rlcc_gain(f, *p)
popt, pcov = curve_fit(fn, freq, signal)
popt, pcov = curve_fit(g.rlcc_gain, freq, signal)
plot(freq, signal, '.')
plot(freq, g.rlcc_gain(freq, *popt))
popt
__
__.clear()
blerp = __[0]
blerp.clear()
practice = g.rlcc_gain(linspace(1, 5e5, 1e6), 996, 1.07e3, 3.16e-16, 1e-16)
f=linspace(1, 5e5, 1e6);plot(f, g.rlcc_gain(f, 996, 1.07e3, 3.16e-16, 1e-16))
f=linspace(1, 5e5, 1e6);plot(f, g.rlcc_gain(f, 996, 1.07, 3.16e-13, 1e-13))
f=linspace(1, 5e5, 1e6);plot(f, g.rlcc_gain(f, 996, 1.07, 3.16e-13, 1e-10))
f=linspace(1, 5e5, 1e6);plot(f, g.rlcc_gain(f, 1, 1.07, 3.16e-13, 1e-10))
plot(freq, signal)
plot(freq, gain)
254.95*1e3
_**-1
_**2
C = 1.538e-11
L = 1e6
R = 1e6
Cft = 1e-11
f=linspace(1, 5e5, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
1/sqrt(L*C)
1/254950e3**2
C = _
Cft = 1e-17
1/sqrt(L*C)
f=linspace(1, 5e5, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
C/=(2*pi)**2
C
1/sqrt(L*C)
Cft = 1e-19
f=linspace(1, 5e5, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
Cft = 1e-10
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
plot(freq, gain)
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
plot(freq, 10**(gain/10))
R = 1e-3;L = 1e5*R/254950;C=1/(254950*2*pi)**2
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
Cft = 1e-17
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
1/sqrt(L*C)
R = 1e-3;L = 1e5*R/254950;C=1/(254950*2*pi)**2/L
1/sqrt(L*C)
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
Cft = 1e-10
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
Cft = 1e-7
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
Cft = 1e-4
f=linspace(254900, 255000, 1e6);plot(f, g.rlcc_gain(f, R, L, C, Cft))
f=linspace(254900, 255000, 1e6);plot(log10(f), g.rlcc_gain(f, R, L, C, Cft))
Cft = 1e-2
f=linspace(254900, 255000, 1e6);plot(log10(f), g.rlcc_gain(f, R, L, C, Cft))
plot(freq, gain)
f=linspace(254900, 255000, 1e6);plot(log10(f), g.rlcc_gain(f, R, L, C, Cft))
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
plot(freq, gain)
plot(freq, signal)
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
R = 1e-3;L = 1e4*R/254950;C=1/(254950*2*pi)**2/L
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
plot(freq, signal)
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
Cft = 1e-3
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
Cft = 1e-5
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
Cft = 1e-3
f=linspace(254900, 255000, 1e6);plot(f, log10(g.rlcc_gain(f, R, L, C, Cft)))
def to_fit(freq, R, L, C, Cft):
    return log10(g.rlcc_gain(f, R, L, C, Cft)
    
    )
get_ipython().magic(u'pinfo curve_fit')
popt, pcov = curve_fit(to_fit, freq, signal, (R, L, C, Cft))
freq, gain = loadtxt('data/2015-05-23 15.56.30')
freq, gain = loadtxt('data/2015-05-23 15.56.30', unpack=True)
popt, pcov = curve_fit(to_fit, freq, signal, (R, L, C, Cft))
len(freq)
def to_fit(freq, R, L, C, Cft):
    return log10(g.rlcc_gain(freq, R, L, C, Cft)
    
    )
popt, pcov = curve_fit(to_fit, freq, signal, (R, L, C, Cft))
plot(freq, signal)
plot(freq, signal, '.')
plot(freq, to_fit(freq, *popt))
popt, pcov = curve_fit(to_fit, freq, signal, popt)
plot(freq, signal, '.');plot(freq, to_fit(freq, *popt))
popt, pcov = curve_fit(to_fit, freq, signal, popt)
plot(freq, signal, '.');plot(freq, to_fit(freq, *popt))
pcov
popt, pcov = curve_fit(to_fit, freq, signal, popt)
pcov
plot(freq, signal, '.');plot(freq, to_fit(freq, *popt))
popt, pcov = curve_fit(to_fit, freq, signal, popt)
plot(freq, signal, '.');plot(freq, to_fit(freq, *popt))
popt, pcov = curve_fit(to_fit, freq, signal, popt)
plot(freq, signal, '.');plot(freq, to_fit(freq, *popt))
popt, pcov = curve_fit(to_fit, freq, signal, popt)
plot(freq, signal, '.');plot(freq, to_fit(freq, *popt))
popt
plot(freq, signal)
get_ipython().magic(u'save 1-112 modeling_attempt.py')
