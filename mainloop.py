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

    #while temp isn't steady
    while not stoploop:
        #fetch curr temp
        T = gettemp.gettemp()
        #send heat
        heat_sent = sendheat.sendheat(T)
        #check if temp has been steady
        stoploop = is_steady(T, heat_sent)

        # progressively write to file
        to_write = fmt % (T, heat_sent, input_status, out)
        f.write(to_write)

        # wait for dt milliseconds
        time.sleep(dt)


    #say temp is steady, and starting data gathering
    print "Steady Temperature achieved. Gathering data." 


    #for gathering data criterea (time or even out)
    while not stoploop:
        #fetch curr temp
        T = gettemp.gettemp()
        #hold heat
        heat_sent = sendheat.holdtemp(T)
        #check if temp has been steady
        stoploop = is_steady(T, heat_sent)

        #send signal
        input_status = sendinput.get_status()
        #fetch data
        out = getoutput.getoutput()

         # progressively write to file
        to_write = fmt % (T, heat_sent, input_status, out)
        f.write(to_write)

        # wait for dt milliseconds
        time.sleep(dt)


if __name__ == '__main__': main()
