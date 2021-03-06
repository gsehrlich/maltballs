import visa
import numpy as np
import time
import datetime
import record_temp

span = {30: 20, # at 30 hz bandwidth, span is 20 hz ######EDITED 20 TO 40
        10: 20} 
N_data_points = 101
na_gpib_addr = 'gpib0::17::instr' # network analyzer
volt_source_gpib_addr = "gpib0::5::instr" # voltage source for DC bias
DC_biases = [8, 4] # volts
DC_on = DC_biases[0]
DC_off = 0
keep_peak_at_dbm = -40
measurement_wait = {30: 0.2342/2*N_data_points + 1,
                    10: 0.9422/2*N_data_points + 1,
                    100: 0.1176/2*N_data_points + 1}
time_fmt = "%04d-%02d-%02d %02d.%02d.%02d"
direc = "data/run3/"

# Passed as arg to time.sleep inside run_loop.py
dt = 1 # sec; measurement itself takes long enough

def now():
    return tuple(datetime.datetime.now().timetuple()[:6])

def get_and_center_argmax():
    volt_source.write('sour:volt %.2f' % DC_on)
    na.write('bw 100') ######EDITED 100 TO 500
    na.write('sing')
    time.sleep(measurement_wait[100])
    na.write('seam max')
    na.write('mkrcent')
    return float(na.query('cent?'))

def find_centers(n, dt):
    # Estimate how fast the peak is moving, then return a list of n next centers

    # Get two measurements at 100 hz
    center1 = get_and_center_argmax()
    center2 = get_and_center_argmax()
    dt_100hz = measurement_wait[100]
    peak_v = (center2 - center1)/dt_100hz

    # Interpolate n next measurements
    begin_center = center2 + 0.5*dt_100hz*peak_v
    return tuple([begin_center + peak_v*(i + 0.5)*dt for i in xrange(n)])

def autoscale():
    na.write("chan1")
    na.write("auto")
    na.write("chan2")
    na.write("auto")
    na.write("chan1")

def get_freq_arr():
    start = float(na.query('star?'))
    stop = float(na.query('stop?'))
    actual_N = float(na.query('poin?'))
    return np.linspace(start, stop, actual_N)

def get_gain_phase():
    na.write('chan1') # gain data
    gain = np.array([float(g) for g in na.query_ascii_values('outpdtrc?')[::2]])
    na.write('chan2') # phase data
    phase = np.array([float(g) for g in na.query_ascii_values('outpdtrc?')[::2]])
    return gain, phase

def take_measurement(if_bw, freq_arr, DC_bias, power):
    # set span
    na.write('span %.2f' % span[if_bw])

    # Set IF bandwidth and whether voltage source is on
    na.write('bw %d' % if_bw)
    volt_source.write('sour:volt %.2f' % DC_bias)

    DC_bias_measured = get_DC_bias()

    # get one measurement
    T_V_start = record_temp.read_voltage()
    time_started = now()
    na.write('sing')
    time.sleep(measurement_wait[if_bw])
    time_finished = now()
    T_V_stop = record_temp.read_voltage()

    # get gain + phase and write to file
    gain, phase = get_gain_phase()
    filename = direc + "%dhz_%s/" % (if_bw, "%dV" % DC_bias)
    filename += time_fmt % time_started
    header_lines = ["Time finished:",
                    time_fmt % time_finished,
                    "Temp volt start:",
                    str(T_V_start),
                    "Temp volt stop:",
                    str(T_V_start),
                    "Approx start T:",
                    str(record_temp.get_temp(T_V_start)),
                    "Approx stop T:",
                    str(record_temp.get_temp(T_V_stop)),
                    "DC bias measured, messed up:",
                    str(DC_bias_measured),
                    "DC bias we asked for:",
                    str(DC_bias),
                    "Source power:",
                    str(power)]
    header = '\n'.join(header_lines)
    np.savetxt(filename, zip(freq_arr, gain, phase), header=header)

def get_DC_bias():
    return float(volt_source.query('meas?'))

# get network analyzer and voltage source
rm = visa.ResourceManager()
na = rm.get_instrument(na_gpib_addr)
volt_source = rm.get_instrument(volt_source_gpib_addr)

# make sure # points is what it's supposed to be
# and voltage source output is on
na.write('poin %d' % N_data_points)
#volt_source.write('outp on')
volt_source.write('sour:volt %.2f' % DC_on)

# autoscale so display is readable
autoscale()

# find peak val, then scale input voltage to keep const
na.write('seam max')
max_gain = float(na.query_ascii_values('outpmkr?')[0])
# source_dbm + max_gain should be == keep_peak_at_dbm
new_source_dbm = keep_peak_at_dbm - max_gain
na.write('powe %.6f' % new_source_dbm)
power = float(na.query('powe?'))

# find centers for the next n measurements
# autoscale again beacuse peak might have gone off the display
centers = find_centers(len(DC_biases), measurement_wait[30])
autoscale()

# get oscillator measurement at 30 hz
for center, DC_bias in zip(centers, DC_biases):
    na.write('cent %.7f' % center)
    freq_arr = get_freq_arr()
    volt_source.write('sour:volt %.2f' % DC_bias)
    take_measurement(30, freq_arr, DC_bias, power)
    volt_source.write('sour:volt %.2f' % DC_off)
    take_measurement(30, freq_arr, DC_off, power)

# find centers for the next n measurements
# autoscale again beacuse peak might have gone off the display
centers = find_centers(len(DC_biases), measurement_wait[10])
autoscale()

# get oscillator measurement at 10 hz
for center, DC_bias in zip(centers, DC_biases):
    na.write('cent %.7f' % center)
    freq_arr = get_freq_arr()
    volt_source.write('sour:volt %.2f' % DC_bias)
    take_measurement(10, freq_arr, DC_bias, power)
    volt_source.write('sour:volt %.2f' % DC_off)
    take_measurement(10, freq_arr, DC_off, power)

# set bw back to 100 hz, turn DC bias back on, center, and run continuously
center_peak() # this does a bunch of stuff
na.write('cont')
