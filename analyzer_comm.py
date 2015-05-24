#!/usr/bin/python

try:
	import vsa_controls as ctrl
except ImportError as ctrl:
	print ctrl.message + ". Proceeding anyway."

def get_output():
	try:
		data = ctrl.get_data()
	except ctrl.visa.VisaIOError as e:
		print "Error encountered in comm:\n %r" % e.message
		return e
	return data

def get_freq():
	try:
		data = ctrl.freq_range()
	except ctrl.visa.VisaIOError as e:
		print "Error encountered in comm:\n %r" % e.message
		return e
	return data

def set_freq(**kwargs):
	try:
		ctrl.freq_range(**kwargs)
	except ctrl.visa.VisaIOError as e:
		print "Error encountered in comm:\n %r" % e.message

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