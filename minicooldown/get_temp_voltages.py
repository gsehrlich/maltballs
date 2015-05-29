#!/usr/bin/ipython

import gettemp
#import visa
import os, sys
import datetime
import time
import numpy as np
#visa.log_to_screen()

def main():
	time_steps = 960
	time_interval = 60 #in seconds
#	rm = visa.ResourceManager()
#	temp_volt_inst = rm.get_instrument('GPIB0::2::INSTR')

	for x in xrange(time_steps):
		temp_volt = -9001
#		temp_volt = temp_volt_inst.query_ascii_values('meas?')[0]
		temp_volt = gettemp.get_temp_volt()
		curr_time = datetime.datetime.now()
		with open("temp_voltages.txt", "a" ) as temp_voltages: 
			temp_voltages.write(str(curr_time) + " - " + str(temp_volt)+" Volts \n")
		time.sleep(time_interval)



if __name__ == '__main__': main()