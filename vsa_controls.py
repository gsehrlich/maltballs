"""Functions for interacting with vector spectrum analyzer

Basic usage: import, check that it found the right thing, and then call
functions as needed."""

import visa
import re
from functools import wraps
import numpy as np
import warnings

_d = locals()
vsa_descriptors = ('cur_resource', 'cur_gpib', 'cur_channel', 'cur_idn')

def no_matching_instrument():
    print "No matching instrument found!"
    for var in vsa_descriptors:
        try:
            del _d[var]
        except KeyError: pass

def check_gpib_and_channel(model_nums=["89410A", "4395A"]):
    """Return the names of at least 1 matching instruments, or raise IOError"""
    s = r"gpib(.*)::(.*)::instr"
    matching_instrs = {}
    rm = visa.ResourceManager()
    for resource in rm.list_resources():
        m = re.match(s, resource, re.IGNORECASE)
        if m:
            idn = rm.get_instrument(resource).query("*IDN?")
            for model_n in model_nums:
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

try:
    check_gpib_and_channel()
except IOError:
    no_matching_instrument()

def _ready_to_get_vsa():
    vsa_information_in_locals = [var in _d for var in vsa_descriptors]
    if all(vsa_information_in_locals): return True
    elif not any(vsa_information_in_locals): return False
    else:
        print vsa_information_in_locals
        try:
            check_gpib_and_channel()
        except IOError:
            no_matching_instrument()
        else: return _ready_to_get_vsa()

def get_vsa(*args):
    """Get the instrument at the specified resource address.

    1. Use the full address:
         get_vsa('gpib0::1::instr')
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
    try:
        _d['cur_vsa'] = visa.ResourceManager().get_instrument(address)
    except visa.VisaIOError:
        print "No instrument found at address %r!" % address
    return _d['cur_vsa']

# Run it to set local variables appropriately
if _ready_to_get_vsa():
    get_vsa()
    cur_instr = cur_vsa

def use_default_vsa(f):
    """Decorator for use with functions that interface with the VSA.

    Usage:
    @use_default_vsa
    def my_function(arg_a, kwarg_b=None, vsa=None): pass
    """
    @wraps(f)
    def _decorator(*args, **kwargs):
        # if ``'vsa' not in kwargs`` evals to True, ``or`` skips second
        # expression, which otherwise would throw an error
        if 'vsa' not in kwargs or kwargs['vsa'] is None:
            try:
                vsa = _d['cur_vsa']
            except KeyError:
                raise TypeError('No default instrument found; please provide')
        return f(*args, **dict(kwargs.items() + [('vsa', vsa)]))
    return _decorator

@use_default_vsa
def set_source(func=None, freq=None, volt=None, vsa=None):
    """Set the vector signal analyzer source type.

    set_source(vsa=None, func=None, freq=None, volt=None)

    type: 'rand' or 'sin'
    freq: e.g. '200 kHz' or '.5MHz'
    ampl: e.g. '-5 dBm' or '5 mV'
    """
    if func is not None:
        vsa.write("sour:func %s" % func)
    if freq is not None:
        vsa.write("sour:freq %s" % freq)
    if volt is not None:
        vsa.write("sour:volt %s" % volt)

@use_default_vsa
def source_on(vsa=None):
    """Turn vector signal analyzer source on."""
    vsa.write('outp on')

@use_default_vsa
def source_off(vsa=None):
    """Turn vector signal analyzer source off."""
    vsa.write('outp off')

@use_default_vsa
def averaging_on(vsa=None):
    """Turn vector signal analyzer averaging on."""
    vsa.write('aver on')

@use_default_vsa
def freq_range(*args, **kwargs):
    """Set and return the range of frequencies. Note: final frequency included.

    Usage:
    freq_range()
        Return a list of the current frequency values.
    freq_range('500 kHz')
        Set the frequency interval to [0, 500] kHz and return a list of the
        frequency values.
    freq_range('200 kHz', '300 kHz')
        Set the frequency interval to [200, 300] kHz and return a list of the
        frequency values.
    freq_range(center='250 kHz')
        Set the center frequency to 250 kHz and return a list of the frequency
        values.
    freq_range(span='100 kHz')
        Set the span to 100 kHz and return a list of the frequency values.
    freq_range(center='250 kHz', span='100 kHz')
        Set the frequency interval to [200, 300] kHz and return a list of the
        frequency values.
    freq_range(n=401)
        Set the number of frequency points to 401 and return a list of the
        frequency values. Allowed values: 401, 801, 1601.
    """
    if 'vsa' not in kwargs:
        kwargs['vsa'] = None
    vsa = kwargs['vsa']

    # Check if default instrument is vector signal analyzer or network analyzer
    instr_type = ("vsa" if "89410A" in _d['cur_idn'] else
                  "na" if "4395A" in _d['cur_idn'] else
                  NotImplemented)
    # Set up initial frequency and #points strings
    # (VSA and NA have different protocols)
    freq_s = "freq:" if instr_type == "vsa" else ""
    poin_s = "swe:" if instr_type == "vsa" else ""

    # Make sure parameters are sensible
    if len(args) > 2:
        raise TypeError('freq_range() takes 0, 1 or 2 arguments (%d given)' %
                        len(args))
    if ('center' in kwargs or 'span' in kwargs) and \
        (len(args) > 0 or 'start' in kwargs or 'stop' in kwargs):
        raise TypeError('Provide either (center=, span=) or (start, stop)')

    if len(args) == 1:
        kwargs['start'] = "0 Hz"
        kwargs['stop'] = args[0]
    elif len(args) == 2:
        kwargs['start'], kwargs['stop'] = args
    if 'start' in kwargs:
        vsa.write(freq_s + 'star %s' % kwargs['start'])
    if 'stop' in kwargs:
        vsa.write(freq_s + 'stop %s' % kwargs['stop'])
    if 'center' in kwargs:
        vsa.write(freq_s + 'cent %s' % kwargs['center'])
    if 'span' in kwargs:
        vsa.write(freq_s + 'span %s' % kwargs['span'])
    if 'n' in kwargs:
        vsa.write(poin_s + 'poin %s' % kwargs['n'])
        if instr_type == "vsa" and kwargs['n'] not in (401, 801, 1601) or \
           instr_type == "na" and kwargs['n'] > 801:
            warnings.warn("Number of points %r not allowed. Value set to %r" %
                          (kwargs['n'], vsa.query_ascii_values('swe:poin?')[0]),
                          stacklevel=2)
    start, = vsa.query_ascii_values(freq_s + 'star?')
    stop, = vsa.query_ascii_values(freq_s + 'stop?')
    n, = vsa.query_ascii_values(poin_s + 'poin?')
    return np.linspace(start, stop, n, endpoint=True)

@use_default_vsa
def freq_auto_stepsize(vsa=None):
    """Returns the frequency step size to auto mode."""
    vsa.write('freq:step:auto on')

@use_default_vsa
def averaging_off(vsa=None):
    """Turn vector signal analyzer averaging off."""
    vsa.write('aver off')

@use_default_vsa
def set_averaging(n=None, vsa=None):
    """Set the number of collected spectra over which to average."""
    if n is not None:
        vsa.write('aver:coun %d' % n)

@use_default_vsa
def get_data(vsa=None):
    """Get data from vector signal analyzer."""
    # Check if default instrument is vector signal analyzer or network analyzer
    if "89410A" in _d['cur_idn']:
        return np.array(vsa.query_ascii_values('calc:data?'))
    elif "4395A" in _d['cur_idn']:
        # Alternate values are always zero for some reason.
        # Switch channels (press buttons on machine) to switch gain/phase
        return np.array(vsa.query_ascii_values('outpdtrc?')[::2])
