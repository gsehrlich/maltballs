#!/usr/bin/ipython

import os, sys
import numpy as np
import datetime
import time
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

def main():
	voltages = open("temp_voltages.txt")
	counter = 0
	date_vec = []
	volt_vec = []
	temp_vec = []
	for line in voltages:
		datestr = line[:25]
		date = datetime.datetime.strptime(datestr, "%Y-%m-%d %H:%M:%S.%f")
		voltage = float(line[29:-8])
		temperature = -464.83 * voltage + 553.72
		date_vec.append(date)
		volt_vec.append(voltage)
		temp_vec.append(temperature)
		counter = counter + 1
	print counter
	
	plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S'))
	plt.plot(date_vec,temp_vec)
	plt.gcf().autofmt_xdate()
	plt.show()

if __name__ == '__main__': main()