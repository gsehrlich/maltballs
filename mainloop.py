#!/usr/bin/ipython

import sendheat, gettemp, sendinput, getoutput
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
        'fmt': "%s\t%s\t%s\t%s\n",
        'dt': 1,
        'accepting_input': False,
        'writing_to_file': False
        }
commands = ('help', 'stop', 'resume')

def make_datafile():
    """Make a timestamped data file for this run and return it"""
    pass

def main():
    """Start data gathering and PID thread, and get user input"""

    # Get data file
    if params['writing_to_file']:
        params['f'] = make_datafile()
        print "Writing in file %r" % f.name

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
                user_input = raw_input("Command: ").split(' ')

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
                        send_help_message("Parameter %r not found." % param)

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
        if not params['accepting_input']:
            print "\tCurrent temperature: %r K" % params['T']
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
        if params['writing_to_file']:
            to_write = params['fmt'] % (params['T'], params['heat_sent'],
                    params['input_status'], params['out'])
            params['f'].write(to_write)

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
        s = raw_input("Are you sure? (y/[n]) ")
        if len(s) > 0 and s[0] == 'y':
            params["accepting_input"] = False
            params["stoploop"] = True 

    elif command == "resume":
        if args:
            send_help_about(command)
        params["accepting_input"] = False

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
        print "Prints a help message. Ex.:\n" \
              "    > help\n" \
              "    > help <command>\n"
    elif command == "stop":
        print "Stop the program.\n"
    elif command == "resume":
        print "Stop accepting input and unhide output to the terminal.\n"
    else:
        print "Command %r not found.\n" % command

def set_param(param, val):
    params[param] = ast.literal_eval(val)
    print "Set %r to %r" % (param, val)

if __name__ == '__main__': main()
