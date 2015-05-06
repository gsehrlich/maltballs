import visa
import re

def check_gpib_and_channel(model_n="89410A"):
    """Return the names of at least 1 matching instruments, or raise IOError"""
    s = r"gpib{}::{}::instr"
    regex_s = s.format(r"(.*)", r"(.*)")
    matching_instrs = {}
    rm = visa.ResourceManager()
    for resource in rm.list_resources():
        m = re.match(regex_s, instr_str)
        if m:
            instr_descrip = rm.get_instrument(resource).query("*IDN?")
            if model_n in instr_descrip:
                matching_instrs[s.format(m.groups())] = instr_descrip

    if matching_insts: return matching_insts
    else: raise IOError("No matching instruments found!")


def get_vsa(gpib=1, channel=1):
    """Get the instrument at the specified GPIB and channel"""
    gpib_str = 'gpib%s::%s::instr' % (gpib, channel)
    return visa.ResourceManager().get_instrument(gpib_str)

def set_source(vsa, type="wnoise", freq=None):
    """Set the vector signal analyzer source type. freq in Hz"""
    if type == "wnoise":
        vsa.write("sour:func rand")
    if type == "sine":
        vsa.write("sour:func sin")
    vsa.write("sour:freq %s hz" % freq)

def source_on(vsa):
    vsa.write('outp on')

def source_off(vsa):
    vsa.write('outp off')
