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
import git
import subprocess
import datetime
import time

log = open('run2/output.log', 'a+')
time_fmt = "%d-%d-%d %d.%d.%d"

def now():
    return tuple(datetime.datetime.now().timetuple())

analyzer_thread = threading.Thread(target=analyzer_cmds, args=())
t_thread = threading.Thread(target=t_cmds, args=())
q_thread = threading.Thread(target=q_cmds, args=())
analyzer_thread.daemon = True
t_thread.daemon = True
q_thread.daemon = True
analyzer_thread.start()
t_thread.start()
q_thread.start()

def analyzer_cmds():
    log.writeline(subprocess.check_output(["git", "pull"]))

    analyzer_globals = {}

    while True:
        try:
            execfile("instruct_analyzer.py", globals=analyzer_globals)
        except Exception as e:
            log.writeline(e.message)

        log.writeline(time_fmt % now())

        log.writeline(subprocess.check_output(["git", "add", "."]))
        log.writline(subprocess.check_output(["git", "commit", "-m", '"data taken"',
            "."])
        log.writeline(subprocess.check_output(["git", "push", "origin", "master"]))

        if 'dt' not in analyzer_globals: analyzer_globals['dt'] = 120
        time.sleep(analyzer_globals['dt'])

def t_cmds():
    while True:
        try:
            execfile("record_temp.py")
        except Exception as e:
            log.writeline(e.message)