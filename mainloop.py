#!/usr/bin/python

import sendheat, gettemp, sendinput, getoutput
import os
import datetime
import time
import numpy as np

def make_datafile():
    """Make a timestamped data file for this run and return it"""
    pass

def main():
    """Loop through user input, PID loop, and data gathering"""

    # Get data file
    f = make_datafile()
    print "Writing in file %r" % f.name
    
    # Start just measuring temperature
    getting_temp = True
    sending_heat = False
    gathering_data = False
    stoploop = False
    fmt = "%g\t%g\t%g\t%g\n"
    dt = 1000

    while not stoploop:
        # get user input somehow

        if getting_temp:
            T = gettemp.gettemp()

        if sending_heat:
            heat_sent = sendheat.sendheat(T)
        else: heat_sent = None

        if gathering_data:
            input_satus = sendinput.get_status()
            out = getoutput.getoutput()
        else:
            input_status = None
            out = None

        # progressively write to file
        to_write = fmt % (T, heat_sent, input_status, out)
        f.write(to_write)

        # wait for dt milliseconds
        time.sleep(dt)

if __name__ == '__main__': main()
