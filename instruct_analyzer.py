import visa
import numpy as np
import time
import datetime

span = 20 	# hz
N_data_points = 101
gpib_addr = 'gpib0::17::instr'
keep_peak_at_dbm = -40
wait_30hz = 11.83 + 1
wait_10hz = 47.58 + 1
time_fmt = "%04d-%02d-%02d %02d.%02d.%02d"
direc = "data/run2/"

def now():
	return tuple(datetime.datetime.now().timetuple()[:6])

def get_gain_phase():
	na.write('chan1') # gain data
	gain = np.array([float(g) for g in na.query_ascii_values('outpdtrc?')[::2]])
	na.write('chan2') # phase data
	phase = np.array([float(g) for g in na.query_ascii_values('outpdtrc?')[::2]])
	return gain, phase

# get instrument
na = visa.ResourceManager().get_instrument(gpib_addr)

# make sure span and # points are what they're supposed to be
na.write('span %d' % span)
na.write('poin %d' % N_data_points)

# find peak freq, then set bw back to 30 hz
na.write('seam max'); na.write('mkrcent')
na.write('bw 30')

# get freq array
start = float(na.query('star?'))
stop = float(na.query('stop?'))
freq_arr = np.linspace(start, stop, N_data_points)

# find peak val, then scale input voltage to keep const
na.write('seam peak')
max_gain = float(na.query_ascii_values('outpmkr?')[0])
# source_dbm + max_gain should be == keep_peak_at_dbm
new_source_dbm = keep_peak_at_dbm - max_gain
na.write('powe %f' % new_source_dbm)

# get one measurement
time_started = now()
na.write('sing')
time.sleep(wait_30hz)
time_finished = now()

# get gain + phase and write to file
gain, phase = get_gain_phase()
filename = direc + "30hz/" + time_fmt % time_started
header = "Time finished\n" + time_fmt % time_finished
np.savetxt(filename, zip(freq_arr, gain, phase), header=header)

# set bw to 10 hz
na.write('bw 10')

# get next measurement
time_started = now()
na.write('sing')
time.sleep(wait_10hz)
time_finished = now()

# get gain + phase
gain, phase = get_gain_phase()
filename = direc + "10hz/" + time_fmt % time_started
header = "Time finished\n" + time_fmt % time_finished
np.savetxt(filename, zip(freq_arr, gain, phase), header=header)

# set bw back to 100 hz and run cont
na.write('bw 100')
na.write('cont')