#!/usr/bin/python

import sendheat, gettemp, sendinput, getoutput, transfer_func_Q as Qfit
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
    """
    f = make_datafile()
    print "Writing in file %r" % f.name"""

    # Start just measuring temperature
    params = {
            'temp_steady': False,
            'gathering_data': False,
            'stoploop': False,
            'fmt': "%s\t%s\t%s\t%s\n",
            'dt': 1
            }

    print "\nvvv Starting loop vvv\n"
    print "Press Ctrl + C to enter a command"
    # Outer loop, to make sure it's always in a try statement
    while True:
        try:
            run_loop(**params)
        except KeyboardInterrupt:
            print "\n\n^^^ Loop paused. ^^^\n"
            command = raw_input("Command: ")
            call_command(command, params)
            if params['stoploop']:
                print "Stopping loop."
                break
            else:
                print "Resuming loop."

def run_loop(temp_steady, gathering_data, stoploop, fmt, dt):
    #while temp isn't steady
    while not stoploop:
        print "Stepping!"
        #fetch curr temp
        T = gettemp.gettemp()
        
        if not temp_steady:
            #send heat
            heat_sent = sendheat.sendheat(T)
        if temp_steady:
            #hold heat
            heat_sent = sendheat.holdtemp(T)
        #check if temp has been steady
        temp_steady = sendheat.is_steady(T)

        if gathering_data:
            #send signal
            input_status = sendinput.get_status()
            #fetch data
            out = getoutput.getoutput()
        else:
            input_status = None
            out = None

        # progressively write to file
        to_write = fmt % (T, heat_sent, input_status, out)
        #f.write(to_write)

        # wait for dt milliseconds
        time.sleep(dt)

def call_command(command, params):
    if command == "stop":
        params["stoploop"] = True
    else:
        print "Command not understood."


if __name__ == '__main__': main()
