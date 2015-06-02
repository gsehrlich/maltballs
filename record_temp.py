#!/usr/bin/ipython

import os, sys
import datetime
import time
import numpy as np
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

def read_voltage():
	temp_volt = get_temp_volt()
	curr_time = datetime.datetime.now()
	with open("data/run2/temp_voltages.txt", "a" ) as temp_voltages: 
		temp_voltages.write(str(curr_time) + " - " + str(temp_volt) + "\n")

	return temp_volt

def get_temp(voltage):
	return -336.89*voltage**3 + 676.59*voltage**2 - 896.77*voltage + 649.61
