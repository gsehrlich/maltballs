"""Functions for interacting with vector spectrum analyzer

Basic usage: import, check that it found the right thing, and then call
functions as needed:

    set_source(vsa=None, func=None, freq=None, volt=None)
    source_on(vsa=None)
    source_off(vsa=None)
"""

import visa
import re

_d = locals()

def check_gpib_and_channel(model_n="89410A"):
    """Return the names of at least 1 matching instruments, or raise IOError"""
    s = r"gpib(.*)::(.*)::instr"
    matching_instrs = {}
    rm = visa.ResourceManager()
    for resource in rm.list_resources():
        m = re.match(s, resource, re.IGNORECASE)
        if m:
            idn = rm.get_instrument(resource).query("*IDN?")
            if model_n in idn:
                gpib, channel = map(int, m.groups())
                matching_instrs[resource] = (gpib, channel), idn

    if matching_instrs:
        for instr in matching_instrs.keys():
            print "Found vector spectrum analyzer at %r with IDN:\n\t%s" \
                  % (instr, matching_instrs[instr][1])
        _d['connected_vsas'] = matching_instrs

        if len(matching_instrs) == 1:
            _d['cur_resource'] = matching_instrs.keys()[0]
            (_d['cur_gpib'], _d['cur_channel']), _d['cur_idn'] = \
                matching_instrs.values()[0]
            print "Setting as current VSA: %r" % _d['cur_resource']

        else:
            del _d['cur_resource']
            del _d['cur_gpib']
            del _d['cur_channel']
            del _d['cur_idn']

        return matching_instrs

    else: raise IOError("No matching instruments found!")

# Run it to set local variables appropriately
check_gpib_and_channel()

def _ready_to_get_vsa():
    important_vars = ('cur_resource', 'cur_gpib', 'cur_channel', 'cur_idn')
    important_vars_in_locals =  [var in _d for var in important_vars]
    if all(important_vars_in_locals): return True
    elif not any(important_vars_in_locals): return False
    else:
        check_gpib_and_channel()
        return _ready_to_get_vsa()

def get_vsa(*args):
    """Get the instrument at the specified resource address.

    1. Use the full address:
         get_vsa('gpib1::1::instr')
    2. Pass the GPIB card number and the channel:
         get_vsa(1, 1)
    3. Use whatever resource is current:
         get_vsa()
    """
    if len(args) == 0:
        if not _ready_to_get_vsa():
            raise TypeError('No default address found; please provide')
        else: address = _d['cur_resource']
    elif len(args) == 1:
        address, = args
    elif len(args) == 2:
        address = 'gpib%s::%s::instr' % args
    elif len(args) > 2:
        raise TypeError('get_vsa() takes 0, 1 or 2 arguments (%d given)' %
                        len(args))
    _d['cur_vsa'] = visa.ResourceManager().get_instrument(address)
    return _d['cur_vsa']

if _ready_to_get_vsa(): get_vsa()

def set_source(vsa=None, func=None, freq=None, volt=None):
    """Set the vector signal analyzer source type.

    set_source(vsa=None, func=None, freq=None, volt=None)

    type: 'rand' or 'sin'
    freq: e.g. '200 kHz' or '.5MHz'
    ampl: e.g. '-5 dBm' or '5 mV'
    """
    if vsa is None:
        try:
            vsa = _d['cur_vsa']
        except KeyError:
            raise TypeError('No default instrument found; please provide')
    if func is not None:
        vsa.write("sour:func %s" % func)
    if freq is not None:
        vsa.write("sour:freq %s" % freq)
    if volt is not None:
        vsa.write("sour:volt %s" % volt)

def source_on(vsa=None):
    """Turn vector signal analyzer source on."""
    if vsa is None:
        try:
            vsa = _d['cur_vsa']
        except KeyError:
            raise TypeError('No default instrument found; please provide')
    vsa.write('outp on')

def source_off(vsa=None):
    """Turn vector signal analyzer source off."""
    if vsa is None:
        try:
            vsa = _d['cur_vsa']
        except KeyError:
            raise TypeError('No default instrument found; please provide')
    vsa.write('outp off')