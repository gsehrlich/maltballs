#!/usr/bin/python

try:
	import vsa_controls as ctrl
except ImportError as ctrl:
	print ctrl.message + ". Proceeding anyway."

def get_output(): pass

if not isinstance(ctrl, Exception):
	def is_responding():
		try:
			ctrl.cur_instr.query("*IDN?")
		except AttributeError:
			# no current instrument
			return False
		except ctrl.visa.VisaIOError:
			return False
		else:
			return True
	def reconnect():
		reload(ctrl)
else:
	def is_responding(): return error
	def reconnect(): print "Cannot reconnect: no module visa found"