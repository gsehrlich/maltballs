#!/usr/bin/python

import sendheat, gettemp, sendinput, getoutput
import os, sys
import datetime
import time
import numpy as np
import threading

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
            'dt': 1,
            'accepting_input': False,
            }

    print "\nvvv Starting loop vvv\n"
    print "Press Ctrl + C to enter a command"
    t = threading.Thread(target=run_loop, args=(params,))
    t.daemon = True
    t.start()
    # Outer loop, to make sure it's always in a try statement
    while True:
        try:
            time.sleep(0.1)
        except KeyboardInterrupt:
            params['accepting_input'] = True
            print "\n\n^^^ Suppressing loop output. ^^^\n"
            command = raw_input("Command: ")
            call_command(command, params)
            if params['stoploop']:
                print "\n\n^^^ Stopping loop. ^^^"
                break
            else:
                print "\n\nvvv Resuming loop output. vvv\n"
                params['accepting_input'] = False

def run_loop(params):
    #while temp isn't steady
    while not params['stoploop']:
        if not params['accepting_input']:
            print "\tStepping!"
        #fetch curr temp
        params['T'] = gettemp.gettemp()
        
        if not params['temp_steady']:
            #send heat
            params['heat_sent'] = sendheat.sendheat(params['T'])
        if params['temp_steady']:
            #hold heat
            params['heat_sent'] = sendheat.holdtemp(params['T'])
        #check if temp has been steady
        params['temp_steady'] = sendheat.is_steady(params['T'])

        if params['gathering_data']:
            #send signal
            params['input_status'] = sendinput.get_status()
            #fetch data
            params['out'] = getoutput.getoutput()
        else:
            params['input_status'] = None
            params['out'] = None

        # progressively write to file
        to_write = params['fmt'] % (params['T'], params['heat_sent'],
                params['input_status'], params['out'])
        #f.write(to_write)

        # wait for dt milliseconds
        time.sleep(params['dt'])

def call_command(command, params):
    if command == "stop":
        params["stoploop"] = True
    else:
        print "Command not understood."


if __name__ == '__main__': main()
