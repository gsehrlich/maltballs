#!/usr/bin/ipython

import gettemp
import os, sys
import datetime
import time
import numpy as np

def read_voltage():
	temp_volt = gettemp.get_temp_volt()
	curr_time = datetime.datetime.now()
	with open("temp_voltages.txt", "a" ) as temp_voltages: 
		temp_voltages.write(str(curr_time) + " - " + str(temp_volt)+" Volts \n")

