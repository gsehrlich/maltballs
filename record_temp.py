#!/usr/bin/ipython

import gettemp
import os, sys
import datetime
import time
import numpy as np

def read_voltage():
	temp_volt = gettemp.get_temp_volt()
	curr_time = datetime.datetime.now()
	with open("data/run2/temp_voltages.txt", "a" ) as temp_voltages: 
		temp_voltages.writeline(str(curr_time) + " - " + str(temp_volt))

	return temp_volt

def get_temp(voltage):
	return -464.83 * voltage + 553.72 