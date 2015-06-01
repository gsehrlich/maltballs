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


while(true): #some sort of statement to control whether we are taking data or not

    output = subprocess.check_output(["git", "pull"])
    q_thread = threading.Thread(target=q_cmds, args=())
    t_thread = threading.Thread(target=t_cmds, args=())
    q_thread.daemon = True
    t_thread.daemon = True
    q_thread.start()
    t_thread.start()

    output = subprocess.check_output(["git", "add", "."])
    output = subprocess.check_output(["git", "commit", "-m", '"data taken"', "."])
    output = subprocess.check_output(["git", "push", "origin", "master"])




