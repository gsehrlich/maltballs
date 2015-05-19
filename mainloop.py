#!/usr/bin/ipython

import sendheat, gettemp, analyzer_comm as comm
import os, sys
import datetime
import time
import numpy as np
import threading
import ast


# Interface between main thread and daemon.
# Start just measuring temperature
params = {
        'T': -9001.,
        'temp_steady': False,
        'gathering_data': False,
        'stoploop': False,
        'dt': 1,
        'accepting_input': False,
        'writing_to_file': False,
        'comm_responding': False,
        'out': None,
        'freq': None
        }
commands = ('help', 'stop', 'resume', 'reconnect', 'getdata')

def make_data_file_name():
    """Make a timestamped data file name for this run and return it"""
    filename_fmt = "data/%04d-%02d-%02d %02d.%02d.%02d"
    t = datetime.datetime.now()
    return filename_fmt % (t.year, t.month, t.day, t.hour, t.minute, t.second)

def main():
    """Start data gathering and PID thread, and get user input"""

    print "\nvvv Starting loop vvv\n"
    print "Press Ctrl + C to enter a command"
    t = threading.Thread(target=run_loop)
    t.daemon = True
    t.start()

    # Repeatedly accept user input
    while True:
        try:
            # Wait for user input
            while True: time.sleep(0.1)
        except KeyboardInterrupt:
            params['accepting_input'] = True
            print "\n\n^^^ Suppressing loop output. ^^^"
            print "    To resume enter 'resume'.\n"

            # Parse and dispatch user requests until done ('resume')
            while params['accepting_input']:
                user_input = raw_input("maltballer> ").split(' ')

                # Call a command
                if user_input[0] in commands:
                    call_command(user_input[0], user_input[1:])

                # Query a parameter
                elif len(user_input) == 1 and user_input[0] in params:
                    print "\t%s: %r" % (user_input[0], params[user_input[0]])

                # Set a parameter manually
                elif len(user_input) >= 2 and user_input[1] == '=':
                    if user_input[0] in params:
                        param = user_input[0]
                        if len(user_input) == 3:
                            set_param(param, user_input[2])
                        else:
                            send_help_message("Equals what?")
                    else:
                        send_help_message("Parameter %r not found." %
                                          user_input[0])

                # Request not understood
                else: send_help_message("Syntax %r not understood." %
                        ' '.join(user_input))

            # Stop the loop, if instructed, or else resume sleeping
            if params['stoploop']:
                print "\n***** Stopping loop. *****\n"
                break
            else:
                print "\n\nvvv Resuming loop output. vvv\n"
                params['accepting_input'] = False

def run_loop():
    #while temp isn't steady
    while not params['stoploop']:
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

        params['comm_responding'] = comm.is_responding()
        if params['gathering_data']:
            # Do it just once
            params['gathering_data'] = False
            if params['comm_responding']:
                # Also write to file
                params['writing_to_file'] = True
                # fetch data
                params['out'] = comm.get_output()
                params['freq'] = comm.ctrl.freq_range()
                print "Done!"
            else:
                print "Analyzer not responding!"
        else:
            params['input_status'] = None
            params['out'] = None

        # display current status to terminal
        if not params['accepting_input']:
            print "\tT: %r K;" % params['T'],
            print "Analyzer responding: %r" % params['comm_responding']

        # progressively write to file
        if params['writing_to_file']:
            # Do it just once
            params['writing_to_file'] = False
            filename = make_data_file_name()
            print "Writing to file %r..." % filename,
            np.savetxt(filename, zip(params['freq'], params['out']),
            #    header="# Temperature: %s K\n" % params['T'])
            # not supported in version of python that's on lab computer...
)
            print "Done!"

        # wait for dt milliseconds
        time.sleep(params['dt'])

def call_command(command, args):
    if command == "help":
        if len(args) > 0:
            send_help_about(args[0])
        else:
            send_help_message()

    elif command == "stop":
        if args:
            send_help_about(command)
        else:
            s = raw_input("Are you sure? (y/[n]) ")
            if len(s) > 0 and s[0] == 'y':
                params["accepting_input"] = False
                params["stoploop"] = True 

    elif command == "resume":
        if args:
            send_help_about(command)
        else:
            params["accepting_input"] = False

    elif command == "reconnect":
        if args:
            send_help_about(command)
        else:
            print "Reconnecting..."
            comm.reconnect()

    elif command == "getdata":
        if args:
            send_help_about(command)
        else:
            print "Gathering data...",
            params['gathering_data'] = True
            # So that message from other thread appears before cmd prompt
            time.sleep(2*params['dt'])

    else:
        send_help_about(command)

def send_help_message(message=None):
    if message is not None: print str(message) + "\n"
    else:
        print "Commands implemented:"
        print "\t%s\n"*len(commands) % commands
        print "Parameters that can be queried and set:"
        print "\t%s\n"*len(params) % tuple(params.keys())

def send_help_about(command):
    """Display command-specific help."""
    if command == "help":
        print "help: Prints a help message. Ex.:\n" \
              "    maltballer> help\n" \
              "    maltballer> help <command>\n"
    elif command == "stop":
        print "stop: Stop the program. Ex.:\n" \
              "    maltballer> stop\n"
    elif command == "resume":
        print "resume: Stop accepting input and unhide output to the " \
              "terminal. Ex.:\n" \
              "    maltballer> resume\n"
    elif command == "reconnect":
        print "reconnect: Try to reconnect to an analyzer. Ex.\n" \
              "    maltballer> reconnect\n"
    elif command == "getdata":
        print "getdata: Request freq, power data from the analyzer. Ex.\n" \
              "    maltballer> getdata\n"
    else:
        print "Command %r not found.\n" % command

def set_param(param, val):
    params[param] = ast.literal_eval(val)
    print "Set %r to %r" % (param, val)

if __name__ == '__main__': main()
