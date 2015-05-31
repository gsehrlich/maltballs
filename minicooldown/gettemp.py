#!/usr/bin/python

import visa

try:
	temp_voltmeter = visa.ResourceManager().get_instrument('gpib0::2::instr')
except VisaIOError as e:
	print e.message
	temp_voltmeter = e
else:
	print "Using temperature voltmeter:\n %s" % temp_voltmeter.query('*idn?')

def get_temp_volt(): 
	return float(temp_voltmeter.query_ascii_values('meas?')[0])

def get_temp(V):
	return 