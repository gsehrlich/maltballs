import visa
import numpy as np
import time
import datetime
import record_temp

span = 20     # hz
N_data_points = 101
na_gpib_addr = 'gpib0::17::instr' # network analyzer
volt_source_gpib_addr = "gpib0::5::instr" # voltage source for DC bias
DC_on = 8 # volts
DC_off = 0 # volts
keep_peak_at_dbm = -40
measurement_wait = {30: 11.83 + 1, 10: 47.58 + 1}
time_fmt = "%04d-%02d-%02d %02d.%02d.%02d"
direc = "data/run2/"

# Passed as arg to time.sleep inside run_loop.py
dt = 1 # sec; measurement itself takes long enough

def now():
    return tuple(datetime.datetime.now().timetuple()[:6])

def center_peak():
    na.write('seam max')
    na.write('mkrcent')

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

def take_measurement(if_bw, freq_arr, DC_is_on, DC_bias):
    # Set IF bandwidth and whether voltage source is on
    na.write('bw %d' % if_bw)
    volt_source.write('sour:volt %.2f' % DC_bias)

    DC_bias = get_DC_bias()

    # get one measurement
    T_V_start = record_temp.read_voltage()
    time_started = now()
    na.write('sing')
    time.sleep(measurement_wait[if_bw])
    time_finished = now()
    T_V_stop = record_temp.read_voltage()

    # get gain + phase and write to file
    gain, phase = get_gain_phase()
    filename = direc + "%dhz_%s/" % (if_bw, "osc" if DC_is_on else "ref")
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
                    "DC bias:",
                    str(DC_bias)]
    header = '\n'.join(header_lines)
    np.savetxt(filename, zip(freq_arr, gain, phase), header=header)

def get_DC_bias():
    return float(volt_source.query('meas?'))

# get network analyzer and voltage source
rm = visa.ResourceManager()
na = rm.get_instrument(na_gpib_addr)
volt_source = rm.get_instrument(volt_source_gpib_addr)

# make sure span and # points are what they're supposed to be
# and voltage source output is on
na.write('span %d' % span)
na.write('poin %d' % N_data_points)
#volt_source.write('outp on')
volt_source.write('sour:volt %.2f' % DC_on)

# autoscale so display is readable
na.write("chan1")
na.write("auto")
na.write("chan2")
na.write("auto")
na.write("chan1")

# find peak freq and get new frequency array
center_peak()
freq_arr = get_freq_arr()

# find peak val, then scale input voltage to keep const
na.write('seam max')
max_gain = float(na.query_ascii_values('outpmkr?')[0])
# source_dbm + max_gain should be == keep_peak_at_dbm
new_source_dbm = keep_peak_at_dbm - max_gain
na.write('powe %.6f' % new_source_dbm)

# get oscillator measurement at 30 hz
take_measurement(30, freq_arr, True, DC_on)

# get 30 hz reference measurement
take_measurement(30, freq_arr, False, DC_off)

# find peak freq and get new frequency array
center_peak()
freq_arr = get_freq_arr()

# get oscillator measurement at 10 hz
take_measurement(10, freq_arr, True, DC_on)

# get 10 hz reference measurement
take_measurement(10, freq_arr, False, DC_off)

# set bw back to 100 hz, turn DC bias back on, and run continuously
volt_source.write('sour:volt %.2f' % DC_on)
na.write('bw 30')
na.write('cont')