import visa

def get_vsa(channel=1):
	gpib_str = 'gpib1::%s::instr' % channel
	return ResourceManager().get_instrument(gpib_str)

def set_source(vsa, type="wnoise", freq=None):
	"""Set the vector signal analyzer source type. freq in Hz"""
	if type == "wnoise":
		vsa.write('sour:func rand')
	if type == "sine":
		vsa.write('sour:func sin')
		vsa.write('sour:freq %s hz' % freq)

def source_on(vsa):
	vsa.write('outp on')

def source_off(vsa):
	vsa.write('outp off')