import visa
import numpy as np
import time
import datetime
import record_temp

span = 20 	# hz
N_data_points = 101
gpib_addr = 'gpib0::17::instr'
keep_peak_at_dbm = -40
measurement_wait = {30: 11.83 + 1, 10: 47.58 + 1}
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

def take_measurement(if_bw, DC_on=True):
	# get one measurement
	T_V_start = record_temp.read_voltage()
	time_started = now()
	na.write('sing')
	time.sleep(measurement_wait[if_bw])
	time_finished = now()
	T_V_stop = record_temp.read_voltage()

	# get gain + phase and write to file
	gain, phase = get_gain_phase()
	filename = direc + "%dhz_%s/" % (if_bw, "gain" if DC_on else "ref")
	fiename += time_fmt % time_started
	header = "Time finished, temp volt start, temp volt stop:\n"
	header += time_fmt % time_finished
	header += str(T_V_start)
	header += str(T_V_start)
	np.savetxt(filename, zip(freq_arr, gain, phase), header=header)

# get instrument
na = visa.ResourceManager().get_instrument(gpib_addr)

# make sure span and # points are what they're supposed to be
na.write('span %d' % span)
na.write('poin %d' % N_data_points)

# find peak freq
na.write('seam max'); na.write('mkrcent')

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

# get measurement at 30 hz
na.write('bw 30')
take_measurement(30)

# get 30 hz reference gain


# get measurement at 10 hz
na.write('bw 10')
take_measurement(10)

# set bw back to 100 hz and run cont
na.write('bw 100')
na.write('cont')