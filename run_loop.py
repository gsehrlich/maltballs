"""
    Created on Wed May 31, 2015
    
    @author: mlu


"""

import math
import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import cmath as cmath
from scipy import signal
import os
import threading
import subprocess
import datetime
import time

def log(s):
    with open(os.path.join('data', 'run2', 'output.txt'), 'w') as f:
        f.write(str(s) + "\n")

time_fmt = "%04d-%02d-%02d %02d.%02d.%02d"
dt = 1 # how often to check whether to stop

def now():
    return tuple(datetime.datetime.now().timetuple()[:6])

def analyzer_cmds():

    log(subprocess.check_output(["git", "pull"]))

    analyzer_globals = {}

    while True:
        try:
            execfile("instruct_analyzer.py", globals=analyzer_globals)
        except Exception as e:
            log(e.message)

        log(time_fmt % now())

        log(subprocess.check_output(["git", "add", " ."]))
        log(subprocess.call(['git', 'commit', '-am', '"data taken"']))
        log(subprocess.check_output(["git", "push", "origin", "master"]))
        

        if 'dt' not in analyzer_globals: analyzer_globals['dt'] = 1
        time.sleep(analyzer_globals['dt'])

def q_cmds():
    q_globals = {}
    while True:
        try:
            execfile("transfer_func_Q.py", globals=q_globals)
        except Exception as e:
            log(e.message)

    if 'dt' not in q_globals: q_globals['dt'] = 1
    time.sleep(q_globals['dt'])

analyzer_thread = threading.Thread(target=analyzer_cmds, args=())
q_thread = threading.Thread(target=q_cmds, args=())
analyzer_thread.daemon = True
q_thread.daemon = True
analyzer_thread.start()
q_thread.start()

while True:
    time.sleep(dt)
    with open('run_loop_instructions.txt') as f:
        if "stop" in f:
            break