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
	return -336.89*voltage^3 + 676.59*voltage^2 - 896.77*voltage + 649.61
	