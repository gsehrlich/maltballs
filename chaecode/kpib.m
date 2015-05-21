%% kpib
% KPIB is a framework for operating laboratory instruments that are
%  connected to a computer by GPIB or serial connections.
%  KPIB provides a unified interface for communicating with different
%  instruments from different manufacturers. KPIB requires the MATLAB
%  Instrument Control toolbox.
%
% Usage:
% RETVAL = KPIB(INSTRUMENT, GPIB, COMMAND, VALUE, CHANNEL, AUX, VERBOSE)
%
% Open the m-file or use "showdemo kpib" for more help.
%

%% Introduction
function retval = kpib(instrument, GPIB, command, value, channel, aux, verbose)
%RETVAL = KPIB(INSTRUMENT, GPIB, COMMAND, VALUE, CHANNEL, AUX, VERBOSE)
%  KPIB: Kenny-Purpose Interface Bus
% v4.8 [NI] MH Apr2010
%  See list of supported instruments below
%
% Current Maintainer:
% M.A. Hopcroft
%      hopcroft at mems stanford edu
%
%% Version Info
versionnum=4.8;
versionstr='kpib.m version 4.8 [NI] (Apr2010)';

%% Description
% KPIB is a framework for operating laboratory instruments that are
%  connected to a computer and controlled by GPIB or serial connections.
%  KPIB provides a unified interface for communicating with different
%  instruments from different manufacturers. KPIB is based on HPIB, written
%  by Aaron Partridge. KPIB requires the MATLAB Instrument Control toolbox.
%  KPIB is licensed for use under the BSD license supported by the File
%  Exchange.
%
% Contributions of new instrument drivers to KPIB are welcome! Please see
%  the section below labelled "Code Organization" for information about
%  adding new instruments. Please feel free to contact the Maintainer at
%  the address above with questions, comments, or contributions.
%
%
% Parameters:
%
% INSTRUMENT (str)      Instrument name or bus-level command
% GPIB (num)            The GPIB address of the instrument or serial port ('COMx')
% COMMAND (str)         Command to instrument
% VALUE (num or str)    Value for command (if applicable)
% CHANNEL (num or str)  Channel for command (if applicable)
% AUX (num or str)      Additional input parameter (if applicable)
% VERBOSE (0,1,2,3)     Controls the amount of status messages
%                        printed to the command window:
%                        0 = silent
%                        1 = important messages only
%                        2 = all instrument messages (default)
%                        3 = all instrument messages + debugging messages
%
%
% INSTRUMENT may be one of the following:
%
% 'all'        All instruments; for init or stop commands.
% 'none'       No instrument; for dummy commands
%
%   Temperature Controllers
%
% 'BlueOven'   2800 Controller for Thermotron S-1.2 Thermal Chamber
%  				(aka "Blue Oven")
% 'GreyOven'   ICS 4809 Modbus interface to Watlow F4 Controller for
%  				TestEquity 1007S Thermal Chamber (aka "Grey Oven")
% 'AO_800'     Alpha Omega Instruments Series 800/850 Temperature
%  				Controller using Watlow Series 96 controller
%  				(Modbus serial comm.)
%  				(RS-232 device, specify 'COM1' for GPIB address)
% 'CV_TIC304'  CryoVac TIC 304-MA Temperature Controller
% 'SI_9700'    Scientific Instruments model 9700 Temperature Controller
% 'NP_3150'    Newport Temperature Controller Model 3150
%
%   Signal Analyzers
%
% 'HP_89410A'  HP 89410A Vector Signal Analyzer
% 'HP_4195A'   HP Network/Spectrum Analyzer
% 'HP_4395A'   HP 4395A Network/Spectrum Analyzer
% 'HP_8753ES'  HP 8753ES S-Parameter Network Analyzer
% 'AG_E5071B'  Agilent E5070B/E5071B RF Network Analyzer
% 'HP_8560A'   HP 8560A Spectrum Analyzer
%
%   Oscilloscopes
%
% 'TEK_TDS'    Tektronix TDS family Oscilloscopes
% 'HP_54600'   Hewlett-Packard 54600-series Oscilloscopes (HP_54602B)
%
%   Multimeters
%
% 'HP_3478A'   Hewlett-Packard 3478A multimeter
% 'HP_34401A'  HP 34401A multimeter
% 'HP_34420A'  HP 34420A 7.5 Digit Nanovoltmeter with RTD
%  				measurement
%
%   Power Supplies
%
% 'HP_E3631A'  HP E3631A triple output DC power supply
% 'HP_6614C'   HP 6614C single-output 100V/0.5A DC power supply
% 'HP_E3632A'  HP E3632A DC power supply 15/30 V
% 'HP_E3634A'  HP E3634A DC power supply 25/50 V
% 'HP_E3641A'  HP E3641A DC power supply
% 'HP_E3647A'  HP E3647A dual output DC power supply
%               (incl. TDS 340, TDS 540, TDS 744A)
% 'HP_53132A'  HP 53132A 225 MHz Universal Counter
% 'HP_33120A'  HP 33120A 15 MHz function generator
% 'SRS_DS345'  Stanford Research Systems DS345 30 MHz function
%  				generator
% 'HP_E3633A'  HP E3633A DC power supply 8/20 V
%
%   Other Instruments
%
% 'KTH_236'    Keithley 236/237/238 Source Measure Unit
% 'KTH_2400'   Keithley 2400 Source-Measure Unit (minimum functionality)
% 'HP_4284A'   HP 4284A LCR Meter
% 'HP_3499B'   Agilent 3499B Multiplexer
% 'VH_2701C'   Valhalla 2701C voltage calibrator
% 'VH_2701B'   Valhalla 2701B voltage calibrator (limited functionality)
% 'OH_EXP'     Ohaus Explorer precision balances (incl. Pro models)
%
%   Bus-level commands (typically used for debugging)
%
% 'scan'       Look for GPIB and serial interfaces and instruments
% 'identify'   Ask an instrument for identifying information
% 'close'      Close a GPIB or serial connection.
% 'clear'      Close all GPIB or serial connections.
% 'open'       Open a GPIB or serial connection.
% 'write'      Send the string VALUE to the instrument at GPIB.
% 'writeread'  Send a string to an instrument and wait for a reply.
%
% Documentation for each instrument is in the code. Use the "Find" command
%  or use the Cepll menu in the MATLAB Editor (the "%%" menu) to jump to the
%  code for a specific instrument. If you use the "File/Publish to HTML"
%  menu item, you will get a web page with a link to each instrument.
%
%  Typical commands include: 
% 'init'    initialize instrument
% 'read'    read a measurement
% 'setV'    set the output voltage
% 'on'      enable output
% 'off'     disable output
% 'getdata' download a data trace from scope or analyzer
%
% %% %%
%
% Examples:
%
% Usage:
% RETVAL = KPIB(INSTRUMENT, GPIB, COMMAND, VALUE, CHANNEL, AUX, VERBOSE)
%
% To read the output (voltage and current) from the HP E3631A Triple
%  Output Power supply with GPIB address 15 and store the reading in the
%  variable called "output", use:
%
%  >> output = kpib('HP_E3631A',15,'read');
%
%  This command will default to channel 1. The result will be a structure:
%
%    output.volt = 5.04
%    output.curr = 0.24
%
% You might only be interested in the voltage reading. Use:
%
%  >> output = kpib('HP_E3631A',15,'read','V');
%
%  The result will be a single value:
%
%    output = 5.04
%
%  (There is usually a small time savings when reading only one value)  
%
% To download the 500 data point trace from channel 2 of the Tektronix TDS
%  540 4-channel oscilloscope with GPIB address 8, see all status messages
%  in the command window, and to store the result in the variable called
%  "data", use:
%
%  >> data = kpib('TEK_TDS',8,'getdata',0,2,0,2);
% 
%  The result will be a structure:
%
%    data =
%         x: [500x1 double]
%         y: [500x1 double]
%     units: [1x1 struct]
%      desc: [1x73 char]
%
% It is recommended to organize your code with constants to describe the
%  instruments, so that they can be modified easily. For example:
%
%   >> pwrsupply.instr = 'HP_E3647A';
%   >> pwrsupply.gpib = 15;
%   >> pwrsupply.channel = 2;
%   >> powervolt = 3.5;
%   >> verbose = 1;
%
%   >> kpib(pwrsupply.instr,pwrsupply.gpib,'set',powervolt,pwrsupply.channel,0,verbose);
%
%   etc.
%   
%   You can also specify instruments as a single structure input. For the
%   example above, you could use:
%
%   >> kpib(pwrsupply,'setV',powervolt,0,verbose);
%
% %% %%
%% GPIB Interface Hardware
%
% KPIB as provided on File Exchange is configured for a computer using a single 
%  National Instruments GPIB interface card ('ni'). For other brands of interface
%  cards and/or multiple cards, you will need to modify the private
%  function PORT, located near the end of this file (approx. 400 lines before the
%  end of the file). To go to this line, search for the string 'GPIBMAN'.
%  See the list of manufacturers supported by MATLAB here:
%    http://www.mathworks.com/products/instrument/supportedio.html
%  KPIB has been tested with GPIB interface hardware from National Instruments
%  and ICS Electronics (both PCI and USB). Note that USB-based GPIB interfaces
%  that use a "GPIB-32.DLL" or similar method act like PCI interfaces as far as
%  MATLAB is concerned (i.e., they use the GPIB command to create the instrument
%  object).
%  As of version 4.8, you can use the KPIB command 'scan' to display a list
%  of available interfaces and instruments. The interface name given by
%  'scan' is the name which must be entered in KPIB.
%
% Code is also included for USB-GPIB interfaces that use a "virtual serial
%  port" (COMx), such as the Prologix GPIB-USB Controller 4.2. These interfaces
%  use the SERIAL command to create the instrument object. Modify the PORT
%  function by commenting in/out the section relevant to your setup. Also set the
%  the IsUSBPro flag in the "Define Constants" cell (near line 600).
%
% %% %%
% Open the file kpib.m to find details for specific instruments and documentation
%  for adding instruments and modifying the code.
% %% %%

% %% %%
%% Code organization
%  The code is grouped by instrument in IF statement blocks which which
%  evaluate the first input parameter (INSTRUMENT) and then execute the
%  COMMAND parameter if the string is matched. Each instrument group begins
%  with the PORT function, which uses the GPIB or SERIAL commands to open a
%  connection to the instrument, if one does not already exist. The PORT
%  function and other specialized subroutines are at the end of the file.
%  Additional instruments can easily be added by following the format below.
%
%
% Template for new instruments:
%  To add a new instrument, use the following template, replacing
%  INSTRUMENT with the name of the instrument. For certain types of
%  instruments (power supplies, temperature controllers, network analyzers,
%  etc), there are certain commands that should be included. See an
%  existing instrument for an example.
%
% % %%%%%
% %% 'Instrument' Description for Cell title
% % Description of instrument and kpib funtionality
%
% %RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% % Valid oven commands:
% % 'init'    Initializes instrument and makes ready for measurement
% % 'read'    Returns some data or parameter from the instrument
% % 'setV'    Sets the output voltage
% %
% if (strcmpi(instrument, 'INSTRUMENT') || strcmpi(instrument, 'all'))
%    baudrate = 0;  % buffer size for GPIB (0 for default), baud rate for serial port instruments
%    io = port(GPIB, instrument, baudrate, verbose);
%    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
%
%        switch command
%            case 'init'
%
%               %<INSTRUMENT CODE HERE>%
%
%				if verbose >= 1, fprintf(1, 'kpib/%s: Warning: <some warning message>.\n',instrument); end
%
%               if verbose >= 2, fprintf(1, 'kpib/%s: Result of command is <whatever>.\n',instrument); end
%
%            case {'read','getdata'}
%               %<INSTRUMENT CODE HERE>%
%
%            otherwise
%                if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s"]\n',instrument,command); end
%        end
%                
%    else % catch incorrect address errors
%       if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
%       retval=0;
%    end
%    validInst = 1;
% end
% % %%%%% end <NEW INSTRUMENT>
%
%
% Notes for adding new instruments:
%
% Default inputs: all 5 additional input parameters are given default values if
%  the user does not provide them. They are:
%
% command = 'none'
% value = 0
% channel = 0
% aux = 0
% verbose = 2
%
% Avoid using "nargin" to test for valid inputs; instead, for example:
%
%   if isnumeric(channel) && any(channel==[1 2 3 4])
%
%
% Choosing command names:
%  When adding a new instrument, pick a similar instrument and copy the command
%  syntax. For example, to download a data trace from an analyzer or oscilloscope,
%  name the command 'getdata'. To read a single value from a power supply or multi
%  meter, use 'read'. Maintaining this consistency is a significant part of the
%  value of using kpib. The standard command names are:
%
% 'init'    Initialize the instrument
% 'stop'    Stop instrument action; set output to zero; release controller, etc.
%   also 'off'  
% 'go'      Start instrument action; begin automatic controlling, etc.
%   also 'on'
% 'getdata' Return the data from the instrument. For instrument with data
%            traces (and screens), "download data from the screen". For
%            other instruments, return the "most important data", e.g., for
%            a counter, return the frequency; for a temperature controller,
%            return the measured temperature.
% 'read'    Return some specific data or parameter specified by VALUE.
%            Default to the same data returned by 'getdata'.
% 'set'     Set the output, controller setpoint, or some other parameter 
% 'setT'     specified by VALUE. 'set' is deprecated; better to use 'setV' 
% 'setV'     to set a voltage, or 'setT' to specify a temperature, or 
%            'setI' for a current, etc.
%
%
% Hewlett-Packard/Agilent Power Supplies:
%  Many HP power supplies share a common GPIB command set and kpib
%  syntax ('read','setV','setI', etc). These are grouped together and listed in the
%  constant HP_power, defined at the beginning of the code. If you add a new
%  HP power supply, be sure to add it to the list.
%
%
% Adding new Network Analyzers:
%  KPIB was originally designed to enable measurement of resonators using
%  network analyzers. In order to maintain compatibility with existing code
%  for resonator measurement (measure_res.m and res_meas.m), the following
%  commands must be included.
%  For measure_res, include the following commands:
%
%  Initialize ['init']
%   Just clear the status registers ("CLS") or similar. Not a full reboot.
%
%  Channel Select ['channel']
%	kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',ampchannel,0,0,verbose);
%
%  Sweep Center Frequency (set/query) ['center']
%	centfreq = kpib(tools.analyzer.instr,tools.analyzer.gpib,'center','query',0,0,verbose);
%
%  Sweep Span (set/query) ['span']
%	kpib(tools.analyzer.instr,tools.analyzer.gpib,'span',spanit,0,0,verbose);
%
%  Averaging (on/off/number of sweeps) ['averaging','on']
%	kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','on',avenum,0,verbose);
%
%  Autoscale the display ['scale','auto']
%   kpib(tools.analyzer.instr,tools.analyzer.gpib,'scale','auto',0,0,verbose);
%
%  Marker (on/query) ['marker','query']
%	mark1 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'marker','query',ampchannel,0,verbose);
%
%  Marker to peak/max or peak tracking ['mark2peak','peak']
%	kpib(tools.analyzer.instr,tools.analyzer.gpib,'mark2peak','peak',0,0,verbose);
%
%  Download a complete data trace ['getdata']
%   This command should also return the units
%	trace1 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'getdata',0,ampchannel,0,verbose);
%
%  Sweep Control (initiate a single sweep and wait until it is finished)
%   This is implemented as two commands- one to start the sweep, and one to
%   poll to determine when the sweep has completed.
%   ['sweep','single] and ['complete']
%	kpib(tools.analyzer.instr,tools.analyzer.gpib,'sweep','single',0,0,verbose);
%	kpib(tools.analyzer.instr,tools.analyzer.gpib,'complete',0,0,0,verbose);
%
%  Wait ['wait']
%   The 'wait' command instructs the analyzer to complete the current
%   command before executing any further commands. This is the "*WAI" GPIB
%   command, which is only supported by newer instruments, and doesn't
%   usually have much effect, anyway.
%
% For res_meas, the following additional commands are required:
%
%  Label ['label']
%   Prints a short message on the analyzer screen.
%   kpib(tools.analyzer,'label','Measuring...',0,0,verbose);
%
%  Display Status ['display','dual','?']
%	Indicates the number of traces currently displayed on the screen. This is
%	used to help res_meas guess the type of data that is being displayed.
%	dstate=kpib(tools.analyzer,'display','dual','?',0,verbose);
%
% Many analyzers may not support all of these features. In this case,
%  simply include a dummy command that returns a hard-coded value (e.g.,
%  units.x = 'Hz', or retval = 1). See the code for the HP_4195A for a good
%  example of an older analyzer that does not support all of the features
%  listed here. The counter example is the HP_4395A, which supports all of
%  these commands.
%
%

%% Changlelog
%
% MH Apr2010
% v4.8   add instrument Fluke 294
%        add command 'scan'
%        re-order version number
%        update GPIB PCI section
% MH Feb2010
% v4.72  typo fixes
%        Temperature read update for GreyOven, AO_800
% MH JAN2010
% v4.70  clean up 4.68a changes, comments
%        AG_E5071B data download now works with all Channels
% MH DEC2009
% v4.68a bugfixes in Cory 484 (mostly HP_4395A)
% v4.68  update comments, clean up AO_800
% MH NOV2009
% v4.66  Complete support for AG_E5071 (with help from Damien Wittwer)
% MH OCT2009
% v4.64  add 'SI_9700' Scientific Instruments model 9700 Temperature Controller
% MH FEB2009
% v4.62  add 'CV_TIC304' CryoVac Temperature Controller
%        add 'AG_E5071' Network Analyzer (incomplete)
% MH SEP2008
% v4.60  format code and comments to use "Cells" (%%)
%        add new instrument: OH_EXP
% MH MAY2008
% v4.59  fix typos in HP_3478A
%        fix typos in comments
% v4.58  add preliminary support for HP_54602B Oscilloscope
%        fix HP_3478A "temperature" code
%        clean up "&&" and "||" warnings
% MH APR2006
% v4.56  fix KTH_2400 'measure' commands
% MH MAR2008
% 4.55  fix 'attenuate' command in HP_4195A
%       add 'measure' to KTH_2400
% MH FEB2008
% 4.54  bugfixes for Prologix support
% 4.53  support for KTH_2400 added (contributed by David Myers)
%       bugfixes for Prologix USB support, incl. IsUSBPro flag
% MH JAN2008
% 4.52  validate port re-write for GPIB/Serial GPIB
%       minor updates to VH instruments
%       minor bugfix in TEK_TDS
% v4.51 fix USB code in port
%       more help comments
% v4.5  preliminary support for HP_4195A analyzer,
%        Prologix USB-GPIB interface
%       fix HP_4395A 'marker to center' command
% HKL AUG2007
% v4.48 fix bugs in HP_8753ES averaging on/off routine
%       fix bugs in HP_8753ES sweep compete check routine
% v4.45 fix bugs in HP_8753ES input channel select routine
% MH JUN2007
% v4.44 fix bugs in TEK_TDS oscilloscope data handling
% HKL JUN2007
% v4.42 add new instruments: NP_3150, VH2701_B, VH2701_C
% MH MAY2007
% v4.40 add 'mode' command to 4395A
% v4.39 add source frequency set for HP89410
% v4.38 bugfixes for 89410 label, channel
% MH MAR2007
% v4.36 change TDS_540 to TEK_TDS (all TDS family programming is same)
%       add channel select, display query to TEK_TDS
%       HP_4395A, HP_89410A handle log frequency data correctly
% v4.34 error handling for HP_8560A data download
% v4.33 error handling for HP_4395A data download
% MH FEB2007
% v4.32 misc. Analyzer functionality to support res_meas
% v4.31 specify download format for 4395A ('FORM4')
% MH JAN2007
% v4.3  HP_53132A Counter code reflects current best practice
%       Fewer warning messages for HP_89410A
% v4.22 SRS DS345 'read' defaults to output voltage amplitude
%       additional documentation
% v4.20 add 'getdata' (same as 'read') to HP_3478A
%       add V, I specification to KTH_236 'read' command
% MH DEC2006
% v4.18 remove duplicate HP_33120A entry, add 'setV'
% v4.16 add 'setV' to func. gen., KTH_236
% v4.14 add marker functionality to HP_8560A
% v4.12 add wait for complete to HP_89410 autozero
% MH NOV2006
% v4.1  add 'config' and 'getdata' to HP_34401A and HP_34420A
% v4.04 HP4395A verbosity
% v4.02 Two major changes to input syntax:
%       1) Structure inputs for tools fully supported
%       2) "out-of-place" arguments are no longer supported.
%        (CHANNEL must always be the channel, etc.)
%       add HP_89410A average 'finish'
%       HP_89410A timeout increased to 30 sec
%       Port shows Timeout, Buffersize
%       verbose_default
% RM 23OCT2006
% v3.971 fixed data structure error in HP_3495A 'units' code
% RM 19OCT2006
% v3.97 included new instrument: HP_3499B Multiplexer
% MH OCT2006
% v3.982 remove "nargin" (beta)
%       fix HP_E3631A channel select (use 1,2,3)
%       fix 8753ES channel select
%       Add New Instrument: HP_3499B Multiplexer
%       (contributed by Renata Melamud)
% v3.97 fix HP4395A units
% v3.96 made all HP power supply code common
% v3.94 Fixed 8753ES data download, units
% v3.93 Yet more improvements to HP53132A-
%         'set' & 'frequency' now work properly
% v3.92 Further improvements to HP53132A
%       Default values for all 7 input parameters
%        "limited parameter" input cases should be eliminated
%       Added synchronization (*OPC) to HP89410A
% v3.9  Improvements to HP53132A
%       fixed buffersize bug in PORT related to 'write'
%       beta implementation of structure inputs
% MH SEP2006
% v3.88 bugfixes (m-lint check).
%       validInstr flag in correct place (incl version!)
%       use "any" instead of "find"
% v3.84 updated port for arbitrary buffer size
% v3.82 added 'getdata' to HP 53132A
% v3.8  added HP_4284A LCR Meter, HP_3633A Power supply
%       (contributed by Robert Hennessey)
% MH AUG2006
% v3.76  more AO_800 error checking
% v3.75  added "high-res temp" to GreyOven
% v3.74  changed AO_800 read
% v3.72  fault tolerant AO_800 'read'
%        'close' closes serial ports as well as GPIB
%        made all instruments tolerant of GPIB address errors 
%        added openloop detect to AO_800
% v3.6  made port tolerant of GPIB address errors
%       made 'identify' more robust- can now check to see if an instrument
%        is present at GPIB without crashing
%       added HOLD commands to analyzers
% MH AUG2006
% v3.52 added HP_E3634A (same as E3632A)
%      added HP_8560A (preliminary)
% v3.45 fixed GreyOven set query
% v3.43 fixed marker command for HP_4395A
% v3.42 added units to 'getdata' command for analyzers (similar to scopes)
% v3.4 added current setting to power supplies - use 'setV' or 'setI'
%      added current reading to HP3478A
%      added AO_800 TE controller (RS-232 device) 
% MH JUL2006
% v3.2 worked on trigger issue with KTH_236
%      added start/stop to analyzers
% MH JUL2006
% v3.02 incorporated HP_8753ES, made marker commands consistent for all
%        three analyzers
% MH JUL2006
% v2.91 fixed 4395A issues with str/num, units
% MH JUN2006
% v2.8 changed blueoven to return scalars
% %% %
% JTL JUL2004
% v0.9 Jeff Li wrote first version, based on hpib, from AP. Incorporated 89410A.
% %% %



% %% %% %% %% %
%% BEGIN CODE

% verify that the Instrument Control Toolbox is installed
if isempty(ver('instrument'))
    error('kpib: ERROR (fatal): The Instrument Control Toolbox does not appear to be installed.\n\n')
    %if verbose >= 1, fprintf('kpib: WARNING The Instrument Control Toolbox does not appear to be installed.\n\n'); end
end

%% Define Constants

% The IsUSBPro variable indicates whether a Prologix USB controller is
%  being used. Some instruments (e.g. KTH_2400) require special treatment
%  from the Prologix. See the function 'port' for more details about the
%  Prologix and other interface hardware. 
IsUSBPro = 0; % set 1 or 0

% HP_power is the list of HP Power supplies which have a common syntax
% use INSTRUMENT = 'HP_POWER' for generic code
HP_power={'HP_POWER','HP_POWERM','HP_6614C','HP_E3631A','HP_E3632A','HP_E3633A','HP_E3634A','HP_E3641A','HP_E3647A'};
% which of these have multiple outputs?
% NOTE: some multiple output supplies use numbered output (1,2) and some
%  use named outputs ("P6V"). Code assumes numbered; adjust in HP_power_M
%  section as necessary for new instruments.
HP_power_M={'HP_POWERM','HP_E3631A','HP_E3647A'};
%


%% Parse Input
% Parse Structure Inputs or Individual Inputs
%RETVAL = KPIB('INSTRUMENT', GPIB, COMMAND, VALUE, CHANNEL, AUX, VERBOSE)
%  may be interpreted as
% RETVAL = KPIB(INSTRUMENT, COMMAND(GPIB), VALUE(COMMAND), AUX(VALUE), VERBOSE(CHANNEL))
%     or
% RETVAL = KPIB(INSTRUMENT, COMMAND(GPIB), VALUE(COMMAND), CHANNEL(VALUE), AUX(CHANNEL), VERBOSE(AUX))
%  depending on whether the first argument is a structure (i.e., tools). If
%  so, interpret INSTRUMENT as a structure named TOOLS:
%   tools.instr
%   tools.gpib
%   tools.channel (optional)
%
% Regardless of the input format, all seven parameters are given default
%  values if they are not provided:
%   COMMAND = 'none'
%   VALUE = 0
%   CHANNEL = 0
%   AUX = 0
%   VERBOSE = 2
%
verbose_default = 2; % default verbose level (recommend 2)

if isstruct(instrument)
    nf=length(fieldnames(instrument));
    if isfield(instrument,'channel')
        if nargin > 4, verbose = channel;
        else verbose = verbose_default; end % verbose default
        channel = instrument.channel;
        if nargin > 3, aux = value;
        else aux = 0; end
    else
        if nargin > 5, verbose = aux;
        else verbose = verbose_default; end % verbose default
        if nargin > 4, aux = channel;
        else aux = 0; end
        if nargin > 3, channel = value;
        else channel = 0; end        
    end

    if nargin > 2, value = command;
    else value = 0; end
    if nargin > 1, command = GPIB; end    

    if isfield(instrument,'gpib')
        GPIB = instrument.gpib;
    else
        error('\nkpib: Input STRUCT error: GPIB address (instrument.gpib) not specified\n');
    end
    if isfield(instrument,'instr')
        instrument = instrument.instr;
    else
        error('\nkpib: STRUCT error: instrument (.instr) not specified\n');
    end
    if verbose >= 3
    fprintf(1,'kpib: (STRUCT %d) %s/%s/%s/%s/%s/%s/%s\n',nf,...
        instrument,num2str(GPIB),num2str(command),num2str(value),num2str(channel),num2str(aux),num2str(verbose));
    end
else
    % verbose defaults to level 2 (all messsages)
    if nargin < 7, verbose = verbose_default; end % verbose default
    if nargin < 6, aux = 0; end
    if nargin < 5, channel = 0; end
    if nargin < 4, value = 0; end
    if nargin < 3, command = 'none'; end
    if verbose >= 3
    fprintf(1,'kpib: (REGULAR) %s/%s/%s/%s/%s/%s/%s\n',instrument,num2str(GPIB),num2str(command),num2str(value),num2str(channel),num2str(aux),num2str(verbose));
    end
end




% %% %% %% %% %% %% %% %% %% %% %% %% %% %
%% Begin interpreting commands
% The main body of the code  begins here. It consists of a series of if
%  statements which check the value of INSTRUMENT and execute the
%  appropriate code block.

% % Flags
validInst = 0; % validInst will be set if a valid instrument has been called.

%% 'version' return kpib version number
if strcmpi(instrument,'version') || strcmpi(instrument,'ver')
    retval=versionnum;
    if verbose > 0
        fprintf(1,'%s\n',versionstr);
    end
    validInst = 1;
end


%% GPIB bus level commands
% Low-level commands that apply to any instrument- close, write, etc.


%% 'identify'
% Requests the "Identity String" from an instrument using the *IDN command
%   Obviously this only works if the instrument supports *IDN ... 
% Returns 0 if no instrument is present at GPIB (or *IDN? not supported)
if strcmpi(instrument,'identify') || strcmpi(instrument,'identity') || strcmpi(instrument,'*IDN')
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        fprintf(io,'*IDN?');
        retval=fscanf(io,'%s');
        if verbose >= 2, fprintf('kpib/identify: %s\n',versionstr); end
        if verbose >= 1, fprintf('kpib/identify: Instrument at GPIB %s identifies as:\n  %s\n',num2str(GPIB),retval); end
        validInst = 1;
    else
        retval=0;
        if verbose >= 1, fprintf(1,'kpib/identify: No instrument at GPIB %s\n',num2str(GPIB)); end
        kpib('close',GPIB,0,0,0,0,verbose);
        validInst = 1;
    end
end


%% 'clear'
% This function is used in order to clear all of the instrument handles
% and to close all the connections without having to go and find each
% individual instrument and close it. Essentially a "close all" command.
if strcmpi(instrument,'clear')
    if verbose >= 2, fprintf('kpib: Closing and clearing all instrument connections.\n'); end
    io = instrfind;
    if verbose >= 2, disp(io); end
    if ~(isempty(io)) 
        fclose(io);
        delete(io);
        clear io;
    end
    if verbose >= 2, fprintf('kpib: All instruments (ports) closed.\n'); end
    validInst = 1;
    if nargout == 1, retval = 1; end
end

%% 'close'
% This function is used in order to close individual instruments with a
%  known GPIB address.
% For many instruments, this returns the instrument to local (front panel)
%  control.
% Can specify GPIB addresses as an array and all addresses will be closed.
% Can specify serial ports ('COM1', 'COM2'), but don't mix serial and GPIB.
if strcmpi(instrument,'close')
    if isnumeric(GPIB)
        if verbose >= 2, fprintf('kpib: Closing GPIB# %d.\n',GPIB); end
        for g=GPIB
            iof = instrfind('Type','gpib','PrimaryAddress',g);
            if ~isempty(iof) 
                fclose(iof);
                delete(iof);
                clear iof;
            else
                if verbose >= 1, fprintf('kpib: No instrument in memory at GPIB# %d.\n',g); end
            end
        end
    elseif strncmpi(GPIB,'COM',3)
        if verbose >= 2, fprintf('kpib: Closing serial port %s.\n',GPIB); end
        iof = instrfind('Type','serial');
        if ~isempty(iof) 
            fclose(iof);
            delete(iof);
            clear iof;
        end
    else
        fprintf('kpib: Error, invalid GPIB address ["%s"].\n',GPIB);
    end
    validInst = 1;
end

%% 'open'
% This function basically calls fopen().
% Sort of a ping.
% Can specify GPIB addresses as an array and all addresses will be opened.
if strcmpi(instrument,'open')
    if isnumeric(GPIB)
        if verbose >= 2, fprintf('kpib: Opening GPIB# %d.\n',GPIB); end
        for g=GPIB
            %io = instrfind('Type','gpib','PrimaryAddress',g);
            io = port(g,instrument,value,verbose);
%             if isempty(io)
%                 io = gpib('ni',0,g);
%                 fopen(io);
% %                 set(io,'EOSMode','read&write')
% %                 set(io,'EOSCharCode','LF')
% %                 EOSmode=get(io,'EOSMode');
% %                 if verbose >= 3, fprintf('kpib/open: EOSmode: %s\n',EOSmode); end
%             else
%                 if verbose >= 1, fprintf('kpib: Instrument at GPIB# %d already open.\n',g); end
%             end
        end
        if nargout > 0, retval = io; end
    else
        fprintf('kpib: Error, invalid GPIB address ["%s"].\n',GPIB);
    end
    validInst = 1;
end

%% 'write'
% This function is used to write the string COMMAND to a specified address.
if strcmpi(instrument,'write')
    if verbose >= 2, fprintf('kpib: Writing to GPIB# %d.\n',GPIB); end
    io = port(GPIB,instrument);
    fprintf(io,command);
    validInst = 1;
end

%% 'writeread'
% This function is used to make queries that return a value. The string
%  COMMAND is written to the GPIB address and whatever is returned is
%  returned. The buffersize can also be set to VALUE. The default buffer
%  size is 1000 bytes. The buffer has to be large enough to contain whatever
%  will be returned.
if strcmpi(instrument,'writeread')
    if verbose >= 2, fprintf('kpib: Writing "%s" to GPIB# %d and reading response.\n',command,GPIB); end
    io = port(GPIB,instrument,value,verbose);
    fprintf(io,command);
    retval = fscanf(io);
    validInst = 1;
end


%% 'scan'
% This function scans the GPIB bus and returns information about the type
%  of GPIB interfaces and connected instruments. Uses the INSTRHWINFO
%  function.
if strcmpi(instrument,'scan')
    if verbose >=2, fprintf(1,'%s\n',versionstr); end
    gpib_interfaces = instrhwinfo('gpib');
    %n = length(gpib_interfaces.InstalledAdaptors);
    for i=1:length(gpib_interfaces.InstalledAdaptors);
        fprintf(1,'kpib/scan: GPIB interface ''%s'':\n',gpib_interfaces.InstalledAdaptors{i});
        fprintf(1,'           Instruments Detected:\n');
        boardinfo=instrhwinfo('gpib',gpib_interfaces.InstalledAdaptors{i});
        for j=1:length(boardinfo.ObjectConstructorName)
            fprintf(1,'             %s\n',boardinfo.ObjectConstructorName{j});
        end
    end
    if verbose >= 3,
        fprintf(1, '%s\n%s\n%s\n%s\n','kpib/scan: Note: if you are having trouble with kpib,',...
                   '            make sure that the correct GPIB interface manufacturer',...
                   '            from the list show here is entered in the kpib code',...
                   '            as the value for the variable "gpib_interface_manufacturer".');
    end
    
    serial_interfaces = instrhwinfo('serial');
    for i=1:length(serial_interfaces.AvailableSerialPorts);
        fprintf(1,'kpib/scan: Serial interface ''%s''\n\n',serial_interfaces.AvailableSerialPorts{i});
    end

    validInst = 1;
end

% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %
%% Individual Instrument Drivers
% Each supported instrument is handled by the appropriate IF statement
% which matches the 'INSTRUMENT' parameter. Documentation for each driver
% is in the comment field for each section.
% 

%% 'None' (no instrument)
% This is a "dummy instrument" so that we can make calls the kpib that have
%  no result
% 'none' | '[none]' | '(none)'
if any(strcmpi(instrument,{'none','[none]','(none)'}))
    if verbose >= 2, fprintf(1, 'kpib: Instrument NONE'); end
    if nargout > 0
        if strcmpi(value,'temp')
            retval = 1776;
            if verbose >= 2, fprintf(1, ', retval = 1776 (temp).\n'); end
        else
            retval = 0;
            if verbose >= 2, fprintf(1, ', retval = 0.\n'); end
        end
    else
        if verbose >= 2, fprintf('.\n'); end
    end
    validInst = 1;
end


%% 'Blueoven' Thermotron S1 with 2800-series controller
% The BlueOven is a Thermotron S1 thermal chamber with a 2800-series
% controller.

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid oven commands:
% 'init'   Initializes the oven with a 3 sec command lock out. Locks the
%           keypad. VALUE determines hard or soft init:
%           VALUE==0 "hard" reset- forces hardware reset with "I"
%           Value~=0 "soft" reset- manual, stop, lock commands, does not use "I"
% 'set'    Sets the temperature setpoint to VALUE in degrees C. Also 'setT'.
%           Query setpoint with VALUE == 'query' or '?'
% 'read'   Reads the current temperature and the setpoint temperature. Returns the
%           oven temperature as read by the controller (change in v2.9)
% 'stop'   Stops the ovens current program, sets the setpoint to 22 C, and
%           unlocks the keypad.
% 'lock'   Locks the keypad.
% 'unlock' Unlocks the keypad.
%

if (strcmpi(instrument, 'BlueOven') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
    
        % default to hard reset
        %if nargin < 4, value = 0; end

        switch command
            case 'init'
                if verbose >= 1, fprintf('kpib/BlueOven: Initializing Blue Oven at address %.0f\n',GPIB); end
                % what kind of reset?
                if value==0 % do a hard reset with "I" command (default)
                    fprintf(io,'I');  % Forces the 2800 to do a hardware reset taking 3 sec.
    %                 pause(10); % pause to prevent further communication with blue oven during reset.
    %                 fprintf(io,'LKS1'); % Locks the oven keypad.
    %                 fclose(io);

                elseif value~=0 % do a soft reset with manual, stop, lock
                    fprintf(io,'RM'); % set to run manual mode
                    fprintf(io,'S'); % stop any programs
                    fprintf(io,'LKS1'); % lock the keypad

                end

            case {'set','setT'}
                if isnumeric(value)
                    value=round(value); % whole numbers only, please
                    if verbose >= 2, fprintf('kpib/BlueOven: Setting the Blue Oven to %d C\n', value); end
                    fprintf(io,'RM');  % Sets the oven into run manual
                    if value >= 0
                        fprintf(io,'LTS+%d',value); % Loads temperature set point
                    end
                    if value < 0
                        fprintf(io,'LTS%d',value); % Loads temperature set point
                    end
                elseif strcmpi(value,'query') || strcmpi(value,'?')
                    fprintf(io, 'DTS'); %Tells the controller to dump temperature setpoint.
                    retval = fscanf(io, '%f'); %Reads the dumped setpoint.
                    if verbose >= 2, fprintf(1,'kpib/BlueOven: Setpoint: %d C\n',retval); end
                else
                    if verbose >= 1, fprintf(1,'kpib/BlueOven: "set" command error\n'); end
                end

            case {'read','getdata'}
                if verbose >= 2, fprintf('kpib/BlueOven: Reading the Blue Oven temperature:'); end
                fprintf(io, 'DTV'); %Tells the controller to dump temperature value.
                retval = fscanf(io, '%f'); %Reads the dumped temp value.
                if verbose >= 2, fprintf(1,' %.1f C\n',retval); end

            case {'stop','off'}
                if verbose >= 2, fprintf('kpib/BlueOven: Stopping the Blue Oven\n'); end
                fprintf(io, 'RM'); %Causes controller to go to manual operation.
                fprintf(io, 'LTS+22'); %Sets the oven temp to 22 C.
                fprintf(io, 'S'); %Stops the controller from any running condition.
                fprintf(io, 'LKS0'); %Unlocks the keypad.

            case 'lock'
                fprintf(io,'LKS1'); % Locks the oven keypad.
                if verbose >= 2, fprintf('kpib/BlueOven: Blue Oven keypad locked.\n'); end

            case 'unlock'
                fprintf(io,'LKS0'); % Unlocks the oven keypad.
                if verbose >= 2, fprintf('kpib/BlueOven: Blue Oven keypad unlocked.\n'); end


            otherwise
                if verbose >= 1, fprintf('kpib/BlueOven: Error, command not supported. ["%s"]\n',command); end
        end
        
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end BlueOven


%% 'GreyOven' Testequity 1007S
% The Grey Oven has a ICS 4809 GPIB interface which communicates with the
%  Watlow F4 termperature controller. See manual on the web: "TestEquity
%  GPIB Interface Option" and printed manual for both the chamber and the
%  controller.
% Note that one decimal point is implied for all communication with the
%  Grey Oven/F4.

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid oven commands:
% 'init'   Initializes the oven with a *RST command. Sets the command timeout to
%           300 ms, as per example in the manual. Locks the keypad.
% 'set'    Sets the temperature setpoint to VALUE in degrees C.
%           Query setpoint with VALUE == 'query' or '?'
% 'read'   Reads the current oven temperature. Returns the oven temperature
%           and setpoint as read by the controller (change in v2.9)
%           Use VALUE=='temp' to read the unfiltered "high-res'
%           temperature.
% 'stop'   Stops the oven controller.
% 'lock'   Locks the keypad (setpoint control only).
% 'unlock' Unlocks the keypad.
%
if (strcmpi(instrument, 'GreyOven') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        
        switch command
            case 'init'
                if verbose >= 2, fprintf(1, 'kpib/GreyOven: Initializing Grey Oven at address %.0f\n',GPIB); end
                % send Reset Command
                fprintf(io,'*RST');
                % set the command timeout to 300 ms
                fprintf(io,'D300');
                % lock the set point
                fprintf(io,'W1300,1');

            case {'set','setT'}
                if isnumeric(value)
                    % setpoint is register 300. Send temperature with one decimal
                    %  point implied.
                    go_set=value*10;
                    fprintf(io,'W300,%0f',go_set);
                    if verbose >= 2, fprintf(1, 'kpib/GreyOven: Setting the Grey Oven to %.1f C\n', value); end
                elseif strcmp(value,'query') || strcmpi(value,'?')
                    % check to be sure that the result will be given using one
                    %  implied decimal point (default)
                    fprintf(io,'R606,1');
                    decimal_pt=fscanf(io, '%f');
                    fprintf(io,'R300,1');
                    set_temp=fscanf(io, '%f');
                    % divide result by ten if required
                    if decimal_pt == 1
                        retval = set_temp/10;
                    else
                        retval = set_temp;
                    end
                else
                    if verbose >= 1, fprintf(1, 'kpib/GreyOven: "set" command error\n'); end
                end

            case {'read','getdata'}
                % check to be sure that the result will be given using one
                %  implied decimal point (default)
                fprintf(io,'R606,1');
                decimal_pt=fscanf(io, '%f');
                %if strcmp(value,'temp')
                if any(strcmpi(value,{'temp','temperature','T'})) %v4.72
                    % read the "high-res" temperature from register 1707
                    % it has two decimal places of precision
                    fprintf(io,'R1707,1');
                    go_temp=fscanf(io, '%f'); retval=go_temp/100;
                else
                    % read the temperature from register 100
                    fprintf(io,'R100,1');
                    go_temp=fscanf(io, '%f');
                    % divide result by ten if required
                    if decimal_pt == 1
                        retval = go_temp/10;
                    else
                        retval = go_temp;
                    end
                end
                if verbose >= 2, fprintf(1, 'kpib/GreyOven: Grey Oven temperature: %.1f\n',retval); end

            case {'stop','off'}
                if verbose >= 2, fprintf(1, 'kpib/GreyOven: Stopping the Grey Oven\n'); end
                % to stop the F4 controller in manual mode, set the temperature
                %  setpoint to the low limit -1 (F4 manual page 3.1)
                % NB: this is the low limit in implied-decimal-point ModBus
                %  numbers-1, NOT setpoint-1 in Deg C.
                fprintf(io,'R602,1'); % read the set point low limit
                lowlimit=fscanf(io,'%f');
                fprintf(io,'W300,%0f',lowlimit-1); % Sets the oven temp to Low Limit -1.
                                                   %  (implied decimal point ModBus numbers)
                fprintf(io,'W1315,0'); % unlock the control panel.

            case 'lock'
                fprintf(io,'W1300,1'); % Locks the oven keypad (setpoint only).
                if verbose >= 2, fprintf('kpib/BlueOven: Grey Oven keypad locked.\n'); end

            case 'unlock'
                fprintf(io,'W1315,0'); % Clears all locks.
                if verbose >= 2, fprintf('kpib/BlueOven: Grey Oven keypad unlocked.\n'); end        

            otherwise
                if verbose >= 2, fprintf(1, 'kpib/GreyOven: Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end GreyOven


%% 'HP_3478A' HP multimeter.
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'    Initialize the multimeter.
% 'read'    Trigger a measurement of type VALUE ('volt'|'ohms'|'curr'|'temp') with
%            range CHANNEL and return the result
%           'read' defaults to voltage measurement for compatibility with code
%            written to kpib < v2.4.
% 'getdata' Same as 'read'.
%
% Valid ranges for measurement in Volts:
%   .030,.300,3,30,300
% Valid ranges for measurement in Ohms:
%   30,300,3000,30000,300000,3000000,30000000
% If no CHANNEL is supplied for the range then the multimeter is set to
% auto.
%
%

% 3478A command strings (manual p59)
% Mxx  SRQ mask
% Zx   Autozero on or off (0 | 1)
% Nx   Display setting: (3 - 5) digits of resolution
% Fx   Instrument function (1 - 7);
%      1 = DC volts, 3 = 2-wire ohms, 5 = DC current
% Rx   Range(-2 - 7, A). A = autorange
% Tx   Trigger. 1 = internal trigger
 
if (strcmpi(instrument, 'HP_3478A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
    %fprintf(io, '*RST');

        switch command
            case 'init'
               fprintf(io,'H0');

            case {'read','getdata'}
                % if VALUE is not specified (volts,ohms,curr,temp), default to volts
                    switch value
                        case {'ohm','ohms','R'}
                            % if a valid range has been specified, use it. CHANNEL is
                            %     the measurement range in ohms
                             switch channel
                                case 30
                                    fprintf(io, 'M01Z1N5F3R1T1');
                                case 300
                                    fprintf(io, 'M01Z1N5F3R2T1');
                                case 3000
                                    fprintf(io, 'M01Z1N5F3R3T1');
                                case 30000
                                    fprintf(io, 'M01Z1N5F3R4T1');
                                case 300000
                                    fprintf(io, 'M01Z1N5F3R5T1');
                                case 3000000
                                    fprintf(io, 'M01Z1N5F3R6T1');
                                case 30000000
                                    fprintf(io, 'M01Z1N5F3R7T1');
                                otherwise
                                    if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                    fprintf(io, 'M01Z1N5F3RAT1');
                            end
                            % read the value returned
                            retval = fscanf(io,'%f');
                            if verbose >=2, fprintf(1,'%s %f %s\n','kpib/HP_3478A: Resistance measurement:',retval,'ohms'); end

                        case {'volt','volts','V','temp','temperature','T'}
                            % "temperature" is a special case of reading
                            %  voltage from a LM35 sensor. Temperature in C
                            %  equals voltage*100
                            
                            % if a valid range has been specified, use it.
                            %   CHANNEL is the measurement range in volts.
                             switch channel
                                case .030
                                    fprintf(io, 'M01Z1N5F1R-2T1');
                                case .300
                                    fprintf(io, 'M01Z1N5F1R-1T1');
                                case 3
                                    fprintf(io, 'M01Z1N5F1R0T1');
                                case 30
                                    fprintf(io, 'M01Z1N5F1R1T1');
                                case 300
                                    fprintf(io, 'M01Z1N5F1R2T1');
                                otherwise
                                    switch value
                                        case {'volt','volts','V'}
                                            if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                            fprintf(io, 'M01Z1N5F1RAT1');
                                        case {'temp','temperature','T'}
                                            if verbose >= 2, fprintf('kpib/HP_3478A: Range 3 volts (default for T measurement)\n'); end
                                            fprintf(io, 'M01Z1N5F1R0T1');
                                    end                                    

                            end
                            % read the value returned
                            retval = fscanf(io,'%f');
                            switch value
                                case {'volt','volts','V'}
                                    if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Voltage measurement:',retval,'volts'); end
                                case {'temp','temperature','T'}
                                    retval = retval *100; % return value in deg C
                                    if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Temperature measurement:',retval,'deg C'); end
                            end
                                    
                        
%                         % 'temp' currently refers to the LM35 circuit where
%                         %    T (deg C) = volts*100
%                         % but this could be changed in future to be a
%                         %  4-wire resistance measurement of an RTD
%                         case {'temp','temperature','T'}
%                             % if a valid range has been specified, use it. Otherwise default to 3 volts.
%                             %  CHANNEL is the measurement range in volts
%                              switch channel
%                                 case .030
%                                     fprintf(io, 'M01Z1N5F1R-2T1');
%                                 case .300
%                                     fprintf(io, 'M01Z1N5F1R-1T1');
%                                 case 3
%                                     fprintf(io, 'M01Z1N5F1R0T1');
%                                 case 30
%                                     fprintf(io, 'M01Z1N5F1R1T1');
%                                 case 300
%                                     fprintf(io, 'M01Z1N5F1R2T1');
%                                 otherwise
%                                     if verbose >= 2, fprintf('kpib/HP_3478A: Range 3 volts (default temp)\n'); end
%                                     fprintf(io, 'M01Z1N5F1R0T1');
%                             end
%                             % read the value returned
%                             retval = fscanf(io,'%f'); retval = retval *100; % return value in deg C
%                             if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Temperature measurement:',retval,'deg C'); end

                        case {'curr','current','I'}
                            % if a valid range has been specified, use it. CHANNEL is
                            %     the measurement range in amps
                             switch channel
                                case .030
                                    fprintf(io, 'M01Z1N5F5R-2T1');
                                case .300
                                    fprintf(io, 'M01Z1N5F5R-1T1');
                                case 3
                                    fprintf(io, 'M01Z1N5F5R0T1');
                                case 30
                                    fprintf(io, 'M01Z1N5F5R1T1');
                                case 300
                                    fprintf(io, 'M01Z1N5F5R2T1');
                                otherwise
                                    if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                    fprintf(io, 'M01Z1N5F5RAT1');
                            end
                            % read the value returned
                            retval = fscanf(io,'%f');
                            if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Current measurement:',retval,'amps'); end

                        otherwise % default to voltage measurement for compatibility with older code
                            % if a valid range has been specified, use it. CHANNEL is
                            %     the measurement range in volts
                             switch channel
                                case .030
                                    fprintf(io, 'M01Z1N5F1R-2T1');
                                case .300
                                    fprintf(io, 'M01Z1N5F1R-1T1');
                                case 3
                                    fprintf(io, 'M01Z1N5F1R0T1');
                                case 30
                                    fprintf(io, 'M01Z1N5F1R1T1');
                                case 300
                                    fprintf(io, 'M01Z1N5F1R2T1');
                                otherwise
                                    if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                    fprintf(io, 'M01Z1N5F1RAT1');
                            end
                            % read the value returned
                            retval = fscanf(io,'%f');
                            if verbose >= 2, fprintf(1,'%s %f %s\n','kpib/HP_3478A: Voltage measurement (default):',retval,'volts'); end

                    end % end ohms/volts/curr (VALUE) switch

            otherwise
                if verbose >= 1, fprintf('kpib/HP_3478A: Error, command not supported by the instrument.\n'); end

        end % end command switch
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_3478A
            
    

%% 'HP_34401A' HP multimeter
% RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid instructions:
% 'read'    Trigger a measurement of type VALUE ('volt'|'ohms') with
%            range CHANNEL and resolution AUX and return the result
%
% 'config'  Configures the multimeter for measurement VALUE ('volt') with range
%            CHANNEL and resolution AUX. Once the instrument has been configured,
%            measurement results can be downloaded from the instrument in quick
%            succession using 'getdata'. Currently, only voltage measurements are
%            supported in kpib, but the principle is applicable to all of the
%            instrument's functions.
%
% 'getdata' Return the current measurement result. This is in contrast to the
%            'read' command, which configures and triggers the measurement before
%            returning the result. As a result, 'getdata' is much faster than
%            'read' for repeated measurements of the same quantity.
%
% Valid ranges for the resistance measurement in ohms:
%     100, 1000, 10000, 1000000, 10000000
% Valid ranges for voltage measurement in volts:
%     .030,.300,3,30,300
%
% If no VALUE is supplied for the range then the multimeter is set to auto.
%
% Returned values:
% For command 'read':
%  retval       The multimeter measurement, as a %f number
%
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
if (strcmpi(instrument, 'HP_34401A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);  cmd = [];
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case {'config','configure'} % use config to set up a measurement and 'getdata' to measure
                switch value
                    case {'volt','volts','V','VDC'}
                        if (any(channel == [0.030 0.300 3 30 300]))
                            if verbose >=2, fprintf(1,'%s %g %s\n','kpib/HP_34401A: Configure for Voltage measurement with range',channel,'volts'); end
                            cmd=sprintf('CONF:VOLT:DC %d,DEF', channel);
                            % if a valid resolution has also been specified, use it
                            if aux >= 1e-8
                                if verbose >=2, fprintf(1,'  %s %g %s\n','and with resolution',aux,'volts'); end
                                cmd=sprintf('CONF:VOLT:DC %d,%d', channel, aux);
                            end
                            % send the resulting command
                            fprintf(io,cmd);             
                        else
                            % if the specified range/resolution are not valid, then
                            %  autorange
                            if verbose >=2, fprintf(1,'%s\n','kpib/HP_34401A: Configure for autorange Voltage measurement'); end
                            fprintf(io,'CONF:VOLT:DC DEF,DEF');
                        end
                    otherwise
                        if verbose >= 1, fprintf('kpib/HP_34401A: Error, only "volt" configuration supported.\n'); end
                end
                        
                        
            case 'read'
                switch value
                    case {'ohm','ohms','R'}
                        if any(channel == [100 1000 10000 1000000 10000000])
                            if verbose >=2, fprintf(1,'%s %d\n','kpib/HP_34401A: Resistance measurement, range:',channel); end
                            cmd = sprintf('MEAS:RES? %d,DEF', channel);
                            % if a valid resolution has been specified, use it
                            if aux >= 0.0001
                                if verbose >=2, fprintf(1,'  %s %g %s\n','with resolution:', aux, 'ohms'); end
                                cmd = sprintf('%s %d%s%d', 'MEAS:RES?', channel, ',', aux);
                            end
                            % send the resulting command
                            fprintf(io, cmd);
                        else
                            % if the specified range/resolution are not valid, then autorange
                            if verbose >=2, fprintf(1,'%s\n','kpib/HP_34401A: Autorange resistance measurement'); end
                            fprintf(io,'MEAS:RES? DEF,DEF');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/HP_34401A: Resistance Measurement:',retval,'ohms'); end

                    case {'volt','volts','V','VDC'}
                        % if a valid range has been specified, use it. CHANNEL
                        %     is the measurement range in volts
                        if (any(channel == [0.030 0.300 3 30 300]))
                            if verbose >=2, fprintf(1,'%s %g %s\n','kpib/HP_34401A: Voltage measurement with range',channel,'volts'); end
                            cmd=sprintf('MEAS:VOLT:DC? %d,DEF', channel);
                            % if a valid resolution has also been specified, use it
                            if aux >= 1e-8
                                if verbose >=2, fprintf(1,'  %s %g %s\n','and with resolution',aux,'volts'); end
                                cmd=sprintf('MEAS:VOLT:DC? %d,%d', channel, aux);
                            end
                            % send the resulting command
                            fprintf(io,cmd);
                        else
                            % if the specified range/resolution are not valid, then
                            % autorange
                            if verbose >=2, fprintf(1,'%s\n','kpib/HP_34401A: Autorange voltage measurement'); end
                            fprintf(io,'MEAS:VOLT:DC? DEF,DEF');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/HP_34401A: Measurement:',retval,'volts'); end

                    case {'curr','current','I','IDC'}
                        % if a valid range has been specified, use it. CHANNEL
                        %     is the measurement range in volts
                        if (any(channel == [0.030 0.300 3 30 300]))
                            if verbose >=2, fprintf(1,'%s %g %s\n','kpib/HP_34401A: Current measurement with range',channel,'Amps'); end
                            cmd=sprintf('MEAS:CURR:DC? %d,DEF', channel);
                            %if nargin > 5
                                % if a valid resolution has also been specified, use it
                                if aux >= 1e-8
                                    if verbose >=2, fprintf(1,'  %s %g %s\n','and with resolution',aux,'Amps'); end
                                    cmd=sprintf('MEAS:CURR:DC? %d,%d', channel, aux);
                                end
                            %end
                            % send the resulting command
                            fprintf(io,cmd);
                        else
                            % if the specified range/resolution are not valid, then
                            % autorange
                            if verbose >=2, fprintf(1,'%s\n','kpib/HP_34401A: Autorange current measurement'); end
                            fprintf(io,'MEAS:CURR:DC? DEF,DEF');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/HP_34401A: Measurement:',retval,'Amps'); end
                        
                    otherwise
                        if verbose >= 1, fprintf('kpib/HP_34401A: Error, must specify measurement: ''ohms'', ''volt'', or ''curr''.\n'); end

                end % end ohms/volts/current switch

            case {'getdata'} % get the current measurement result
                fprintf(io,'READ?');
                retval = fscanf(io,'%f');
                if verbose >=2, fprintf(1,'kpib/HP_34401A: Measurement: %f\n',retval); end
                
            otherwise
                if verbose >= 1, fprintf('kpib/HP_34401A: Error, command not supported by the instrument. ["%s"]\n',command); end

        end % end read

                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_34401A


%% HP Power Supplies ('HP_POWER')
% The GPIB commands are the same for all recent generations of HP power
%  supplies; the only difference is whether or not they have multiple outputs.
%  Note that kpib is doing no limit checking, and different models have
%  different output limits.
% If your model is not listed here, that means it hasn't been tested, but
%  it probably works if it is reasonably recent (< 10 yrs old). Use
%  INSTRUMENT == 'HP_POWER' to control a generic HP power supply.

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'  Send the *RST command to reset the instrument and clear registers
% 'read'  Reads the output levels of the specified Output CHANNEL.
%           Returns a single value if you specify VALUE ('volt' or 'curr'),
%           otherwise result is returned as a two-field structure of %f numbers:
%          retval.volt
%          retval.curr
% 'setV'   Sets the output voltage to VALUE in Volts. Also 'set' (deprecated).
% 'setI'   Sets the output current to VALUE in Amps.
%
% 'off'   Turns off both outputs.
% 'on'    Turns on both outputs.
%
 
if (any(strcmpi(instrument, HP_power)) || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        
        % do we need to select an output channel?
        if any(strcmpi(instrument, HP_power_M))
            % select the Output channel if specified, default to 1
            if ~(any(channel == [1 2 3]))
                channel=1;
            end
            if strcmpi(instrument,'HP_E3631A') % use name of channel instead of number
                switch channel
                    case 1
                        fprintf(io, 'INST:SEL P6V');
                    case 2
                        fprintf(io, 'INST:SEL P25V');
                    case 3
                        fprintf(io, 'INST:SEL N25V');
                end
            else
                fprintf(io, 'INST:SEL OUT%d', channel); % Selects the output
            end
            if verbose >= 2, fprintf(1, 'kpib/%s(%d): Output %d ',instrument,GPIB,channel); end
        end
        
        switch command
            case 'init'
                fprintf(io,'*RST');
            case 'read'
                switch value % return a single value or both V & I?
                    case {'volt','volts','V','v'}
                        % read the voltage
                        fprintf(io, 'MEAS:VOLT?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'reads %f Volts\n',retval); end
                    case {'curr','I','A','current'}
                        % read the current
                        fprintf(io, 'MEAS:CURR?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'reads %f Amps\n',retval); end
                    otherwise
                    % read the output
                    fprintf(io, 'MEAS:VOLT?');
                    retval.volt = fscanf(io,'%f');
                    fprintf(io, 'MEAS:CURR?');
                    retval.curr = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'reads %f Volts & %f Amps\n',retval.volt,retval.curr); end
                end

            case {'setV','volt','voltage','set'}
                % set the voltage
                fprintf(io, 'VOLT %f',value); % Sets voltage.
                if verbose >= 2, fprintf('Output Voltage set to %g Volts\n',value); end

            case {'setI','curr','current'}
                % set the current
                fprintf(io, 'CURR %f',value); % Sets current.
                if verbose >= 2, fprintf('Output Current set to %g Amps\n',value); end

            case 'off'
                fprintf(io, 'OUTP OFF'); % Disables all outputs.
                if verbose >= 2, fprintf(1, 'Outputs off.\n'); end
            case 'on'
                fprintf(io, 'OUTP ON'); % Enables all outputs.
                if verbose >= 2, fprintf(1, ' Outputs on.\n'); end

            otherwise
                if verbose >= 1, fprintf('Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_POWER


%% 'HP_89410A' HP Vector Signal Analyzer
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% In general, these commands assume that the analyzer is setup for Network
%  measurements, for example by recalling the state file "NA_1p2M.sta".
% Valid Commands:
% 'label'     Writes VALUE to the CHANNEL ('right' or 'left') corner
%              of the Analyzer display.
% 'channel'   Selects a channel (1-4) on the display. On the instrument, these
%              are called "traces" (A,B,C,D). The 'channel' command makes the
%              specified trace active for purposes of the marker, changing
%              settings, etc. CHANNEL does not refer to the
%              inputs on the front of the instrument.
% 'autozero'  Turns automatic autozeroing 'on' or 'off', or performs a
%              single autozero ('once').
% 'average'   VALUE can be:
%              'on'        turns averaging on
%              'off'       turns averaging off
%              'type'      sets type to CHANNEL ('norm','exp','repeat')
%              'repeat'    enables averaging repeat
%              'restart'   restarts the averaging
%              'finish'    waits for averaging to complete
%              <number>    number of measurements to average (default)
% 'autoscale' Autoscales the y axis for channel CHANNEL 'on','off' or
%              'once'. Default is once on the current channel. Use 'both'
%              for resonator measurements to autoscale channels 1 & 2.
% 'scale'     Sets the y scale (units/division) of the display. VALUE is the
%              scale in the current units, or 'VALUE' = 'autoy' for autoscale
%              command.
%              Query with VALUE = 'query', returns y scale in dB/division. 
% 'auto x'    Auto scales x axis 'off' or 'once'. Default is 'once'.
%              Not often used with Network measurements.
% 'mark2peak' Set Marker peak tracking to VALUE 'on' or 'off' for CHANNEL.
%              Default channel is 1.
% 'peaktrack' Same as 'mark2peak'.
% 'marker'    Sets the x position of the main marker on CHANNEL to VALUE.
%              Query with VALUE = 'query', returns x & y positions in Hz/dBm.
%              Also activates some marker functions, for VALUE:
%               'center','m2c',marker2center'
%                  makes the current marker position the frequency center
%               'peak','searchpeak','marker2peak'
%                  moves the marker to the location of maximum amplitude
% 'marker?'   (Alternate query form) Returns the markey position for CHANNEL.
%              Returns x & y values.
% 'center'    Set the center frequency to VALUE. Units of Hz.
%              Query with VALUE = 'query', returns center frequency in Hz.
% 'span'      Set the frequency sweep span VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'start'     Set the frequency sweep start VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'stop'      Set the frequency sweep stop VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'source'    Set the source (stimulus output) signal level. VALUE is the
%              desired signal level. Units of dBm.
%              Query with VALUE = 'query', returns a structure with two values:
%               state = 'on' | 'off'
%               level = source power in dBm.
% 'source?'   (Alternate query form) Returns source power in dBm.
% 'power'     Same as 'source'.
% 'autorange' Automatically determine the best input sensitivity. Default
%              CHANNEL is 1. VALUE can be 'up' or 'up-down'.
% 'getdata'   Download the current data trace from the analyzer. Data is
%              returned as a structure with fields x and y for the
%              specified CHANNEL. If AUX is one of a family of units
%              {'am','angl','freq','pow','time'}, then the units for the
%              data will also be returned. Default CHANNEL is 1. If VALUE
%              is 'x' or 'y', only that data is returned in a single
%              column array.
% 'units'     Returns the units for the axis VALUE ('x','y'). For Y units,
%              you must specify a "family" in AUX:
%                  'am','angl','freq','pow','time'
%              See the programming manual under CALC:UNITs for more information.
% 'display'   Turns trace CHANNEL 'on' or 'off'. Query state with 'query'.
%              Returns a binary word representing the on/off status of the four
%              channels (traces) on the display.
% 'trace'     Same as display.
% 'screen'    Turns the screen 'on' or 'off'. Query state with 'query'.
% 'pause'     Pauses measurement.
% 'continue'  Continues paused measurement.
% 'loadstate' Loads state file VALUE from default disk.
% 'savestate' Saves current state as state file VALUE to default disk.
% 'complete'  Enable status byte (SERS) "operation complete" (*OPC) for
%              the currently executing command, or the following command
%              if none is currently executing. Use with 'complete?' for
%              polling of instrument status.
% 'complete?' Query status byte (SERS). If bit 0 == 1, operation is
%              complete. Must use 'complete' *before* command of interest
%              for polling. Returns a decimal value equal to the binary
%              byte value. See manual p18,36.
% 'event?'    Returns the value of the event register. Bit 4 indicates
%              that an "event" has occurred.
% 'precision' Sets the number of digits of precision for the trace data
%             outputed to the value specified.
% 'precision?'Requests the amount of precision set for the trace data.
%             This returns an integer for the amount of precision.
% 'wait'      Instructs analyzer to finish its current command before
%              starting subsequent [overlapping] commands.

if (strcmpi(instrument, 'HP_89410A') || strcmpi(instrument, 'all'))
    % open a GPIB port for the instrument
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        % define list of Y unit types (manual p107)
        yunit_types={'am','angl','freq','pow','time'};
        % define list of source unit types (manual p349)
        srcunit_types={'dBm','dBV','dBVrms','dBVpk','V','Vpk','Vrms','W','Wrms'};
        
        switch command
            case 'init'
                % do nothing
                if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Initialize (nada). Load NA_1p3m.sta manually.\n'), end

            case 'label'
                if ~(strcmpi(channel,'left') || strcmpi(channel,'right'))
                    channel = 'left';
                end
                if isequal(channel,'left')
                    fprintf(io, 'DISP:TRAC:LAB:USER "%s"',value); % Writes to the upper left of the display.
                elseif isequal(channel,'right')
                    fprintf(io, 'DISP:TRAC:INFO "%s"',value); % Writes to the upper right of the display.
                else
                    fprintf(io, 'DISP:TRAC:LAB:USER "%s"',value); % Default to the upper left of the display.
                end

            case 'channel' % activate a channel
                % note that the 89410 has more display "traces" (4) than
                %  "channels" (2). So this command really does not activate
                %  a channel; it makes a certain trace the active trace on
                %  the display, for purposes of changing the scale or
                %  whatever. In our usual configuration for resonators, trace 1 will be
                %  showing magnitude, and trace 2 phase, both from Channel 2.
                                
                if isnumeric (value) && any(value == [1 2 3 4])
                    fprintf(io, 'DISP:WIND%d:ACTIVE ONCE',value); % manual p128
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Channel %d active.\n',value), end
                elseif ~isnumeric(value) && (strcmpi(value,'query') || strcmpi(value,'?'))
                    fprintf(io, 'DISP:WIND%d:ACTIVE?',value);
                    retval = fscanf(io); % % returns 1 or 0
                else
                    if verbose >= 1, fprintf(1, 'kpib/HP_89410A: Bad VALUE for channel (must be 1-4 or ''query'') ["%s"].\n',num2str(value)), end
                end

            case 'autozero'
                switch value
                    case 'on'
                        fprintf(io, 'CAL:ZERO:AUTO ON');
                    case 'off'
                        fprintf(io, 'CAL:ZERO:AUTO OFF');
                    case 'once'
                        fprintf(io, 'CAL:ZERO:AUTO ONCE');
                        
                        % wait for autozero to complete
                        % Polls Operational Status Register, see manual p19
                        pause(3); % register does not appear to set immediately??
                        fprintf(io,'STAT:OPER:COND?'); % are we calibrating now?
                        c1 = fscanf(io,'%f'); c=1;
                        if c1 == 1
                            if verbose >=2, fprintf(1, 'kpib/HP_89410A: Waiting for Autozero to finish\n'); end
                        else
                            if verbose >=1, fprintf(1, 'kpib/HP_89410A: Warning: Unexpected Operational Status Register value: %i\n',c1); end
                        end
                        while c
                            fprintf(io,'STAT:OPER:COND?');
                            c = fscanf(io,'%f');
                            pause(1);
                        end
                        if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autozero complete.\n'); end

                    otherwise
                        if verbose >= 1, fprintf(1, 'kpib/HP_89410A: Autozero: Not a valid VALUE parameter.\n'), end
                end

            case 'average'
                switch value
                    case 'on'
                        fprintf(io, 'AVER ON');
                        if verbose >=2, fprintf(1, 'kpib/HP_89410A: Measurement Averaging on'); end
                        if isnumeric(aux) && aux > 0
                            fprintf(io,'AVER:COUN %d',aux);
                            if verbose >= 2, fprintf(1, ', aver. factor: %d\n',aux); end
                        else
                            if verbose >= 2, fprintf(1, '\n'); end
                        end
                    case 'off'
                        fprintf(io, 'AVER OFF');
                        if verbose >=2, fprintf(1, 'kpib/HP_89410A: Measurement Averaging off\n'); end
                    case {'query','?'}
                        fprintf(io, 'AVERAGE?');
                        retval = fscanf(io,'%f');
                    case {'num','num?','number','number?','count','count?'} % return the current average count
                        fprintf(io, 'AVER:COUN:INT?');
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1, 'kpib/HP_89410A: Average count: %d\n',retval); end
                    case {'numaverages?'} % return the current average num setting
                        fprintf(io, 'AVER:COUN?');
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1, 'kpib/HP_89410A: Number of measurements to average: %d\n',retval); end
                    case 'type'
                        switch channel
                            case {'norm','rms','normal'}
                                fprintf(io, 'AVER:TYPE RMS;TCON NORM');
                                if verbose >=2, fprintf(1, 'kpib/HP_89410A: Measurement Averaging rms ("normal")\n'); end
                            case {'exp','rmsexp','exponential'}
                                fprintf(io, 'AVER:TYPE RMS;TCON EXP');
                                if verbose >=2, fprintf(1, 'kpib/HP_89410A: Measurement Averaging rms exp.\n'); end
                            case {'rmsrep','repeat'}
                                fprintf(io, 'AVER:TYPE RMS;TCON REP');
                                if verbose >=2, fprintf(1, 'kpib/HP_89410A: Measurement Averaging rms repeat.\n'); end
                            otherwise
                                fprintf(io, 'AVER:TYPE RMS;TCON NORM');
                                if verbose >=2, fprintf(1, 'kpib/HP_89410A: Default averaging type: rms\n'); end
                        end
                    case 'repeat'
                        fprintf(io, 'AVER:TCON REPEAT');
                        if verbose >=2, fprintf(1, 'kpib/HP_89410A: Averaging measurements repeat\n'); end
                    case 'restart'
                        fprintf(io, 'ABOR;*WAI'); % note that this does not seem to have exactly the same effect as the front panel key;
                                                    % the *WAI command seems to be separate somehow
                        if verbose >=2, fprintf(1, 'kpib/HP_89410A: Restarting averaging\n'); end
                    case {'wait','finish','complete'}
                        % is averaging actually on?
                        fprintf(io, 'AVERAGE?');
                        as = fscanf(io,'%f');
                        if as == 1
                            % wait for averaging to complete
                            % Polls Operational Status Register, see manual p19
                            fprintf(io, 'AVER:COUN?'); % how many averages?
                            ac = fscanf(io,'%f');
                            pause(1); % averaging register does not appear to set immediately??
                            fprintf(io,'STAT:OPER:COND?'); % are we averaging now?
                            c1 = fscanf(io,'%f'); c=1;
                            if c1 == 280
                                if verbose >=2, fprintf(1, 'kpib/HP_89410A: Waiting for Averaging to finish (%d measurements)\n',ac); end
                            elseif c1 ~= 0
                                if verbose >=1, fprintf(1, 'kpib/HP_89410A: Warning: Unexpected Operational Status Register value: %i\n',c1); end
                            end
                            while c
                                fprintf(io,'STAT:OPER:COND?');
                                c = fscanf(io,'%f');
                                pause(1);
                            end
                            fprintf(io, 'AVER:COUN:INT?');
                            retval = fscanf(io,'%f');
                            if verbose >=2, fprintf(1, 'kpib/HP_89410A: Averaging complete (%d measurements).\n',retval); end
                        else
                            if verbose >=1, fprintf(1, 'kpib/HP_89410A: Warning: Averaging is off [pause 2 sec].\n'); end
                            retval = 0;
                            pause(2);
                        end
                        
                    otherwise % set the number of measurements to average
                        if isnumeric(value) && value > 0
                            if value > 0
                                fprintf(io, 'AVER:COUN %d', value);
                                if verbose >=2, fprintf(1, 'kpib/HP_89410A: Averaging factor set to %d\n',value); end
                            end
                        end
                end

            case {'auto y','autoy','autoscale'}
%                 if nargin > 3
                    switch value
                        case 'on'
                            fprintf(io, 'DISP:TRAC:Y:AUTO ON');
                            if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale on\n'); end
                        case 'off'
                            fprintf(io, 'DISP:TRAC:Y:AUTO OFF');
                            if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale off\n'); end
%                         case {'once','single'}
%                             if nargin > 4
%                                 if isnumeric(channel) & any(channel == [1 2 3 4]) % autoscale channel
%                                     fprintf(io, 'DISP:WIND%d:TRAC:Y:AUTO ONCE', channel);
%                                     if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale Y channel %d\n',channel); end
%                                 else
%                                     fprintf(io, 'DISP:TRAC:Y:AUTO ONCE');
%                                     if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale Y current channel\n'); end
%                                 end
%                             else
%                                 fprintf(io, 'DISP:TRAC:Y:AUTO ONCE');
%                                 if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale Y Channel 1 (default channel)\n'); end
%                             end
                        case 'both' % specific to resonators - autoscale channels 1 & 2
                            fprintf(io, 'DISP:WIND1:TRAC:Y:AUTO ONCE');
                            fprintf(io, 'DISP:WIND2:TRAC:Y:AUTO ONCE');
                            if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale once Y channels 1 & 2\n'); end
                        otherwise % autoscale once
                                if isnumeric(channel) && any(channel == [1 2 3 4]) % autoscale channel
                                    fprintf(io, 'DISP:WIND%d:TRAC:Y:AUTO ONCE', channel);
                                    if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale once Y channel %d\n',channel); end
                                else
                                    fprintf(io, 'DISP:TRAC:Y:AUTO ONCE');
                                    if verbose >=2, fprintf(1, 'kpib/HP_89410A: Autoscale once Y current channel\n'); end
                                end                            
                     end

            case 'scale' % manual p154
                % first, some error checking
                if ~isnumeric(channel)
                    channel = 1;
                    if verbose >= 2, fprintf('kpib/HP_89410A: Warning: CHANNEL must be numeric 1 - 4. Defaulting to 1.\n'); end
                elseif channel == 0
                    channel = 1;
                    if verbose >= 2, fprintf('kpib/HP_89410A: Warning: CHANNEL must be numeric 1 - 4. Defaulting to 1.\n'); end
                end
                % now if we just have a value, assume channel 1
                %  set scale to VALUE dB/div
                if isnumeric(value)
                    cmd = sprintf('DISP:WIND%d:TRAC:Y:PDIV %d',channel,value);
                    fprintf(io, cmd);
                    if verbose >= 2, fprintf('kpib/HP_89410A: Y Scale on channel %d set to %d/division\n',channel,value); end
                % but if we have a command, switch on it
                else
                    switch value
                        case {'auto','AUTO','autoscale','autoy'}
                            cmd = sprintf('DISP:WIND%d:TRAC:Y:AUTO ONCE',channel);
                            fprintf(io, cmd);
                            if verbose >= 2, fprintf('kpib/HP_89410A: Y Autoscale channel %d\n',channel); end
                        case {'query','?','read'}
                            fprintf(io, 'DISP:WIND%d:TRAC:Y:PDIV?',channel);
                            retval = fscanf(io,'%f');
                            if verbose >= 2, fprintf('kpib/HP_89410A: Y Scale on Channel %d is %d/division\n',channel,retval); end
                        otherwise
                            if verbose >= 1, fprintf('kpib/HP_89410A: VALUE for ''scale'' command not understood.\n'); end
                    end
                end

            case 'auto x'
                switch value
                    case 'off'
                        fprintf(io, 'DISP:TRAC:X:AUTO OFF');
                    case 'once'
                        fprintf(io, 'DISP:TRAC:X:AUTO ONCE');
                    otherwise
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Auto Scale X default: Once\n'); end
                        fprintf(io, 'DISP:TRAC:X:AUTO ONCE');
                end

            case {'mark2peak','peaktrack'}
                if ~(any(channel==[1 2 3 4]))
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Default channel 1 set for mark2peak.\n'); end
                    channel = 1; % Default channel is 1.
                end
                switch value
                    case 'on'
                        fprintf(io, 'CALC%d:MARK:MAX:TRAC ON', channel);
                    case 'off'
                        fprintf(io, 'CALC%d:MARK:MAX:TRAC OFF', channel);
                end

            case 'marker' % either set or query marker (set is default)
                if ~isnumeric(channel)
                    if verbose >= 1, fprintf('kpib/HP_89410A: Note: CHANNEL must be numeric 1 - 4. Defaulting to 1.\n'); end
                    channel = 1;
                elseif channel == 0
                    channel = 1;
                end
                if channel < 1 || channel > 4, channel = 1; end
                % set the marker position
                if isnumeric(value)
                    cmd=sprintf('CALC%d:MARK:X %0.0f HZ',channel,value);
                    fprintf(io, cmd);
                    if verbose >= 2, fprintf(1,'%s %d %s %f %s\n','kpib/HP_89410A: Marker on Channel',channel,'set to',value,'Hz'); end
                % or query the marker position
                else
                    switch value
                        case {'query','?'}
                            switch aux
                                case {'x','X'}
                                    fprintf(io, 'CALC%d:MARK:X?',channel);
                                    retval = fscanf(io,'%f');
                                case {'y','Y'}
                                    fprintf(io, 'CALC%d:MARK:Y?',channel);
                                    retval = fscanf(io,'%f');
                                otherwise
                                    fprintf(io, 'CALC%d:MARK:X?',channel);
                                    retval.x = fscanf(io,'%f');
                                    fprintf(io, 'CALC%d:MARK:Y?',channel);
                                    retval.y = fscanf(io,'%f');
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Marker on Channel %d position is %f/%f\n',channel,retval.x,retval.y); end
                            end
                        case {'center','m2c','mark2center'}
                            fprintf(io, 'CALC%d:MARK:X?',channel);
                            mc = fscanf(io,'%f');
                            fprintf(io,'FREQ:CENT %.3f',mc);
                            if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Marker to Center at %.3f Hz\n',mc); end
                        case {'peak','searchpeak','mark2peak'}
                            fprintf(io, 'CALC%d:MARK:MAX', channel);
                        otherwise
                            if verbose >= 1, fprintf(1, 'kpib/HP_89410A: Error at ''marker'' command (VALUE incorrect ["%s"]).\n',value); end
                    end                       
                end

            case 'marker?'
%                 if ~(any(channel==[1 2 3 4]))
%                     if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Default channel 1 marker.\n'); end
%                     value = 1; % Default channel is 1.
%                 else
%                     value = channel;
%                 end
                fprintf(io, 'CALC%d:MARK:X?',value);
                retval.x = fscanf(io,'%f');
                if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Channel %d marker x: %f\n',value,retval.x); end
                fprintf(io, 'CALC%d:MARK:Y?',value);
                retval.y = fscanf(io,'%f');
                if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Channel %d marker y: %f\n',value,retval.y); end

            case 'center' % manual p307
                % the query returns the center frequency.
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'FREQ:CENT?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Center at %g\n',retval); end
                else
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Center set to %g\n',value); end
                    fprintf(io,'FREQ:CENT %.3f',value);
                end

            case 'span'
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'FREQ:SPAN?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf('kpib/HP_89410A: Span at %g\n',retval); end
                else
                    if verbose >= 2, fprintf('kpib/HP_89410A: Span set to %g\n',value); end
                    fprintf(io,'FREQ:SPAN %.3f',value);
                end

            case 'start' % manual p321
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'FREQ:START?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Sweep start at %g\n',retval); end
                else
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Sweep start set to %g\n',value); end
                    fprintf(io,'FREQ:START %.3f',value);
                end

            case 'stop' % manual p324
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'FREQ:STOP?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Sweep stop at %g\n',retval); end
                else
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Sweep stop set to %g\n',value); end
                    fprintf(io,'FREQ:STOP %.3f',value);
                end

            case {'source','power'} % manual p349
                switch value
                    case 'on'
                        if verbose >= 2, fprintf('kpib/HP_89410A: Source output ON\n'); end
                        fprintf(io,'OUTP ON');
                    case 'off'
                        if verbose >= 2, fprintf('kpib/HP_89410A: Source output OFF\n'); end
                        fprintf(io,'OUTP OFF');
                    case {'query','?'}
                        fprintf(io,'OUTPUT:STATE?');
                        retval.state = fscanf(io,'%d');
                        if retval.state == 1
                            retval.state = 'on';
                        else
                            retval.state = 'off';
                        end
                        fprintf(io,'SOUR:VOLT:LEV:IMM:AMPL?');
                        retval.level = fscanf(io,'%f');
                        if verbose >= 2, fprintf('kpib/HP_89410A: Source %s; output level is set to %d dBm\n',retval.state, retval.level); end
                    case {'func','function'}
                        if any(strcmpi(channel,{'sin','sinusoid','rand','random','noise','pch','chirp'}))
                            fprintf(io,'SOUR:FUNCTION %s',channel);
                            if verbose >= 2, fprintf('kpib/HP_89410A: Source function set to %s\n',channel); end
                        else
                            if verbose >= 1, fprintf('kpib/HP_89410A: Warning: Source function not understood. [%s]\n',num2str(channel)); end
                        end
                    case {'freq','frequency'} %p342
                        fprintf(io,'SOUR:FREQ %f',channel);
                        if verbose >= 2, fprintf('kpib/HP_89410A: Source frequency %g Hz\n',channel); end
                    case {'offset'}
                        if abs(channel) <= 5
                            fprintf(io,'SOUR:VOLT:LEV:IMM:OFFSET %fV',channel);
                            if verbose >= 2, fprintf('kpib/HP_89410A: Source DC offset %g V\n',channel); end
                        else
                            if verbose >= 1, fprintf('kpib/HP_89410A: Warning: No change to Offset voltage. Max. offset +/- 5 V\n'); end
                        end
                    otherwise % set source power to the requested value
                        %sp=str2num(value);
                        % check input for allowed values
                        if isnumeric(value)% & (-110 <= value) & (value < 20)
                            if ~any(strcmpi(aux,srcunit_types))
                                aux='dBm';
                            end
                            cmd=sprintf('SOUR:VOLT:LEV:IMM:AMPL %d%s',value,aux);
                            fprintf(io,cmd);
                            if verbose >= 2, fprintf('kpib/HP_89410A: Source output level set to %g %s\n',value,aux); end
                        else
                            if verbose >= 1, fprintf('kpib/HP_89410A: Error: Specify source level (VALUE) as numeric.\n'); end
                        end
                end

            case {'source?','power?'}
                fprintf(io,'OUTPUT:STATE?');
                retval.state = fscanf(io,'%d');
                if retval.state == 1
                    retval.state = 'on';
                else
                    retval.state = 'off';
                end
                fprintf(io,'SOUR:VOLT:LEV:IMM:AMPL?');
                retval.level = fscanf(io,'%f');
                %retval = str2num(retval.source);
                if verbose >= 2, fprintf('kpib/HP_89410A: Source %s; output level is set to %g (dBm?)\n',retval.state, retval.level); end

            case 'autorange'
                % If channel is invalid, default to channel 1
                if ~(isequal(channel,1) || isequal(channel,2))
                    if verbose >= 2, fprintf('kpib/HP_89410A: Default channel 1 range.\n'); end
                    channel = 1;
                end
                % select a autorange direction
                % did the user specify a value? up or up-down?
                %  default to up
                if isnumeric(value)
                    if verbose >= 2, fprintf('kpib/HP_89410A: Default autorange up-only.\n'); end
                    value = 'up'; % Default is autorange up.
                else
                    switch value
                        case {'up','up-only'}
                            fprintf(io,'VOLT%d:RANG:AUTO:DIR UP',channel);
                        case {'updown','up-down','either'}
                            fprintf(io,'VOLT%d:RANG:AUTO:DIR EITHER',channel);
                        otherwise
                            fprintf(io,'VOLT%d:RANG:AUTO:DIR UP',channel);
                    end
                end
                % do the autorange            
                fprintf(io,'VOLT%d:RANG:AUTO ONCE',channel);
                if verbose >= 2, fprintf('kpib/HP_89410A: Autorange %s on channel %d.\n',value,channel); end


            case 'getdata'
                % did the user specify a channel? If not, or if channel is invalid,
                %  default to channel 1
                if ~(any(channel == [1 2 3 4]))
                %if ~(isequal(channel,1) | isequal(channel,2) | isequal(channel,3) | isequal(channel,4))
                    if verbose >= 2, fprintf('kpib/HP_89410A: Default channel 1 data.\n'); end
                    channel = 1;
                end
                % did the user specify x or y data? If not, send both
                switch value
                    case {'x','X'}
                        fprintf(io, 'TRAC:X:DATA? TRAC%d', channel);
                        data = fscanf(io);
                        raw = sscanf([data,','],'%e,');
                        retval = truncx(raw);
                        if verbose >= 2, fprintf('kpib/HP_89410A: Channel %d X data downloaded.\n',channel); end
                    case {'y','Y'}
                        fprintf(io,'CALC%d:DATA?',channel);
                        data = fscanf(io);
                        retval = sscanf([data,','],'%e,');
                        if verbose >= 2, fprintf('kpib/HP_89410A: Channel %d Y data downloaded.\n',channel); end
                    otherwise % return both x & y in a structure
                        fprintf(io, 'TRAC:X:DATA? TRAC%d', channel);
                        data = fscanf(io);
                        raw = sscanf([data,','],'%e,');
                        retval.x = truncx(raw);
                        fprintf(io,'CALC%d:DATA?',channel);
                        data = fscanf(io);
                        retval.y = sscanf([data,','],'%e,');
                        if verbose >= 2, fprintf('kpib/HP_89410A: Channel %d X & Y data downloaded.\n',channel); end
                        % does the user want units as well?
                        if any(strcmpi(aux,yunit_types))
                            % get x units
                            fprintf(io, 'TRAC:X:UNIT? TRAC%d', channel);
                            rd = fscanf(io);
                            retval.units.x = rd(2:end-2); % strip the trailing carriage return and quotes
                            % log or linear?
                            fprintf(io, 'DISP:WINDOW%d:TRAC:X:SPACING?', channel); % manual p151
                            mode = fscanf(io,'%s');
                            if strcmp(mode,'LOG')
                                retval.units.x = ['log ' retval.units.x];
                            end                            
                            if verbose >= 2, fprintf('kpib/HP_89410A: Channel %d X units are %s\n',channel,retval.units.x); end
                            % get y units
                            fprintf(io, 'CALC%d:UNIT:%s?',[channel aux]);
                            rd = fscanf(io);
                            retval.units.y = rd(1:end-1); % strip the trailing carriage return
                            % everything is in capitals
                            if isequal(retval.units.y,'DB'), retval.units.y='dB'; end
                            if isequal(retval.units.y,'DBM'), retval.units.y='dBm'; end
                            if isequal(retval.units.y,'DEG'), retval.units.y='deg'; end
                            if verbose >= 2, fprintf('kpib/HP_89410A: Channel %d Y units are %s\n',channel,retval.units.y); end
                        else
                            % get x units only
                            fprintf(io, 'TRAC:X:UNIT? TRAC%d', channel);
                            rd = fscanf(io);
                            retval.units.x = rd(2:end-2); % strip the trailing carriage return and quotes
                            % log or linear?
                            fprintf(io, 'DISP:WINDOW%d:TRAC:X:SPACING?', channel); % manual p151
                            mode = fscanf(io,'%s');
                            if strcmp(mode,'LOG')
                                retval.units.x = ['log ' retval.units.x];
                            end
                            retval.units.y = ' ';
                        end                   
                end

            case 'units'
                if ~(any(channel == [1 2 3 4]))
                    if verbose >= 2, fprintf('kpib/HP_89410A: Default channel 1 set for units.\n'); end
                    channel = 1; %Default channel is 1.
                end
                switch value
                    case 'x'
                        fprintf(io, 'TRAC:X:UNIT? TRAC%d', channel);
                        retval = fscanf(io);
                        retval = retval(2:end-2); % strip the trailing carriage return and the quotes
                        % log or linear?
                        fprintf(io, 'DISP:WINDOW%d:TRAC:X:SPACING?', channel); % manual p151
                        mode = fscanf(io,'%s');
                        if strcmp(mode,'LOG')
                            retval = ['log ' retval];
                        end
                        if verbose >= 2, fprintf('kpib/HP_89410A: Channel %d X units are %s\n',channel,retval); end
                    case 'y'
                        % Y units have to be specified in terms of their
                        %  "family"; see manual p106
                        if ~(any(strcmpi(aux,yunit_types)))
                            if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Y assumed to be measured for phase angle.\n'); end
                            channel = 'angl';
                        end

                        fprintf(io, 'CALC%d:UNIT:%s?',[channel aux]);
                        retval = fscanf(io);
                        retval = retval(1:end-1); % strip the trailing carriage return
                        % everything is in capitals
                        if isequal(retval,'DB'), retval='dB'; end
                        if isequal(retval,'DBM'), retval='dBm'; end
                        if isequal(retval,'DEG'), retval='deg'; end
                        if isequal(retval,'RAD'), retval='rad'; end

                        if verbose >= 2, fprintf('kpib/HP_89410A: Channel %d Y units are %s\n',channel,retval); end
                end

            case {'display','trace'} % either turn a channel display on/off, or return a binary word
                             %  (string) representing the state of the four displays
                switch value
                    case {'on','ON'}
                        fprintf(io, 'DISP:WIND%d:TRAC ON',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Trace %d on.\n',channel); end
                    case {'off','OFF'}
                        fprintf(io, 'DISP:WIND%d:TRAC OFF',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Trace %d off.\n',channel); end
                    case {'query','?'} % returns 1 for on, 0 for off for each channel
                        dstateword=[];
                        for cd=1:4
                            fprintf(io, 'DISP:WIND%d:TRAC:STATE?',cd);
                            dstateword(cd)=str2num(fscanf(io)); %#ok<AGROW>
                            if dstateword(cd)==1, dstate='on';
                            elseif dstateword(cd)==0, dstate='off';
                            end
                            if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Trace %d is %s.\n',cd,dstate); end
                            retval(cd)=num2str(dstateword(cd));
                        end
                end
            case {'screen'} % turn the screen on and off
                switch value
                    case{'on','ON',1}
                        fprintf(io, 'DISP:ENABLE ON');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Screen on\n'); end
                    case{'off','OFF',0}
                        fprintf(io, 'DISP:ENABLE OFF');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Screen off\n'); end                    
                    case{'query','?'}
                        fprintf(io, 'DISP:ENABLE?');
                        retval=fscanf(io,'%d');
                        if verbose >= 2
                            if retval==1
                                fprintf(1, 'kpib/HP_89410A: Screen is on\n');
                            elseif retval==0
                                fprintf(1, 'kpib/HP_89410A: Screen is off\n');
                            end
                        end
                end

            case 'pause'
                fprintf(io,'PAUSE');

            case 'continue'
                fprintf(io,'CONTINUE');

            case 'loadstate'
                fprintf(io,'MMEM:LOAD:STAT 1,%s',value);

            case 'savestate'
                fprintf(io,'MMEM:STOR:STAT 1,%s',value);

            case 'complete'
                if strcmp(value,'single')
                    % for single, use the averaging command for wait
                    kpib(instrument,GPIB,'average','complete',0,0,verbose);
                else
                    % Enable the Operation Complete bit of the Status Byte. Get
                    %  Status Byte with 'complete?' (manual p18)
                    % Note that many commands may trigger the OPC bit. Use
                    %  'wait' (*WAI) to force *currently buffered* commands to
                    %  execute in sequence.
                    fprintf(io,'*CLS');
                    %pause(1)
                    fprintf(io,'*OPC');
    %                 fprintf(io,'*ESR?');
    %                 esr = fscanf(io);
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Begin wait for Operation\n'); end
                    retval = 1; % for compatibility with older code
                end
                
            case 'complete?' % return Status Byte
                %fprintf(io,'*WAI;*OPC?');
                fprintf(io,'*ESR?');
                esr = fscanf(io);
                retval = str2num(esr);
                if verbose >= 2
                    if retval > 0
                        fprintf(1, 'kpib/HP_89410A: Operation complete.\n');
                    else
                        fprintf(1, 'kpib/HP_89410A: Operation complete.\n');
                    end
                end
                    
            case {'event?'}
                % For synchronizing with Averaging, the start of averaging
                %  after filling the time record and every new average
                %  count is an "event".
                % Queries the Device State Event register (manual p366)
                fprintf(io,'STATUS:DEVICE:EVENT?');
                dser = fscanf(io);
                retval = str2num(dser); %RETVAL of 32 (bit 4) indicates "Event Occurred"
                if verbose >= 2
                    if retval > 31
                        fprintf(1, 'kpib/HP_89410A: Operation complete.\n');
                    else
                        fprintf(1, 'kpib/HP_89410A: Operation not complete.\n');
                    end
                end
                
            case 'wait'
                % Note that *WAI does not really perform sychronization- the code
                %  continues to execute and send new commands to the instrument.
                % The instrument finishes its current command before
                %  processing any further commands.
                fprintf(io,'*WAI');
                retval = 1; % for compatibility with older code

            case 'precision'
                if value > 0
                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Default precision 10.\n'); end
                    value = 10;
                    fprintf(io, 'FORM ASC,%d', value);
                end

            case 'precision?'
                fprintf(io,'FORM?');
                retval = fscanf(io,'ASC,%i%i');

            case {'abort','restart'} % "pressing Meas Restart"
                fprintf(io,'ABORT');
                %retval = fscanf(io,'ASC,%i%i');
                
                
               % added by HKL & need test --------------------------
            case 'instmode' % selects the instrument mode p211 of the GPIB manual  
                switch value
                    case{'scalar','SCALAR'}
                        fprintf(io, 'INST:SEL SCALAR');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Instrument mode = scalar measurement\n'); end
                    case{'demod','DEMOD','ademod','ADEMOD','analog'}
                        fprintf(io, 'INST:SEL ADEMOD');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Instrument mode = analog demodulation\n'); end    
                    case{'ddem','DDEM','digital'}
                        fprintf(io, 'INST:SEL DDEM');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Instrument mode = digital demodulation\n'); end
                    case{'vect','vector','VECT','VECTOR'}
                        fprintf(io, 'INST:SEL VECTOR');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Instrument mode = vector measurement\n'); end
                    case{'video','VIDEO','vdem','VDEM'}
                        fprintf(io, 'INST:SEL VDEM');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Instrument mode = video demodulation\n'); end    
                    case{'wcdma','WCDMA','wcdm','WCDM'}
                        fprintf(io, 'INST:SEL WCDMA');
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Instrument mode = WCDMA measurment\n'); end    
                        
                    case{'query','QUERY','?'}
                        fprintf(io, 'INST:SEL?');
                        retval=fscanf(io,'%s');
                        if verbose >= 2
                            fprintf(1, 'kpib/HP_89410A: Instrument mode = %s\n',retval);
                        end
                        
                    otherwise
                        fprintf(1, 'kpib/HP_89410A: improper value field for instmode command\n');

                end

            case 'demod' % selects the analog demodulation result p324 of the GPIB manual    
                
                switch value
                    case{'off','OFF'}
                        fprintf(io,'SENS:DEMOD%d OFF',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Demodulation off\n'); end
                    case{'am','AM'}
                        fprintf(io,'SENS:DEMOD%d AM',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Demodulation result = Analog Demod.\n'); end
                    case{'pm','PM'}
                        fprintf(io,'SENS:DEMOD%d PM',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Demodulation result = Phase Demod.\n'); end    
                    case{'fm','FM'}
                        fprintf(io,'SENS:DEMOD%d FM',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Demodulation result = Frequency Demod.\n'); end
                    case{'base','BASE','baseband','BASEBAND'}
                        fprintf(io,'SENS:DEMOD%d BASE',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: specify baseband\n'); end
                    
                    case{'autocarrieron','AUTOCARRIERON'}    
                        fprintf(io,'SENS:DEMOD%d:CARR:AUTO ON',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Auto carrier on\n'); end
                    case{'autocarrieroff','AUTOCARRIEROFF'}    
                        fprintf(io,'SENS:DEMOD%d:CARR:AUTO OFF',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Auto carrier off\n'); end 
                    
                    case{'autocarrierphaseonly','AUTOCARRIERPHASEONLY'}    
                        fprintf(io,'SENS:DEMOD%d:CARR:AUTO:PM PHASE',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Auto carrier = Phase compensation only\n'); end  
                    case{'autocarrierphaseandfreq','AUTOCARRIERPHASEANDFREQ'}    
                        fprintf(io,'SENS:DEMOD%d:CARR:AUTO:PM PAFREQ',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Auto carrier = Phase and Freq. compensation\n'); end      
                    
                    case{'autocarrierfreq?','AUTOCARRIERFREQ?'}    
                        fprintf(io,'SENS:DEMOD:CARR:FREQ?');
                        retval=fscanf(io,'%f');
                        if verbose >= 2
                            fprintf(1, 'kpib/HP_89410A: Auto carrier Freq. = %f\n',retval);
                        end
                    
                    % selects the measurement data to be displayed (analog demodulation only). GPIB manual p.55    
                    case{'PSD'}
                        if(channel == 1 || channel == 2) 
                            switch aux
                                case{'PM','pm','Phase','phase'}
                                    fprintf(io,'CALC%d:FEED ''XFR:PM:PSD %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = PM PSD of Ch%d\n',channel); end 
                                case{'AM','am','Amplitude','amplitude'}
                                    fprintf(io,'CALC%d:FEED ''XFR:AM:PSD %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = AM PSD of Ch%d\n',channel); end 
                                case{'FM','fm','Frequency','frequency'}
                                    fprintf(io,'CALC%d:FEED ''XFR:FM:PSD %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = FM PSD of Ch%d\n',channel); end 
                                otherwise
                                    fprintf(io,'CALC%d:FEED ''XFR:PM:PSD %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = PM PSD of Ch%d\n',channel); end 
                            end
                        else
                             fprintf(1, 'kpib/HP_89410A: Channel for demod result should be either 1 or 2\n');
                        end
                    case{'spectrum'}
                        if(channel == 1 || channel == 2) 
                            switch aux
                                case{'PM','pm','Phase','phase'}
                                    fprintf(io,'CALC%d:FEED ''XFR:PM %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = PM spectrum of Ch%d\n',channel); end 
                                case{'AM','am','Amplitude','amplitude'}
                                    fprintf(io,'CALC%d:FEED ''XFR:AM %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = AM spectrum of Ch%d\n',channel); end 
                                case{'FM','fm','Frequency','frequency'}
                                    fprintf(io,'CALC%d:FEED ''XFR:FM %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = FM spectrum of Ch%d\n',channel); end 
                                otherwise
                                    fprintf(io,'CALC%d:FEED ''XFR:PM %d''',[channel channel]);
                                    if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Measurement data = PM spectrum of Ch%d\n',channel); end 
                            end
                        else
                            fprintf(1, 'kpib/HP_89410A: Channel for demod result should be either 1 or 2\n');
                        end
                        
                    case{'query','QUERY','?'}
                        fprintf(io, 'SENS:DEMOD?');
                        retval=fscanf(io,'%s');
                        if verbose >= 2
                            fprintf(1, 'kpib/HP_89410A: Demodulation result = %s\n',retval);
                        end
                    
    
                        
                    otherwise
                        fprintf(1, 'kpib/HP_89410A: improper value field for demod command\n');
                        
                end
                
                
           
                
                        
                        
            case 'RBW?'
                fprintf(io, 'SENS:BANDWIDTH:RESOLUTION?');
                retval=fscanf(io,'%f');
                if verbose >= 2
                    fprintf(1, 'kpib/HP_89410A: RBW = %f\n',retval);
                end
                
            % ------------------------------------------------       
                
                
            otherwise
                if verbose >= 1, fprintf('kpib/HP_89410A: Error, command not supported. ["%s"]\n',command); end

        end % commands
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_89410A


%% 'TEK_TDS' Tektronix oscilloscope
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% This function is used to 'read' the 'amplitude', 'frequency',
% 'peak2peak' or 'rms'.  It also returns the units of the measurement.  In
% order to obtain the waveform data 'getdata' is used and it outputs the data
% in a matrix.  All this can be done for channels 1 to 4. Note that the
% measurement does not need to be displayed on the screen of the oscilloscope.
% Note: this code should be valid for all members of the TDS family of oscilloscopes.
% Valid instructions:
% 'read'         Returns a measurement of type VALUE from CHANNEL (default 1).
%                 Measurement types are:
%                  'amplitude'  the high value minus the low value.
%                  'frequency'  the frequency of the signal.
%                  'peak2peak'  absolute difference between maximum and minimum
%                                values of the waveform.
%                  'rms'        the root mean square voltage.
% 'measure'      Same as 'read'.
% 'channel'      select a channel (1-4)
% 'display'      either turn a channel display on/off, or VALUE=='query' to
%                 return a binary word representing the state of the 4
%                 channels.
% 'getdata'      Downloads the complete waveform from the oscilloscope.
%                 The data is returned in a structure:
%                 retval.x
%                 retval.y
%                 retval.units.x
%                 retval.units.y
%
if strcmpi(instrument, 'TEK_TDS') || strcmpi(instrument, 'TDS_540') || strcmpi(instrument, 'all')
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case {'label'}
                fprintf(io,'MESSAGE:STATE ON');
                fprintf(io,'MESSAGE:SHOW "%s"',value);
                pause(2)
                fprintf(io,'MESSAGE:STATE OFF');
                
            case {'read','measure'}
                if any(channel == [1 2 3 4])
                    if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Channel %d selected.\n',channel); end
                    fprintf(io,'MEASU:IMM:SOURCE CH%d',channel);
                else % default to channel 1
                    if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Default channel is set to 1.\n'); end
                    channel=1;
                    fprintf(io,'MEASU:IMM:SOURCE CH1');
                end
                switch value
                    case {'amplitude','amp','ampl'}
                        fprintf(io,'MEASU:IMM:TYP AMPL');
                        fprintf(io,'MEASU:IMM:VAL?');
                        retval.val = fscanf(io,'%f');
                        fprintf(io,'MEASU:IMM:UNI?');
                        retval.units = fscanf(io,'%s');
                        retval.units = retval.units(2:end-1); % strip quotes
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/TEK_TDS: Channel:',channel,'Amplitude:',retval.val,retval.units);
                        end
                    case {'frequency','freq','f'}
                        fprintf(io,'MEASU:IMM:TYP FREQ');
                        fprintf(io,'MEASU:IMM:VAL?');
                        retval.val = fscanf(io,'%f');
                        fprintf(io,'MEASU:IMM:UNI?');
                        retval.units = fscanf(io,'%s');
                        retval.units = retval.units(2:end-1); % strip quotes
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/TEK_TDS: Channel:',channel,'Frequency:',retval.val,retval.units);
                        end
                    case {'peak2peak','p-p','vpp'}
                        fprintf(io,'MEASU:IMM:TYP PK2');
                        fprintf(io,'MEASU:IMM:VAL?');
                        retval.val = fscanf(io,'%f');
                        fprintf(io,'MEASU:IMM:UNI?');
                        retval.units = fscanf(io,'%s');
                        retval.units = retval.units(2:end-1); % strip quotes
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/TEK_TDS: Channel:',channel,'Peak2Peak:',retval.val,retval.units);
                        end
                    case {'rms','RMS'}
                        fprintf(io,'MEASU:IMM:TYP RMS');
                        fprintf(io,'MEASU:IMM:VAL?');
                        retval.val = fscanf(io,'%f');
                        fprintf(io,'MEASU:IMM:UNI?');
                        retval.units = fscanf(io,'%s');
                        retval.units = retval.units(2:end-1); % strip quotes
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/TEK_TDS: Channel:',channel,'RMS:',retval.val,retval.units);
                        end
                    otherwise
                        if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: No valid measurement type selected.\n'); end
                end

            case {'display','trace'} % either turn a channel display on/off, or return a binary word
                                     %  (string) representing the state of the four displays
                switch value
                    case {'on','ON'}
                        fprintf(io, 'SELECT:CH%d ON',channel);
                        if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Channel %d on.\n',channel); end
                    case {'off','OFF'}
                        fprintf(io, 'SELECT:CH%d OFF',channel);
                        if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Channel %d off.\n',channel); end
                    case {'query','?'} % returns 1 for on, 0 for off for each channel             
                        fprintf(io,'SELECT?'); % query the channel state (4 channels)
                        ch = fscanf(io);
                        dstate = sscanf(ch,'%d;%d;%d;%d;',4);
                        for cd=1:4
                            dstateword(cd) = num2str(dstate(cd));
                            if dstate(cd)==1 && verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Channel %d active.\n',cd); end
                            retval=dstateword;
                        end
                    case {'active','active?'}
                        fprintf(io,'SELECT?'); % query the channel state
                        ch = fscanf(io);
                        retval = sscanf(ch(23:end),'CH%d');
                    otherwise
                        if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Error: ''display'' VALUE not understood.\n'); end
                end
            
            case {'channel'} % select a channel
                if any(channel == [1 2 3 4])
                    fprintf(io,'SELECT:CH%d ON',channel); % select a channel (manual p2-214)
                    if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Channel %d selected.\n',channel); end
                end
            
            case 'getdata'
                if ~(any(channel == [1 2 3 4]))
                    if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Default channel 1 selected.\n'); end
                    channel=1;
                end
                        
%                 end              
                if any(channel == [1 2 3 4])
                    fprintf(io,'SELECT:CH%d ON',channel); % make sure the channel is on, otherwise it hangs
                    fprintf(io,'DAT:SOU CH%d',channel); % Sets which channel to be reading from.
                    if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Channel %d selected.\n',channel); end
                    fprintf(io,'DAT:ENC ASCI');
                    % determine what acquisition mode we are in
                    fprintf(io,'ACQ:MODE?');
                    mode = fscanf(io);
                    switch mode
                        case {'SAMPLE','ENVELOPE','PEAKDETECT','SAM','ENVE','PEAK'}
                            fprintf(io,'DAT:WID 1'); % 1 8-bit byte
                        case {'HIRES','AVERAGE','AVE','HIR'}
                            fprintf(io,'DAT:WID 2'); % 1 8-bit byte
                    end

                    fprintf(io,'DAT:STAR 1'); % Sets the start point of the waveform to the first point of data.
                    fprintf(io,'DAT:STOP 1000000'); % Sets the stop point of data transfer to the record length 
                                                    %  by far exceeding any possible record length.
                    fprintf(io,'WFMP:ENC ASC'); % ascii preamble
                    fprintf(io,'WFMP:PT_F Y'); % Specifies the function used to get the correct waveform data.
                    %fprintf(io,'WFMP:PT_OFF 1');
                    fprintf(io,'WFMP?');
                    preamble = fscanf(io);
                    preamble = [preamble,';'];

                    % Process the preamble
                    % Preamble has several useful fields (manual p2-207):
                    % {6}   a text description of the waveform
                    % {8}   data format ('Y' or 'ENV')
                    % {7}   number of data points
                    % {9}   X units
                    % {10}  X increment
                    % {11}  X offset
                    % {12}  Y units
                    % {13}  Y multiplier
                    % {14}  Y offset
                    % {15}  Y zero
    %                 [BYT_Nr,BIT_Nr,encoding,BN_Fmt,BYT_Order,desc,...
    %                         numdatapoints,PT_Fmt,xunits,xincr,xoffset,yunits,ymult,yoffset,yzero]...
    %                     =strread(preamble,'%s','delimiter',';')
                    pre=strread(preamble,'%s','delimiter',';');
                    if verbose >= 3
                        fprintf(1, 'kpib/TEK_TDS: Data preamble:\n');
                        for i=1:length(pre)
                            fprintf(1, '%s\n',pre{i});
                        end
                    end

                    % Read the data from the oscilloscope
                    fprintf(io,'CURVE?');
                    data = fscanf(io);
                    yval = sscanf([data,','],'%e,');
                    if verbose >= 2, fprintf(1, 'kpib/TEK_TDS: Data downloaded.\n'); end
                    %size(yval)

                    % Converts the necessary preamble values from strings into
                    %  numbers.
                    numdatapoints  = str2num(pre{7}); % The number of data points
                    dformat = pre{8}; % envelope or normal
                    xincr = str2double(pre{10}); % The x increment
                    xoffset = str2double(pre{11}); % The x offset ("PT_off")
                    ymult = str2double(pre{13}); % The y multiplier ("YMUlt")
                    yoffset = str2double(pre{14}); % The y offset ("Y_OFf")
                    yzero = str2double(pre{15}); % The y zero ("YZEro")

    %                 numdatapoints  = str2num(numdatapoints); % The number of data points
    %                 xincr = str2double(xincr); % The x multiplier
    %                 xoffset = str2num(xoffset);    % The x offset
    %                 ymult = str2double(ymult); % The y multiplier
    %                 yoffset = str2double(yoffset); % The y offset
    %                 yzero = str2double(yzero); % The y zero


                    % Scale the data according the the values in the preamble.
                    % See manual page 2-211 for scaling. Assumes "Y"
                    %  data format (preamble field #8)
                    switch dformat
                        case 'Y'
                            retval.x=([0:1:numdatapoints-1]'*xincr);
                            retval.y=((yval-yoffset).*ymult)+yzero;
                            actualdatapoints = length(retval.y);
                            if verbose >= 3, fprintf(1,'kpib/TEK_TDS: data format Y\n'); end
                        case 'ENV'
%                             retval.x=([0:1:numdatapoints-1]'*xincr);
%                             retval.y=((yval-yoffset).*ymult)+yzero;
%                             actualdatapoints = length(retval.y);
                            if verbose >= 1
                                fprintf(1,'kpib/TEK_TDS: WARNING: data format ENV\n');
                                fprintf(1,'              Not handled by this version of KPIB\n');
                                fprintf(1,'              (use normal, not max/min data)\n');
                            end
                    end

                    retval.units.x = pre{9}(2:end-1); % strip quotes
                    if strcmp(retval.units.x,'s'), retval.units.x='sec'; end
                    retval.units.y = pre{12}(2:end-1); % strip quotes
                    retval.desc=pre{6};
                    
                    if actualdatapoints~=numdatapoints
                        if verbose >= 1
                            fprintf(1, 'kpib/TEK_TDS: WARNING: number of data points received from scope appears to be incorrect.\n');
                            fprintf(1, '              Expected: %d, Received: %d [Using Received]\n',numdatapoints,actualdatapoints);
                            fprintf(1, '              (Try Reset GPIB with ''clear'' or check io.Buffersize)\n');
                            retval.y=retval.y(1:actualdatapoints);
                            retval.x=retval.x(1:actualdatapoints);
                        end
                    end

                else
                    if verbose >= 1, fprintf(1, 'kpib/TEK_TDS: Error: channel specified incorrectly.\n'); end
                    retval=0;
                end

            otherwise
                if verbose >= 1, fprintf(1, 'kpib/TEK_TDS: Error, command not supported. ["%s"]\n',command); end
                retval=0;
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end TEK_TDS


%% 'HP_53132A' HP universal counter
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% This driver is focused on frequency measurements. If you want rise time,
%  phase, etc, then you are SOL.
% Valid instructions:
% 'init'         Initializes the counter with settings designed for fastest
%                 measurement data rate. Use 'frequency' or 'arm' to complete
%                 the initialization for frequency measurement.
% 'frequency'    Configures the counter for a frequency measurement near
%                 VALUE Hz with AUX resolution (in Hz) on channel CHANNEL.
%                 The expected value should be within 10% of the input
%                 frequency. The resolution should use a mantissa of 1.0
%                 and be an even power of 10 (i.e., "0.001"). The default
%                 is 4 digits of resolution for all channels. The default
%                 channel is channel 1.
% 'channel'      Select a channel for frequency measurement.
% 'arm'          Set the gating conditions:
%                'digits'   Gate time is adjusted to get AUX digits of
%                            resolution
%                'timer'    Gate time is AUX seconds
%                'auto'     Gate time is automatically determined
%                'armstart' Measurements begin on AUX ('ext' or 'imm')
%                            external signal or internal (immediate) trigger.
% 'set'          Same as 'arm'.
%                Note that the gating is set by 'frequency' (above) for 'digits'.
% 'read'         Performs the measurement as configured and returns the
%                 frequency value from the counter. Use CHANNEL to
%                 select the counter channel. If CHANNEL is not specified,
%                 the most recently used channel will be read.
% 'getdata'      Returns the data from the measurement in progress on the
%                 current channel. This is much faster than 'read', which
%                 restarts the measurement every time it is called.
% 'run'          Puts the counter in "free-run" mode (continuous measurement).
%                 Also 'start'.
% 'single'       Initiate a single measurement.
% 'stop'         Stops measurements. Current measurement will be displayed
%                 on counter. Use 'stop' to exit "free-run" mode before
%                 initiating single measurements with 'single'.
%
% Note: fastest possible operation (returning measurement data) is usually
% desired. This can be accomplished by using:
%  'init'       (to setup the counter) 
%  'frequency'  (specifying expected frequency, resolution, and channel)
%               (continuous measurements will be started)
%  'getdata'    (to get the measurement result
%               (use 'getdata' in subsequent loops)
% 
% Note that 'read','single' will take a single measurement and stop.
%  Subsequent 'getdata' commands will return the previous frequency reading.
%  Use 'run' to put the counter into continuous measurement mode
%  before resuming 'getdata' commands. Use 'channel' to switch channels
%  without doing measurements.
% For 1.3 MHz measurements, 2 Hz data rate is just possible with 'getdata'
%  in a loop and gate time of 0.5 seconds.
%
% MH SEP2006
%

if (strcmpi(instrument, 'HP_53132A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case {'init','INIT'} % initialize for fastest data transfer. See manual p3-35
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Initializing for fastest measurements:\n'); end
                fprintf(io,'*RST'); pause(0.5); fprintf(io,'*CLS');
                fprintf(io,':HCOPY:CONT OFF');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Hard Copy off\n'); end
                fprintf(io,':CALC:MATH:STATE OFF');
                fprintf(io,':CALC2:LIMIT:STATE OFF');
                fprintf(io,':CALC3:AVERAGE:STATE OFF');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Math off\n'); end
                fprintf(io,':FORMAT:DATA ASCII');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: ACSII format data\n'); end                
                fprintf(io,':ROSC:SOURCE INT');
                fprintf(io,':ROSC:EXT:CHECK OFF');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Using Internal Reference Oscillator\n'); end
                fprintf(io,':SENSE:EVENT1:LEVEL:AUTO ON');
                pause(1); % wait for auto level to pick a level
                fprintf(io,':SENSE:EVENT1:LEVEL?');
                alevel = fscanf(io,'%f'); % what level did it pick?
                fprintf(io,':SENSE:EVENT1:LEVEL:AUTO OFF');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Auto trigger level off. Trigger level at %g V\n',alevel); end
                fprintf(io,':SENSE:FREQ:ARM:SOURCE IMM');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Start Arm is Immediate\n'); end
                fprintf(io,':INPUT1:IMPEDANCE 1M');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Ch. 1 input impedance 1M ohm\n'); end
                pause(1);
                % read current frequency (ch. 1), set target frequency for current reading
                cf = kpib(instrument,GPIB,'read',0,1,aux,verbose);
                fprintf(io,'CONF:FREQ %d,DEF',value);
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Target frequency set for %d Hz.\n',cf); end
                % set gate time to 0.5 seconds
                fprintf(io,'FREQ:ARM:STOP:SOURCE TIM');
                fprintf(io,'FREQ:ARM:STOP:TIMER 0.5');
                if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Gate Time set to 0.5 seconds.\n'); end                
                %if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Init: Use ''frequency'' to complete configuration.\n'); end
                
            
            
            case {'config','frequency','freq'} % set the counter for automatic frequency measurements
                % VALUE is expected frequency in Hz
                % CHANNEL is channel
                % AUX is resolution in Hz
                
                if channel ~= 0 && value ~= 0 && aux ~= 0
                    fprintf(io,'CONF:FREQ %d,%d,(@%d)',[value,aux,channel]);
                    fprintf(io,':FREQ:EXPECTED%d %d',[channel,value]);
                    if verbose >= 1
                        fprintf(1, 'kpib/HP_53132A: Configured for Frequency Measurement:\n at %g Hz, with %g Hz resolution, on Channel %d.\n',...
                        value,aux,channel);
                    end
                else
                    if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Configured for Frequency Measurement:\n '); end
                    if value == 0
                        value = 'DEF';
                        if verbose >= 1, fprintf(1, 'at 10 MHz (default) '); end
                    else
                        if verbose >= 1, fprintf(1, 'at %g Hz ',value); end
                    end
                    if channel == 0
                        channel = 1;
                        if verbose >= 1, fprintf(1, 'on Channel 1 (default) '); end
                    else
                        if verbose >= 1, fprintf(1, 'on Channel %d ',channel); end
                    end
                    if aux == 0
                        aux = 'DEF';
                        if verbose >= 1, fprintf(1, 'with default resolution (default)'); end
                    else
                        if verbose >= 1, fprintf(1, 'at default resolution '); end
                    end
                    cmd=sprintf('CONF:FREQ %s,%s',value,aux);
                    fprintf(io,cmd);
                    if verbose >= 1, fprintf(1, '\n'); end
                end

                % start the counter
                fprintf(io,'INIT:CONT ON');
                
            case {'set','arm'} % set the arming type (aka "gate time")
                       % digits, time, auto
                switch value
                    case 'digits'
                        fprintf(io,'FREQ:ARM:STOP:SOURCE DIG');
                        fprintf(io,'FREQ:ARM:STOP:DIGITS %d',aux);
                        if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Frequency measurement gating for %d digits resolution.\n',aux); end
                    case {'time','timer','gatetime'}
                        fprintf(io,'FREQ:ARM:STOP:SOURCE TIM');
                        fprintf(io,'FREQ:ARM:STOP:TIMER %d',aux);
                        if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Frequency measurement gating for %g seconds per measurement.\n',aux); end
                    case {'armstart'}
                        if isequal(aux,'imm')
                            fprintf(io,'FREQ:ARM:SOURCE IMM');
                            if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Frequency measurement gating continuously ("immediate").\n'); end
                        elseif isequal(aux,'ext')
                            fprintf(io,'FREQ:ARM:SOURCE EXT');
                            if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Frequency measurement gating on external signal.\n'); end
                        end
                    case 'auto'
                        fprintf(io,'FREQ:ARM:STOP:SOURCE IMM');
                        if verbose >= 1, fprintf(1, 'kpib/HP_53132A: Frequency measurement automatic gating.\n'); end
                    otherwise
                        if verbose >= 1, fprintf(1,'kpib/HP_53132A: Set VALUE not understood ("%s")\n',value); end
                end
                
            case {'channel','CHAN'}
                if any(channel==[1 2 3])
                    fprintf(io,'FUNC "FREQ %d"',channel);
                    if verbose >= 2, fprintf(1,'kpib/HP_53132A: Select channel %d\n',channel); end
                else
                    if verbose >= 2, fprintf(1,'kpib/HP_53132A: No channel selected.\n'); end
                end
                
            case 'read'
                % 'read' will do a frequency measurement. If VALUE is
                %  'single', the counter will stop taking measurements after it completes the 'read'.  
                % If channel is specified, switch the channel first. Otherwise,
                %  do not change the channel.
                % See Manual p4-89 for FUNC description.
                if any(channel==[1 2 3])
                    fprintf(io,'FUNC "FREQ %d"',channel);
                    if verbose >= 2, fprintf(1,'kpib/HP_53132A: Select channel %d\n',channel); end
                end
                fprintf(io,':READ?');
                retval = fscanf(io, '%f');
                if ~(strcmp(value,'single')==1 || strcmp(value,'one')==1)
                    % start the counter running again unless a single read
                    %  is requested
                    fprintf(io,'INIT:CONT ON');
                end
                if verbose >= 2, fprintf(1, '%s %.3f %s\n','kpib/HP_53132A: Frequency:',retval,'Hz'); end

                
            case {'single'}
                % initiate a single measurement. Use 'getdata' to get the
                %  result. 
                fprintf(io,':INIT:IMM');
                if verbose >= 2, fprintf(1,'kpib/HP_53132A: Single measurement initiated\n'); end
 
            case {'stop','off'}
                % initiate a single measurement. Use 'getdata' to get the
                %  result.
                fprintf(io,':INIT:CONT OFF');
                if verbose >= 2, fprintf(1,'kpib/HP_53132A: Measurements stopped.\n'); end                
                
            case {'getdata','fetch'}
                % 'getdata' will get the data from the current measurement.
                % Note that if the counter is not currently taking new
                % measurements (e.g. after a 'read'), then 'getdata' will
                % return old data. The commands 'frequency', 'read', and
                % 'run' will initiate continuous measurements.
                fprintf(io,':FETCH?');
                retval = fscanf(io, '%f');
                if verbose >= 2, fprintf(1,'kpib/HP_53132A: Frequency %f Hz\n',retval); end
                
            case {'run','free','go','start'}
                % put the counter to "free run" mode, taking measurements
                %  continuously
                fprintf(io,'INIT:CONT ON');
                if verbose >=2, fprintf(1, '%s\n','kpib/HP_53132A: Counter in Continuous Measurement mode.'); end

            otherwise
                if verbose >= 1, fprintf('kpib/HP_53132A: Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_53132A

%% 'HP_33120A' Agilent Function Generator
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid instructions:
%
% 'sin' / 'square' / 'triangle' / 'ramp'
%           These are combined forms of 'set', which allow you to specify the
%            first four parameters of 'set' in one kpib command. The inputs
%            correspond to settings in the following way:
%           COMMAND = function ('sin'|'square'|'triangle'|'ramp')
%           VALUE = frequency (Hz)
%           CHANNEL = amplitude (Vpp)
%           AUX = offset (V) (optional)
%              example:
%              kpib('HP_33120A',gpib_addr,'sin',5e6,5.5,0,verbose);
% 'DC'      DC ouput
% 'dcycle'  Duty cycle for DC pulses
% 'setV'    Set the output amplitude, in the current units (Vpp or Vrms)
% 'read'    Returns the current output amplitude in Volts (Vpp or Vrms)
%
if (strcmpi(instrument, 'HP_33120A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case 'sin'
                if aux > 0
                    fprintf(io,'APPLY:SIN %d, %d, %d',[value,channel,aux]);
                else
                    fprintf(io,'APPLY:SIN %d, %d',[value,channel]);
                end
                
            case 'square'
                if aux > 0
                    fprintf(io,'APPLY:SQU %d, %d, %d',[value,channel,aux]);
                else
                    fprintf(io,'APPLY:SQU %d, %d',[value,channel]);
                end
                
            case 'triangle'
                if aux > 0
                    fprintf(io,'APPLY:TRI %d, %d, %d',[value,channel,aux]);
                else
                    fprintf(io,'APPLY:TRI %d, %d',[value,channel]);
                end
                
            case 'ramp'
                if aux > 0
                    fprintf(io,'APPLY:RAMP %d, %d, %d',[value,channel,aux]);
                else
                    fprintf(io,'APPLY:RAMP %d, %d',[value,channel]);
                end
                
            case 'DC'
                if nargin > 5
                    fprintf(io,'APPLY:DC %d, %d, %d',[value,channel,aux]);
                elseif (nargin > 3) && (nargin < 5)
                    fprintf(io,'APPLY:DC %d, %d',[value,channel]);
                elseif (nargin > 2) && (nargin < 4)
                    fprintf(io,'APPLY:DC %d,DEF',value);
                else
                    fprintf(io,'APPLY:DC DEF,DEF');
                end

            case {'setV'} % special case for setting output voltage
                fprintf(io,'VOLT %f',value); % sets the units of the current function (Vpp, Vrms, etc)
                if verbose >= 2, fprintf('kpib/HP_33120A: Output amplitude set to %g V\n',value); end

            case {'read'} % reading output voltage
                fprintf(io,'VOLT?'); % reads the units of the current function (Vpp, Vrms, etc)
                retval = fscanf(io,'%e');
                if verbose >= 2, fprintf('kpib/HP_33120A: Output amplitude reads %g V\n',retval); end

            %The following 'dcycle' or duty cycle only works with DC output.
            case {'dcycle','dutycycle'}
                if isequal(value,'min')
                   fprintf(io,'PULS:DCYC MIN');
               elseif isequal(value,'max')
                   fprintf(io,'PULS:DCYC MAX');
               else
                   fprintf(io,'PULS:DCYC %d',value);
                   if verbose >= 2, fprintf('kpib/HP_33120A: Duty cycle set to %d%%\n',value); end
               end
            otherwise
                if verbose >= 1, fprintf('kpib/HP_33120A: Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_33120A


%% 'SRS_DS345' Stanford Research Systems function generator
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid commands:
%
% 'set'     Sets VALUE ('function'|'frequency'|'amplitude'|'offset'|'phase') to CHANNEL.
%             For 'function', CHANNEL can be: 'sin','square,'triangle','ramp'
%             For 'frequency', CHANNEL is the output frequency in Hz.
%             For 'amplitude', CHANNEL can be Volts peak-peak, Volts RMS, or
%                 dBm. You can specify the units with AUX ('vpp'|'rms'|'dbm').
%                 The default is Vpp.
%             For 'offset', CHANNEL is the offset in Volts.
%             For 'phase', CHANNEL is the phase offset in degrees.
%
% 'sin' / 'square' / 'triangle' / 'ramp'
%           These are combined forms of 'set', which allow you to specify the
%            first four parameters of 'set' in one kpib command. The inputs
%            correspond to settings in the following way:
%           COMMAND = function ('sin'|'square'|'triangle'|'ramp')
%           VALUE = frequency (Hz)
%           CHANNEL = amplitude (Vpp)
%           AUX = offset (V)
%              example: kpib('SRS_DS345',gpib_addr,'sin',5e6,5.5,0,verbose);
%
% 'read'    Returns the current value of the parameter VALUE
%            ('freq'|'amp'|offset'|'phase')
%
% 'setV'    Sets the output amplitude to VALUE in Volts RMS.
%
if (strcmpi(instrument, 'SRS_DS345') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case 'set'
                switch value
                    case 'sin'
                        fprintf(io,'FUNC0');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Function: Sine wave\n'); end
                    case 'square'
                        fprintf(io,'FUNC1');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Function: Square wave\n'); end        
                    case 'triangle'
                        fprintf(io,'FUNC2');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Function: Triangle wave\n'); end
                    case 'ramp'
                        fprintf(io,'FUNC3');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Function: Ramp\n'); end
                    case {'frequency', 'freq', 'f'}
                        if isnumeric(channel)
                            fprintf(io,'FREQ %d',channel)
                            if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Frequency: %g Hz\n',channel); end
                        else
                            if verbose >= 0, fprintf(1, 'kpib/SRS_DS345: Error: Frequency incorrectly specified (must be a number)\n'); end
                        end
                    case {'amplitude', 'ampl', 'amp'}
                        switch aux
                            case {'vpp','VP','Vpp'}
                                fprintf(io,'AMPL %dVP',channel);
                                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Amplitude: %.4f Vpp\n',channel); end
                            case {'rms','VR','Vrms','RMS'}
                                fprintf(io,'AMPL %dVR',channel);
                                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Amplitude: %.4f Vrms\n',channel); end
                            case {'dBm','DB','Vdbm'}
                                fprintf(io,'AMPL %dDB',channel);
                                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Amplitude: %.4f dBm\n',channel); end
                            otherwise % default to Vrms
                                fprintf(io,'AMPL %dVR',channel);
                                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Amplitude: %.4f Vrms (default units)\n',channel); end
                        end
                    case {'offset','offs'}
                        if isnumeric(channel)
                            fprintf(io,'OFFS %d',channel)
                            if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Offset: %d V\n',channel); end
                        else
                            if verbose >= 0, fprintf(1, 'kpib/SRS_DS345: Error: Offset incorrectly specified (must be a number)\n'); end
                        end
                    case {'phase','phse'}
                        if isnumeric(channel)
                            fprintf(io,'PHSE %d',channel)
                            if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Phase: %d deg\n',channel); end
                        else
                            if verbose >= 0, fprintf(1, 'kpib/SRS_DS345: Error: Phase incorrectly specified (must be a number)\n'); end
                        end
                    otherwise % default to amplitude
                        if isnumeric(channel)
                            fprintf(io,'AMPL %dVP',channel);
                            if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Amplitude: %.4f Vpp (default units)\n',channel); end
                        else
                            if verbose >= 0, fprintf(1, 'kpib/SRS_DS345: Error: Amplitude incorrectly specified (must be a number)\n'); end
                        end
                end

            case {'setV'} % special case for setting output voltage
                kpib(instrument,GPIB,'set','amplitude',value,'Vrms',verbose);
                
            case {'sin','sine'}
                fprintf(io,'FUNC0');
                fprintf(io,'FREQ %d',value);
                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Sine wave: Frequency: %.3f Hz',value); end

                fprintf(io,'AMPL %dVR',channel);
                if verbose >= 2, fprintf(1, ', Amplitude: %.4f Vrms',channel); end

                fprintf(io,'OFFS %d',aux)
                if verbose >= 2, fprintf(1, ', Offset: %d V',aux); end

                if verbose >= 2, fprintf(1, '\n'); end

            case 'square'
                fprintf(io,'FUNC1');
                fprintf(io,'FREQ %d',value);
                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Square wave: Frequency: %.3f Hz',value); end
                fprintf(io,'AMPL %dVP',channel);
                if verbose >= 2, fprintf(1, ', Amplitude: %.4f Vpp',channel); end
                fprintf(io,'OFFS %d',aux);
                if verbose >= 2, fprintf(1, ', Offset: %d V',aux); end
                if verbose >= 2, fprintf(1, '\n'); end

            case 'triangle'
                fprintf(io,'FUNC2');
                fprintf(io,'FREQ %d',value);
                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Triangle wave: Frequency: %.3f Hz',value); end
                fprintf(io,'AMPL %dVP',channel);
                if verbose >= 2, fprintf(1, ', Amplitude: %.4f Vpp',channel); end
                fprintf(io,'OFFS %d',aux)
                if verbose >= 2, fprintf(1, '\n'); end

            case 'ramp'
                fprintf(io,'FUNC3');
                fprintf(io,'FREQ %d',value);
                if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Ramp wave: Frequency: %.3f Hz',value); end
                fprintf(io,'AMPL %dVP',channel);
                if verbose >= 2, fprintf(1, ', Amplitude: %.4f Vpp',channel); end
                fprintf(io,'OFFS %d',aux);
                if verbose >= 2, fprintf(1, ', Offset: %d V',aux); end
                if verbose >= 2, fprintf(1, '\n'); end

            case {'read','query'}
                switch value
                    case {'freq','frequency','f'}
                        fprintf(io,'FREQ?');
                        retval=fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Frequency set point: %g Hz\n',retval); end

                    case {'ampl','amplitude','a'}
                        switch channel % use CHANNEL to specify units
                            case {'VP','Vpp','p-p'}
                                fprintf(io,'AMPL? VP'); % specify volts peak-to-peak.
                            case {'VR','Vrms','rms'}
                                fprintf(io,'AMPL? VR'); % specify volts rms
                            case {'DB','Vdb','db'}
                                fprintf(io,'AMPL? DB'); % specify volts in decibels
                            otherwise % default to Vpp
                                fprintf(io,'AMPL? VP'); % specify volts peak-to-peak.
                        end
                        retstr=fscanf(io,'%s'); % value is returned as a string with units appended: VP, VR, DB
                        retval.units=retstr(end-1:end);
                        if ~isequal(channel,retval.units)
                            if verbose >= 1, fprintf(1, 'kpib/SRS_DS345: Warning: Amplitude units error (%s/%s)\n',channel,retval.units); end
                        end
                        retval.val=str2num(retstr(1:end-2));
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Amplitude set point: %.4f %s\n',retval.val,retval.units); end

                    case {'offs','offset'}
                        fprintf(io,'OFFS?'); % volts
                        retval=fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Offset set point: %g V\n',retval); end

                    case 'phase'
                        fprintf(io,'PHSE?');
                        retval=fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Phase set point: %g deg\n',retval); end

                    otherwise % default to amplitude Vrms
                        fprintf(io,'AMPL? VR');
                        retval=fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/SRS_DS345: Output Amplitude (default) set point: %f Vrms\n',retval); end
                end

            otherwise
                if verbose >= 1, fprintf(1, 'kpib/SRS_DS345: Error, command not supported. ["%s"]\n',command); end
        end

    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end SRS_DS345


%% 'HP_4395A' HP Network and Spectrum Analyzer
%
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% VALUE is typically the modifier to COMMAND.
% Valid Commands:
% 'init'      Resets the Analyzer.
% 'label'     Writes 'VALUE' to the display.
% 'channel'   Makes channel VALUE the active channel.
% 'meas'      Set the measurement type.
%              VALUE can be: 'a/r', 'b/r', 'a', 'b', or 'r'. 
% 'display'   Controls what is displayed on the Analyzer screen.
%              VALUE can be: 'data', 'memory','datamem', or 'dual'.
%              For 'dual', CHANNEL= 'on' or 'off', 'query', or '?'. 
% 'format'    Set the format of the graph on the Analyzer display:
%             VALUE= 'linear','log mag','phase','delay','linear mag', etc. 
% 'scale'     Sets the scale of the display. VALUE is the scale in the
%              current units, or 'VALUE' = 'auto' for autoscale command. 
% 'ref line'  Sets the position of the reference line of the display.
%              VALUE is the position of the reference line in the current
%              units.
% 'average'   Turns averaging on or off, restarts averaging, or returns
%              the current number of averages taken.
%              VALUE= 'on','off','restart','query', or a number to set
%              number of measurements to average.
%             For 'query', RETVAL returns 0 (off) or the current number of averages (on).
% 'mark2peak' Finds the peak and sets the marker, or finds the peak and
%              sets the peak location to the center of the scan.
%              VALUE='off','center', or 'peak'.
% 'marker'    Turns the marker on or off, or returns the current
%              position of the marker. 'VALUE' = 'on','off', or 'query'.
%              The position is returned as retval.x, retval.y in current
%              units. Also 'peak' to move marker to peak, or 'center' to
%              make marker value the center frequency.
% 'center'    Set the center frequency to VALUE. Units of Hz.
%              Query with VALUE = 'query', returns center frequency in Hz.
% 'span'      Set the frequency span VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'sweep'     Sets sweep parameters
% 'source'    Set the source (stimulus output) signal level. VALUE is the
%              desired signal level. Units of dBm.
%              Query with VALUE = 'query', returns source power in dBm.
% 'source?'   (Alternate query form) Returns source power in dBm.
% 'power'     Same as 'source'.
% 'getdata'   Download the current data trace from the analyzer. Data is
%              returned as two columns, x and y, for the specified
%              CHANNEL. Current channel if CHANNEL is not set. Returns:
%              retval.x
%              retval.y
%              retval.units.x
%              retval.units.y 
% 'units'     Returns the units of the data from the analyzer. Must
%              specify VALUE = 'x' or 'y' axis units.
% 'pause'     Pauses measurement.
% 'continue'  Continues paused measurement.
% 'complete'  Wait for the previous sweep to complete. This command
%              contains a loop that does not exit until the status byte is
%              set. Use VALUE=='single' to do a single sweep and return
%              when the sweep is complete.           
% 'wait'      Wait for the previous command to complete (*WAI)
if (strcmpi(instrument, 'HP_4395A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command

            case 'init'
                %fprintf(io,'*RST');
                fprintf(io,'CLES')
                fprintf(io,'*SRE 4;ESNB 1'); % enable the registers; see manual p5-14

            case 'label'
                if length(value) > 53
                    value=value(1:53); % 53 chars max
                end
                fprintf(io,'TITL "%s"',value);

            case 'channel'
                switch value
                    case 1
                        fprintf(io,'CHAN1')
                        if verbose >=2, fprintf(1, 'kpib/HP_4395A: Channel %d selected.\n',value); end
                    case 2
                        fprintf(io,'CHAN2')
                        if verbose >=2, fprintf(1, 'kpib/HP_4395A: Channel %d selected.\n',value); end
                    otherwise % query active channel
                        fprintf(io,'CHAN1?')
                        ch = fscanf(io);
                        if ch == 1
                            if verbose >=2, fprintf(1, 'kpib/HP_4395A: Channel 1 active.\n'); end
                            retval = 1;
                        else
                            retval = 2;
                            if verbose >=2, fprintf(1, 'kpib/HP_4395A: Channel 2 active.\n'); end
                        end
                end

            case 'meas'
                switch value
                    case {'a/r','A/R','AR'}
                        fprintf(io,'MEAS AR');
                    case {'b/r','B/R','BR'}
                        fprintf(io,'MEAS BR');
                    case {'a','A'}
                        fprintf(io,'MEAS A');
                    case {'b','B'}
                        fprintf(io,'MEAS B');
                    case {'r','R'}
                        fprintf(io,'MEAS R');
                    otherwise
                        if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Error, %s is not a valid input (a/r,b/r,a,b,r).',value); end
                end

            case {'display','trace'}
                switch value
                    case {'data'}
                        fprintf(io,'DISP %s',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Display data only\n'); end
                    case {'memory','mem'}
                        fprintf(io,'DISP MEMO');
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Display memory only\n'); end
                    case {'both','data&memory','datamem','data+memory'}
                        fprintf(io,'DISP DATM');
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Display data & memory\n'); end
                    case {'dual'}
                        switch channel
                            case {'on',1}
                                fprintf(io, 'DUAC ON');
                                if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display on.\n'); end
                            case {'off',0}
                                fprintf(io, 'DUAC OFF');
                                if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display off.\n'); end
                            case {'query','?'} % returns 1 for dual-channel on, 0 for off
                                fprintf(io, 'DUAC?');
                                dstatebit=str2num(fscanf(io));
                                if dstatebit==1, dstate='on';
                                elseif dstatebit==0, dstate='off';
                                end
                                retval=dstatebit;
                                if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display is %s\n',dstate); end
                        end
                     case {'query','?'} % returns binary state for channels (emulate 4 channels)
                        fprintf(io, 'DUAC?');
                        dstateb=str2num(fscanf(io)); % like dstatebits, only different
                        if dstateb==1, dstate='1 1 0 0';
                            if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display is on\n'); end
                        % NB: fix this- query active channel?
                        %    Assume CH 1 until then
                        elseif dstateb==0, dstate=[1 0];
                        end
                        retval=dstate;
%                         if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display is %s\n',dstate); end

                end

%                 
%                         dstateword=[];
%                         for cd=1:4
%                             fprintf(io, 'DISP:WIND%d:TRAC:STATE?',cd);
%                             dstateword(cd)=str2num(fscanf(io));
%                             if dstateword(cd)==1, dstate='on';
%                             elseif dstateword(cd)==0, dstate='off';
%                             end
%                             if verbose >= 2, fprintf(1, 'kpib/HP_89410A: Trace %d is %s.\n',cd,dstate); end
%                             retval(cd)=num2str(dstateword(cd));
%                         end
                

    %                 case {'on','ON'}
    %                     fprintf(io, 'DUAC ON');
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display on.\n'); end
    %                 case {'off','OFF'}
    %                     fprintf(io, 'DUAC OFF');
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display off.\n'); end
    %                 case {'query','?'} % returns 1 for dual-channel on, 0 for off
    %                     fprintf(io, 'DUAC?');
    %                     dstatebit=str2num(fscanf(io));
    %                     if dstatebit==1, dstate='on';
    %                     elseif dstatebit==0, dstate='off';
    %                     end
    %                     retval=dstatebit;
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display is %s\n',dstate); end
    %             end 

            case 'format'
                switch value
                    case 'log mag'
                        fprintf(io,'FMT LOGM');
                    case 'phase'
                        fprintf(io,'FMT PHAS');
                    case 'delay'
                        fprintf(io,'FMT DELA');
                    case 'linear mag'
                        fprintf(io,'FMT LINM');
                    case 'polar'
                        fprintf(io,'FMT POLA');
                    case 'admit smith'
                        fprintf(io,'FMT ADMIT');
                    case 'spectrum'
                        fprintf(io,'FMT SPECT');
                    case 'linear y'
                        fprintf(io,'FMT LINY');
                    case 'complex'
                        fprintf(io,'FMT COMP');
                    case 'exp phase'
                        fprintf(io,'FMT EXPP');
                    case {'query','?'}
                        fprintf(io,'FMT?');
                        retval=fscanf(io);
                    otherwise
                        fmttype={'swr','real','imag','smith','spec','noise','logy'};
                        if any(strcmpi(value,fmttype))
                        %if isequal(value,'swr') || isequal(value,'real') || isequal(value,'imag') || isequal(value,'smith') || isequal(value,'spect') || isequal(value,'noise') || isequal(value,'logy')
                            fprintf(io,'FMT %s',value);
                        else
                            if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Set Analyzer data format to default log magnitude.\n'); end
                            fprintf(io,'FMT LOGM');
                        end
                end

            case {'autoscale','auto','autoy'};
%                 if nargin > 3
                    switch value
                        case 'off'
                            % DNE
                        case 'once'
                            if nargin > 4
                                if channel == 0 % autoscale current channel
                                    fprintf(io,'AUTO');
                                    if verbose >=2, fprintf(1, 'kpib/HP_4395A: Autoscale current channel\n'); end
                                else
                                    fprintf(io,'CHAN%d',channel);
                                    fprintf(io,'AUTO');
                                    if verbose >=2, fprintf(1, 'kpib/HP_4395A: Autoscale channel %d\n',channel); end
                                end
                            else
                                fprintf(io, 'DISP:TRAC:Y:AUTO ONCE');
                                if verbose >=2, fprintf(1, 'kpib/HP_4395A: Autoscale Y Once Channel 1 (default channel)\n'); end
                            end
                        case 'both' % specific to resonators - autoscale channels 1 & 2
                            fprintf(io,'CHAN1'); fprintf(io,'AUTO');
                            fprintf(io,'CHAN2'); fprintf(io,'AUTO');
                            fprintf(io,'CHAN1');
                            if verbose >=2, fprintf(1, 'kpib/HP_4395A: Autoscale channels 1 & 2\n'); end

                        otherwise
                            if isnumeric(value) && any(value == [1 2 3 4])
                                fprintf(io,'CHAN%d',channel);
                                fprintf(io,'AUTO');
                                if verbose >=2, fprintf(1, 'kpib/HP_4395A: Autoscale channel %d\n',channel); end
                            else
                                fprintf(io,'AUTO');
                                if verbose >=2, fprintf(1, 'kpib/HP_4395A: Autoscale Y current channel (default)\n'); end
                            end
                     end
% %                  else
%                      fprintf(io, 'DISP:TRAC:Y:AUTO ONCE');
%                      if verbose >=2, fprintf(1, 'kpib/HP_4395A: Auto Scale Y default: Once\n'); end
%                 end

            case 'scale'
                if isnumeric(value)
                    fprintf(io,'SCAL %d',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Scale of current channel set to %d.\n',value); end
                elseif isequal(value,'auto') || isequal(value,'autoscale')
                    fprintf(io,'AUTO');
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Autoscale current channel.\n'); end
                end

            case {'ref line','ref val','REFL','REFV'}
                fprintf(io,'REFV %d',value);
                if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Reference value set to %g dBm.\n',value); end

            case 'average'
                switch value
                    case {'on'}
                        fprintf(io,'AVER ON');
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Measurement Averaging on'); end
                        if isnumeric(channel) && channel > 0
                            fprintf(io,'AVERFACT %d',channel);
                            if verbose >= 2, fprintf(1, ', aver. factor: %d\n',channel); end
                        else
                            if verbose >= 2, fprintf(1, '\n'); end
                        end
                    case {'off'}
                        fprintf(io,'AVER OFF');
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Measurement Averaging off\n'); end
                    case {'num','number','count'} % not available for 4395A? Use number of groups
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Warning: Averaging Count not available for 4395A, use number of groups instead.\n'); end
                    case {'restart','Restart'}
                        fprintf(io,'AVERREST');
                        if verbose >=2, fprintf(1, 'kpib/HP_4395A: Restarting averaging\n'); end
                    case {'query','?'}
                        fprintf(io,'AVER?');
                        aver = fscanf(io);
                        if aver == 0
                            retval = 0;
                            if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Averaging is off.'); end
                        else
                            fprintf(io,'AVERFACT?');
                            retval = fscanf(io);
                            if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Averaging is on; Averaging factor is: %d', retval); end
                        end
                    otherwise % set the number of measurements to average
                        if isnumeric(value) && value > 0
                            fprintf(io,'AVERFACT %d',channel);
                            if verbose >=2, fprintf(1, 'kpib/HP_4395A: Averaging factor set to: %d\n',value); end
                        else
                            if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Warning: Averaging command not understood ("%s")\n',value); end
                        end
                end

    %             if isequal(value,'on') | isequal(value,'off')
    %                 fprintf(io,'AVER %s',value);
    %                 if nargin > 4
    %                     fprintf(io,'AVERFACT %d',channel);
    %                     
    %                 end
    %             elseif isequal('restart') | isequal ('Restart')
    %                 fprintf(io,'AVERREST');
    %             else
    %                 fprintf(io,'AVER?');
    %                 aver = fscanf(io);
    %                 if aver == 0
    %                     retval = 0;
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Averaging is off.'); end
    %                 else
    %                      fprintf(io,'AVERFACT?');
    %                     retval = fscanf(io);
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Averaging is on; Averaging factor is: %d', retval); end
    %                 end
    %             end

            case {'marker'}
                % change the channel if specified (default do nothing)
                if (isnumeric(channel) && channel==(1 | 2))
                    fprintf(io,'CHAN%d',channel);
                end
                switch value
                    case 'on'
                        fprintf(io,'MKR ON');
                        if verbose >= 2, fprintf(1,'kpib/HP_4395A: Marker ON\n'); end
                    case 'off'
                        fprintf(io,'MKR OFF');
                        if verbose >= 2, fprintf(1,'kpib/HP_4395A: Marker OFF\n'); end
                    case {'query','?'} % query the marker position
                        fprintf(io,'OUTPMKR?');
                        mkr = fscanf(io);
                        mkr = str2num(mkr);
                        retval.y = mkr(1);
                        retval.x = mkr(3);
                        if verbose >= 2, fprintf(1,'kpib/HP_4395A: Marker on Channel %d position: %f/%f\n',channel,retval.x,retval.y); end
                    case {'center','m2c','mark2center'} % make the marker position the center freq
                        fprintf(io,'MKRCENT');
                        if verbose >= 2, fprintf(1,'kpib/HP_4395A: Marker to Center\n'); end
                    case {'peak','searchpeak','mark2peak','max','m2p'}
                        fprintf(io,'SEAM PEAK');                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4395A: Marker to Peak'); end
                    otherwise
                        if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Error at ''marker'' command (VALUE incorrect ["%s"]).\n',value); end
                end                       

            case {'mark2peak','peaktrack'}
                switch value
                    case 'off'
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4395A: Marker Search Off'); end
                        fprintf(io,'SEAM OFF');
                    case 'on'
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4395A: Search Peak; Tracking on'); end
                        fprintf(io,'SEAM PEAK');
                        fprintf(io,'TRACK ON');
                    case 'center'
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4395A: Peak to Center'); end
                        fprintf(io,'PEAKCENT');
                    case 'peak'
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4395A: Marker to Peak'); end
                        fprintf(io,'SEAM PEAK');
                    otherwise
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4395A: Marker to Peak (default)'); end
                        fprintf(io,'SEAM PEAK');
                end

            case 'sweep'
                % enable the status registers for synchronization
                fprintf(io,'CLES'); % clear the status registers
                fprintf(io,'*SRE 4;ESNB 1'); % enable the registers; see manual p5-14

                if isnumeric(value) % set the sweep time
                    fprintf(io,'SWET %d',value);
                else
                    switch value
                        % set sweep type
                        case {'on','off'}
                            fprintf(io,'SWETAUTO %s',value);
                        case {'linear freq','linfreq'}
                            fprintf(io,'SWPT LINF');
                        case {'log freq','logf'}
                            fprintf(io,'SWPT LOGF');
                        case {'list freq','freq list','list'}
                            fprintf(io,'SWPT LIST');
                        case {'power','power sweep'}
                            fprintf(io,'SWPT POWE');
                        case {'query','?'}
                            fprintf(io,'SWPT?');
                            retval=fscanf(io,'%s');
                            
                        % perform sweep action    
                        case {'single'}
                            fprintf(io,'SING');
                        case {'continuous','cont'}
                            fprintf(io,'CONT');
                        case {'hold'}
                            fprintf(io,'HOLD');
                        case {'group','groups','number','N'}
                            if isnumeric(channel) && channel >= 1 && channel <= 999
                                fprintf(io,'NUMG %d',channel);
                            else
                                if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Sweep Number must be between 1 and 999.\n'); end
                            end
                        case {'setpoints','set'}
                            if isnumeric(channel) && channel >= 2 && channel <= 801
                                fprintf(io,'POIN %i',channel);
                                if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Number of points set to %i.\n',channel); end
                            else
                                if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Number must be between 2 and 801.\n'); end
                            end
                        otherwise
                            if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Sweep command not supported ["%s"]\n',num2str(value)); end
                    end
                end
                            
%                 elseif isequal(value,'on') | isequal(value,'off')
%                     fprintf(io,'SWETAUTO %s',value);
%                 elseif isequal(value,'linear freq')
%                     fprintf(io,'SWPT LINF');
%                 elseif isequal(value,'log freq')
%                     fprintf(io,'SWPT LOGF');
%                 elseif isequal(value,'list freq')
%                     fprintf(io,'SWPT LIST');
%                 elseif isequal(value,'power sweep')
%                     fprintf(io,'SWPT POWE');
% 
%                 elseif strcmpi(value,'single')
%                     fprintf(io,'SING');
%                 elseif strcmpi(value,'continuous')
%                     fprintf(io,'CONT');
%                 elseif strcmpi(value,'hold')
%                     fprintf(io,'HOLD');
%                 elseif strcmpi(value,'group')
%                     if isnumeric(channel) & channel >= 1 & channel <= 999
%                         fprintf(io,'NUMG %d',channel);
%                     else
%                         if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Sweep Number must be between 1 and 999.\n'); end
%                     end
% 
%                 elseif strcmpi(value,'setpoints')
%                     if isnumeric(channel) & channel >= 2 & channel <= 801
%                         fprintf(io,'POIN %i',channel);
%                         if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Number of points set to %i.\n',channel); end
%                     else
%                         if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Number must be between 2 and 801.\n'); end
%                     end
%                 else
%                     if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Sweep command not supported\n'); end
%                 end

            case 'center'
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'CENT?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Center value is %g\n',retval); end
                else
                    fprintf(io,'CENT %f',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Center set to %g\n',value); end
                end

            case 'span'
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'SPAN?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Span value is %g\n',retval); end
                else
                    fprintf(io,'SPAN %f',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Span set to %g\n',value); end
                end

            case 'start'
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'STAR?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Start value is %g\n',retval); end
                else
                    fprintf(io,'STAR %f',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Start set to %g\n',value); end
                end

            case 'stop'
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'STOP?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Stop value is %g\n',retval); end
                else
                    fprintf(io,'STOP %f',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Stop set to %g\n',value); end
                end

            case {'power','source'}
                if isequal(value,'query') || isequal(value,'?')
                    fprintf(io,'POWE?');
                    retval = fscanf(io,'%f');
                elseif isnumeric(value) && value >= -50 && value <= 15
                    fprintf(io,'POWE %d',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Source Power set to %d dBm\n',value); end
                else
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Source Power not set. Power must be between -50 and 15 dBm.\n'); end
                end

            case {'power?','source?'}
                fprintf(io,'POWE?');
                retval.level = fscanf(io,'%f');
                if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Source Power: %g dBm\n',retval.level); end
                retval.state='on'; % 4395A source is always on

            case 'bandwidth'
                if isnumeric(value)
                    fprintf(io,'BW %d',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Bandwidth set to %d Hz.\n',value); end
                elseif isequal(value,'auto')
                    if isequal(channel,'on') || isequal(channel,'off')
                        fprintf(io,'BWAUTO %s',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Bandwidth set to auto.\n'); end
                    end
                elseif isequal(value,'limit')
                    if isnumeric(channel)
                        fprintf(io,'BWLMT%d',channel);
                    else
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: A numeric value must be entered for channel.\n'); end
                    end
                end

            case 'trigger'
                switch value
                    case 'internal'
                        fprintf(io,'TRGS INT');
                    case 'external'
                        fprintf(io,'TRGS EXT');
                    case 'GPIB'
                        fprintf(io,'TRGS BUS');
                    case 'video'
                        fprintf(io,'TRGS VID');
                    case 'manual'
                        fprintf(io,'TRGS MAN');
                    case 'ext gate'
                        fprintf(io,'TRGS GAT');
                    otherwise
                        trgstype={'int','ext','vid','man','gat','bus'};
                        if any(strcmpi(value,trgstype))
                        %if isequal(value,'int') | isequal(value,'ext') | isequal(value,'vid') | isequal(value,'man') | isequal(value,'gat') | isequal(value,'bus')
                            fprintf(io,'TRGS %s',value);
                        else
                            if verbose >= 1, fprintf(1, 'kpib/HP_4395A: Not a valid trigger.\n'); end
                        end
                end

            case {'mode','type'}
                % set or get instrument mode
                % find out what mode the analyzer is in:
                %   Network or Spectrum
                switch value
                    case {'?','query'}
                        fprintf(io,'NA?');
                        mode = fscanf(io,'%d');
                        if mode==1
                            mode='NA';
                            if verbose >= 2, fprintf('kpib/HP_4395A: Analyzer in Network mode.\n'); end
                            retval=mode;
                        else
                            fprintf(io,'SA?');
                            mode = fscanf(io,'%d'); 
                            if mode==1
                                mode='SA';
                                if verbose >= 2, fprintf('kpib/HP_4395A: Analyzer in Spectrum mode.\n'); end
                                retval=mode;
                            end
                        end
                        
                    case {'NA','network'}
                        fprintf(io,'NA');
                        if verbose >= 2, fprintf('kpib/HP_4395A: Analyzer set to Network mode.\n'); end
                    case {'SA','spectrum'}
                        fprintf(io,'SA');
                        if verbose >= 2, fprintf('kpib/HP_4395A: Analyzer set to Spectrum mode.\n'); end
                        
                    otherwise
                        if verbose >= 1, fprintf('kpib/HP_4395A: WARNING: ''mode'' command needs a VALUE parameter (e.g., ''?'').\n'); end
                        retval=-1;
                end

            case 'getdata'
                % Select the channel. For compatibility with old code, the
                %  channel is *not* set if it is not explicitly specified, i.e.,
                %  the default is to do nothing, rather than to select a channel.

                % first, find out what mode the analyzer is in:
                %   Network or Spectrum
                mode=kpib(instrument,GPIB,'mode','query',channel,aux,verbose);
%                 fprintf(io,'NA?');
%                 mode = fscanf(io,'%d');
%                 if mode==1
%                     mode='NA';
%                     if verbose >= 2, fprintf('kpib/HP_4395A: Analyzer in Network mode.\n'); end
%                 else
%                     fprintf(io,'SA?');
%                     mode = fscanf(io,'%d'); 
%                     if mode==1
%                         mode='SA';
%                         if verbose >= 2, fprintf('kpib/HP_4395A: Analyzer in Spectrum mode.\n'); end
%                     end
%                 end

                % now, did the user specify a channel or not?
                if isnumeric(channel) && any(channel == [1 2])
                    fprintf(io,'CHAN%d',channel);
                    if verbose >= 2, fprintf('kpib/HP_4395A: Channel %d selected for data download.\n',channel); end
                else
                    if verbose >= 2, fprintf('kpib/HP_4395A: Current channel for data download.\n'); end
                end

                % specify the data format as ASCII
                fprintf(io,'FORM4');
                % download the data. The HP4395A only sends the Y values.
                fprintf(io,'OUTPDTRC?');
%                  rawdata = fscanf(io)
%                  rawdata = [rawdata ','];
                %rawdata = str2num(rawdata)
                retstr=fscanf(io,'%s'); retstr=[retstr ','];
                %size(retstr)
                retdata=sscanf(retstr,'%f,');
                [actualnumpoints, anpc] = size(retdata);
                if verbose >= 2, fprintf('kpib/HP_4395A: Data downloaded.\n'); end

                % X values are not provided, we have to infer them, so get
                %  data about the frequency sweep
                fprintf(io,'POIN?');
                numdatapoints = fscanf(io);
                numdatapoints = str2num(numdatapoints);
                % how many points did you say?
                if strcmp(mode,'NA')
                    if (ceil(actualnumpoints/2) ~= numdatapoints)
                        if verbose >= 1, fprintf(1, 'kpib/HP_4395A: WARNING: actual number of points downloaded (%d)\n',ceil(actualnumpoints/2));
                            fprintf(1,'                 does not equal expected number of points (%d).\n',numdatapoints);
                        end
                        numdatapoints = ceil(actualnumpoints/2);
                    end
                elseif strcmp(mode,'SA')
                    if (actualnumpoints ~= numdatapoints)
                        if verbose >= 1, fprintf(1, 'kpib/HP_4395A: WARNING: actual number of points downloaded (%d)\n',actualnumpoints);
                            fprintf(1,'                 does not equal expected number of points (%d).\n',numdatapoints);
                        end
                        numdatapoints = round(actualnumpoints);
                    end
                end
                fprintf(io,'CENT?');
                 center = fscanf(io);
                 center = str2num(center);
                fprintf(io,'SPAN?');
                 span = fscanf(io);
                 span = str2num(span);
                start = center - span/2;
                data_end = center + span/2;
                delta = span/(numdatapoints-1);

                % we have to infer the x values, and we need to know what
                % type of sweep it is- log or linear?
                fprintf(io,'SWPT?');
                 stype=fscanf(io,'%s');
                switch stype
                    case {'LINF'} % linear, easy
                        retval.x=([0:1:numdatapoints-1]*delta)'+start;
                        if verbose >= 2, fprintf('kpib/HP_4395A: Frequency Sweep is %s.\n',stype); end
                        retval.units.x = 'Hz';
                    case {'LOGF'}
                        retval.x=logspace(log10(start),log10(data_end),numdatapoints)';
                        if verbose >= 2, fprintf('kpib/HP_4395A: Frequency Sweep is %s.\n',stype); end
                        retval.units.x = 'log Hz';
                        
                    otherwise
                        retval.x=([0:1:numdatapoints-1]*delta)'+start;
                        if verbose >= 2, fprintf('kpib/HP_4395A: WARNING: Freq. Sweep type not understood ["%s"]. Assuming linear.\n',stype); end
                end
                
                % handle Y values
                switch mode % the returned data is different for different modes
                    case 'NA'
                        % the real data is every other point in the returned array,
                        %  so the array has twice as many members as there are data points
                        %  (manual p O-10). Vectorize!
                        % Return the data in columns
                        %size(rawdata)
                        %retval.x=([0:1:numdatapoints-1]*delta)'+start;
                        retval.y=retdata([1:2:(numdatapoints)*2]);
                        % determine the Y units
                        % what format is this channel in?
                        fprintf(io,'FMT?');
                        fmt=fscanf(io);
                        fmt = fmt(1:end-1); % strip the trailing carriage return
                        if strcmpi(fmt, 'LOGM')
                           retval.units.y = 'dB';
                        elseif strcmpi(fmt, 'LINM')
                            retval.units.y = 'U';
                        elseif strcmpi(fmt, 'PHAS')
                            fprintf(io,'PHAU?');
                            rd = fscanf(io);
                            retval.units.y = rd(1:end-1); % strip the trailing carriage return
                            if strcmp(retval.units.y,'DEG')==1, retval.units.y='deg'; end
                        else
                            retval.units.y = '??';
                        end
                        if verbose >= 2, fprintf('kpib/HP_4395A: Network Analyzer mode Y unit is %s.\n',retval.units.y); end

                    case 'SA'
                        % The spectrum analyzer returns only the data we are
                        %  interested in, no extraneous points
                        % Return the data in columns
                        %retval.x=([0:1:numdatapoints-1]*delta)'+start;
                        retval.y=retdata;
                        % determine the Y units
                        fprintf(io,'SAUNIT?');
                        rd = fscanf(io);
                        retval.units.y = rd(1:end-1); % strip the trailing carriage return
                        if strcmp(retval.units.y,'DBM')==1, retval.units.y='dBm'; end
                        if verbose >= 2, fprintf('kpib/HP_4395A: Spectrum Analyzer mode Y unit is %s.\n',retval.units.y); end
                end


            case 'units'
                if verbose >= 2, fprintf('kpib/HP_4395A: Get Units:\n'); end
                % now, did the user specify a channel or not?
                if isnumeric(channel) && any(channel == [1 2])
                    fprintf(io,'CHAN%d',channel);
                    if verbose >= 2, fprintf('kpib/HP_4395A: Channel %d selected for data download.\n',channel); end
                else
                    if verbose >= 2, fprintf('kpib/HP_4395A: Current channel for data download.\n'); end
                end
                switch value
                    case {'x','X'}
                        % either 'Hz' or 'log Hz'
                        fprintf(io,'SWPT?');
                         stype=fscanf(io,'%s');
                        switch stype
                            case {'LINF'} % linear, easy
                                if verbose >= 2, fprintf('kpib/HP_4395A: Frequency Sweep is %s.\n',stype); end
                                retval.units.x = 'Hz'; % X is always in Hz, as far as I know
                            case {'LOGF'}
                                if verbose >= 2, fprintf('kpib/HP_4395A: Frequency Sweep is %s.\n',stype); end
                                retval.units.x = 'log Hz'; % X is always in Hz, as far as I know
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_4395A: WARNING: Freq. Sweep type not understood ["%s"]. Assuming linear.\n',stype); end
                                retval.units.x = '';
                        end

                    case {'y','Y'}
                         % In Network Analyzer mode, the units depend on the format.
                         % The units for Y phase could be either deg or rad
                         % In Spectrum Analyzer mode, there is a single command.
                         fprintf(io,'SA?');
                         mode=fscanf(io,'%d');
                         if mode==1
                             fprintf(io,'SAUNIT?');
                             retval = fscanf(io);
                             retval = retval(1:end-1); % strip the trailing carriage return
                             if strcmp(retval,'DBM')==1, retval='dBm'; end
                             if verbose >= 2, fprintf('kpib/HP_4395A: Spectrum Analyzer mode Y unit is %s.\n',retval); end
                         else % NA mode
                             % what format is this channel in?
                             fprintf(io,'FMT?');
                             fmt=fscanf(io);
                             fmt = fmt(1:end-1); % strip the trailing carriage return
                             if strcmpi(fmt, 'LOGM')
                                retval = 'dB';
                             elseif strcmpi(fmt, 'LINM')
                                 retval = 'U';
                             elseif strcmpi(fmt, 'PHAS')
                                 fprintf(io,'PHAU?');
                                 retval = fscanf(io);
                                 retval = retval(1:end-1); % strip the trailing carriage return
                                 if strcmp(retval,'DEG')==1, retval='deg'; end
                             else
                                 retval = '??';
                             end
                             if verbose >= 2, fprintf('kpib/HP_4395A: Network Analyzer mode Y unit is %s.\n',retval); end
                         end
                    otherwise % return both
                        retval.x='Hz';
                        retval.y=kpib(instrument,GPIB,'units','y',0,0,verbose);
                                                
                end

            case 'pause'
                if isequal(value,'query')
                    fprintf(io,'HOLD?');
                    retval = fscanf(io);
                else
                    fprintf(io,'HOLD');
                    if verbose >= 2, fprintf('kpib/HP_4395A: Measurement paused.\n'); end
                end

            case {'continue','cont'} % continuous sweeping
                fprintf(io,'CONT');
                if verbose >= 2, fprintf('kpib/HP_4395A: Measurement continue.\n'); end

            case 'complete'
                % complete uses the status registers to know when a sweep has
                %  completed. This method only works for SINGLE and GROUP
                %  sweeps, it does not work for continuous sweeps. If you try
                %  to wait for the complete of a sweep in continuous mode, the
                %  program will hang (you will wait forever).
                % The registers are enabled during the sweep command, above.

                %fprintf(io,'*SRE 4;ESNB 1'); % enable the registers; see manual p5-14

                % can issue a single command for a sweep and complete
%                 if nargin > 3 
                    switch value
                        case {'single','sing','SING'}
%                            % enable the status registers for synchronization
%                            fprintf(io,'CLES'); % clear the status registers
%                            fprintf(io,'*SRE 4;ESNB 1'); % enable the registers; see manual p5-14
%                            fprintf(io,'SING');
							kpib(instrument, GPIB, 'sweep', 'single', channel, aux, verbose);
							if verbose >= 2, fprintf('kpib/HP_4395A: Single Sweep & Complete\n'); end
						case {'group','groups','number','N'}
							kpib(instrument, GPIB, 'sweep', 'group', channel, aux, verbose);
							if verbose >= 2, fprintf('kpib/HP_4395A: Group Sweep (%d) & Complete\n',channel); end
                    end
%                 end
                % or just a single command     
                if verbose >= 2, fprintf('kpib/HP_4395A: Waiting for sweep to complete...\n'); end
                warning off instrument:fscanf:unsuccessfulRead
                
                retval=0;
                while 1
                    pause(1);
                    fprintf(io,'ESB?'); % check the status byte
                    retval=str2num(fscanf(io,'%+f'));
                    esb=dec2bin(retval); % return binary value represents the status registers
                    if esb(end) == '1' % indicates sweep complete
                        if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Sweep complete.\n'); end
                        break;
                    end
                    if length(esb) > 6
                        if esb(end-6) == '1' % indicates "Target not found"
                            if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Analyzer reports: "Target not Found".\n'); end
                        end
                    end
                end

    %            disp('END OF ESB')

            case 'wait'
                % The *WAI command is only moderately useful on the 4395A. See
                %  manual p4-4. 
                fprintf(io,'*WAI'); % wait for previous commands to finish before executing new ones.
                retval = 1;

            otherwise
                if verbose >= 1, fprintf('kpib/HP_4395A: Error, command not supported. ["%s"]\n',command); end

        end

                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_4395A


%% 'HP_34420A' HP nanovoltmeter
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% NOTE: This driver is limited to temperature measurements; it assumes an RTD is
%  connected for a four-wire measurement.
% Valid instructions:
% 'read'    Trigger a measurement and return the result
%
% 'config'  Configures the multimeter for measurement VALUE ('temp') with a
%            100-ohm platinum RTD. Once the instrument has been configured,
%            measurement results can be downloaded from the instrument in quick
%            succession using 'getdata'. Currently, only RTD measurements are
%            supported in kpib, but the principle is applicable to all of the
%            instrument's functions.
%
% 'getdata' Return the current measurement result. This is in contrast to the
%            'read' command, which configures and triggers the measurement before
%            returning the result. As a result, 'getdata' is much faster than
%            'read' for repeated measurements of the same quantity.
%
% 'sampleN' The instrument will make VALUE measurements (max 1024) and store them in
%            the instrument's internal memory before returning them. This allows
%            many measurements to be made quickly, in order to examine a high-
%            frequency event.
%
% Returned values:
% For command 'read':
%  retval       The temperature in deg C, as a %f number
%

if (strcmpi(instrument, 'HP_34420A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case 'config'
                switch value
                    case {'temp','T','temperature','RTD'}
                        fprintf(io,'CONF:TEMP FRTD,DEF,1,DEF');
                        if verbose >=2, fprintf(1,'kpib/HP_34420A: Configured for RTD measurement\n'); end
                    otherwise
                        if verbose >=2, fprintf(1,'kpib/HP_34420A: Error: only RTD (''temp'') supported for rapid measurement\n'); end
                end
            
            case 'read'
                switch value
                    case {'ohm','ohms','R'}
                    % CHANNEL is the measurement range in ohms
                        %if channel == 100 | channel == 1000 | channel == 10000 | channel == 1000000 | channel == 10000000
                        if any(channel == [100 1000 10000 1000000 10000000])
                            if verbose >=2, fprintf(1,'%s %d\n','kpib/HP_34420A: Resistance measurement, range:',channel); end
                            cmd = sprintf('MEAS:RES? %d,DEF', channel);
                            % if a valid resolution has been specified, use it
                            if aux >= 0.0001
                                if verbose >=2, fprintf(1,'  %s %g %s\n','with resolution:', aux, 'ohms'); end
                                cmd = sprintf('%s %d%s%d', 'MEAS:RES?', channel, ',', aux);
                                %fprintf(io,'%s %d%s%d', 'MEAS:RES?', channel, ',', aux);
                            end
                            fprintf(io, cmd);
                        else
                            % if the specified range/resolution are not valid, then autorange
                            if verbose >=2, fprintf(1,'%s\n','kpib/HP_34420A: Autorange resistance measurement'); end
                            fprintf(io,'MEAS:RES? DEF,DEF');
                        end
                    % read the value returned
                    retval = fscanf(io,'%f');
                    if verbose >=2, fprintf(1,'%s %g %s\n','kpib/HP_34420A: Resistance Measurement:',retval,'ohms'); end

                    case {'volt','volts','V'}
                        % if a valid range has been specified, use it. CHANNEL
                        %     is the measurement range in volts
                        if any(channel == [0.030 0.300 3 30 300])
                            if verbose >=2, fprintf(1,'%s %g %s\n','kpib/HP_34420A: Voltage measurement with range',channel,'volts'); end
                            cmd = sprintf('MEAS:VOLT:DC? %d,DEF', channel);
%                                     if nargin > 5
                                % if a valid resolution has also been specified, use it
                                if aux >= 0.00001
                                    if verbose >=2, fprintf(1,'  %s %g %s\n','and with resolution',aux,'volts'); end
                                    cmd=sprintf('MEAS:VOLT:DC? %d,%d', channel, aux);
                                end
%                                     end
                            % send the resulting command
                            fprintf(io, cmd);
                        else
                            % if the specified range/resolution are not valid, then
                            % autorange
                            if verbose >=2, fprintf(1,'%s\n','kpib/HP_34420A: Autorange voltage measurement (invalid options specified)'); end
                            fprintf(io,'MEAS:VOLT:DC? DEF,DEF');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/HP_34420A: Voltage Measurement:',retval,'volts'); end

                    case {'temp','temperature','T'}
                        fprintf(io,'MEAS:TEMP? FRTD');
                        retval=fscanf(io,'%f');
                        if verbose >=2, fprintf(1, '%s %.3f %s\n','kpib/HP_34420A: RTD Temperature:',retval,'C'); end

                    otherwise % default to RTD
                        fprintf(io,'MEAS:TEMP? FRTD');
                        retval=fscanf(io,'%f');
                        if verbose >=2, fprintf(1, '%s %.3f %s\n','kpib/HP_34420A: RTD Temperature (default):',retval,'C'); end
                end

            case 'sampleN'
                if value > 1024
                    if verbose >=1, fprintf(1,'kpib/HP_34420A: Warning: maximum number of readings is 1024.'); end
                else
                    fprintf(io,'CONF:TEMP FRTD,DEF');
                    if channel > 0
                        fprintf(io,'TEMP:NPLC %d',channel);
                    else
                        channel = 0;
                    end
    %                 fprintf(io,'*CLS');
    %                 fprintf(io,'*SRE 32');
                    fprintf(io,'SAMPLE:COUNT %d',value);
                    fprintf(io,'TRIG:SOURCE IMM');
                    fprintf(io,'INITIATE');
                    %fprintf(io,'*OPC');
                    %fprintf(io,'READ?');

                    %pause(value*channel/300+1);
                    fprintf(io,'FETCH?');
                    %retval=fscanf(io,'%f,')
                    % The data is returned as a single giant comma-delimited string
                    %  for some reason. Append a comma to the end so that we can use
                    %  a '%f,' format to read it without any warnings.
    %                 retopc=0
    %                 while retopc < 32
    %                     fprintf(io,'*STB?'); retopc=fscanf(io,'%f')
    %                 end
                    retstr=fscanf(io,'%s'); retstr=[retstr ','];
                    retval=sscanf(retstr,'%f,');
                    fprintf(io,'SAMPLE:COUNT 1'); % reset the sample count
                    fprintf(io,'TEMP:NPLC 10'); % reset NPLC setting
                end
                
            case 'getdata'
                fprintf(io,'READ?');
                retval=fscanf(io,'%f');
                if verbose >=2, fprintf(1, 'kpib/HP_34420A: Measurement: %.3f \n',retval); end

            otherwise
                if verbose >= 1, fprintf(1, 'kpib/HP_34420A: Error, command not supported. ["%s"]\n',command); end
        end 
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;
 end % end HP_34420A


%% 'KTH_236' Keithley 236/237/238 Source Measure Unit
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% This driver focuses on using the Keithley as a precision DC voltage source.
% Valid instructions:
% 'init'    Put the device into DC source mode.
% 'read'    Trigger a measurement and return the result VALUE ('volt' | 'curr').
%             If VALUE is not specified, returns %f structure:
%             retval.volt
%             retval.curr
% 'set'		Sets the Voltage or Current (depending on instrument's mode) output to VALUE.
% 'setV'	Sets output voltage to VALUE.
% 'on'      Enables output.
% 'off'     Disables output.
%
% Note: If the KTH_236 "freezes up" during GPIB use, check the Trigger
%  status. If the trigger light is blinking, you may be set for manual
%  trigger, and nothing will happen until you push the trigger button. Set
%  the trigger to "IEEE X" (when X is sent on gpib). See manual p3-59. The
%  wake-up factory default is manual.
% Also, the KTH_236 seems to have a problem with the 'read' command- it will
%  freeze up at certain times for no apparent reason. If you can figure out
%  why, please let me know! MH
%


if (strcmpi(instrument, 'KTH_236') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case 'init'
    %             fprintf(io,'*REN'); % enter remote state
    %             fprintf(io,'Y4X');
                fprintf(io,'T0,0,0,0'); %SET TRIGGER TO GPIB (manual p3-59)
                switch value
                    case {'voltage','volt','V'}
                        fprintf(io,'F0,0X'); % Function source voltage and measure current
                        if verbose >=2, fprintf(1, '%s\n','kpib/KTH_236: Initialized as Voltage Source/Current Measure'); end
                    case {'current','amps','A','I'}
                        fprintf(io,'F1,0X'); % Function source current and measure voltage
                        if verbose >=2, fprintf(1, '%s\n','kpib/KTH_236: Initialized as Current Source/Voltage Measure'); end
                    otherwise
                        fprintf(io,'J0X'); % Factory defaults
                        if verbose >=2, fprintf(1, '%s\n','kpib/KTH_236: Initialized as Voltage Source (Factory Defaults)'); end
                end

                fprintf(io,'O0X') % specify local sense function ("Oh zero")

            case 'read'
                %fprintf(io,'*REN');
                % get instrument status string. See manual p3-28
                fprintf(io,'G5,0,0X');
                kth=fscanf(io,'%s');
                % The instrument returns its status as a string that we have to
                %  parse. See manual p3-29.
                line_pos=find(kth==','); % the string is comma-delimited
                source=kth(1:line_pos(1)-1);
                sstate=sscanf(source,'%5s,',1);
                if length(line_pos) >= 2
                    measure=kth(line_pos(1)+1:line_pos(2)-1);
                    mstate=sscanf(measure,'%5s,',1);
                else
                    mstate='XXXXX';
                end
                if sstate(5)=='V'
                    kvolt=sscanf(source,[sstate '%e'],1);
                    if verbose >=2, fprintf(1, 'kpib/KTH_236: Source: %.4f V',kvolt); end
                    if mstate(5)=='I'
                        kcurr=sscanf(measure,[mstate '%e'],1);
                        if verbose >=2, fprintf(1, ', Measure %.4f I\n',kcurr); end
                    else
                        kcurr=1776;
                        if verbose >=2, fprintf(1, '\n'); end
                    end
                elseif sstate(5)=='I'
                    kcurr=sscanf(source,[sstate '%e'],1);
                    if verbose >=2, fprintf(1, 'kpib/KTH_236: Source: %.4f I',kcurr); end
                    if mstate(5)=='V'
                        kvolt=sscanf(measure,[mstate '%e'],1);
                        if verbose >=2, fprintf(1, ', Measure %.4f V\n',kvolt); end
                    else
                        kvolt=1776;
                        if verbose >=2, fprintf(1, '\n'); end
                    end
                end
                
                switch value
                    case {'volt','volts','V','v'}
                        retval=kvolt;
                        
                    case {'curr','current','I','i'}
                        retval=kcurr;
                        
                    otherwise
                        retval.volt=kvolt;
                        retval.curr=kcurr;
                end



    %             if sstate(5)=='V' & mstate(5)=='I'
    %                 retval.volt=sscanf(source,[sstate '%e'],1);
    %                 retval.curr=sscanf(measure,[mstate '%e'],1);
    %                 if verbose >=2, fprintf(1, '%s %e %s\n              %s %e %s\n',...
    %                         'kpib/KTH_236: Source:',retval.volt,'V',...
    %                         'Measure:',retval.curr,'A'); end
    %             elseif sstate(5)=='I' & mstate(5)=='V'
    %                 retval.curr=sscanf(source,[sstate '%e'],1);
    %                 retval.volt=sscanf(measure,[mstate '%e'],1);
    %                 if verbose >=2, fprintf(1, '%s %e %s\n              %s %e %s\n',...
    %                         'kpib/KTH_236: Source:',retval.curr,'A',...
    %                         'Measure:',retval.volt,'V'); end
    %             end

                % the first character of the returned string is "n" for normal or 'O' for overload
                if sstate(1) == 'O'
                    if verbose >=2, fprintf(1, '%s\n','kpib/KTH_236: Source overload condition reported'); end
                end
                if mstate(1) == 'O'
                    if verbose >=2, fprintf(1, '%s\n','kpib/KTH_236: Measure overload condition reported'); end
                end

            case {'set','setV'}
    %             fprintf(io,'*REN');
                fprintf(io,'B%f,0,0X',value);
                if verbose >=2, fprintf(1, '%s %+f %s\n','kpib/KTH_236: Output set to:',value,'V'); end

            case 'on'
    %             fprintf(io,'*REN');
                fprintf(io,'N1X');
                if verbose >=2, fprintf(1, '%s\n','kpib/KTH_236: Output enabled'); end

            case 'off'
    %             fprintf(io,'*REN');
                fprintf(io,'N0X');
                if verbose >=2, fprintf(1, '%s\n','kpib/KTH_236: Output disabled'); end

            otherwise
                if verbose >= 1, fprintf(1, 'kpib/KTH_236: Error, command not supported. ["%s"]\n',command); end
        end 
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;
 end % end KTH_236


%% 'HP_8753ES' HP S-Parameter Network Analyzer
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'      Resets the Analyzer.
% 'label'     Writes 'VALUE' to the display. NOTE: may work intermittently.
% 'channel'   Makes channel VALUE the active channel.
% 'meas'      Set the measurement type.
%             VALUE can be: 'a/r', 'b/r', 'a', 'b', or 'r'. 
% 'display'   Controls what is displayed on the Analyzer screen.
%             VALUE can be: 'data', 'memory', or 'datamem'. VALUE can also
%             be 'on' or 'off' to turn on or off dual display mode, or
%             'query' for status of dual display mode.
% 'format'    Set the format of the graph on the Analyzer display:
%             Linear, log/mag, etc. non-exponentially ('norm').
%             Exponentially is the default.
% 'scale'     Sets the scale of the display. VALUE is the scale in the
%             current units, or 'VALUE' = 'auto' for autoscale command. 
% 'ref line'  Sets the position of the reference line of the display.
%             VALUE is the position of the reference line in the current
%             units.
% 'average'   Turns averaging on or off, restarts averaging, or returns
%             the current number of averages taken.
%             VALUE='on','off','restart', or 'query'. For 'query', RETVAL
%             returns 0 (off) or the current number of averages (on).
% 'mark2peak' Finds the peak and sets the marker, or finds the peak and
%             sets the peak location to the center of the scan.
%             VALUE='off','center', or 'peak'.
% 'marker'    Turns the marker on or off, or returns the current
%              position of the marker. 'VALUE' = 'on','off', or 'query'.
%              The position is returned as retval.x, retval.y in current
%              units.
% 'center'    Set the center frequency to VALUE. Units of Hz.
%              Query with VALUE = 'query', returns center frequency in Hz.
% 'span'      Set the frequency span VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'sweep'     Sets sweep parameters
% 'source'    Set the source (stimulus output) signal level. VALUE is the
%              desired signal level. Units of dBm. Query with VALUE =
%              'query', returns source power in dBm.
% 'source?'   (Alternate query form) Returns source power in dBm.
% 'power'     Same as 'source'.
% 'getdata'   Download the current data trace from the analyzer. Data is
%              returned as two columns, x and y, for the specified CHANNEL.
%              Default CHANNEL is not set. If VALUE is 'x' or 'y', only
%              that data is returned in a single column.
% 'units'     Returns the units of the data from the analyzer. Must
%              specify VALUE = 'x' or 'y' axis units.
% 'pause'     Pauses measurement. 'continue'  Continues paused measurement.
% 'complete'  Wait for the previous sweep to complete. This command
%              contains a loop that does not exit until the status byte
%              shows
% 'wait'      Wait for the previous command to complete (*WAI)

if (strcmpi(instrument, 'HP_8753ES') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command

            case 'init' %ok
                %fprintf(io,'*RST');
                fprintf(io,'CLES')

            case {'label','title'}  %ok
                if length(value) > 53
                    value=value(1:53); % 53 chars max
                end
                fprintf(io,'TITL "%s"',value);

            case 'channel' %ok
                if channel==0 && any(value==[1 2 3 4])
                    channel=value;
                end
                if any(channel==[1 2 3 4])
                    fprintf(io,'CHAN%d',channel);
                    if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Channel %d selected.\n',channel); end
                else
                    if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Warning: Channel select error (must be 1-4).\n'); end
                end

            case 'meas' %ok
                switch value
                    case {'a/r','A/R','AR'}
                        fprintf(io,'AR');
                    case {'b/r','B/R','BR'}
                        fprintf(io,'BR');
                     case {'r','R','R'}
                        fprintf(io,'MEASR');
                    case {'a','A'}
                        fprintf(io,'MEASA');                    
                    case {'b','B'}
                        fprintf(io,'MEASB');
                    otherwise
                        if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Error, %s is not a valid input (a/r,b/r,A,B,R).\n',value); end
                end
                if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Measurement set to %s.\n',value); end


            case {'display','trace'} %ok
                switch value
                    case {'data'}
                        fprintf(io,'DISPDATA');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Display data only\n'); end
                    case {'memory','mem'}
                        fprintf(io,'DISPMEMO');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Display memory only\n'); end
                    case {'both','data&memory','datamem','data+memory'}
                        fprintf(io,'DISPDATM');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Display data & memory\n'); end
                    case {'dual'} %ok
                        switch channel
                            case {'on',1}
                                fprintf(io, 'DUACON');
                                if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display on.\n'); end
                            case {'off',0}
                                fprintf(io, 'DUACOFF');
                                if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display off.\n'); end
                            case {'query','?'} % returns 1 for dual-channel on, 0 for off
                                fprintf(io, 'DUAC?');
                                dstatebit=str2num(fscanf(io));
                                if dstatebit==1, dstate='on';
                                elseif dstatebit==0, dstate='off';
                                end
                                retval=dstatebit;
                                if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display is %s\n',dstate); end
                        end
                    case {'on',1}
                        fprintf(io,'BLADOFF');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Screen on\n'); end
                    case {'off',1}
                        fprintf(io,'BLADON');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Screen off\n'); end 
                     case {'query','?'} % returns binary state for channels (emulate 4 channels)
                        fprintf(io, 'DUAC?');
                        dstateb=str2num(fscanf(io));
                        if dstateb==1, dstate='1 1 0 0';
                            if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display is on\n'); end
                        % NB: fix this- query active channel?
                        %    Assume CH 1 until then
                        elseif dstatebit==0, dstate='1 0 0 0';
                            if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display is off (assume CH1)\n'); end
                        % NB: fix this- query active channel?
                        end
                        retval=dstate;
%                         if verbose >= 2, fprintf(1, 'kpib/HP_4395A: Dual-channel display is %s\n',dstate); end

                end 

            case 'format' %ok
                switch value
                    case 'log mag'
                        fprintf(io,'LOGM');
                    case 'phase'
                        fprintf(io,'PHAS');
                    case 'delay'
                        fprintf(io,'DELA');
                    case 'linear mag'
                        fprintf(io,'LINM');
                    case 'polar'
                        fprintf(io,'POLA');
                    case 'real'
                        fprintf(io,'REAL');
                    otherwise
                        if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Set Analyzer data format to default log magnitude.\n'); end
                        fprintf(io,'LOGM');
                end

            case {'autoscale','auto','autoy'};
                switch value
                    case 'off'
                        % DNE
                    case 'once'
                        if isnumeric(channel) && any(channel == [1 2 3 4])
                            fprintf(io,'CHAN%d',channel);
                            fprintf(io,'AUTO');
                            if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale channel %d\n',channel); end
                        else
                            fprintf(io,'AUTO');
                            if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale current channel\n'); end                                    
                        end
                    case 'both' % specific to resonators - autoscale channels 1 & 2
                        fprintf(io,'CHAN1'); fprintf(io,'AUTO');
                        fprintf(io,'CHAN2'); fprintf(io,'AUTO');
                        fprintf(io,'CHAN1');
                        if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale channels 1 & 2\n'); end

                    otherwise
                        if isnumeric(channel) && any(channel == [1 2 3 4])
                            fprintf(io,'CHAN%d',channel);
                            fprintf(io,'AUTO');
                            if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale channel %d\n',channel); end
                        else
                            fprintf(io,'AUTO');
                            if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale Y current channel (default)\n'); end
                        end
                 end

            case 'scale' %ok
                if isnumeric(value)
                    fprintf(io,'SCAL%d',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Scale of current channel set to %d/div.\n',value); end
                else
                	switch value
                		case {'auto','AUTO'}
		                    fprintf(io,'AUTO');
      			            if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Autoscale current channel.\n'); end
                    	case {'?','query'}
		                	fprintf(io,'SCAL?')
		                	retval = fscanf(io);
		                	if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Scale is %g/division.\n',retval); end
		                case {'ref','refline','ref line'}
		                	fprintf(io,'REFV%d',value);
		                	if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Reference value set to %g dBm.\n',value); end
                    end
                end

            case 'ref line' %ok
                fprintf(io,'REFV%d',value);
                if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Reference value set to %g dBm.\n',value); end

            case {'average','averaging'} %ok
                switch value
                    case {'on',1}
                        fprintf(io,'AVEROON'); 
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Averaging on'); end
                        if isnumeric(channel) && channel > 0
                            fprintf(io,'AVERFACT%.0f',channel);
                            if verbose >= 2, fprintf(1, ', aver. factor %d.\n',channel); end
                        else
                            if verbose >= 2, fprintf(1,', aver. factor is not specified.\n'); end
                        end
                    case {'off',0};
                        fprintf(io,'AVEROOFF');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Averaging off.\n'); end
                    case {'num','number','count'} % not available for 8753? Use number of groups
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Warning: Averaging Count not available for 8753ES, use number of groups instead.\n'); end
                    case{'restart','Restart'}
                        fprintf(io,'AVERREST');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Averaging restarted.\n'); end
                    case {'query','?'}
                        fprintf(io,'AVERO?');
                        retval = fscanf(io,'%f');
                        if retval == 0
                            if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Averaging is off.\n'); end
                        else
                            fprintf(io,'AVERFACT?');
                            retval = fscanf(io,'%f');
                            if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Averaging is on; Averaging factor is: %g\n', retval); end
                        end
                    otherwise % set the number of measurements to average
                        if isnumeric(value) && value > 0
                            fprintf(io,'AVERFACT %d',channel);
                            if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Averaging factor set to: %d\n',value); end
                        end

                end

            case {'marker'} %ok
                if isnumeric(channel) && any(channel == [1 2 3 4])
                    fprintf(io,'MARK%d',channel);
                    if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Marker channel %d\n',channel); end
                else
                    channel=1;
                    if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Marker channel 1 (default)\n'); end                                   
                end                

                if isnumeric(value) && value > 0 % move marker to that point
                    cmd=sprintf('MARK%d%f',channel,value');
                    fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Marker channel %d set to %f Hz\n',channel,value); end
                else
                    switch value
                        case 'on'
                            fprintf(io,'MARK%d',channel);
                        case 'off'
                            fprintf(io,'MARKOFF');
                        case {'query','?'} % query the marker position
                            fprintf(io,'OUTPMARK');
                            mkr = fscanf(io);
                            mkr = str2num(mkr);
                            %retval=mkr;
                            retval.y = mkr(1);
                            retval.x = mkr(3);
                            if verbose >= 2, fprintf(1,'kpib/HP_8753ES: Marker position: %f/%f\n',mkr(1),mkr(3)); end
                    case {'center','m2c','mark2center'} % make the marker position the center freq
                        fprintf(io,'SEAMAX');
                        fprintf(io,'MARKCENT');
                        if verbose >= 2, fprintf(1,'kpib/HP_8753ES: Peak to Center\n'); end
                    case {'peak','searchpeak','mark2peak','max'}
                        fprintf(io,'SEAMAX');                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8753ES: Marker to Peak (max)'); end
                    case {'min','valley'}
                        fprintf(io,'SEAMIN');                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8753ES: Marker to Valley (min)'); end
                    otherwise
                        if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Error at ''marker'' command (VALUE incorrect ["%s"]).\n',value); end
                    end
                end

            case {'mark2peak','m2p','findpeak'} %ok
                switch value
                    case 'off'
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8753ES: Marker Search Off'); end
                        fprintf(io,'SEAOFF');
                    case 'center'
                        fprintf(io,'SEAMAX');
                        fprintf(io,'MARKCENT');
                        if verbose >= 2, fprintf(1,'kpib/HP_8753ES: Peak to Center\n'); end
                    case {'peak','max'}
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8753ES: Marker to Peak (max)'); end
                        fprintf(io,'SEAMAX');
                    case 'min'
                         if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8753ES: Marker to minimum'); end
                        fprintf(io,'SEAMIN');                   
                    otherwise
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8753ES: Marker to Max (default)'); end
                        fprintf(io,'SEAMAX');
                end

            case 'sweep' %ok
                fprintf(io,'CLES'); % clear the status registers
                fprintf(io,'*OPC?'); % to check operation(sweep) complete.
                % *OPC? + sweep command will return '1' when sweep is
                %  done. complete check is done in 'complete' command
                
                if isnumeric(value) && value > 0 % set the sweep time
                    fprintf(io,'SWET%d',value);
                else
                    switch value
                        case {'auto','AUTO'}
                            fprintf(io,'SWEA');
                        case {'linear freq'}
                            fprintf(io,'LINFREQ');
                        case {'list freq'}
                            fprintf(io,'LISFREQ');
                        case {'log freq'}  
                            fprintf(io,'LOGFREQ');
                        case {'power sweep'}
                            fprintf(io,'POWS');
                        case {'single','sing','SING'}                            
                            fprintf(io,'SING');
                        case {'continuous','cont','CONT'}
                            fprintf(io,'CONT');
                        case {'hold','HOLD'}
                            fprintf(io,'HOLD');
                        case {'group','groups','number','N'}
                            if isnumeric(channel) && channel >= 1 && channel <= 999
                                fprintf(io,'NUMG%d',channel);
                            else
                                if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Sweep Error: Number or sweeps must be between 1 and 999.\n'); end
                            end
                        case {'points','numpoints','setpoints'}
                            if isnumeric(channel) && channel >= 2 && channel <= 801
                                fprintf(io,'POIN%i',channel);
                            else
                                if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Sweep Error: Number of points must be between 2 and 801.\n'); end
                            end
                        otherwise
                            if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Sweep command not supported ["%s"]\n',value); end
                    end
                end

            case 'center' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'CENT?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'CENT%f',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Center set to %f Hz\n',value); end
                end

            case 'span' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'SPAN?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'SPAN%f',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Span set to %f Hz\n',value); end
                end

            case 'start' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'STAR?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'STAR%f',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Start set to %f Hz\n',value); end
                end

            case 'stop' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'STOP?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'STOP%f',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Stop set to %f Hz\n',value); end
                end

            case {'power','source'} %ok
                if isequal(value,'query')
                    fprintf(io,'POWE?');
                    retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Source Power is %d dBm\n',retval); end
                elseif isnumeric(value) && value >= -50 && value <= 15
                    fprintf(io,'POWE%d',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Source Power set to %d dBm\n',value); end
                else
                    if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Source Power not set. Power must be specified between -50 and 15 dBm.\n'); end
                end

            case {'power?','source?'} %ok
                fprintf(io,'POWE?');
                retval.level = fscanf(io,'%f');
                if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Source Power: %g dBm\n',retval.level); end
                retval.state='on'; % source is always on

    %         case 'bandwidth'
    %             if isnumeric(value)
    %                 fprintf(io,'BW %d',value);
    %             elseif isequal(value,'auto')
    %                 if isequal(channel,'on') | isequal(channel,'off')
    %                     fprintf(io,'BWAUTO %s',channel);
    %                 end
    %             elseif isequal(value,'limit')
    %                 if isnumeric(channel)
    %                     fprintf(io,'BWLMT%d',channel);
    %                 else
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: A numeric value must be entered for channel.\n'); end
    %                 end
    %             end

    %         case 'trigger'
    %             switch value
    %                 case 'internal'
    %                     fprintf(io,'TRGS INT');
    %                 case 'external'
    %                     fprintf(io,'TRGS EXT');
    %                 case 'GPIB'
    %                     fprintf(io,'TRGS BUS');
    %                 case 'video'
    %                     fprintf(io,'TRGS VID');
    %                 case 'manual'
    %                     fprintf(io,'TRGS MAN');
    %                 case 'ext gate'
    %                     fprintf(io,'TRGS GAT');
    %                 otherwise
    %                     if isequal(value,'int') | isequal(value,'ext') | isequal(value,'vid') | isequal(value,'man') | isequal(value,'gat') | isequal(value,'bus')
    %                         fprintf(io,'TRGS %s',value);
    %                     else
    %                         if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Not a valid trigger.\n'); end
    %                     end
    %             end

            case 'getdata' %ok
                % Select the channel. For compatibility with old code, the
                %  channel is *not* set if it is not explicitly specified, i.e.,
                %  the default is to do nothing, rather than to select a channel.

                % specify the data format as ASCII
                fprintf(io,'FORM4');

                % now, did the user specify a channel or not?
                if isnumeric(channel) && any(channel == [1 2 3 4])
                    fprintf(io,'CHAN%d',channel);
                    if verbose >= 2, fprintf('kpib/HP_8753ES: Channel %d selected for data download.\n',channel); end
                else
                    if verbose >= 2, fprintf('kpib/HP_8753ES: Current channel for data download.\n'); end                                   
                end    

                % download the data. The HP_8753ES only sends the Y values.
                fprintf(io,'POIN?');
                numdatapoints = fscanf(io,'%f');
                fprintf(io,'OUTPFORM');
                for fg=1:numdatapoints
                    rd = fscanf(io);
                    rawdata(fg,:) = str2num(rd); % only column 1 is data
                end
                retval.y=rawdata(:,1); % only column 1 is data
                if verbose >= 2, fprintf('kpib/HP_8753ES: Data downloaded.\n'); end
                % Now we must infer the X values
                %numdatapoints = str2num(numdatapoints);
                fprintf(io,'CENT?');
                center = fscanf(io);
                center = str2num(center);
                fprintf(io,'SPAN?');
                span = fscanf(io);
                span = str2num(span);
                start = center - span/2;
                delta = span/(numdatapoints-1);
                retval.x=([0:1:numdatapoints-1]*delta)'+start;

                % get the units
                retval.units.x = 'Hz'; % X is always in Hz, as far as I know
                % the units for Y amplitude depend on the Format
                fprintf(io,'LOGM?');
                fmt=fscanf(io,'%d');
                if fmt==1
                    retval.units.y='dB';
                else
                    fprintf(io,'LINM?');
                    fmt=fscanf(io,'%d');
                    if fmt==1
                        retval.units.y='U';
                    else
                       fprintf(io,'PHAS?');
                       fmt=fscanf(io,'%d');
                       if fmt==1
                           retval.units.y='deg';
                       else
                           retval.units.y='??';
                       end
                    end
                end 

    %             switch mode % the returned data is different for different modes
    %                 case 'NA'
    %                     % the real data is every other point in the returned array,
    %                     %  so the array has twice as many members as there are data points
    %                     %  (manual p O-10). Vectorize!
    %                     % Return the data in columns
    %                     retval.x=([0:1:numdatapoints-1]*delta)'+start;
    %                     retval.y=rawdata([1:2:numdatapoints*2])';
    %                     
    %                 case 'SA'
    %                     % The spectrum analyzer returns only the data we are
    %                     %  interested in, no extraneous points
    %                     % Return the data in columns
    %                     retval.x=([0:1:numdatapoints-1]*delta)'+start;
    %                     retval.y=rawdata';
    %             end 

            case 'units' %ok
                % See the manual p1-82 (Table 1-4) for units
                %  query the display format, and then assume the units
                % now, did the user specify a channel or not?
                if isnumeric(channel) && any(channel == [1 2 3 4])
                    fprintf(io,'CHAN%d',channel);
                    if verbose >= 2, fprintf('kpib/HP_8753ES: Channel %d selected for units.\n',channel); end
                else
                    if verbose >= 2, fprintf('kpib/HP_8753ES: Current channel for units.\n'); end                                   
                end

                %if verbose >= 2, fprintf('kpib/HP_8753ES: Get Units:\n'); end
                switch value
                    case {'x','X'}
                        % the units for X are always Hz, as far as I can tell
                         retval='Hz';
                    case {'y','Y'}
                         % the units for Y amplitude depend on the Format
                         fprintf(io,'LOGM?');
                         fmt=fscanf(io,'%d');
                         if fmt==1
                             retval='dB';
                         else
                             fprintf(io,'LINM?');
                             fmt=fscanf(io,'%d');
                             if fmt==1
                                 retval='U';
                             else
                                fprintf(io,'PHAS?');
                                fmt=fscanf(io,'%d');
                                if fmt==1
                                    retval='deg';
                                else
                                    retval='??';
                                end
                            end
                         end
                    otherwise % get both
                        retval.x='Hz';
                        retval.y=kpib(instrument,GPIB,'units','y',channel,aux,verbose);
                end

            case 'pause' %ok
                if isequal(value,'query')
                    fprintf(io,'HOLD?');
                    retval = fscanf(io);
                else
                    fprintf(io,'HOLD');
                    if verbose >= 2, fprintf('kpib/HP_8753ES: Measurement paused.\n'); end
                end

            case {'continue','cont'} % continuous sweeping
                fprintf(io,'CONT');
                if verbose >= 2, fprintf('kpib/HP_8753ES: Measurement continue.\n'); end

            case 'complete' %ok
                %  complete check return value from io-port after issuing 
                %  *OPC? + (sweep command) to know when a sweep has
                %  completed. This method only works for SINGLE and GROUP
                %  sweeps, it does not work for continuous sweeps. If you try
                %  to wait for the complete of a sweep in continuous mode, the
                %  program will hang (you will wait forever).
                %  *OPC? + (sweep command) (i.e. *OPC?; SING) is issued during   
                %  the 'sweep' command above. Here, we do fscanf(io,%d) until
                %  '1' is returned. For safety, no GPIB command should be
                %  issued between 'sweep' and 'complete'
         
                if verbose >= 2, fprintf('kpib/HP_8753ES: Waiting for sweep to complete...\n'); end            
                warning off instrument:fscanf:unsuccessfulRead
                
				% can issue a single command for a sweep and wait for completion
				%  e.g., kpib(tools.analyzer,'complete','single',0,0,verbose);
				switch value
					case {'single','sing','SING'}
						kpib(instrument, GPIB, 'sweep', 'single', channel, aux, verbose);
						if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Single Sweep & Complete\n'); end
					case {'group','groups','number','N'}
						kpib(instrument, GPIB, 'sweep', 'group', channel, aux, verbose);
						if verbose >= 2, fprintf('kpib/HP_8753ES: Group Sweep (%d) & Complete\n',channel); end
				end

                retval=0;               
                while 1
                    retval = fscanf(io,'%d'); % read return value after *OPC? is issued in 'sweep'
                    if ~isempty(retval) && retval == 1 % if return value is '1', sweep is completed.
                        if verbose >= 2, fprintf(1,'kpib/HP_8753ES: Sweep complete.\n'); end
                        break;
                    else % if return value is ' ', sweep is not completed.
                        if verbose >= 2, fprintf(1,'kpib/HP_8753ES: Sweep not complete.\n'); end
                    end
                end

            case 'wait'  % *WAI is not supported by 8753?
                retval = 1;

            otherwise
                if verbose >= 1, fprintf('kpib/HP_8753ES: Error, command not supported. ["%s"]\n',command); end

        end

                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end

    validInst = 1;
 end % end HP_8753ES

 

%% 'AO_800' AlphaOmega Instruments 800-series Temperature controller
% The AO_800 uses a serial port interface. GPIB should be the com port
%  (e.g. 'COM1'). The AO_800 uses a Watlow series 96 controller, so the
%  programming follows the Watlow "Modbus Register" conventions.

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'        Test the serial connections, make sure controller is set up
%                for "normal" operation.
% 'set','setT'  Set the temperature setpoint for automatic temperature
%                control. Use VALUE = 'query' or '?' to query.
% 'manual'      Set the controller to manual mode and set the output to
%                VALUE percent. + = heating, - = cooling.
% 'read'        Read the current temperature from the feedback sensor.
%                Returns temperature with two decimal places of precision.
% 'on'          Set the controller for automatic mode (control temperature).
% 'off'         Stop controlling temperature (manual mode) and set output
%                power to zero.
% 'readreg'     Return the contents of CHANNEL memory registers, starting at
%                register VALUE. Results are returned as decimal value. For
%                VERBOSE = 2, results are displayed in hex.
% 'writereg'    Write a byte (CHANNEL) to register VALUE.
%
% 'openloop'    Enable and disable the "Open Loop Detect" feature.
%
if (strcmpi(instrument, 'AO_800') || strcmpi(instrument, 'all'))

    % baudrate for serial communications
    baudrate = 9600; % bps
    conaddr = 1; % the controller defaults to address 1
                % (in theory, you could connect multiple controllers on a serial bus)
                % Make this flexible in future versions? (MH, v3.4)
    
    io = port(GPIB, instrument, baudrate, verbose);
    try % Wrap the whole thing in try/catch to deal with serial cable noise and errors.
        %  The error rate seems to be on the order of 1/1000 operations.
        %  Its not clear where the real source of the problem lies. See the
        %  Catch block for further discussion. (MH v4.64)
    
        switch command
            case 'init'
                if verbose >= 2, fprintf(1, 'kpib/AO_800: Initializing AlphaOmega 800 Series Temp. Controller on %s:\n',GPIB); end
                % loopback command to check wiring
                message=[conaddr 8 42 42];
                crc=makeCRC(message);
                fwrite(io,[message crc]);
                confirm = fread(io,6);
                if confirm' == [message crc]
                    fprintf(1, '  OK Serial port connection to controller is ok\n');
                else
                    fprintf(1, '  ERROR: Serial port connection to controller is bad (failed loopback)\n');
                end

%                 % enable open loop detect Register 
%                 message=[conaddr 6 3 136 0 1];
%                 crc=makeCRC(message);
%                 response = watwrite(io,[message crc],verbose);
%                 if response == 0
%                     if verbose >= 1, fprintf(1, '  OK Controller confirms open loop detect enable\n'); end
%                 else
%                     if verbose >= 1, fprintf(1, '  WARNING: Controller does not confirm open loop detect\n'); end
%                 end

                % disable open loop detect Register 
                message=[conaddr 6 3 136 0 0];
                crc=makeCRC(message);
                response = watwrite(io,[message crc],verbose);
                if response == 0
                    if verbose >= 1, fprintf(1, '  OK Controller confirms open loop detect disable\n'); end
                else
                    if verbose >= 1, fprintf(1, '  WARNING: Controller does not confirm open loop detect\n'); end
                end

                % disable the EEPROM
                message=[conaddr 6 0 24 0 0];
                crc=makeCRC(message);
                response = watwrite(io,[message crc],verbose);
                if response == 0
                    if verbose >= 1, fprintf(1, '  OK Controller confirms EEPROM disable\n'); end
                else
                    if verbose >= 1, fprintf(1, '  WARNING: Controller does not confirm EEPROM disable\n'); end
                end

                % check to be sure that the result will be given using one
                %  implied decimal point (default): read register 606 (0x025E)
                message=[conaddr 3 2 94 0 1];
                crc=makeCRC(message);
                fwrite(io,[message crc]);
                got_decimal = fread(io,7); % decimal(5) is our answer
                if got_decimal(5) == 1
                    if verbose >= 1, fprintf(1, '  OK Controller is using 1 implied decimal point (standard)\n'); end
                else
                    if verbose >= 1, fprintf(1, '  WARNING: Controller decimal point setting is non-standard.\n'); end
                    if verbose >= 1, fprintf(1, '           (Recommend setting register 606 to 1).\n'); end
                end

                % % NB: locking out the setpoint, etc., locks it for remote
                % %  programming as well.

    %             pause(0.1)
    %             % lock out the front panel setpoint
    %             message=[value 6 5 20 0 2];
    %             crc=makeCRC(message);
    %             fwrite(io,[message crc]);
    
    
                % Personal preference whether 'init' should leave the
                %  controller on or off ...
                if verbose >= 1, fprintf(1, '\n  Initialization sequence complete.\n'); end
                kpib(instrument,GPIB,'off',value,channel,aux,verbose);
                if verbose >= 1, fprintf(1, '\n  Controller is OFF (manual mode).\n\n'); end
%                 kpib(instrument,GPIB,'on',value,channel,aux,verbose);
%                 if verbose >= 1
%                     setp=kpib(instrument,GPIB,'set','query',channel,aux,verbose);                
%                     fprintf(1, '\n  WARNING: Controller is ON, with setpoint %d C.\n',setp);
%                     fprintf(1, '           Verify that TE element is ready for power.\n\n');
%                 end

                
              % % end 'init'
              

            case {'on',1,'lock'} % enable the controller for Auto operation (i.e. controlling temperature)
                % register 301 set to 0
                message=[conaddr 6 1 45 0 0];
                crc=makeCRC(message);
                response = watwrite(io,[message crc],verbose);
                if response == 0
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller is ON (controlling temperature)\n'); end
                else
                    if verbose >= 1, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm ON\n'); end
                end


            case {'off',0,'stop'} % put controller into Manual mode and set output power to 0
                % register 301 set to 1 for Manual
                message=[conaddr 6 1 45 0 1];
                crc=makeCRC(message);
                response = watwrite(io,[message crc],verbose);
                if response == 0
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller in Manual mode\n'); end
                else
                    if verbose >= 1, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm Manual Mode\n'); end
                end            
%                 % register 310 set for Manual mode setpoint
%                 % check to be sure that the result will be given using one
%                 %  implied decimal point (default): read register 606 (0x025E)
%                 message=[conaddr 3 2 94 0 1];
%                 crc=makeCRC(message);
%                 fwrite(io,[message crc]);
%                 got_decimal = fread(io,7); % decimal(5) is our answer
%                 pause(0.1)
                % now set the setpoint to 0
                message=[conaddr 6 1 54 0 0];
                crc=makeCRC(message);
                response = watwrite(io,[message crc],verbose);
                if response == 0
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller is OFF (output 0%%)\n'); end
                else
                    if verbose >= 1, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm OFF\n'); end
                end


            case {'openloop','opld'} % open-loop detect can trip unnecessarily
                                     %  if you are trying to get to the extreme
                                     %  low temperature ranges (because it takes
                                     %  a long time to get there)
                toggle=0; % flag
%                 if nargin > 3
                    switch value
                        case {'on'} % enable open loop detect Register 
                            message=[conaddr 6 3 136 0 1];
                            crc=makeCRC(message);
                            response = watwrite(io,[message crc],verbose);
                            if response == 0
                                if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller confirms open loop detect enable\n'); end
                            else
                                if verbose >= 2, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm open loop detect\n'); end
                            end
                        case {'off'} % disable open loop detect Register 
                            message=[conaddr 6 3 136 0 0];
                            crc=makeCRC(message);
                            response = watwrite(io,[message crc],verbose);
                            if response == 0
                                if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller confirms open loop detect disable\n'); end
                            else
                                if verbose >= 2, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm open loop detect\n'); end
                            end
                        otherwise % toggle
                            toggle=1; % set flag
                    end
%                 else % toggle
%                     toggle=1;
%                 end
                if toggle==1 % you know what to do
                    % read the register to determine the current state
                    message=[conaddr 3 3 136 0 1];
                    crc=makeCRC(message);
                    fwrite(io,[message crc]);
                    opld = fread(io,7); % decimal(5) is our answer
                    if opld(5)==0
                        message=[conaddr 6 3 136 0 1];
                        crc=makeCRC(message);
                        response = watwrite(io,[message crc],verbose);
                        if response == 0
                            if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller confirms open loop detect enable\n'); end
                        else
                            if verbose >= 2, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm open loop detect\n'); end
                        end                        
                    else
                        message=[conaddr 6 3 136 0 0];
                        crc=makeCRC(message);
                        response = watwrite(io,[message crc],verbose);
                        if response == 0
                            if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller confirms open loop detect disable\n'); end
                        else
                            if verbose >= 2, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm open loop detect\n'); end
                        end
                    end
                end

            case {'set','setT','setpoint'}
                if isnumeric(value) && value < 125 && value > -55
                    % setpoint is register 300. Send temperature with one decimal
                    %  point implied.
                    go_set=round(value*10);
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Changing setpoint to %.1f C\n', go_set/10); end
                    % sort out the setpoint values for transmission
                    sp=makeBytes(go_set);
                    message=[conaddr 6 1 44 sp];
                    crc=makeCRC(message);
                    response = watwrite(io,[message crc],verbose);
                    if response == 0
                        if verbose >=2, fprintf(1, 'kpib/AO_800: Controller confirms setpoint change to %.1f C\n', go_set/10); end
                    end

                elseif strcmpi(value,'query') || strcmpi(value,'?') % return setpoint
                    % check decimal register
                    message=[conaddr 3 2 94 0 1];
                    crc=makeCRC(message);
                    fwrite(io,[message crc]);
                    got_decimal = fread(io,7); % decimal(5) is our answer
                    pause(0.1)

                    % now read setpoint register
                    message=[conaddr 3 1 44 0 1];
                    crc=makeCRC(message);
                    fwrite(io,[message crc]); pause(0.005)
                    setp = fread(io,7);
                    retval = makeDecimal(setp(4:5));
                    % divide result by ten if required
                    if got_decimal(5) == 1
                        retval = retval/10;
                    end
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Temperature Setpoint is: %.1f C\n',retval); end

                else
                    if verbose >= 1, fprintf(1, 'kpib/AO_800: "set" command error\n'); end
                end


            case {'read','getdata'}
                % we can read register 100 (Process 1) for the control value
                %  or we can read secret register 1707 for "High Resolution"
                %  temperature value. Hmm. 1707 seems to use 2 decimal places.

                %if strcmpi(value,'temp') || strcmpi(value,'T')
                if any(strcmpi(value,{'temp','temperature','T'})) %v4.72
                    % read the high-res temperature from register 1707 (0x06AB)
                    message=[conaddr 3 06 171 0 1];
                    highres = 1;
                else
                    % read the temperature from register 100 (0x0064)
                    message=[conaddr 3 00 100 0 1];
                    highres = 0;
                end

                crc=makeCRC(message);
                % this try/catch is superseded by the command-wide
                %   try/catch (v3.76)
%                 try 
                    fwrite(io,[message crc]);
                    got_temp = fread(io,7); % got_temp(4:5) is our answer
                    retval=makeDecimal(got_temp(4:5));
                    % divide result by ten if required
                    if highres == 1
                        retval = retval/100; % 100 for high-res
                    else
                        retval = retval/10; % 10 for normal
                    end
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Temperature reading: %.2f C\n',retval); end
%                 catch
%                     if verbose >= 0, fprintf(1, 'kpib/AO_800: WARNING: serial port error (read). Retrying:\n'); end
%                     % close the serial port and try again
%                     kpib('close',GPIB,0,0,0,0,verbose);
%                     pause(1);
%                     retval=kpib(instrument,GPIB,command,value,channel,aux,verbose);
%                 end


            case 'manual'
                % register 301 set to 1 for Manual
                message=[conaddr 6 1 45 0 1];
                crc=makeCRC(message);
                response = watwrite(io,[message crc],verbose);
                if response == 0
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller in Manual mode\n'); end
                else
                    if verbose >= 1, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm Manual Mode\n'); end
                end

                if isnumeric(value) % set the output to VALUE percent
                    go_set=round(value*10);
                    if verbose >= 2, fprintf(1, 'kpib/AO_800: Changing output to %.1f%%\n', go_set/10); end
                    sp=makeBytes(go_set);
                    % now set the setpoint to go_set
                    message=[conaddr 6 1 54 sp];
                    crc=makeCRC(message);
                    response = watwrite(io,[message crc],verbose);
                    if response == 0
                        if verbose >= 2, fprintf(1, 'kpib/AO_800: Controller output is %.1f%%\n',value); end
                    else
                        if verbose >= 1, fprintf(1, 'kpib/AO_800: WARNING: Controller does not confirm output\n'); end
                    end
                else
                    switch value
                        case {'on','go'}
                            kpib(instrument,GPIB,'on',value,channel,aux,verbose);
                        case {'off','stop'}
                            kpib(instrument,GPIB,'off',value,channel,aux,verbose);
                        otherwise %case {'query','?'}
                            retval=kpib(instrument,GPIB,'read',301,channel,aux,verbose);
                            if verbose >= 2
                                if retval == 1
                                    fprintf(1, 'kpib/AO_800: Controller in manual mode.\n');
                                elseif retval == 0
                                    fprintf(1, 'kpib/AO_800: Controller in manual mode.\n');
                                else
                                    fprintf(1, 'kpib/AO_800: ERROR: Controller mode not known.\n');
                                end
                            end
                    end
                end 


            case 'readreg'  % return the contents of an arbitrary register
                if isnumeric(channel) && channel < 1 && channel > 10
                    channel=1; % number of 2-byte registers to read
                    if verbose >= 1, fprintf(1,'kpib/readreg: Read one byte (max. 10)\n'); end
                elseif ~isnumeric(channel) || channel==0
                    channel=1;
                end
                if verbose >= 2, fprintf(1,'kpib/readreg: Read %d bytes starting at %d\n',channel,value); end
                % code the register value for transmission
                reg=makeBytes(value);
                message=[conaddr 3 reg 0 channel];
                crc=makeCRC(message);
                fwrite(io,[message crc]);
                got_reg = fread(io,5+channel*2);
                reghex=dec2hex(got_reg(4:4+got_reg(3)-1),2);
                rhex=[];
                for r=1:channel*2
                    rhex=[rhex reghex(r,:)];
                end
                got_val=got_reg(4:4+got_reg(3)-1);
                if verbose >= 2
                    fprintf(1,'kpib/readreg: register bytes (hex):\n');
                    fprintf(1,'  %c%c',rhex);
                    fprintf(1,'\n');
                    fprintf(1,'kpib/readreg: register bytes (decimal):\n');
                    fprintf(1,'  %d',got_val);
                    fprintf(1,'\n');
                end
                retval=[];
                for i=1:2:channel*2
                    retval=[retval makeDecimal(got_val(i:i+1))];
                end

            case 'writereg'  % write CHANNEL to register VALUE
                if isnumeric(channel) && abs(channel) < 32678
                    sp=makeBytes(channel);
                    reg=makeBytes(value);
                    message=[conaddr 6 reg sp];
                    crc=makeCRC(message);
                    response = watwrite(io,[message crc],verbose);
                    if response == 0 && verbose >= 2
                        fprintf(1, 'kpib/AO_800: Controller confirms write of %d to register %d\n',channel,value);
                    end

                end

            otherwise
                if verbose >= 2, fprintf(1, 'kpib/AO_800: Error, command not supported. ["%s"]\n',command); end
        end
        validInst = 1;

    % Serial communications seem to be prone to errors. This catch block repeats the command.
    % However, the latest experience suggests that closing the port exacerbates the problem.
    catch
        validInst = 1;
        % if there is an error, close the port and try again
        %kpib('close',GPIB,0,0,0,0,verbose);
        if verbose >= 1, fprintf(1, 'kpib/AO_800: WARNING serial port error at ''%s'' (%s). Retrying...\n',command,datestr(clock)); end
        pause(1);
        % flush the serial port?
        fread(io, io.BytesAvailable)
        pause(1)
        if verbose >= 1,
            fprintf(1,'             kpib(%s,%s,%s,%s,%s,%s,%d)\n',instrument,GPIB,command,num2str(value),num2str(channel),num2str(aux),verbose);
        end
%         disp(instrument)
%         disp(GPIB)
%         disp(command)
%         disp(value)
%         disp(channel)
%         disp(aux)
%         disp(verbose)
        if nargout >= 1
            retval = kpib(instrument,GPIB,command,value,channel,aux,verbose);
        elseif nargout == 0
            kpib(instrument,GPIB,command,value,channel,aux,verbose);
        end

    end % end try/catch
    
 end % end AO_800
    


%% 'HP_8560A' HP Spectrum Analyzer 50 Hz - 2.9 GHz
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% VALUE is typically the modifier to COMMAND.
% Valid Commands:
% 'init'      Resets the Analyzer and clears the error list.
% 'label'     Writes 'VALUE' to the display. 32 char max.
%             non-exponentially ('norm'). Exponentially is the default.
% 'scale'     Sets the scale of the display. VALUE is the scale in the
%             current units, or 'VALUE' = 'auto' for autoscale command. 
% 'ref line'  Sets the position of the reference line of the display.
%             VALUE is the position of the reference line in the current
%             units. Also 'reflevel'.
% 'average'   Turns averaging on or off, restarts averaging, or returns
%             the current number of averages taken.
%             VALUE='on','off','restart', or 'query'. CHANNEL= number of
%             sweeps to average.
%             For 'query', RETVAL returns 0 (off) or the current number of averages (on).
% 'mark2peak' Finds the peak and sets the marker, or finds the peak and
%             sets the peak location to the center of the scan.
%             VALUE='off','center', or 'peak'.
% 'marker'    Turns the marker on or off, sets the marker to position
%              VALUE (in Hz), or returns the current position of the
%              marker. 'VALUE' = 'on','off', or 'query'. The position is
%              returned as retval.x, retval.y in current units. Can also
%              select a marker function: VALUE = 'center', 'min', 'max'.
% 'center'    Set the center frequency to VALUE. Units of Hz.
%              Query with VALUE = 'query', returns center frequency in Hz.
% 'span'      Set the frequency span VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'start'     Set the start of the sweep range to VALUE Hz.
% 'stop'      Set the end of the sweep range to VALUE Hz.
% 'source'    Set the source (stimulus output) signal level. VALUE is the
%              desired signal level. Units of dBm.
%              Query with VALUE = 'query', returns source power in dBm.
% 'source?'   (Alternate query form) Returns source power in dBm.
% 'power'     Same as 'source'.
% 'getdata'   Download the current data trace from the analyzer. Data is
%              returned as two columns, x and y, for the specified
%              CHANNEL. Default CHANNEL is not set. If VALUE is 'x' or 'y', only
%              that data is returned in a single column.
% 'units'     Returns the units of the data from the analyzer. Must
%              specify VALUE = 'x' or 'y' axis units.
% 'pause'     Pauses measurement.
% 'continue'  Continues paused measurement.
% 'complete'  Wait for the previous sweep to complete. This command
%              contains a loop that does not exit until the status byte shows
% 'wait'      Wait for the previous command to complete (*WAI)

if (strcmpi(instrument, 'HP_8560A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case 'init' %ok
                %fprintf(io,'*RST');
                %fprintf(io,'CLEAR')
                clrdevice(io);
                fprintf(io,'ERR?;');
                err=fscanf(io,'%f,');
                %fprintf(io,'*SRE 4;ESNB 1'); % enable the registers;

            case {'label','title'}  %ok
                if length(value) > 32 % two rows of 16 each allowed
                    value=value(1:32); % 16x2 chars max
                end
                fprintf(io,'TITLE@%s@;',value);

    %             
    %         case {'display','trace'} %ok
    %             switch value
    %                 case {'data'}
    %                     fprintf(io,'DISPDATA',value);
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Display data only\n'); end
    %                 case {'memory','mem'}
    %                     fprintf(io,'DISPMEMO');
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Display memory only\n'); end
    %                 case {'both','data&memory','datamem','data+memory'}
    %                     fprintf(io,'DISPDATM');
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Display data & memory\n'); end
    %                 case {'dual'} %ok
    %                     switch channel
    %                         case {'on',1}
    %                             fprintf(io, 'DUACON');
    %                             if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display on.\n'); end
    %                         case {'off',0}
    %                             fprintf(io, 'DUACOFF');
    %                             if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display off.\n'); end
    %                         case {'query','?'} % returns 1 for dual-channel on, 0 for off
    %                             fprintf(io, 'DUAC?');
    %                             dstatebit=str2num(fscanf(io));
    %                             if dstatebit==1, dstate='on';
    %                             elseif dstatebit==0, dstate='off';
    %                             end
    %                             retval=dstatebit;
    %                             if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Dual-channel display is %s\n',dstate); end
    %                     end
    %                 case {'on',1}
    %                     fprintf(io,'BLADOFF',value);
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Screen on\n'); end
    %                 case {'off',1}
    %                     fprintf(io,'BLADON',value);
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Screen off\n'); end 
    %             end 
    %             
    %         case 'format' %
    %             switch value
    %                 case 'log mag'
    %                     fprintf(io,'LOGM');
    %                 case 'phase'
    %                     fprintf(io,'PHAS');
    %                 case 'delay'
    %                     fprintf(io,'DELA');
    %                 case 'linear mag'
    %                     fprintf(io,'LINM');
    %                 case 'polar'
    %                     fprintf(io,'POLA');
    %                 case 'real'
    %                     fprintf(io,'REAL');
    %                 otherwise
    %                     if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Set Analyzer data format to default log magnitude.\n'); end
    %                     fprintf(io,'LOGM');
    %             end

    %         case {'autoscale','auto','autoy'};
    %             if nargin > 3
    %                 switch value
    %                     case 'off'
    %                         % DNE
    %                     case 'once'
    %                         if nargin > 4
    %                             if channel == 0 % autoscale current channel
    %                                 fprintf(io,'AUTO');
    %                                 if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale current channel\n'); end
    %                             else
    %                                 fprintf(io,'CHAN%d',channel);
    %                                 fprintf(io,'AUTO');
    %                                 if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale channel %d\n',channel); end
    %                             end
    %                         else
    %                             fprintf(io, 'DISP:TRAC:Y:AUTO ONCE');
    %                             if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale Y Once Channel 1 (default channel)\n'); end
    %                         end
    %                     case 'both' % specific to resonators - autoscale channels 1 & 2
    %                         fprintf(io,'CHAN1'); fprintf(io,'AUTO');
    %                         fprintf(io,'CHAN2'); fprintf(io,'AUTO');
    %                         fprintf(io,'CHAN1');
    %                         if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale channels 1 & 2\n'); end
    %                                                 
    %                     otherwise
    %                         if isnumeric(value) & value == (1 | 2 | 3 | 4)
    %                             fprintf(io,'CHAN%d',channel);
    %                             fprintf(io,'AUTO');
    %                             if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale channel %d\n',channel); end
    %                         else
    %                             fprintf(io,'AUTO');
    %                             if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Autoscale Y current channel (default)\n'); end
    %                         end
    %                  end
    %              else
    %                  fprintf(io, 'DISP:TRAC:Y:AUTO ONCE');
    %                  if verbose >=2, fprintf(1, 'kpib/HP_8753ES: Auto Scale Y default: Once\n'); end
    %             end

            case 'scale' %ok
                if isnumeric(value)
                    fprintf(io,'LG %fDB',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Scale of current channel set to %g dB/div.\n',value); end
    %             elseif isequal(value,'auto')
    %                 fprintf(io,'AUTO');
    %                 if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Autoscale current channel.\n'); end
                end

            case {'ref line','reflevel'} %ok
                fprintf(io,'RL %fDBM',value);
                if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Reference value set to %g dBm.\n',value); end

            case {'average','averaging'} %ok
                switch value
                    case {'on'}
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Averaging on'); end
                        if isnumeric(channel) && channel > 0
                            fprintf(io,'VAVG %f',channel);
                            if verbose >= 2, fprintf(1, ', aver. factor %d.\n',channel); end
                        else
                            fprintf(io,'VAVG ON');
                            if verbose >= 2, fprintf(1,'.\n'); end
                        end
                    case {'off'};
                        fprintf(io,'VAVG OFF');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Averaging off.\n'); end
                    case {'num','number','count'}
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Warning: Average Count not available on 8560A\n'); end
                    case{'restart','Restart'}
                        fprintf(io,'AVERREST');
                    case {'query','?'}
                        fprintf(io,'VAVG?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Averaging factor is: %g\n', retval); end
                    otherwise % set the number of measurements to average
                        if isnumeric(value) && value > 0
                            fprintf(io,'VAVG %F',channel);
                            if verbose >=2, fprintf(1, 'kpib/HP_8560A: Averaging factor set to: %d\n',value); end
                        end
                end

            case {'marker'} %ok
                if isnumeric(value) % move marker to that point
                    cmd=sprintf('MKF %fHZ',value);
                    fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Marker set to %f Hz\n',value); end
                else
                    switch value
                        case 'on' % there is no "marker on", we have to give a frequency
                            fprintf(io,'CF?');
                            cf=fscanf(io,'%f');
                            fprintf(io,'MKF %fHZ',cf);
                            if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Marker ON\n'); end
                        case 'off'
                            fprintf(io,'MKOFF');
                            if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Marker OFF\n'); end
                        case {'query','?'} % query the marker position
                            switch aux
                                case {'x','X'}
                                    fprintf(io,'MKF?');
                                    retval = fscanf(io,'%f');
                                    if verbose >= 2, fprintf(1,'kpib/HP_8560A: Marker position: %g Hz\n',retval); end
                                case {'y','Y'}
                                    fprintf(io,'MKA?');
                                    retval = fscanf(io,'%f');
                                    if verbose >= 2, fprintf(1,'kpib/HP_8560A: Marker position: %g\n',retval); end
                                otherwise
                                    fprintf(io,'MKF?');
                                    retval.x = fscanf(io,'%f');                                    
                                    fprintf(io,'MKA?');
                                    retval.y = fscanf(io,'%f');
                                    if verbose >= 2, fprintf(1,'kpib/HP_8560A: Marker position: %g Hz/%g\n',retval.x,retval.y); end
                            end
                        case {'center','m2c','mark2center'} % make the marker position the center freq
                            fprintf(io,'MKCF');
                            if verbose >= 2, fprintf(1,'kpib/HP_8560A: Marker to Center\n'); end
                        case {'peak','searchpeak','mark2peak','max'}
                            fprintf(io,'MKPK HI');                        
                            if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Marker to Peak (max)'); end
                        case {'min','valley'}
                            fprintf(io,'MKMIN');                        
                            if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Marker to Valley (min)'); end
                        otherwise
                            if verbose >= 1, fprintf(1, 'kpib/HP_8560A: Error at ''marker'' command (VALUE incorrect ["%s"]).\n',value); end
                    end
                end

            case {'mark2peak','m2p','findpeak'} %ok
                switch value
                    case 'off'
                        fprintf(io,'MKTRACK OFF');
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Marker Search Off'); end
                    case 'center'
                        fprintf(io,'MKPK HI;MKCF');
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Peak (max) to Center'); end
                    case {'peak','max'}
                        fprintf(io,'MKPK HI;MKTRACK ON');
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Marker to Peak (max)'); end
    %                 case 'min'
    %                      if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8753ES: Marker to minimum'); end
    %                     fprintf(io,'SEAMIN');                   
                    otherwise
                        fprintf(io,'MKPK HI');
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Marker to Max (default)'); end
                end

            case {'peaktrack'} %ok
                switch value
                    case {'on',1}
                        fprintf(io,'MKPK HI;MKTRACK ON');
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Marker Peak Tracking ON'); end
                    case {'off',0}
                        fprintf(io,'MKTRACK OFF');
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: Marker Peak Tracking OFF'); end
                    otherwise
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_8560A: ERROR: do you want Peak Tracking on or off?'); end
                end
    % 
    %         case 'sweep' %
    %             % enable the status registers for synchronization
    %             fprintf(io,'CLES'); % clear the status registers
    %             fprintf(io,'*SRE 4;ESNB 1'); % enable the registers;
    %             
    %             if isnumeric(value) % set the sweep time
    %                 fprintf(io,'SWET%d',value);
    %             else
    %                 switch value
    %                     case {'auto','AUTO'}
    %                         fprintf(io,'SWEA');
    %                     case {'linear freq'}
    %                         fprintf(io,'LINFREQ');
    %                     case {'list freq'}
    %                         fprintf(io,'LISFREQ');
    %                     case {'log freq'}
    %                         fprintf(io,'LOGFREQ');
    %                     case {'power sweep'}
    %                         fprintf(io,'POWS');
    %                     case {'single','sing','SING'}
    %                         fprintf(io,'SING');
    %                     case {'continuous','cont','CONT'}
    %                         fprintf(io,'CONT');
    %                     case {'group','groups','number','N'}
    %                         if isnumeric(channel) & channel >= 1 & channel <= 999
    %                             fprintf(io,'NUMG%d',channel);
    %                         else
    %                             if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Sweep Error: Number or sweeps must be between 1 and 999.\n'); end
    %                         end
    %                     case {'points','numpoints','setpoints'}
    %                         if isnumeric(channel) & channel >= 2 & channel <= 801
    %                             fprintf(io,'POIN%i',channel);
    %                         else
    %                             if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Sweep Error: Number of points must be between 2 and 801.\n'); end
    %                         end
    %                     otherwise
    %                         if verbose >= 1, fprintf(1, 'kpib/HP_8753ES: Sweep command not supported ["%s"]\n',value); end
    %                 end
    %             end

            case 'center' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'CF?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'CF %fHZ',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Center set to %f Hz\n',value); end
                end

            case 'span' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'SP?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'SP %fHZ',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Span set to %g Hz\n',value); end
                end

            case 'start' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'FA?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'FA %fHZ',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Start set to %g Hz\n',value); end
                end

            case 'stop' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'FB?');
                        retval = fscanf(io,'%f');
                    otherwise
                        fprintf(io,'FB %fHZ',value);
                        if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Stop set to %g Hz\n',value); end
                end

            case {'power','source'} %ok
                if isnumeric(value) && value >= -10 && value <= 2.8
                    fprintf(io,'SRCPWR %fDBM',value);
                    if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Source Power set to %g dBm\n',value); end
                else
                    switch value
                        case {'query','?'}
                            fprintf(io,'SRCPWR?');
                            retval = fscanf(io,'%f');
                            if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Source Power is %d dBm\n',retval); end
                        case {'on','ON'}
                            fprintf(io,'SRCPWR ON');
                            if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Source Power ON\n'); end
                        case {'off','OFF'}
                            fprintf(io,'SRCPWR OFF');
                            if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Source Power OFF\n'); end
                    end
                end

            case {'power?','source?'} %ok
                fprintf(io,'SRCPWR?');
                retval.level = fscanf(io,'%f');
                if verbose >= 2, fprintf(1, 'kpib/HP_8560A: Source Power: %g dBm\n',retval.level); end
                retval.state='unknown'; % no query for state

    %         case 'bandwidth'
    %             if isnumeric(value)
    %                 fprintf(io,'BW %d',value);
    %             elseif isequal(value,'auto')
    %                 if isequal(channel,'on') | isequal(channel,'off')
    %                     fprintf(io,'BWAUTO %s',channel);
    %                 end
    %             elseif isequal(value,'limit')
    %                 if isnumeric(channel)
    %                     fprintf(io,'BWLMT%d',channel);
    %                 else
    %                     if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: A numeric value must be entered for channel.\n'); end
    %                 end
    %             end

    %         case 'trigger'
    %             switch value
    %                 case 'internal'
    %                     fprintf(io,'TRGS INT');
    %                 case 'external'
    %                     fprintf(io,'TRGS EXT');
    %                 case 'GPIB'
    %                     fprintf(io,'TRGS BUS');
    %                 case 'video'
    %                     fprintf(io,'TRGS VID');
    %                 case 'manual'
    %                     fprintf(io,'TRGS MAN');
    %                 case 'ext gate'
    %                     fprintf(io,'TRGS GAT');
    %                 otherwise
    %                     if isequal(value,'int') | isequal(value,'ext') | isequal(value,'vid') | isequal(value,'man') | isequal(value,'gat') | isequal(value,'bus')
    %                         fprintf(io,'TRGS %s',value);
    %                     else
    %                         if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Not a valid trigger.\n'); end
    %                     end
    %             end

            case {'getdata'}
                % use real numbers (aka "parameters')
                % Returns comma-delimited string, 601 points
                %  no comma at the end of the string makes format matching
                %    annoying
                % Y-values only
                fprintf(io, 'TDF P;TRA?');
                ydata = fscanf(io);
                ydata=[ydata ',']; % add a comma at the end for matching
                retval.y=sscanf(ydata,'%f,');
                numdatapoints = length(retval.y);
                %retval.y=data
                if numdatapoints == 0
                    if verbose >= 1, fprintf('kpib/HP_8560A: ERROR: Data download error (0 points).\n'); end
                else
                    if verbose >= 2, fprintf('kpib/HP_8560A: Data downloaded (%d points).\n',numdatapoints); end
                end
                % Now we must infer the X values
                %numdatapoints = 601;
                fprintf(io,'CF?');
                center = fscanf(io,'%f');
                %center = str2num(center);
                fprintf(io,'SP?');
                span = fscanf(io,'%f');
                %span = str2num(span);
                start = center - span/2;
                delta = span/(numdatapoints-1);
                retval.x=([0:1:numdatapoints-1]*delta)'+start;

                % get the units
                retval.units.x = 'Hz'; % X is always in Hz, as far as I know
                % the units for Y amplitude depend on the Format
                fprintf(io,'AUNITS?');
                rd = fscanf(io);
                retval.units.y = rd(1:end-1); % strip trailing LF
                if strcmpi(retval.units.y,'DBM')
                    retval.units.y = 'dBm';
                end
                if verbose >= 2, fprintf('kpib/HP_8560A: Y units are %s.\n',retval.units.y); end


            case 'units' %ok
                % See the manual p1-82 (Table 1-4) for units
                %  query the display format, and then assume the units
                switch value
                    case {'x','X'}
                        % the units for X are always Hz
                         retval='Hz';
                         if verbose >= 2, fprintf('kpib/HP_8560A: X units are %s\n',retval); end
                    case {'y','Y'}
                        fprintf(io,'AUNITS?');
                        rd = fscanf(io);
                        retval = rd(1:end-1); % strip trailing LF
                        if verbose >= 2, fprintf('kpib/HP_8560A: Y units are %s\n',retval); end
                    otherwise
                        retval.units.x='Hz';
                        fprintf(io,'AUNITS?');
                        rd = fscanf(io);
                        retval.units.y = rd(1:end-1); % strip trailing LF
                        if verbose >= 2, fprintf('kpib/HP_8560A: Units are %s/%s\n',retval.units.x,retval.units.y); end
                end

    %         case 'pause' %
    %             if isequal(value,'query')
    %                 fprintf(io,'HOLD?');
    %                 retval = fscanf(io);
    %             else
    %                 fprintf(io,'HD');
    %                 if verbose >= 2, fprintf('kpib/HP_8753ES: Measurement paused.\n'); end
    %             end

            case {'continue','cont'} %ok
                fprintf(io,'CONTS');
                if verbose >= 2, fprintf('kpib/HP_8560A: Measurement continue.\n'); end

            case 'complete' %ok
                % the DONE command waits for the previous action to finish

                % can issue a single command for a sweep and complete
%                 if nargin > 3 
                    switch value
                        case {'single','sing','SING'}
                            if verbose >= 2, fprintf('kpib/HP_8560A: Single Sweep & Complete:\n'); end
                            fprintf(io,'SINGS; TS; DONE?');
                            if verbose >= 2, fprintf('kpib/HP_8560A:   Sweep... '); end
                            stat=0;
                            while ~stat % wait for sweep to complete
                                stat=fread(io);
                                pause(1);
                            end
                            if verbose >= 2, fprintf('Complete\n'); end
                    end
%                 end
                % or just a single command
                fprintf(io,'DONE?');
                if verbose >= 2, fprintf('kpib/HP_8560A: Waiting for command to complete...'); end
                stat=0;
                while ~stat % wait for sweep to complete
                    stat=fread(io);
                    pause(1);
                end
                if verbose >= 2, fprintf('Done.\n'); end
                retval=stat;
                %warning off instrument:fscanf:unsuccessfulRead

    %             retval=0; while 1
    %                  pause(1);
    %                  fprintf(io,'ESB?'); % check the status byte
    %                  retval=str2num(fscanf(io,'%+f'));
    %                  esb=dec2bin(retval); % return binary value represents the status registers
    %                  if esb(end) == '1' % indicates sweep complete
    %                      if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Sweep complete.\n'); end
    %                      break;
    %                  end
    %                  if length(esb) > 6
    %                      if esb(end-6) == '1' % indicates "Target not found"
    %                          if verbose >= 2, fprintf(1, 'kpib/HP_8753ES: Analyzer reports: "Target not Found".\n'); end
    %                      end
    %                  end
    %              end
    % 
    % %            disp('END OF ESB')


            case 'wait'  %ok
                warning off instrument:fscanf:unsuccessfulRead
                fprintf(io,'DONE?');
                if verbose >= 2, fprintf('kpib/HP_8560A: Waiting for command to complete...'); end
                stat=fread(io);
                while ~stat % wait for sweep to complete
                    pause(1);
                    stat=fread(io);
                end
                retval=stat;
                if verbose >= 2, fprintf('Done.\n'); end

            otherwise
                if verbose >= 1, fprintf('kpib/HP_8560A: Error, command not supported. ["%s"]\n',command); end


        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end

    validInst=1;
 end % end HP_8560A


%% 'HP_4284A' HP LCR Meter
%   Contributed by Robert Hennessey
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid  commands:
%'freq'     sets the oscillator frequency. the frequncy is 20 Hz to 1 MHz.
%           Frequencies outside of that range will be clipped.
%'volt'     sets the oscillator's output voltage. min voltage is 5 mV, max
%           voltage is 2V (high power mode is off), 20V (high power mode is
%           on). If needed, turns on high power.
%'curr'     sets the oscillator's output current. min current is 50uA. max
%           current is 20mA (high power mode is off) and 200mA (high power
%           mode is on). Note: max turns ALC off. If needed, turns on high
%           power.
%'ALCON'    used to turn the automatic level control on
%'ALCOFF'   used to turn the automatic level control off
%'HPOWON'   High power turned off
%'HPOWOFF'  High power is turned off
%'BIASON'   Turns the bias on. Note: the bias is turned off when the device
%           is given *RST. The bias is also turned off when control
%           settings are loaded from memory
%'BIASOFF'  Turns the bias off
%'VDC'      sets the dc bias voltage. Must call BIASON to turn on the bias
%           voltage. min = 0V max = 2V (high power mode is off) or 40V
%           (high power mode is on)
%'IDC'      sets the dc bias current. Must call BIASON to turn on the bias
%           current. min = 0A max = 100mA (high power mode is on) Note:
%           Applying IDC will reduce the voltage seen by the DUT (see 9-24
%           pg. 366 of the user manual)
%'IMP'      sets the measurement function. The type of functions are
%           CPD Sets function to Cp-D      LPRP Sets function to Lp-Rp
%           CPQ Sets function to Cp-Q      LSD Sets function to Ls-D
%           CPG Sets function to Cp-G      LSQ Sets function to Ls-Q
%           CPRP Sets function to Cp-Rp    LSRS Sets function to Ls-Rs
%           CSD Sets function to Cs-D      RX Sets function to R-X
%           CSQ Sets function to Cs-Q      ZTD Sets function to Z-theta (deg)
%           CSRS Sets function to Cs-Rs    ZTR Sets function to Z-theta (rad)
%           LPQ Sets function to Lp-Q      GB Sets function to G-B
%           LPD Sets function to Lp-D      YTD Sets function to Y-theta (deg)
%           LPG Sets function to Lp-G      YTR Sets function to Y-theta (rad)
%'IMPAUTO'  turns on or off the auto range. The auto range should be turned
%           on for almost all measurements
%'TRIG'     causes the trigger to execute a measurement or a sweep
%           meaurement
%'INITCONT' If set to on, the idle state is automatically set to wait for
%           trigger. To start taking measurements, 'TRIG' command needs to
%           be used after this command.
%'FETCH'    retrieves the measurement data taken by measurements initiated
%           by a trigger, and places the data into the output buffer.
%           Also 'read' or 'getdata'.
%'FORMAT'   sets the data output formats. value = ASCII or REAL (uses
%           floating point to represent the data)
%'TRIGSOURCE'   sets the trigger mode. The bus mode will probably be used
%               in most instances. values = INT, EXT, BUS, HOLD
%'ERROR'    Returns the error number and error message. 

if (strcmpi(instrument, 'HP_4284A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        switch command
            case {'f', 'freq', 'frequency'}
                if(value<20)
                    fprintf(io,'FREQ MIN')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: Frequency clipped to min (20 Hz) \n')
                    end
                elseif(value>1e6)
                    fprintf(io,'FREQ MAX')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: Frequency clipped to max (1 MHz) \n')
                    end
                else
                    fprintf(io,'FREQ %f',value)
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: Frequency set to %f Hz \n',value)
                    end
                end
            case {'V', 'volt', 'voltage'}
                if(value<5e-3)
                    fprintf(io,'VOLT MIN')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: Voltage clipped to min (5 mV) \n')
                    end
                elseif(value >= 5e-3 && value <=2)
                    fprintf(io,'VOLT %f', value)
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: Voltage set to %f V \n', value)
                    end
                elseif(value >2 && value <=20)
                    fprintf(io,'Outp:HPOW ON')
                    fprintf(io,'VOLT %f', value)
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: High power turned on \n')
                        fprintf('kpib/HP_4284A: Voltage set to %f V \n', value)
                    end
                else
                    fprintf(io,'Outp:HPOW ON')
                    fprintf(io,'VOLT MAX')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: High power turned on \n')
                        fprintf('kpib/HP_4284A: Voltage clipped to Max (20V) \n')
                    end
                end
            case{'I','curr','current'}
                if(value<50e-6)
                    fprintf(io,'CURR MIN')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: Current clipped to min (50 uA) \n')
                    end
                elseif(value >= 50e-6 && value <=20e-3)
                    fprintf(io,'CURR %f', value)
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: Current set to %f A \n', value)
                    end
                elseif(value >20e-3 && value <=200e-3)
                    fprintf(io,'Outp:HPOW ON')
                    fprintf(io,'CURR %f', value)
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: High power turned on \n')
                        fprintf('kpib/HP_4284A: Current set to %f A \n', value)
                    end
                else
                    fprintf(io,'Outp:HPOW ON')
                    fprintf(io,'CURR MAX')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: High power turned on \n')
                        fprintf('kpib/HP_4284A: Voltage clipped to Max (200 mA) \n')
                    end
                end
            case 'ALCON'
                fprintf(io,'AMPL:ALC ON')
                if verbose >= 2
                    fprintf('kpib/HP_4284A: Automated Level Control turned on \n')
                end
            case 'ALCOFF'
                fprintf(io,'AMPL:ALC OFF')
                if verbose >= 2
                    fprintf('kpib/HP_4284A: Automated Level Control turned off \n')
                end
            case 'HPOWON'
                fprintf(io,'OUTP:HPOW ON')
                if verbose >= 2
                    fprintf('kpib/HP_4284A: High Power turned on \n')
                end
            case 'HPOWOFF'
                fprintf(io,'OUTP:HPOW OFF')
                if verbose >= 2
                    fprintf('kpib/HP_4284A: High Power turned off \n')
                end
            case 'BIASON'
                fprintf(io,'BIAS:STAT ON')
                if verbose >= 2
                    fprintf('kpib/HP_4284A: Bias turned on \n')
                end
            case 'BIASOFF'
                fprintf(io,'BIAS:STAT OFF')
                if verbose >= 2
                    fprintf('kpib/HP_4284A: Bias turned off \n')
                end
            case 'VDC'
                if(value < 0)
                    fprintf(io,'BIAS:VOLT MIN')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: VDC clipped at min (0V) \n')
                    end
                elseif(value >=0 && value <= 2)
                    fprintf(io,'BIAS:VOLT %f',value)
                    if verbose >= 2
                        fprintf('kpib/HP_4284A: VDC set at %f V \n', value)
                    end
                elseif(value >2 && value <= 40)
                    fprintf(io,'Outp:HPOW ON')
                    fprintf(io,'BIAS:VOLT %f',value)
                    if verbose >= 2
                        fprintf('kpib/HP_4284A:High Power turned on\n')
                        fprintf('kpib/HP_4284A: VDC set at %f V \n', value)
                    end
                else
                    fprintf(io,'Outp:HPOW ON')
                    fprintf(io,'BIAS:VOLT MAX')
                    if verbose >= 2
                        fprintf('kpib/HP_4284A:High Power turned on\n')
                        fprintf('kpib/HP_4284A: VDC clipped at max (40 V) \n')
                    end
                end
            case 'IDC'
                fprintf(io,'BIAS:CURR %f', value);
                if verbose >= 2
                    fprintf('kpib/HP_4284A: IDC set to %f \n', value)
                end
            case 'IMP'
                SupVals = 'CPD CPQ CPG CPRP CSD CSQ CSRS LPQ LPD LPG LPRP LSD LSQ LSRS RX ZTD ZTR GB YTD YTR';
                if(isempty(findstr(SupVals,value)))
                    if(verbose >= 2)
                        fprintf('kpib/HP_4284A: Typo in call to IMP. check %s \n', value);
                    end
                else
                    fprintf(io,'FUNC:IMP %s', value);
                    if(verbose >= 2)
                        fprintf('kpib/HP_4284A: Measurement function is set to %s \n', value);
                    end
                end
            case 'IMPAUTO'
                switch(value)
                    case {'on', 'ON'}
                        fprintf(io,'FUNC:IMP:RANG:AUTO ON');
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Impedence auto range turned on \n');
                        end
                    case {'off', 'OFF'}
                        fprintf(io,'FUNC:IMP:RANG:AUTO OFF');
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Impedence auto range turned off \n');
                        end
                    otherwise
                        if(verbose >= 1)
                            fprintf('kpib/HP_4284A: Error using impedence auto range. value = on or off \n');
                        end
                end
            case {'trig','TRIG','trigger'}
                fprintf(io,'TRIG:IMM');
                if(verbose >= 2)
                    fprintf('kpib/HP_4284A: Triggered measurement\n');
                end
            case 'INITCONT'
                switch(value)
                    case{'on', 'ON'}
                        fprintf(io,'INIT:CONT ON');
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Trigger continuous mode turned on \n');
                        end
                    case{'OFF', 'off'}
                        fprintf(io,'INIT:CONT OFF');
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Trigger continuous mode turned off \n');
                        end
                    otherwise
                        if(verbose >= 1)
                            fprintf('kpib/HP_4284A: Error using trigger continuous mode. value = on or off \n');
                        end
                end
            case {'FETCH','read','getdata'}
                fprintf(io,'FORM?');
                ASCIION = strcmp(fscanf(io,'%s'),'ASC');
                fprintf(io,'FETC?');
                if(ASCIION)
                    [t1 count]=fscanf(io,'%s');
                    %the following code assumes that the output mode is ascii
                    %one data point
                    if(length(t1) < 29 || t1(29)~=',')
                        retval.meas1=str2num(t1(1:12));
                        retval.meas2=str2num(t1(14:25));
                        retval.status=str2num(t1(27:28));
                        retval.binNumb=str2num(t1(29:length(t1)));
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Fetching data \n');
                            fprintf('kpib/HP_4284A: meas1= ');
                            fprintf('%d ',retval.meas1);
                            fprintf('\nkpib/HP_4284A: meas2= ');
                            fprintf('%d ',retval.meas2);
                            fprintf('\nkpib/HP_4284A: status= ');
                            fprintf('%d ',retval.status);
                            fprintf('\nkpib/HP_4284A: binNumb= ');
                            fprintf('%d ',retval.binNumb);
                            fprintf('\n');
                        end
                        %more than one data point
                    else
                        conString = str2num(t1);
                        lenConString = length(conString);
                        retval.meas1=conString(1:4:lenConString);
                        retval.meas2=conString(2:4:lenConString);
                        retval.status=conString(3:4:lenConString);
                        retval.InOut=conString(4:4:lenConString);
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Fetching data \n');
                            fprintf('kpib/HP_4284A: meas1= ');
                            fprintf('%d ',retval.meas1);
                            fprintf('\nkpib/HP_4284A: meas2= ');
                            fprintf('%d ',retval.meas2);
                            fprintf('\nkpib/HP_4284A: status= ');
                            fprintf('%d ',retval.status);
                            fprintf('\nkpib/HP_4284A: InOut= ');
                            fprintf('%d ',retval.InOut);
                            fprintf('\n');
                        end
                    end
                else
                    %bit format
                    header=char(fread(io,1,'char'));
                    NumbHeader=str2num(char(fread(io,1,'char')));
                    numberBytes=str2num((char(fread(io,NumbHeader,'char')))');
    %                 NumbHeader=fread(io,1,'int8')
    %                 numberBytes=0;
    %                 for i=1:1:NumbHeader
    %                     numberBytes=10*numberBytes+fread(io,1,'int8')
    %                 end
                    if(numberBytes<=25) % 1 data point
                        %test
                        retval.meas1=BitToFloat(fread(io,8,'char'));
                        retval.meas2=BitToFloat(fread(io,8,'char'));
                        retval.status=fread(io,1,'double');
                        fread(io,2,'char'); %remove the ending 0 and new line
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Fetching data Float Mode\n');
                            fprintf('kpib/HP_4284A: meas1= ');
                            fprintf('%d ',retval.meas1);
                            fprintf('\nkpib/HP_4284A: meas2= ');
                            fprintf('%d ',retval.meas2);
                            fprintf('\nkpib/HP_4284A: status= ');
                            fprintf('%d ',retval.status);
                            fprintf('\n');
                        end
                    elseif(numberBytes>25 && numberBytes<=33)
                        retval.meas1=BitToFloat(fread(io,8,'char'));
                        retval.meas2=BitToFloat(fread(io,8,'char'));
                        retval.status=fread(io,1,'double');
                        retval.binNumb=fread(io,1,'double');
                        fread(io,2,'char'); %remove the ending 0 and new line
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Fetching data \n');
                            fprintf('kpib/HP_4284A: meas1= ');
                            fprintf('%d ',retval.meas1);
                            fprintf('\nkpib/HP_4284A: meas2= ');
                            fprintf('%d ',retval.meas2);
                            fprintf('\nkpib/HP_4284A: status= ');
                            fprintf('%d ',retval.status);
                            fprintf('\nkpib/HP_4284A: binNumb= ');
                            fprintf('%d ',retval.binNumb);
                            fprintf('\n');
                        end
                    else %more than 1 datapoint. read in one byte at a time.
                        for i=1:1:(numberBytes/24)
                            retval.meas1(i)=BitToFloat(fread(io,8,'char'));
                            retval.meas2(i)=BitToFloat(fread(io,8,'char'));
                            retval.status(i)=fread(io,1,'double');
                            retval.InOut(i)=fread(io,1,'double');
                        end
                        if(verbose >= 2)
                            fprintf('kpib/HP_4284A: Fetching data \n');
                            fprintf('kpib/HP_4284A: meas1= ');
                            fprintf('%d ',retval.meas1);
                            fprintf('\nkpib/HP_4284A: meas2= ');
                            fprintf('%d ',retval.meas2);
                            fprintf('\nkpib/HP_4284A: status= ');
                            fprintf('%d ',retval.status);
                            fprintf('\nkpib/HP_4284A: InOut= ');
                            fprintf('%d ',retval.InOut);
                            fprintf('\n');
                        end
                    end
                end
            case {'format','FORMAT','fmt'}
                switch(value)
                    case {'ASCII', 'ascii'}
                        fprintf(io,'FORM ASC')
                        if(verbose>=2)
                            fprintf('kpib/HP_4284A: Output format set to ASCII\n');
                        end
                    case {'REAL', 'real'}
                        fprintf(io,'FORM REAL')
                        if(verbose>=2)
                            fprintf('kpib/HP_4284A: Output format set to REAL\n');
                        end
                    otherwise
                        if(verbose>=1)
                            fprintf('kpib/HP_4284A: Error setting output format. value = ASCII or REAL\n');
                        end
                end
            case 'TRIGSOURCE'
                switch(value)
                    case {'bus','BUS'}
                        fprintf(io,'TRIG:SOUR BUS')
                        if(verbose>=2)
                            fprintf('kpib/HP_4284A: Trigger set to bus mode\n');
                        end
                    case {'EXT','ext'}
                        fprintf(io,'TRIG:SOUR EXT')
                        if(verbose>=2)
                            fprintf('kpib/HP_4284A: Trigger set to external mode\n');
                        end
                    case {'int','INT'}
                        fprintf(io,'TRIG:SOUR INT')
                        if(verbose>=2)
                            fprintf('kpib/HP_4284A: Trigger set to internal mode\n');
                        end
                    case {'hold','HOLD'}
                        fprintf(io,'TRIG:SOUR HOLD')
                        if(verbose>=2)
                            fprintf('kpib/HP_4284A: Trigger set to hold mode\n');
                        end
                    otherwise
                        if(verbose>=1)
                            fprintf('kpib/HP_4284A: Error setting trigger mode\n');
                        end
                end
            case {'error','ERROR'}
                fprintf(io,'SYST:ERR?');
                %pause(1)
                ind=1;
                numbChar = fread(io,1,'char');
                while(numbChar ~= 44) %44=ascii code for ,
                    numbStr(ind)=char(numbChar);
                    ind=ind+1;
                    numbChar = fread(io,1,'char');
                end
                errorNum=str2num(numbStr);
                %get rid of the first "
                numbChar = fread(io,1,'char');
                ind=1;
                numbChar = fread(io,1,'char');
                while(numbChar ~= 34) %34 = ascii code for "
                    errStr(ind)=char(numbChar);
                    ind=ind+1;
                    numbChar = fread(io,1,'char');
                end
                fread(io,1,'char'); %remove the end of line character
                retval=errorNum; %retval=0 if no error has occured
                if(verbose>=1)
                    fprintf('kpib/HP_4284A: %d, %s\n',errorNum,errStr);
                end
            case {'*rst','reset'}
                fprintf(io,'*RST')
                
            otherwise
                if verbose >= 1, fprintf(1, 'kpib/HP_4284A: Error, command not supported. ["%s"]\n',command); end
            % %%

        end

    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
    end

    validInst = 1;
end % end HP_4284A


%% 'HP_3499B' Multiplexer
%   Contributed by Renata Melamud
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
%
% Note: When calling kpib with this instrument, refer below to command
%       specific meaning of value and channel.
% 
% Valid Commands:
% 'init'        Sends the *RST command to reset instrument. Clears Errors. 
%               Does a self test to make sure device passes. Returns 0 if 
%               device passes or other errors described p.172 of manual. 
% 'funcmode'    Sets the mode of the MUX for a particular slot (channel)
%               VALUE = slot #
%               CHANNEL = mode #
%               mode #1: 80 channel, 1 wire MUX
%               mode #2: 40 channel, 2 wire MUX
%               mode #3: two 20 channel 2 wire MUX
%               mode #4: 20 channel 4 wire MUX
% 'monitor' Turns on the monitor channel functionality on the MUX front display
%               VALUE = slot #
% 'clearerr' Clears any errors
% 'close'   Close a channel in the specified slot (i.e. close switch)
%               VALUE = slot #
%               CHANNEL = channel # or array of channel #
% 'open'    Open a channel in the specified slot (i.e. open switch)
%               VALUE = slot #
%               CHANNEL = channel # or array of channel #
% 'reset'   Open all channels in the specified slot
%               VALUE = slot #
if (strcmpi(instrument, 'HP_3499B') || strcmpi(instrument, 'AG_3499B') || strcmpi(instrument, 'all'))
   baudrate = 0;  % buffer size for GPIB (0 for default), baud rate for serial port instruments
   io = port(GPIB, instrument, baudrate, verbose);
   if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
       
       switch command
           case 'init'
               fprintf(io, '*RST');             % reset instrument
               fprintf(io, '*CLS');             % clear any errors
               fprintf(io, '*TST?');            % self test
               retval = fscanf(io);             % result of self test 
               if str2num(retval)               %RETVAL != 0 if failed
                   fprintf(1, 'kpib/%s: MUX did not pass self test (code %s).\n',instrument,str2num(retval)); 
               end
               if verbose >= 1, fprintf(1, 'kpib/%s: Initialization passed.\n',instrument); end
 
           case 'funcmode'
              fprintf(io, 'ROUT:FUNC %d,%d',[value channel]);
              switch channel
                  case 1
                      modetype = '(1) 80 channel, 1 wire MUX';
                  case 2
                      modetype = '(2) 40 channel, 2 wire MUX';
                  case 3
                      modetype = '(3) two 20 channel 2 wire MUX';
                  case 4
                      modetype = '(4) 20 channel 4 wire MUX';
                  otherwise
                      fprintf(1, 'HP_3499B does not recognize this funcmode (1-4 only)');
                      return;
              end
              if verbose >= 2, fprintf(1, 'kpib/%s: Mode on slot %d is set to %s.\n',instrument, value, modetype); end
               
           case 'monitor'
               if isnumeric(value)
                   fprintf(io, 'DIAG:MON %d', value);
                   if verbose >= 2, fprintf(1, 'kpib/%s: Monitoring is turned on.\n',instrument); end
               else
                   fprintf(1, 'kpib/%s: Monitoring requires slot #\n',instrument);
               end
                   
           case 'clearerr'
               fprintf(io, '*CLS');
              if verbose >= 2, fprintf(1, 'kpib/%s: All errors cleared.\n',instrument); end
           
           case 'close'
               if length(channel)>1
                   % close multiple channels given in array channel
                   mychannels = sprintf('%d,',value*100+channel);
                   fprintf(io, 'ROUT:CLOS (@%s)', mychannels); 
                   if verbose >= 2, fprintf(1, 'kpib/%s: Closing channels (%s).\n',instrument, mychannels); end
               else
                    % close just one channel
                    fprintf(io, 'ROUT:CLOSE (@%d)', value*100+channel);
                    if verbose >= 2, fprintf(1, 'kpib/%s: Closing channels (%d).\n',instrument, value*100+channel); end
               end
              
           case 'open'
               if length(channel) >1
                   % open multiple channels given in array channel
                   mychannels = sprintf('%d,',value*100+channel);
                   fprintf(io, 'ROUT:OPEN (@%s)', mychannels);
                   if verbose >= 2, fprintf(1, 'kpib/%s: Opening channels (%s).\n',instrument, mychannels); end
               else
                    % close just one channel
                    fprintf(io, 'ROUT:OPEN (@%d)', value*100+channel);
                    if verbose >= 2, fprintf(1, 'kpib/%s: Opening channels (%d).\n',instrument, value*100+channel); end
               end
              

           case 'slotreset'
               fprintf(io, 'SYST:CPON %d', value);
              if verbose >= 2, fprintf(1, 'kpib/%s: Open all channels in slot %d.\n',instrument,value); end
 
           case 'hardreset'
               fprintf(io, '*RST');
              if verbose >= 2, fprintf(1, 'kpib/%s: Reset instrument %d.\n',instrument,value); end

           otherwise
               if verbose >= 1, fprintf(1,'kpib/INSTRUMENT: Error, command not supported. ["%s"]\n',command); end
       end
               
   else % catch incorrect address errors
      if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
   end
   validInst = 1;
end % End HP_3499B



%% 'NP_3150' Newport Temperature Controller Model 3150
%   Contributed by Hyungkyu Lee
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
%
% Note: When call to kpib with this instrument, refer below to command
% specific meaning of value and channel.
% 
%
% 'init'    initialize instrument, and display current setting of the
%           controller
%
% 'read'    read various values.
%           'output'    : output status( on/off )
%           'sensor'    : sensor type (RTD,AD590 etc..)
%           'mode'      : control mode ( ITE, R and T )
%           'T'         : current temperature
%           'setT'      : set temperature
%           'highT'     : high temperature limit
%           'lowT'      : low temperature limit
%           'maxI'      : maximum current thru TEC
%           'gain'      : gain for controller
%           'tol'       : tolerance and time window
%           'cond'      : condition of TEC
%           'fin'       : operation completed
%            
% 'set'     set various values.
%           'output'    : output status( on/off )
%           'sensor'    : sensor type (RTD,AD590 etc..)
%           'mode'      : control mode ( ITE, R and T )
%           'T'         : current temperature
%           'setT'      : set temperature
%           'highT'     : high temperature limit
%           'lowT'      : low temperature limit
%           'maxI'      : maximum current thru TEC
%           'gain'      : gain for controller
%           'tol'       : tolerance and time window
%           'cond'      : condition of TEC
%
% 'on'      enable TEC output
%
% 'off'     disable TEC output. Also 'stop'.


if (strcmpi(instrument, 'NP_3150') || strcmpi(instrument, 'all'))
   baudrate = 0;  % buffer size for GPIB (0 for default), baud rate for serial port instruments
   io = port(GPIB, instrument, baudrate, verbose);
   if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

       switch command
           case 'init'
               %fprintf(io, '*RST');             % reset instrument    
               fprintf(io, '*CLS');             % clear any errors
               fprintf(io,'*OPC');
               fprintf(io, '*TST?');            % self test
               retval = fscanf(io);             % result of self test 
               if str2num(retval)               %RETVAL != 0 if failed
                   fprintf(1, 'kpib/%s: Temp. controller did not pass self test (code %s).\n',instrument,retval); 
               end
               if verbose >= 1, fprintf(1, 'kpib/%s: Initialization passed.\n',instrument); end
               
               fprintf(1,'**Controller Status Report:\n');
               
               % get TEC output status
               kpib('NP_3150',GPIB,'read','output');
               
               % get  sensor type
               kpib('NP_3150',GPIB,'read','sensor');
               
               % get mode(const Temp.,const Ref.,const ITE )
               kpib('NP_3150',GPIB,'read','mode');
               
               % get measured temperature
               kpib('NP_3150',GPIB,'read','T');
               
               % get set temperature
               kpib('NP_3150',GPIB,'read','setT');
               
               % get high temperature limit
               kpib('NP_3150',GPIB,'read','highT');
               
               % get lower temperature limit
               kpib('NP_3150',GPIB,'read','lowT');
               
               % get max. current limit thru TEC
               kpib('NP_3150',GPIB,'read','maxI');
              
               % get TEC gain
               kpib('NP_3150',GPIB,'read','gain');
               
               % get TEC gain
               kpib('NP_3150',GPIB,'read','gain');
               
               % get Tolerance and time
               kpib('NP_3150',GPIB,'read','tol');
               
               % get TEC condition
               kpib('NP_3150',GPIB,'read','cond');
               
           % end of 'init'    
              
           case 'read'
                switch value
                    case {'output','out','Output','Out'}
                        fprintf(io, 'TEC:OUTput?');
                        retval = fscanf(io);
                        switch str2num(retval)
                            case 0 
                                output='off';
                            case 1 
                                output='on';
                        end
                        retval = output;
                        if verbose >=2, fprintf(1,'kpib/%s: TEC output : %s\n',instrument,retval); end
                        
                    case {'T','t','Temp','temp','Temperature','temperature'}             
                        fprintf(io, 'TEC:T?');
                        retval = str2num(fscanf(io));
                        if verbose >=2, fprintf(1,'kpib/%s: Current Temperature: %.2d degree C\n',instrument,retval); end
                        
                    case {'setT','setTemp','settemp','setTemperature','settemperature'}
                        fprintf(io,'TEC:SET:T?');
                        retval = str2num(fscanf(io));
                        if verbose >=2, fprintf(1, 'kpib/%s: Set Temperature: %.2d degree C\n',instrument,retval); end
                    
                    case {'highT','highLimit','hLimit','highLim'} 
                        fprintf(io,'TEC:LIMit:THI?');
                        retval = str2num(fscanf(io));
                        if verbose >=2, fprintf(1, 'kpib/%s: Temp. High Limit: %.1d degree C\n',instrument,retval); end
                        
                    case {'lowT','lowLimit','lLimit','lowLim'} 
                        fprintf(io,'TEC:LIMit:TLO?');
                        retval = str2num(fscanf(io));
                        if verbose >=2, fprintf(1, 'kpib/%s: Temp. Low Limit: %.1d degree C\n',instrument,retval); end  
                    
                    case {'maxI','maxCurrent'}
                        fprintf(io,'TEC:LIMit:ITE?');
                        retval = str2num(fscanf(io));
                        if verbose >=2, fprintf(1, 'kpib/%s: Max. Current Limit: %.1d ampere\n',instrument,retval); end
                    
                    case {'gain','Gain'}
                        fprintf(io,'TEC:GAIN?');
                        retval = fscanf(io);
                        if verbose >=2, fprintf(1, 'kpib/%s: Gain For Temp. Controller: %s',instrument,retval); end                 
                    
                    case{'mode','Mode'}
                        fprintf(io,'TEC:MODE?');
                        retval = fscanf(io);
                        if verbose >=2, fprintf(1, 'kpib/%s: Temp. Control Mode: %s',instrument,retval); end
                    
                    case {'sensor','Sensor','sens','SNSR','snsr'}
                        fprintf(io,'TEC:SENsor?');
                        retval = fscanf(io);
                        switch str2num(retval)
                            case 0 
                                sensor='None';
                            case 1 
                                sensor='Thermistor at 100uA drive';
                            case 2 
                                sensor='Thermistor at 10uA drive';
                            case 3
                                sensor='LM335';
                            case 4
                                sensor='AD590';
                            case 5
                                sensor='RTD';
                            otherwise
                                sensor='None';
                        end
                        retval = sensor;
                        fprintf(1, 'kpib/%s: Temp. Sensor Type: %s\n',instrument,retval);
                        
                    case{'const','constants','constant','Const','Constants','Constant'}
                        fprintf(io,'TEC:CONST?');
                        retval = fscanf(io);
                        kpib('NP_3150',GPIB,'read','sensor');
                        fprintf(1, 'kpib/%s: TEC sensor constants: %s\n',instrument,retval);
                        
                    case{'cond','condition','Cond','Condition'}
                        fprintf(io,'TEC:COND?');
                        retval = str2num(fscanf(io));
                        fprintf(1,'***** TEC condition report:\n');
                        if(retval == 0)
                            fprintf(1,'kpib/%s: Everything is O.K. with TEC\n',instrument);
                        end
                        if(bitget(retval,1)==1)
                            fprintf(1,'kpib/%s: TE Current Limit\n',instrument);
                        end
                        if(bitget(retval,2)==1)
                            fprintf(1,'kpib/%s: Voltage Limit Error\n',instrument);
                        end
                        if(bitget(retval,3)==1)
                            fprintf(1,'kpib/%s: R(reference) Limit\n',instrument);
                        end
                        if(bitget(retval,4)==1)
                            fprintf(1,'kpib/%s: High Temperature Limit\n',instrument);
                        end
                        if(bitget(retval,5)==1)
                            fprintf(1,'kpib/%s: Low Temperature Limit\n',instrument);
                        end
                        if(bitget(retval,6)==1)
                            fprintf(1,'kpib/%s: Sensor Shorted\n',instrument);
                        end
                        if(bitget(retval,7)==1)
                            fprintf(1,'kpib/%s: Sensor Shorted\n',instrument);
                        end
                        if(bitget(retval,8)==1)
                            fprintf(1,'kpib/%s: Sensor Open\n',instrument);
                        end
                        if(bitget(retval,9)==1)
                            fprintf(1,'kpib/%s: N/A \n',instrument);
                        end
                        if(bitget(retval,10)==1)
                            fprintf(1,'kpib/%s: Output Out of Tolerance\n',instrument);
                        end
                        if(bitget(retval,11)==1)
                            fprintf(1,'kpib/%s: Output On\n',instrument);
                        end
                        if(bitget(retval,12)==1)
                            fprintf(1,'kpib/%s: Ready for Calibration Data\n',instrument);
                        end
                        if(bitget(retval,13)==1)
                            fprintf(1,'kpib/%s: Calculation Error\n',instrument);
                        end
                        if(bitget(retval,14)==1)
                            fprintf(1,'kpib/%s: TEC Interlock\n',instrument);
                        end
                        if(bitget(retval,15)==1)
                            fprintf(1,'kpib/%s: Software Error\n',instrument);
                        end
                        if(bitget(retval,16)==1)
                            fprintf(1,'kpib/%s: TEC EPROM Checksum Error\n',instrument);
                        end
                       
                        
                    case{'finish','fin','Finish','Fin','opc','OPC'}
                        fprintf(io,'*OPC?');
                        retval = str2num(fscanf(io));
                        if(retval == 1)
                            fprintf(1,'kpib/%s: Operation completed \n',instrument);
                        else
                            fprintf(1,'kpib/%s: Operation incomplete \n',instrument);       
                        end
                        
                    case{'tol','tolerance','Tol','Tolerance'}
                        fprintf(io,'TEC:TOLerance?');
                        retval = fscanf(io);
                        fprintf(1,'kpib/%s: Tolerance(degree),Time window(sec) : %s',instrument,retval);
                       
                    otherwise
                       if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s"]\n',instrument,command); 
                       end
                       
                end %end of switch
           %end of 'read'
           
           case 'getdata'
               retval=kpib(instrument,GPIB,'read','T',channel,aux,verbose);
           
           case {'set','setT'}
               if isnumeric(value) % then set the temperature setpoint to that value
                   
                   % verify the high/low limit
                   fprintf(io,'TEC:LIMit:THI?');
                   highlim = str2num(fscanf(io));                   
                   fprintf(io,'TEC:LIMit:TLO?');
                   lowlim = str2num(fscanf(io));
                   
                   if value <= highlim && value >= lowlim
                       fprintf(io,'TEC:T %f',value);
                       if verbose >= 2, fprintf(1,'kpib/%s: Temperature setpoint set to %f C\n',instrument,value); end
                   else
                       if verbose >= 1, fprintf(1,'kpib/%s: WARNING: Temperature setpoint (%f C) outside the limits (%f/%f C)\n',instrument,value,lowlim,highlim); end
                   end
                   
               else % else set a specific setting of the instrument
                   switch value
                       case {'output','out','Output','Out'}
                           if(isnumeric(channel))
                               fprintf(io,'TEC:OUTput %d',channel);    
                           else
                               switch channel
                                   case {'on','On'} 
                                        fprintf(io,'TEC:OUTput 1');
                                   case {'off','Off'}
                                        fprintf(io,'TEC:OUTput 0');                        
                               end
                           end
                           kpib('NP_3150',GPIB,'read','output');

                       case {'t','T','Temp','temp','Temperature','temperature','setT'} 
                            kpib('NP_3150',GPIB,'read','T');
                            fprintf(io,'TEC:T %d',channel); 
                            if verbose >= 1
                                if( channel > kpib('NP_3150',GPIB,'read','highT') )
                                    fprintf(1,'kpib/%s: %d degree C is over high temperature limit\n',instrument,channel);
                                elseif ( channel < kpib('NP_3150',GPIB,'read','lowT'))
                                    fprintf(1,'kpib/%s: %d degree C is below lower temperature limit\n',instrument,channel);
                                else
                                    fprintf(1,'kpib/%s: temperature is set to %d degree C\n',instrument,channel);
                                end
                            end
                       case {'highT','highLimit','hLimit','highLim'} 
                            fprintf(io,'TEC:LIMit:THI %d',channel);
                            kpib('NP_3150',GPIB,'read','highT');

                       case {'lowT','lowLimit','lLimit','lowLim'} 
                            fprintf(io,'TEC:LIMit:TLO %d',channel);
                            kpib('NP_3150',GPIB,'read','lowT');

                       case {'maxI','maxCurrent','MaxI'}
                            fprintf(io,'TEC:LIMit:ITE %d',channel);
                            kpib('NP_3150',GPIB,'read','maxI');

                       case {'gain','Gain','G'}
                           %gain :
                           %'0.2S','0.6S','1S','1,'2S','3','5','6S','10S','20S'
                           %'30','50','60S','100','300'
                           if(isnumeric(channel))
                                fprintf(1,'kpib/%s: Error, gain value should be string. Possible gains are\n',instrument);
                                fprintf(1,'kpib/%s: 0.2S,0.6S,1S,1,2S,3,5,6S,10S,20S,30,50,60S,100 and 300\n',instrument);
                           else
                                fprintf(io,'TEC:GAIN %s',channel);
                                kpib('NP_3150',GPIB,'read','gain');
                           end


                       case {'sensor','Sensor','sens','SNSR','snsr'}
                           if(isnumeric(channel))
                               %1:Thermistor 100uA, 2:Thermistor 10uA, 3:LM335, 
                               %4:AD590, 5:RTD
                               fprintf(io,'TEC:SENsor %d',channel);
                               kpib('NP_3150',GPIB,'read','Sensor');
                           else
                               switch channel
                                   case {'Th100','T100'} 
                                        fprintf(io,'TEC:SENsor 1');
                                        kpib('NP_3150',GPIB,'read','Sensor');
                                   case {'Th10','T10'}
                                        fprintf(io,'TEC:SENsor 2');
                                        kpib('NP_3150',GPIB,'read','Sensor');
                                   case {'LM335'}
                                        fprintf(io,'TEC:SENsor 3');
                                        kpib('NP_3150',GPIB,'read','Sensor');
                                   case {'AD590'}
                                        fprintf(io,'TEC:SENsor 4');
                                        kpib('NP_3150',GPIB,'read','Sensor');
                                   case {'RTD'}
                                        fprintf(io,'TEC:SENsor 5');
                                        kpib('NP_3150',GPIB,'read','Sensor');
                               end
                           end

                       case{'mode','Mode'}
                           %mode: 'ITE':constant current mode
                           %      'R'  :constant resistance/linear sensor reference mode
                           %      'T'  :constant temperature mode
                           fprintf(io,'TEC:MODE:%s',channel);
                           kpib('NP_3150',GPIB,'read','mode');

                       case{'const','constants','constant','Const','Constants','Constant'}
                           fprintf(io,'TEC:CONST:%s',channel);
                           kpib('NP_3150',GPIB,'read','const');

                       case{'tol','tolerance','Tol','Tolerance'}
                           fprintf(1,'tolerance in degree C(0.1 to 10.0)\n');
                           fprintf(1,'time window in seconds (0.001 to 50.000)\n');
                           fprintf(1,'ex: 0.11,50.0\n');
                           fprintf(io,'TEC:TOLerance %s',channel);
                           kpib('NP_3150',GPIB,'read','tol');

                       case{'OPC'}
                           fprintf(io,'*OPC');
                           fprintf(1,'kpib/%s: Operation Complete command\n',instrument);

                       otherwise
                           if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s/%s"]\n',instrument,command,value); 
                           end
                   end % end of switch
               end
               % end of 'set'    
           
           case {'on','On','ON'}
               kpib('NP_3150',GPIB,'set','out','on');
           % end of 'on'    
           
           case {'off','Off','OFF','stop','STOP'}               
               kpib('NP_3150',GPIB,'set','out','off'); 
           % end of 'off'

           otherwise
               if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s"]\n',instrument,command); end
       end
               
   else % catch incorrect address errors
      if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
      retval=0;
   end
   validInst = 1;
end  % End NP_3150



%% 'VH_2701C' Valhalla 2701C voltage calibrator
%   Contributed by Jim Salvia
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
%
% Valid Commands:
% 'init'  Resets the instrument
% 'read'  Reads the output value.
%         Returns a value and units ('volts' or 'mamps')
% 'setV'   Sets the output voltage to VALUE in Volts. Also 'set'
%         Will bring the device out of standby mode into operate mode!
% 'setI'   Sets the output current to VALUE in mA. 
%         Will bring the device out of standby mode into operate mode!
% 'off'   Goes to standby mode (output off)
% 'on'    Goes to operate mode (output on)
%
 
if (strcmpi(instrument, 'VH_2701C') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
%         temp_str = fscanf(io,'%c');
        
        switch command
            case {'init'}
                fprintf(io, 'S');
                fprintf(io, 'L'); % Resets instrument.
                if verbose >= 2, fprintf(1, 'kpib/VH_2701C: Reset VH_2701C\n'); end
                
            case 'read'
                temp_str = fscanf(io,'%c');
                %[retval.value,tempchar,opcode] = strread(temp_str,'%f%s%s');
                [level,tempchar,opcode] = strread(temp_str,'%f%s%s');
                if verbose >= 2, fprintf(1, 'kpib/VH_2701C '); end
                
                switch value % return a single value or both V & I?
                    case {'volt','volts','V','v'}
                    	retval = level;
                    	if verbose >= 2, fprintf(1, 'reads %f Volts\n',retval); end
                        if ~strcmp(tempchar,'V')
                            if verbose >= 1, fprintf(1, 'kpib/VH_2701C: WARNING Volts requested but mAmps returned!\n'); end
                        end
                    case {'curr','I','A','current'}
                        % read the current
                        retval = level;
                        if verbose >= 2, fprintf(1, 'reads %f Amps\n',retval); end
                        if ~strcmp(tempchar,'mA')
                            if verbose >= 1, fprintf(1, 'kpib/VH_2701C: WARNING mAmps requested but Volts returned!\n'); end
                        end                        
                    otherwise % return a structure with detailed info
                    	retval.value=level;
                        if(char(opcode) =='*')
                            retval.opcode = 'standby';
                        else
                            retval.opcode = 'operating';
                        end

                        switch char(tempchar) % Voltage or current?
                            case {'V'}
                            % read a voltage
                                retval.units = 'Volts';
                                retval.volts=level;
                                if verbose >= 2, fprintf(1, 'kpib/VH_2701C reads %f Volts\n',retval.value); end
                            case {'mA'}
                            % read a current
                                retval.units = 'mAmps';
                                retval.curr=level;
                                if verbose >= 2, fprintf(1, 'kpib/VH_2701C reads %f mAmps\n',retval.value); end
                            otherwise
                                if verbose >= 1, fprintf('kpib/VH_2701C Error, returned string not recognized ["%s"]\n',temp_str); end    
                        end
                end
                    
            case {'setV','volt','voltage','set'}
                % set the voltage
                if(value <= 120)
                    fprintf(io, 'VO%f',value); % Sets voltage.   
                    if verbose >= 2, fprintf('kpib/VH_2701C Output Voltage set to %g Volts\n',value); end
                else
                    fprintf(io, 'VO%f',0);       % standby if the requested voltage is > 120V
                    if verbose >= 1, fprintf('kpib/VH_2701C Requested voltage = %gV > 120V\nHigh voltage operation via KPIB has been disabled for safety\nOutput set to 0V\n',value); end
                end

            case {'setI','curr','current'}
                % set the current
                fprintf(io, 'II%f',value); % Sets current.
                if verbose >= 2, fprintf('kpib/VH_2701C Output Current set to %g mAmps\n',value); end

            case {'off','standby'}
                fprintf(io, 'S'); % Standby
                if verbose >= 2, fprintf(1, 'kpib/VH_2701C in Standby mode.\n'); end
            case {'on','operate'}
                fprintf(io, 'V'); % Operate mode.
                if verbose >= 2, fprintf(1, 'kpib/ VH_2701C in Operate Mode.\n'); end
%             case {'local'}                
%                 iof = instrfind('Type','gpib','PrimaryAddress',GPIB);
%                 if ~isempty(iof) 
%                     fclose(iof);
%                     delete(iof);
%                     clear iof;
%                 else
%                     if verbose >= 1, fprintf('kpib: No instrument in memory at GPIB# %d.\n',g); end
%                 end
%                 if verbose >= 2, fprintf(1, ' VH_2701C in Local Mode.\n'); end
            otherwise
                if verbose >= 1, fprintf('kpib/Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end VH_2701C
 
 
%% 'VH_2701B' Valhalla 2701B voltage calibrator
%   Contributed by Jim Salvia
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
%
% Valid Commands:
% 'set'   Sets the output voltage to VALUE in Volts. 
%         Will NOT bring the device out of standby mode into operate mode!
%         The device must be put into operate mode manually
%
% 'local' Will return the instrument to local control
%         Note that this returns the intrument's output voltage to that 
%         displayed on the manual knobs on the front panel
 
if (strcmpi(instrument, 'VH_2701B') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        
        switch command
            case {'read'}
                if verbose >=1, fprintf('kpib/VH_2701B: Warning: Read function not operational (DEC2007)\n'), end
                retval = 1776;                
                
            case {'setV','volt','voltage','set'}
                % set the voltage
                if value < 0
                    value = abs(value)
                    if verbose >=1, fprintf('kpib/VH_2701B: Warning: Cannout output negative voltages, using absolute value\n'), end
                end
                if (value > 120)
                    safeval = 0;
                    if verbose >= 1, fprintf('kpib/VH_2701B Warning: Requested voltage = %gV > 120V\nHigh voltage operation via KPIB has been disabled for safety\n',value); end
                else
                    safeval = value;
                end
                if (safeval < 1000 && safeval >= 100)
                    modvalue = sprintf('%6.0f',safeval/.001);
                    fprintf(io, 'R3V%s',modvalue); % Sets voltage.
                elseif (safeval < 100 && safeval >= 10)
                    modvalue = sprintf('%6.0f',safeval/.0001);
                    fprintf(io, 'R2V%s',modvalue); % Sets voltage.
                elseif (safeval < 10 && safeval >= 1)
                    modvalue = sprintf('%6.0f',safeval/.00001);
                    fprintf(io, 'R1V%s',modvalue); % Sets voltage.
                elseif (safeval < 1)
                    modvalue = sprintf('%6.0f',safeval/.000001);
                    fprintf(io, 'R0V%s',modvalue); % Sets voltage.
                elseif safeval < 1100 && safeval >= 1000
                    modvalue = sprintf(':%5.0f',(safeval-1000)/.001);
                    fprintf(io, 'R3V%s',modvalue); % Sets voltage.
                elseif safeval < 1200 && safeval >= 1100
                    modvalue = sprintf(';%5.0f',(safeval-1100)/.001);
                    fprintf(io, 'R3V%s',modvalue); % Sets voltage.
                elseif safeval < 1210 && safeval >= 1200
                    modvalue = sprintf(';:%4.0f',(safeval-1200)/.001);
                    fprintf(io, 'R3V%s',modvalue); % Sets voltage.
                else
                    fprintf(io,'V000000')
                    fprintf('Requested Voltage Out of range %g not in [0V to 1200V]\n',value)
                    value = 0;
                end

                if verbose >= 2, fprintf('Output Voltage set to %g Volts\n',safeval); end
                
            case {'on'} % does not work with our 2701B?
                fprintf(io,'V'); % manual p6-9
                
            case {'off'} % does not work with our 2701B?
                fprintf(io,'S'); % manual p6-9
                
            case {'local'}
                iof = instrfind('Type','gpib','PrimaryAddress',GPIB);
                if ~isempty(iof) 
                    fclose(iof);
                    delete(iof);
                    clear iof;
                else
                    if verbose >= 1, fprintf('kpib: No instrument in memory at GPIB# %d.\n',g); end
                end
                if verbose >= 2, fprintf(1, ' VH_2701B in Local Mode.\n'); end
                
            otherwise
                if verbose >= 1, fprintf('Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end VH_2701B


%% 'HP_4195A' HP Network/Spectrum Analyzer
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% VALUE is typically the modifier to COMMAND.
% Valid Commands:
% 'init'      Resets the Analyzer. Returns the decimal value of the status
%              byte (should be zero for normal condition).
% 'label'     Writes 'VALUE' to the display.
% 'channel'   Makes channel VALUE the active channel. NOTE: 'channel' (1|2)
%              corresponds to the Data Registers A and B. To select the
%              Test Input Channel, use the parameter 'aux' (1|2). Default is 1.
% 'attenuate' Set the imput attenuation to level CHANNEL in dB.
%              VALUE can be 'T' or 'R' ('test' or 'reference'). 
% 'display'   Controls what is displayed on the Analyzer screen.
%             VALUE can be any of the four registers: 'a','b','c','d' and
%             CHANNEL is 'on' or 'off'.
% 'format'    Set the format of the graph on the Analyzer display:
%             Linear, log/mag, etc. 
%             non-exponentially ('norm'). Exponentially is the default.
% 'scale'     Sets the scale of the display. VALUE is the scale in the
%             current units, or 'VALUE' = 'auto' for autoscale command. 
% 'ref line'  Sets the position of the reference line of the display.
%             VALUE is the position of the reference line in the current
%             units.
% 'average'   Turns averaging on or off, restarts averaging, or returns
%             the current number of averages taken.
%             VALUE='on','off','restart', or 'query'.
%             For 'query', RETVAL returns 0 (off) or the current number of averages (on).
% 'mark2peak' Finds the peak and sets the marker, or finds the peak and
%             sets the peak location to the center of the scan.
%             VALUE='off','center', or 'peak'.
% 'marker'    Turns the marker on or off, or returns the current
%              position of the marker. 'VALUE' = 'on','off', or 'query'.
%              The position is returned as retval.x, retval.y in current
%              units.
% 'center'    Set the center frequency to VALUE. Units of Hz.
%              Query with VALUE = 'query', returns center frequency in Hz.
% 'span'      Set the frequency span VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'sweep'     Sets sweep parameters
% 'source'    Set the source (stimulus output) signal level. VALUE is the
%              desired signal level. Units of dBm.
%              Query with VALUE = 'query', returns source power in dBm.
% 'source?'   (Alternate query form) Returns source power in dBm and state (on|off).
% 'power'     Same as 'source'.
% 'bias'      The 4195A has a built-in DC source that can be used for
%              bias. The commands 'setV' and 'read' are supported, so that
%              the 4195 can pretend to be a power supply (e.g., you can
%              do:  tools.biasset.instr = 'HP_4195A' )
% 'getdata'   Download the current data trace from the analyzer. Data is
%              returned as two columns, x and y, for the specified
%              CHANNEL. Default CHANNEL is not set. If VALUE is 'x' or 'y', only
%              that data is returned in a single column.
% 'units'     Returns the units of the data from the analyzer. Must
%              specify VALUE = 'x' or 'y' axis units.
% 'pause'     Pauses measurement. Not supported by 4195A.
% 'continue'  Continues paused measurement. Not supported by 4195A.
% 'complete'  Wait for the previous sweep to complete. This command
%              contains a loop that does not exit until the status byte shows
%              that the sweep is complete. Use with 'sweep','single' or
%              'complete','single'.
% 'wait'      Wait for the previous command to complete (*WAI)
%              Not supported by 4195A.

 if (strcmpi(instrument, 'HP_4195A') || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
    
        % 'aux' is the Test Input (aka "Channel") for all commands
        %  ('channel' is the data register A|B, for magnitude|phase traces)
        if ~isnumeric(aux), T_IN=1; end
        if aux==0, T_IN=1; end % default to channel 1
        if aux==1, T_IN=1; end
        if aux==2, T_IN=2; end

        switch command

            case 'init' %ok
                %fprintf(io,'*RST');
                fprintf(io,'CLS');
                fprintf(io,'STB?');
                retval=fscanf(io,'%d');
                % make sure that input attenuation is 0
                kpib(instrument, GPIB, 'attenuate', 'T', 0, aux, verbose);
                kpib(instrument, GPIB, 'attenuate', 'R', 0, aux, verbose);
                
                if verbose >= 2
                	fprintf(1, 'kpib/HP_4195A: Initialized. Load setup RES1 manually.\n');
                end
                if verbose >= 3
                      % % The ID string just causes trouble. Don't use it.
%                     fprintf(io,'ID?'); % ID? returns three separate strings
%                     id1 = fscanf(io,'%s'); 
%                     id2 = fscanf(io,'%s');
%                     id3 = fscanf(io,'%s');
%                     fprintf(1, 'kpib/HP_4195A: %s %s %s\n',id1,id2,id3);
                	fprintf(1,'kpib/HP_4195A: Status byte: %s\n',dec2bin(retval,8));
                end

            case 'label' % manual pE-3 
                if length(value) > 53
                    value=value(1:53); % 53 chars max [verify this for 4195A]
                end
                cmd = sprintf('%s"%s"','CMT',value); fprintf(io,cmd);

			case {'channel','CHAN'}
				% 'channel' is not meaningful for this instrument; include for compatibility
				% 'channel' (1|2) for kpib means Trace A or B for the Analyzer
                % Note that some commands have specific channel select, i.e., trace A or B
                %  commands (e.g., 'scale', 'marker')
                if verbose >= 3
                    fprintf(1, 'kpib/HP_4195A: Using Test Channel %d. Use AUX parameter to specify Test Input Channel (1|2). Default is 1.', T_IN);
                end
                
            case {'display','trace'}
                switch value
            		case {'dual'} % for compatibility with res_meas
            			switch channel
            				case {'query','?'}
            					retval = 1; % assume for compatibility
            					% turn on both traces
            					fprintf(io,'DPA1;DPB1');
                            otherwise
                                % turn on both traces
            					fprintf(io,'DPA1;DPB1');
                                retval = 0;
            			end
            		case {'a','A'}
            			switch channel
            				case {'on','ON'}
            					fprintf(io,'DPA1');
            				case {'off','OFF'}
            					fprintf(io,'DPA0');
						end
             		case {'b','B'}
            			switch channel
            				case {'on','ON'}
            					fprintf(io,'DPB1');
            				case {'off','OFF'}
            					fprintf(io,'DPB0');
                        end
             		case {'c','C'}
            			switch channel
            				case {'on','ON'}
            					fprintf(io,'SPC1');
            				case {'off','OFF'}
            					fprintf(io,'SPC0');
                        end
					case {'d','D'}
            			switch channel
            				case {'on','ON'}
            					fprintf(io,'SPD1');
            				case {'off','OFF'}
            					fprintf(io,'SPD0');
						end
                end


			case {'attenuate','ATT','AT','att'} %ok            	
            	switch value
            		case {'input','T','test'}
            			switch channel
							case {'query','?'}
								cmd = sprintf('ATT%d?',T_IN); fprintf(io,cmd);
								retval = fscanf(io,'%f');
							otherwise
								% round value (0-50, in steps of 10) manual F-4
								value=10*round(channel/10);
								if channel > 50, channel = 50; end
								if channel < 0, channel = 0; end
								cmd = sprintf('ATT%d=%d',T_IN,channel); fprintf(io,cmd);
								if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Input attenuation on Test Input (T%d) set to %d dB\n',T_IN,channel); end 
						end			
            		
            		case {'reference','R','ref'}
            			switch channel
							case {'query','?'}
								cmd = sprintf('ATR%d?',T_IN); fprintf(io,cmd);
								retval = fscanf(io,'%f');
							otherwise
								% round value (0-50, in steps of 10) manual F-4
								value=10*round(channel/10);
								if channel > 50, channel = 50; end
								if channel < 0, channel = 0; end
								cmd = sprintf('ATR%d=%d',T_IN,channel); fprintf(io,cmd);
								if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Input attenuation on Reference Input (R%d) set to %d dB\n',T_IN,channel); end 
            			end
            	
                end
            
            case 'scale'
                % select the channel (for the scale command only)
                switch channel
                    case 1
                        fprintf(io,'SCL1');
                    case 2
                        fprintf(io,'SCL2');
                    otherwise
                        fprintf(io,'SCL1');
                        channel = 1;
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Scale: default Channel 1.\n'); end
                end
                if isnumeric(value)
                    cmd = sprintf('DIV=%d',value); fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Scale set to %g/division.\n',value); end
                else
                	switch value
                		case {'auto','AUTO'}
		                    fprintf(io,'AUTO');
                    		if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Autoscale channel %d.\n',channel); end
                    	case {'?','query'}
		                	fprintf(io,'DIV?')
		                	retval = fscanf(io,'%f');
		                	if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Scale on channel %d is %g/division.\n',channel,retval); end
		                case {'lin','linear'}
		                	fprintf(io,'SCT1');
		                	if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Linear X scale.\n'); end
		                case {'log','logarithmic'}
		                	fprintf(io,'SCT2');
		                	if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Logarithmic X scale.\n'); end
		                end
                end

            case {'ref line','refline'}
                if isnumeric(value)
    				cmd = sprintf('REF=%d',value); fprintf(io,cmd);
                 	if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Reference value set to %g dB.\n',value); end
                else
                    switch value
                        case{'?','query'}
                            fprintf(io,'REF?')
                            retval = fscanf(io,'%f');
                    end
                end
                            
            case {'average','averaging','video'} % Use "video filtering", manual p4-32
				retval = 1;
                switch value
                    case {'on','ON','yes',1}
                        fprintf(io,'VFTR1');
                        retval = 1;
        				if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Averaging (video filter) enabled\n'); end
                    case {'off','OFF','no',0}
                        fprintf(io,'VFTR0');
                        retval = 0;
        				if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Averaging (video filter) disabled\n'); end
                end

            case 'center' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'CENTER?');
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=['CENTER=' num2str(value)];
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Center set to %f Hz\n',value); end
                end

            case 'span' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'SPAN?');
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=['SPAN=' num2str(value)];
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Span set to %f Hz\n',value); end
                end

            case 'start' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'START?');
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=['START=' num2str(value)];
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Start set to %f Hz\n',value); end
                end

            case 'stop' %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'STOP?');
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=['STOP=' num2str(value)];
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Stop set to %f Hz\n',value); end
                end

            case {'bias','set','setV'} %ok
                switch value
                    case {'query','?'}
                        fprintf(io,'BIAS?');
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=['BIAS=' num2str(value)];
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Bias voltage set to %f V\n',value); end
                end
                
            case {'bias?','read'} % emulate a power source for bias operation
					fprintf(io,'BIAS?');
					retval = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Bias voltage set to %f V (''read'')\n',value); end                

            case {'power','source'} %ok
                switch value
%                    case 'on'
%                        if verbose >= 2, fprintf('kpib/HP_4195A: Warning: Must select channel and value (power in dBm)\n'); end
%                    case 'off'
%                        fprintf(io,'PWR0');
%                        if verbose >= 2, fprintf('kpib/HP_4195A: Source output OFF\n'); end
					case {'query','?'}
						cmd=['OSC' num2str(T_IN) '?']; fprintf(io,cmd);
						retval = fscanf(io,'%f');
                    	if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Source Amplitude (S%d) is %d dBm\n',T_IN,retval); end
                	otherwise						
						if isnumeric(value) && value >= -50 && value <= 15
							cmd = sprintf('OSC%d=%d',T_IN,value);
							fprintf(io,cmd);
							if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Source Power (S%d) set to %d dBm\n',T_IN,value); end
						else
							if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Source Power not set. Power must be specified between -50 and 15 dBm.\n'); end
						end
				end

            case {'power?','source?'} % alternate query form
                cmd=['OSC' num2str(T_IN) '?']; fprintf(io,cmd);
                retval.level = fscanf(io,'%f');
                if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Source Power: %g dBm\n',retval.level); end
                retval.state='on'; % 4195A source is always on
                
			case {'marker','mkr'}
                % select the channel (for the marker command only)
                switch channel
                    case 1
                        fprintf(io,'MKCR1');
                    case 2
                        fprintf(io,'MKCR2');
                    otherwise
                        fprintf(io,'MKCR1');
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Marker: default Channel 1.\n'); end
                end
				switch value
					case 'on'
						fprintf(io,'MCF1');
						if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Marker on.\n'); end
					case 'off'
						fprintf(io,'MCF0');
						if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Marker off.\n'); end
					case {'query','?'}
						fprintf(io,'MKR?');
						retval.x = fscanf(io,'%f');
						if ~isnumeric(channel) || channel==0, channel=1; end
						if any(channel==[1 2])
							switch channel
								case 1
									trace='A';
								case 2
									trace='B';
							end
                            cmd=['MKR' trace '?']; fprintf(io,cmd);
							retval.y = fscanf(io,'%f');
							if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Marker on Trace %s at %g Hz, %g.\n',trace,retval.x,retval.y); end
						else
							if verbose >= 2, fprintf(1, 'kpib/HP_4195A: ''marker'': must specify a valid channel (1,2).\n'); end
						end
					case 'line'
						fprintf(io,'MCF3');
						if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Marker in Line mode.\n'); end
                    case {'center','m2c','mark2center'} % make the marker position the center freq
                        fprintf(io,'MKCTR');
                        if verbose >= 2, fprintf(1,'kpib/HP_4195A: Marker to Center\n'); end
                    case {'peak','searchpeak','mark2peak','max','m2p'}
                        fprintf(io,'MKMX');                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4195A: Marker to Maximum'); end
                    case {'min','minimum','valley','antipeak'}
                        fprintf(io,'MKMN');                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4195A: Marker to Minimum'); end
                    case {'stop'}
                        fprintf(io,'MKSP');                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4195A: Marker to Stop'); end
                    case {'start'}
                        fprintf(io,'MKST');                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/HP_4195A: Marker to Start'); end
                    otherwise
                    	if verbose >= 1, fprintf(1, 'kpib/HP_4195A: Error at ''marker'' command (VALUE incorrect ["%s"]).\n',value); end
                           
                end

            case {'mark2peak','peaktrack'}
                % the 4195A does not have some of these explicit commands
                switch value
                    case 'center'
                        fprintf(io,'MKMX'); % marker to max
                        fprintf(io,'MKCTR'); % marker to center
                    case 'peak'
                        fprintf(io,'MKMX');
                end

            case {'mode','type'}
                % set or get instrument mode
                % find out what mode the analyzer is in:
                %   Network or Spectrum
                switch value
                    case {'?','query'}  % Mode query is not supported by 4195A
                        mode = 'NA';    % Assume Network Analyzer
                        retval = mode;
                        if verbose >= 2, fprintf('kpib/HP_4195A: Warning: Analyzer does not support mode query (kpib returns ''NA'').\n'); end
%                         fprintf(io,'FCN1?');
%                         mode = fscanf(io,'%d');
%                         if mode==1
%                             mode='NA';
%                             if verbose >= 2, fprintf('kpib/HP_4195A: Analyzer in Network mode.\n'); end
%                             retval=mode;
%                         else
%                             fprintf(io,'FCN2?');
%                             mode = fscanf(io,'%d'); 
%                             if mode==1
%                                 mode='SA';
%                                 if verbose >= 2, fprintf('kpib/HP_4195A: Analyzer in Spectrum mode.\n'); end
%                                 retval=mode;
%                             end
%                         end
                        
                    case {'NA','network'}
                        fprintf(io,'FNC1');
                        if verbose >= 2, fprintf('kpib/HP_4195A: Analyzer set to Network mode.\n'); end
                    case {'SA','spectrum'}
                        fprintf(io,'FNC2');
                        if verbose >= 2, fprintf('kpib/HP_4195A: Analyzer set to Spectrum mode.\n'); end
                        
                    otherwise
                        if verbose >= 1, fprintf('kpib/HP_4195A: WARNING: ''mode'' command needs a VALUE parameter (e.g., ''?'' or ''NA'').\n'); end
                        retval=-1;
                end

            case 'getdata' %ok
                % Select the channel. For compatibility with old code, the
                %  channel is *not* set if it is not explicitly specified, i.e.,
                %  the default is to do nothing, rather than to select a channel.

                % specify the data format as ASCII
                fprintf(io,'FMT1');

                % now, did the user specify a channel or not?
                if isnumeric(channel) && any(channel == [1 2 3 4])
                    if verbose >= 2, fprintf('kpib/HP_4195A: Channel [Trace] %d (Test Input %d) selected for data download.\n',channel,T_IN); end
					switch channel % see manual p F-1
						case 1
							fprintf(io,'A?');
							retval.units.y = 'dB'; %  FIX, could be spectrum mode
						case 2
							fprintf(io,'B?');
							retval.units.y = 'deg'; % FIX, could be rad
						case 3
							fprintf(io,'C?'); % C and D are saved data
                            retval.units.y = 'dB'; %  FIX, could be spectrum mode
						case 4
							fprintf(io,'D?'); % C and D are saved data
                            retval.units.y = 'deg'; % FIX, could be rad
					end
                    rawdata = fscanf(io);
                    rawdata = [rawdata ',']; % append a comma so that the format matching works right
					retval.y = sscanf(rawdata,'%e,');
                else
                    if verbose >= 2, fprintf('kpib/HP_4195A: Default channel 1 (Input %d) for data download.\n',T_IN); end
                    if verbose >= 3, fprintf('kpib/HP_4195A: Get Y points.\n'); end
                    fprintf(io,'A?');
                    rawdata = fscanf(io);
                    rawdata = [rawdata ',']; % append a comma so that the format matching works right
                    retval.y = sscanf(rawdata,'%e,');
                    retval.units.y = 'dB'; %  FIX, could be spectrum mode
                end
                % double-check the download
                fprintf(io,'NOP?');
                numdatapoints = fscanf(io,'%i');
                if (length(retval.y) ~= numdatapoints)
                    if verbose >= 1, fprintf(1, 'kpib/HP_4195A: WARNING: actual number of y points downloaded (%d)\n',length(retval.y));
                        fprintf(1,'                 does not equal expected number of points (%d).\n',numdatapoints);
                    end
                end
                
                % get the x data points
                if verbose >= 3, fprintf('kpib/HP_4195A: Get X points.\n'); end
                fprintf(io,'X?');
                rawdata = fscanf(io);
                rawdata = [rawdata ',']; % append a comma so that the format matching works right
                retval.x = sscanf(rawdata,'%e,');
                retval.units.x = 'Hz'; % FIX
                
                % did we just want some numbers?
                switch value
                    case {'x','X'}
                        retval=retval.x;
                    case {'y','Y'}
                        retval=retval.y;
                end

                
                % See command SAP for spectrum mode

			case 'sweep'
                % enable the status byte for synchronization (manual p6-47)
                fprintf(io,'CLS'); % clear the status registers

                if isnumeric(value) % set the sweep time
                    fprintf(io,'ST=%d',value);
                else
                    switch value
                        % set sweep type
                        case {'freq','frequency'}
                            fprintf(io,'SWP1');
                        case {'linear sweep','lin','linear'}
                            fprintf(io,'SWT1');
                        case {'log sweep','log','logarithmic'}
                            fprintf(io,'SWT2');
                        case {'list freq','freq list','list'}
                            fprintf(io,'SWPT LIST');
                        case {'power','power sweep','osc','osclevel'} % sweep in dBm pE-17
                            fprintf(io,'SWP4');
                        %case {'query','?'}
                            %fprintf(io,'SWPT?');
                            %retval=fscanf(io,'%s');
                            
                        % perform sweep action    
                        case {'single'}
                            fprintf(io,'SWM2');
                            fprintf(io,'TRGM1');
                            fprintf(io,'SWTRG');
                        case {'continuous','cont'}
                            fprintf(io,'SWM1');
                            if verbose >= 1, fprintf(1, 'kpib/HP_4195A: WARNING: 4195A does not support continuous sweep?? (p6-22).\n'); end
                        case {'hold'}
                            fprintf(io,'HOLD');
                        case {'group','groups','number','N'}
                            if verbose >= 3, fprintf(1, 'kpib/HP_4195A: NOTE: 4195A does not support group sweep (avenum fixed at 4).\n'); end
                            % now initiate a single sweep (presumably video filter is on) 
                            fprintf(io,'SWM2');
                            fprintf(io,'TRGM1');
                            fprintf(io,'SWTRG');
                        case {'setpoints','set','numpoints'}
                            if isnumeric(channel) && channel >= 2 && channel <= 401 % maximum points is 401 (p4-28)
                                fprintf(io,'NOP=%i',channel);
                                if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Number of sweep points set to %i.\n',channel); end
                            else
                                if verbose >= 1, fprintf(1, 'kpib/HP_4195A: Number of sweep points must be between 2 and 401.\n'); end
                            end
                        case {'restart'}
                        	fprintf(io,'SWTRG');
                        otherwise
                            if verbose >= 1, fprintf(1, 'kpib/HP_4195A: Sweep command not supported ["%s"]\n',num2str(value)); end
                    end
                end
                


            case 'complete'
                % complete uses the status byte to know when a sweep has
                %  completed.
                % The registers are enabled during the sweep command, above.

                % can issue a single command for a sweep and complete
%                 if nargin > 3 
                    switch value
                        case {'single','sing','SING'}
							kpib(instrument, GPIB, 'sweep', 'single', channel, aux, verbose);
							if verbose >= 2, fprintf('kpib/HP_4195A: Single Sweep & Complete\n'); end
						case {'group','groups','number','N'}
							kpib(instrument, GPIB, 'sweep', 'group', channel, aux, verbose);
							if verbose >= 2, fprintf('kpib/HP_4195A: Group Sweep (%d) & Complete\n',channel); end
                    end
%                 end
                % or just a single command     
                if verbose >= 2, fprintf('kpib/HP_4195A: Waiting for sweep to complete...\n'); end
                warning off instrument:fscanf:unsuccessfulRead
                
                retval=0;
                while 1
                    pause(1);
                    fprintf(io,'STB?'); % check the status byte
                    retval=fscanf(io,'%d');
                    esb=dec2bin(retval,8); % return binary value represents the status registers
                    if verbose >= 3, fprintf(1, 'kpib/HP_4195A: Status Byte: %s.\n',esb); end
                    if esb(end-1) == '1' % Bit 2 indicates sweep complete
                        if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Sweep complete.\n'); end
                        break;
                    end
                    if length(esb) > 5
                        if esb(end-5) == '1' % indicates "Error"
                        	fprintf(io,'ERR?');
                        	errno = fscanf(io,'%d');
                            if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Analyzer reports: "Error Code %d.\n',errno); end
                        end
                    end
                end


			case 'units' % FIX -- DEPRECATED
				switch value
					case {'x','X'}
						retval = 'Hz';
					case {'y','Y'}
						retval = 'dB';
					otherwise
						retval.x = 'Hz';
						retval.y = 'dB';
				end

			case 'wait'  % *WAI is not supported by 4195A
                retval = 1;
                if verbose >= 3, fprintf('kpib/%s: WARNING: ''%s'' not supported by %s\n',command,instrument); end

			case 'continue'  % not supported by 4195A
                retval = 1;
                if verbose >= 3, fprintf('kpib/%s: WARNING: ''%s'' not supported by %s\n',command,instrument); end

			case 'pause'  % not supported by 4195A
                retval = 1;
                if verbose >= 3, fprintf('kpib/%s: WARNING: ''%s'' not supported by %s\n',command,instrument); end
                
            otherwise   
                if verbose >= 1, fprintf('Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
end % end HP_4195A

 
%% 'KTH_2400' Keithley 2400 Sourcemeter
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Contributed by David Myers
%  This sourcemeter has some special needs. Most seem to be derived from
%  using the Prologix GPIB controller. Be sure to set the IsUSBPro flag
%  near the beginning of the file.
% 
%  Issue #1 - Quoted from Prologix GPIB-USB Controller Manual 
%  The default setting for the Prologix contoller is to automatically address 
%  instruments to talk after sending a command in order to read their response 
%  (++auto 1).  When sending a command which does not require a response, a
%  Query Unterminated error, -420, is generated in the Keithley 2400.  
%  In essense, the instrument is saying "I have been asked to talk, but I 
%  have nothing to say."  While the instrument will continue to operate, the
%  repeated error messages and buzzing are irksome.  This is resolved by setting 
%  the Prologix to NOT automatically address the instrument, only for the KTH_2400
%  to talk (++auto 0), and addressing the instrument to talk only after sending a
%  query command (see the PORT function).
%  Example:
%  ++auto 0 - turn off read-after-write and address instrument to listen
%  Set VOLT 1.0 - Non-query command
%  *idn? - Query Command
%  ++ read eoi - read until EOI asserted by instrument
% 
%  Issue #2 - 
%  The Prologix controller is using a different EOI for this tool than for
%  other tools. "CR" rather than "CR/LF", this was solved by adding a line
%  in the PORT function to change the EOI to CR for the KTH_2400.
%
%  Issue #3 - 
%  The Keithley will not read without setting some value initially, and
%  turning the output on.  For now, the user is directed to call kpib
%  commands in an order that will not produce this error.
%
%
% Valid Commands:
% 'init'  Send the *RST command to reset the instrument and clear registers
% 'read'  Reads the output levels of the specified output ('V' or 'I').
%           Returns a single value if you specify VALUE ('volt' or 'curr'),
%           otherwise result is returned as a two-field structure of %f numbers:
%          retval.volt
%          retval.curr
%         Note that 'read' returns the *setpoint* value, not a measured
%          value. Other power supplies in kpib (e.g. HP_Exxxx) return a
%          *measured* value in response to the 'read' command. For
%          KTH_2400, use 'measure' to return a measurement of the output
%          values. This behavior may be changed in a future versions.
%
% 'measure'  Performs a measurement of signal at the terminals. VALUE should be
%             'V' or 'A' or 'R'
%             Note that measure ohms ('R') puts the instrument into a mode
%             that you cannot get out of using the currently implemented
%             commands.
% 'setV'   Sets the output voltage to VALUE in Volts. Also 'set' (deprecated).
% 'setI'   Sets the output current to VALUE in Amps.
%
% 'off'   Disables the source output.
% 'on'    Enables the source output.
%
 
if (any(strcmpi(instrument, 'KTH_2400')) || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        
        switch command
            case 'init'
                fprintf(io,'*RST');
                % turn the friggin beeper off
				fprintf(io, ':BEEPER:STATE OFF');
				% turn off the "auto-off" function
				fprintf(io, ':SOURce1:CLEar:AUTO OFF');
                
            case 'function'
                switch value
                    case {'query','?'}
                        fprintf(io, ':SOURCE:FUNCTION?');
                        if IsUSBPro, fprintf(io, '++read 13'); end
                        retval = fscanf(io,'%s');
                        if verbose >= 2, fprintf(1, 'kpib/KTH_2400: Source Function is "%s"\n',retval); end
                    case {'V','volt','volts'}
                        fprintf(io, ':SOURCE:FUNCTION VOLT');
                        fprintf(io, ':SOURCE:VOLT:MODE FIX');
                        if verbose >= 2, fprintf(1, 'kpib/KTH_2400: Voltage Source selected\n'); end
                     case {'I','amp','amps'}
                        fprintf(io, ':SOURCE:FUNCTION CURR');
                        fprintf(io, ':SOURCE:VOLT:MODE FIX');
                        if verbose >= 2, fprintf(1, 'kpib/KTH_2400: Current Source selected\n'); end
                end
                
            case 'read' %assume that instrument output is on and this command is okay
                switch value % return a single value or both V & I?
                    case {'volt','volts','V','v'}
                        % read the voltage
                        fprintf(io, ':SOURCE:VOLTAGE:IMM:AMPLITUDE?');
                        if IsUSBPro, fprintf(io, '++read 13'); end
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/KTH_2400: reads %f Volts\n',retval); end
                    case {'curr','I','A','current'}
                        fprintf(io, ':SOURCE:CURRENT:IMM:AMPLITUDE?');
                        if IsUSBPro, fprintf(io, '++read 13'); end
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/KTH_2400: reads %f Amps\n',retval); end
                    otherwise
                    % read the output
                    fprintf(io, ':SOURCE:VOLTAGE:IMM:AMPLITUDE?');
                    if IsUSBPro, fprintf(io, '++read 13'); end
                    retval.volt = fscanf(io,'%f');
                    fprintf(io, ':SOURCE:CURRENT:IMM:AMPLITUDE?');
                    if IsUSBPro, fprintf(io, '++read 13'); end
                    retval.curr = fscanf(io,'%f');
                    if verbose >= 2, fprintf(1, 'kpib/KTH_2400: reads %f Volts && %f Amps\n',retval.volt,retval.curr); end
                end

            case {'setV','volt','voltage','set'}
                % set the voltage
                fprintf(io, ':SOUR:FUNC VOLT');
                fprintf(io, ':SOUR:VOLT:MODE FIX');
                fprintf(io, ':SOUR:VOLT:RANGE 200'); %Set to maximum value
                cmd=sprintf(':SOURCE:VOLT:LEVEL %g',value); fprintf(io,cmd); % Sets voltage.
                if verbose >= 2, fprintf('kpib/KTH_2400: Output Voltage set to %g Volts\n',value); end

            case {'setI','curr','current'}
                % set the current
                fprintf(io, ':SOURCE:FUNCTION CURR');
                fprintf(io, ':SOUR:CURR:MODE FIX');
                fprintf(io, ':SOUR:CURR:RANGE 1'); %Set to maximum value
                cmd=sprintf(':SOURCE:CURR:LEVEL %g',value); fprintf(io,cmd) % Sets voltage
                if verbose >= 2, fprintf('kpib/KTH_2400: Output Current set to %g Amps\n',value); end

            case 'off'
                fprintf(io, ':OUTPUT OFF'); % Disables all outputs.
                if verbose >= 2, fprintf(1, 'kpib/KTH_2400: Outputs off.\n'); end
            case 'on'
                fprintf(io, ':OUTPUT ON'); % Enables all outputs.
                if verbose >= 2, fprintf(1, 'kpib/KTH_2400: Outputs on.\n'); end
                
			case 'measure' % perform a "one-shot" measurement, manual p17-5
                % ":MEASURE?" returns 5 values in a comma-delimited string
				switch value
					case {'V','volt','volts'}
						fprintf(io, ':MEASURE:VOLT?');
						if IsUSBPro, fprintf(io, '++read 13'); end
						r = fscanf(io,'%s');
                        rs=str2num(r);
                        retval = rs(1);
					case {'A','amp','amps','I'}
						fprintf(io, ':MEASURE:CURR?');
						if IsUSBPro, fprintf(io, '++read 13'); end
						r = fscanf(io,'%s');
                        rs=str2num(r);
                        retval = rs(2);
					case {'R','ohm','ohms'}
						fprintf(io, ':MEASURE:RES?');
						if IsUSBPro, fprintf(io, '++read 13'); end
						r = fscanf(io,'%s');
                        rs=str2num(r);
                        retval = rs(3);
                    otherwise % will perform currently selected function
						fprintf(io, ':MEASURE?');
						if IsUSBPro, fprintf(io, '++read 13'); end
						r = fscanf(io,'%s,');
                        %r=[r ,];
                        rs=str2num(r);
                        retval.volt=rs(1);
                        retval.curr=rs(2);
                        retval.ohms=rs(3);
                        retval.time=rs(4);
                        retval.status=dec2bin(rs(5));
                        
				end
				
            otherwise
                if verbose >= 1, fprintf('kpib/KTH_2400: Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
end % end KTH_2400 
 


%% 'HP_54600' Hewlett-Packard digital oscilloscope
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% This code should be valid for all members of the HP 54600 family of oscilloscopes,
%  but later models (i.e., 54622) may have some incompatibilities. This code was
%  tested only against a 54602B.
% Valid instructions:
% 'label'        Write VALUE on the instrument screen. Shows for 3 seconds.
% 'read'         Returns a measurement of type VALUE from CHANNEL (default 1).
%                 Measurement types are:
%                  'amplitude'  the high value minus the low value.
%                  'frequency'  the frequency of the signal.
%                  'peak2peak'  absolute difference between maximum and minimum
%                                values of the waveform.
%                  'rms'        the root mean square voltage.
% 'measure'      Same as 'read'.
% 'display'      Turn a channel display on/off
% 'getdata'      Downloads the complete waveform from the oscilloscope.
%                 The data is returned in a structure:
%                 retval.x
%                 retval.y
%                 retval.units.x  (always 'sec')
%                 retval.units.y  (always 'V')
%

if strcmpi(instrument, 'HP_54600') || strcmpi(instrument, 'HP_54602B') || strcmpi(instrument, 'all')
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            case {'init','initialize'} %ok
            	if verbose >= 2, fprintf(1, 'kpib/HP_54600: Initialize instrument.\n'); end
                fprintf(io,':TIMEBASE:MODE NORMAL'); % necessary for data download
                fprintf(io,':WAVEFORM:FORMAT ASC'); % ASCII format data
                fprintf(io,':ACQUIRE:TYPE NORMAL'); % as opposed to peak or average 
                
            case {'label'} %ok
                fprintf(io,':DISPLAY:TEXT BLANK');
                fprintf(io,':DISPLAY:LINE "%s"',value);
                pause(3)
                fprintf(io,':DISPLAY:TEXT BLANK');
                
            case {'read','measure'} %ok
                if any(channel == [1 2 3 4])
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Channel %d selected.\n',channel); end
                    fprintf(io,':MEAS:SOURCE CHAN%d',channel);
                else % default to channel 1
                    channel=1;
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Default channel is set to %d.\n',channel'); end
                    fprintf(io,':MEAS:SOURCE CHAN%d',channel);
                end
                switch value
                    case {'amplitude','amp','ampl','V'} %ok
                        fprintf(io,':MEAS:VAMP?');
                        retval.val = fscanf(io,'%f');
                        retval.units='V';
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/HP_54600: Channel:',channel,'Amplitude:',retval.val,retval.units);
                        end
                    case {'frequency','freq','f'} %ok
                        fprintf(io,':MEAS:FREQ?');
                        retval.val = fscanf(io,'%f');
                        retval.units = 'Hz';
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/HP_54600: Channel:',channel,'Frequency:',retval.val,retval.units);
                        end
                    case {'peak2peak','p-p','vpp'} %ok
                        fprintf(io,':MEAS:VPP?');
                        retval.val = fscanf(io,'%f');
                        retval.units='V';
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/HP_54600: Channel:',channel,'Peak2Peak:',retval.val,retval.units);
                        end
                    case {'rms','RMS'} %ok
                        fprintf(io,':MEAS:VRMS?');
                        retval.val = fscanf(io,'%f');
                        retval.units = 'Vrms';
                        if verbose >= 2,
                            fprintf(1, '%s %d %s %f %s\n', 'kpib/HP_54600: Channel:',channel,'RMS:',retval.val,retval.units);
                        end
                    otherwise
                        if verbose >= 2, fprintf(1, 'kpib/HP_54600: No valid measurement type selected (V,f,vpp,rms).\n'); end
                end

            case {'autoscale','auto y'} %ok
                fprintf(io,'AUTOSCALE');
                if verbose >= 2, fprintf(1, 'kpib/HP_54600: Autoscale display.\n'); end
            
            case {'display','trace'} % either turn a channel display on/off, or return a binary word
                                     %  (string) representing the state of the four displays
                switch value
                    case {'on','ON'} %ok
                        fprintf(io, ':VIEW CHAN%d',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_54600: Channel %d on.\n',channel); end
                    case {'off','OFF'} %ok
                        fprintf(io, ':BLANK CHAN%d',channel);
                        if verbose >= 2, fprintf(1, 'kpib/HP_54600: Channel %d off.\n',channel); end
                    case {'query','?'} % HP_54600 does not have a display on/off query             
                        for cd=1:4
                            fprintf(io, ':VIEW CHAN%d',cd);
                            if verbose >= 2, fprintf(1, 'kpib/HP_54600: Display state query: Enable all channels\n'); end
                            fprintf(io, ':VIEW CHAN1');
                            fprintf(io, ':VIEW CHAN2');
                            fprintf(io, ':VIEW CHAN3');
                            fprintf(io, ':VIEW CHAN4');
                            retval='1111'; % return hardcoded value
                        end
%                     case {'active','active?'}
%                         fprintf(io,'SELECT?'); % query the channel state
%                         ch = fscanf(io);
%                         retval = sscanf(ch(23:end),'CH%d');
                    otherwise
                        if verbose >= 2, fprintf(1, 'kpib/HP_54600: Error: ''display'' VALUE not understood.\n'); end
                end
            
            case {'channel'} % select a channel
                if verbose >= 2, fprintf('kpib/HP_54600: Channel Select not supported by instrument\n'); end
%                 if any(channel == [1 2 3 4])
%                     fprintf(io,'SELECT:CH%d ON',channel); % select a channel (manual p2-214)
%                     if verbose >= 2, fprintf(1, 'kpib/HP_54600: Channel %d selected.\n',channel); end
%                 end
            
            case 'getdata' %ok
                if ~(any(channel == [1 2 3 4]))
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Default channel 1 selected.\n'); end
                    channel=1;
                else
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Channel %d selected.\n',channel); end
                end
                if ~(isnumeric(aux))
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Default 2000 points.\n'); end
                    aux=2000;
                elseif aux > 0
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: %d data points specified.\n',aux); end
                else
                    aux=2000;
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Default 2000 points.\n'); end
                end                        
             
                if any(channel == [1 2 3 4])
                    fprintf(io,':WAVEFORM:SOURCE CHAN%d',channel); % select channel
                    fprintf(io,':WAVEFORM:POINTS %d',aux); % 2000 data points is default
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Channel %d, %d points.\n',channel,aux); end
                    fprintf(io,':WAVEFORM:FORMAT ASC'); % ASCII format data
         
                    fprintf(io,':DIGITIZE CHAN%d',channel); % capture the data
                    pause(2); % to ensure that digitizing completes
                    fprintf(io,':WAVEFORM:PRE?'); % download the preamble
                    preamble = fscanf(io); % preamble is comma-separated numbers
                    preamble = [preamble,','];

                    % Process the preamble
                    % Preamble has several useful fields (manual p8-18):
                    % (1) FORMAT        : int16 0 = ASCII, 1 = BYTE, 2 = WORD
                    % (2) TYPE          : int16 0 = AVERAGE, 1 = NORMAL, 2 = PEAK DETECT
                    % (3) POINTS        : int32 number of data points transferred
                    % (4) COUNT         : int32 1 and is always 1
                    % (5) XINCREMENT    : float32 - time difference between data points
                    % (6) XORIGIN       : float64 - always the first data point in memory
                    % (7) XREFERENCE    : int32 - specifies the data point associated with x-origin
                    % (8) YINCREMENT    : float32 - voltage difference between data points
                    % (9) YORIGIN       : float32 - value is the voltage at center screen
                    % (10)YREFERENCE    : int16 - specifies data point where y-origin occurs

                    %pre=strread(preamble,'%f','delimiter',',');
                    pre = sscanf(preamble,'%f,');
                    if verbose >= 3
                        fprintf(1, 'kpib/HP_54600: Data preamble:\n');
                        for i=1:length(pre)
                            fprintf(1, '%f\n',pre(i));
                        end
                    end

                    % Read the data from the oscilloscope
                    fprintf(io,':WAVE:DATA?');
                    data = fscanf(io); % data will be a long series of characters
                    nc = str2num(data(2));
                    data=data(nc+3:end); % remove string header "#800008000"
                                        % "#" starts the data
                                        % next character is remaining
                                        % number of characters in string
                                        % header
                                        % Following value is number of
                                        % bytes in data string
                    yval = sscanf([data,','],'%e,');
                    if verbose >= 2, fprintf(1, 'kpib/HP_54600: Data downloaded.\n'); end
                    actualdatapoints = length(yval);
                    
                    % Converts the necessary preamble values from strings into
                    %  numbers.
                    numdatapoints  = pre(3); % The number of data points
                    xincr = pre(5); % The x increment
                    xoffset = pre(6); % The x offset (left side of screen)
                    yincr = pre(8); % The y increment
                    yzero = pre(9); % The y offset
                    yoffset = pre(10); % the y value at the origin
                    
                    % scale the data
                    % the y data is integers from the A-D converter. Scale
                    %  by the values from the preamble
                    retval.y=((yval-yoffset).*yincr)+yzero;
                    % generate the corresponding x values
                    retval.x=([0:1:numdatapoints-1]'*xincr);
                    retval.x = retval.x + xoffset;

                    % assume units
                    retval.units.x = 'sec';
                    retval.units.y = 'V';
                    
                    if actualdatapoints~=numdatapoints
                        if verbose >= 1
                            fprintf(1, 'kpib/HP_54600: WARNING: number of data points received from scope appears to be incorrect.\n');
                            fprintf(1, '              Expected: %d, Received: %d [Using Received]\n',numdatapoints,actualdatapoints);
                            fprintf(1, '              (Try Reset GPIB with ''clear'' or check io.Buffersize)\n');
                            retval.y=retval.y(1:actualdatapoints);
                            retval.x=retval.x(1:actualdatapoints);
                        end
                    end
                    

                else
                    if verbose >= 1, fprintf(1, 'kpib/HP_54600: Error: channel specified incorrectly.\n'); end
                    retval=0;
                end

            otherwise
                if verbose >= 1, fprintf(1, 'kpib/HP_54600: Error, command not supported. ["%s"]\n',command); end
                retval=0;
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
       retval=0;
    end
    
    validInst = 1;    
 end % end HP_54600



%% 'OH_EXP' Ohaus Explorer and Explorer Pro precision balances
% This code should be valid for all members of the Ohaus Explorer and
%  Explorer Pro family of balances, but some advanced features may not be
%  supported. This code was tested only against a Explorer EOL210. Use a
%  serial port to sonnect to this instrument.
%
% NOTE: The default serial port settings for Explorers are 2400/7/2/1,
%  which is unusual. Make life easy for yourself and use the "RS-232" menu
%  on the balance to change the settings to 2400/8/N/1, which is more
%  normal. You may also have to disable the "Auto-Print" feature.
%
% IMPORTANT: The Explorers have a so-called "RS232" port, but they require
%  a custom serial cable that does not conform to any known standard.
%  Regular serial cables will not work! You must use a DE9 cable with the
%  pinout shown in the manual. In addition, data returned is always
%  terminated with a CRLF (two characters).

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'ID?'          Returns instrument ID and firmware revision.
% 'read'         Returns a measurement in the current mode
%                   (default 'weigh' mode) without units. Also 'print'.
% 'measure'      Returns a measurement in the current mode in a structure
%                   with units. Also 'weigh'. If the units result has a "?"
%                   after it, then the balance is not stable. Example:
%                     retval.val = 34
%                     retval.units = 'g'
%                   Use VALUE = 'animal' to start an animal measurement cycle.
% 'units'        Set the units to VALUE ('mg' | 'g' | 'kg' | 'kt' | 'oz'). 
%                   [This is the "mode" of the balance.]
%                   Note the each unit must be "enabled" using the
%                   front-panel Setup menu. If a unit is not enabled, the
%                   'units' command has no effect.
% 'mode'         Set balance to mode VALUE ('weigh' | 'percent' | 'parts' | 'animal')
%                   Use CHANNEL for reference value for percent or parts counting.
%                   [This is the "function" of the balance.]
%                   Note the each mode or function must be "enabled" using the
%                   front-panel Setup menu. If a function is not enabled, the
%                   'mode' command has no effect.
% 'zero'         Set the current value to zero. Also 'O/T'. This is the
%                   same as pressing the "0/T" button on the front panel.
% 'offset'       Set the offset weight value (tare weight) to VALUE in grams.
%                   Also 'tare'.
%
%

if (strcmpi(instrument, 'OH_EXP') || strcmpi(instrument, 'all'))
   baudrate = 2400;  % baud rate for serial port instruments
   io = port(GPIB, instrument, baudrate, verbose);
   if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

       switch command
           case {'ID?','init','version'}
               fprintf(io,'0A');  % auto-print off
               fprintf(io,'V');  % display EEPROM version
               retval = fscanf(io);
               retval=retval(1:end-2); % strip trailing CRLF
               fprintf(io,'SN');  % display serial number
               sn = fscanf(io,'%s');
               unitz = kpib(instrument,GPIB,'units','?',0,0,0);
               func = kpib(instrument,GPIB,'mode','?',0,0,0);
               if verbose >= 2
                   fprintf(1, 'kpib/%s: Initialize:\n    Balance firmware %s\n',instrument,retval);
                   fprintf(1,'    Serial Number: %s.\n',sn);
                   fprintf(1,'    Function: %s, Mode (units): "%s".\n',func,unitz);
               end
               
		   case {'zero','O/T'}
			   fprintf(io,'T');
			   if verbose >= 2, fprintf(1, 'kpib/%s: Balance zero value set.\n',instrument); end

		   case {'units'}
			   switch value
				   case {'mg','MG'}
					   fprintf(io,'1M');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance units set to milligrams ("mg").\n',instrument); end
				   case {'g','G'}
					   fprintf(io,'2M');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance units set to grams ("g").\n',instrument); end
				   case {'kg','KG'}
					   fprintf(io,'3M');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance units set to kilograms ("kg").\n',instrument); end
				   case {'kt','KT','carats','Carats','cd','CD'}
					   fprintf(io,'5M');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance units set to carats ("cd").\n',instrument); end					   
				   case {'oz','OZ','ounces'}
					   fprintf(io,'6M');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance units set to ounces ("oz").\n',instrument); end
				   case {'?','query'}
					   fprintf(io,'?');
					   retval = fscanf(io,'%s');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance units setting is "%s".\n',instrument,retval); end					   
				   otherwise
					   if verbose >= 1, fprintf(1, 'kpib/%s: Warning: Balance units command not understood ("%s")\n',instrument,value); end
				   end

		   case {'mode'}
			   switch value
				   case {'weigh','none'}
					   fprintf(io,'0F');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance mode set to normal weighing.\n',instrument); end
				   case {'%','percent'}
					   fprintf(io,'1F');
					   if channel > 0,
                           cmd = [num2str(channel) '%'];
                           fprintf(io,cmd);
                           if verbose >= 2, fprintf(1, 'kpib/%s: Balance mode set to percent relative to %e grams.\n',instrument,channel); end
                       else
                           if verbose >= 2, fprintf(1, 'kpib/%s: Balance mode set to percent.\n',instrument); end
                           if verbose >= 2, fprintf(1, 'kpib/%s: Warning: reference value not set (use CHANNEL).\n',instrument); end
                       end
                   case {'parts','Parts'}
					   fprintf(io,'2F');
					   if channel > 0,
                           cmd = [num2str(channel) '#'];
                           fprintf(io,cmd);
                           if verbose >= 2, fprintf(1, 'kpib/%s: Balance mode set to parts count relative to %e grams.\n',instrument,channel); end
                       else
                           if verbose >= 2, fprintf(1, 'kpib/%s: Balance mode set to parts.\n',instrument); end
                           if verbose >= 2, fprintf(1, 'kpib/%s: Warning: reference value not set (use CHANNEL).\n',instrument); end
                       end
				   case {'animal','Animal'}
					   fprintf(io,'3F');
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance mode set to Animal Weighing.\n',instrument); end					   
				   case {'?','query'}
					   fprintf(io,'F');
					   retval = fscanf(io,'%s');
                       if strcmp(retval,'None'), retval = 'Normal Weighing ("None")'; end
					   if verbose >= 2, fprintf(1, 'kpib/%s: Balance mode is "%s".\n',instrument,retval); end					   
				   otherwise
					   if verbose >= 1, fprintf(1, 'kpib/%s: Warning: Balance mode command not understood ("%s")\n',instrument,value); end
               end

            case {'read','print','P'}
                fprintf(io,'P');
                ret = fscanf(io);
                % find out if we have a negative value or not
                if isnumeric(sscanf(ret,'%f'))
                    retval = sscanf(ret,'%f');
                else
                    retval = sscanf(ret,'-%f');
                    retval=retval*-1;
                end
                if verbose >= 2, fprintf(1, 'kpib/%s: Balance reads %f\n',instrument,retval); end

            case {'measure','weigh','weight'}
                if ~isnumeric(value) && strcmpi(value,'animal')
                    fprintf(io,'E');
                else
                    fprintf(io,'P');
                    ret = fscanf(io);
                    % find out if we have a negative value or not
                    if isnumeric(sscanf(ret,'%f'))
                        retv = textscan(ret,'%f %s %s');
                        retval.val = retv{1};
                        retval.units = [retv{2}{1} retv{3}{1}];
                        if isempty(retv{2}) && verbose >= 2
                            fprintf(1, 'kpib/%s: Note: unit printing not enabled.\n',instrument);
                        end
                    else
                        retv = textscan(ret,'%c %f %s %s');
                        retval.val = retv{2}*-1;
                        retval.units = [retv{3}{1} retv{4}{1}];
                        if isempty(retv{3}) && verbose >= 2
                            fprintf(1, 'kpib/%s: Note: unit printing not enabled.\n',instrument);
                        end                        
                    end
                end
                if verbose >= 2, fprintf(1, 'kpib/%s: Balance reads %f %s.\n',instrument,retval.val,retval.units); end

            case {'offset','tare'}
                if isnumeric(value)
                   cmd = [num2str(value) 'T'];
                   fprintf(io,cmd);
                   if verbose >= 2, fprintf(1, 'kpib/%s: Balance offset (tare weight) set to %g grams.\n',instrument,value); end
                else
                   if verbose >= 1, fprintf(1, 'kpib/%s: Warning: Offset weight not valid ("%s")\n',instrument,num2str(value)); end
                end

            otherwise
               if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s"]\n',instrument,command); end
        end
               
    else % catch incorrect address errors
        if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
        retval=0;
        
    end
    validInst = 1;
end % End OH_EXP


% %%%%%
%% 'CV_TIC304'  CryoVac TIC 304-MA Temperature Controller
% The CryoVac TIC 304-MA Temperature Controller is sold with the Karl
%  Suss cryogenic probe station. The stsation must be set for "remote" mode
%  by enabling it on the front panel after startup (press "DIAL 8").
%
% Note that the TIC is intended for use with cryogenic systems, so its
%  default temperature units are in Kelvin. The default for temperature
%  units in KPIB is degrees C. Specify units with the AUX parameter ('C' || 'K').
%

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid oven commands:
% 'init'    Initializes instrument and makes ready for measurement
% 'self'    Begin instrument self-destruct procedure
%
if (strcmpi(instrument, 'CV_TIC304') || strcmpi(instrument, 'all'))
   baudrate = 0;  % buffer size for GPIB (0 for default), baud rate for serial port instruments
   io = port(GPIB, instrument, baudrate, verbose);
   if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
       
       lowlim = 20; % lower limit of input in K
       highlim = 125; % upper limit of temerpature in K
       

       switch command
            case 'init'
                if verbose >= 1, fprintf('kpib/%s: Initializing CryoVac at address %.0f\n',instrument,GPIB); end
                % what kind of reset?
                try
                    fprintf(io,'?K1');
                    retval = fscanf(io, '%f');
                    fprintf(1,'kpib/%s: Controller on. Temperature Setpoint %f K.\n',instrument,retval);
                catch
                    fprintf(1,'kpib/%s: Controller does not respond. Verify that it is in remote mode.\n',instrument);
                end

            case {'set','setT'}
                % did user specify a channel?
                if isnumeric(channel) && any(channel==[1 2]) 
                    if verbose >= 2, fprintf('kpib/%s: Channel F%d selected\n',instrument, channel); end
                else
                    channel = 1;
                    if verbose >= 2, fprintf('kpib/%s: Channel F%d (default)\n',instrument, channel); end
                end
                command = sprintf('R%d',channel); fprintf(io,command); % set the active channel                    

                if isnumeric(value) % proceed if a number was entered
                    % did the user specify temperature units?
                    if strcmpi(aux,'K')
                        if verbose >= 2, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument, aux); end
                        valueC = value - 273; % convert to C
                    else
                        aux = 'C'; % default to degrees celcius
                        if verbose >= 3, fprintf('kpib/%s: Temperature units of degrees %s (default)\n',instrument, aux); end
                        valueC = value;
                        value = value + 273; % convert to K                        
                    end
                    
                    % check input range (deg K)
                    if value < lowlim 
                        value = lowlim;
                        if verbose >= 1, fprintf('kpib/%s: Warning: Temperature setpoint below lower limit (%d K)\n',instrument,lowlim); end
                    end
                    if value > highlim
                        value = highlim;
                        if verbose >= 1, fprintf('kpib/%s: Warning: Temperature setpoint above upper limit (%d K)\n',instrument,highlim); end
                    end
                    
                    % set the temperature setpoint (K)
                    command = sprintf('KS %d',value); fprintf(io,command); % set setpoint for current channel
                    if verbose >= 2, fprintf('kpib/%s: Temperature set to %d C (%d K)\n',instrument,valueC,value); end
 
                elseif strcmpi(value,'query') || strcmpi(value,'?')
                    fprintf(io,'?KS'); % query temperature setpoint for current channel
                    retval = fscanf(io, '%f');

                    % did the user specify temperature units?
                    if strcmpi(aux,'K')
                        if verbose >= 2, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument,aux); end
                    else
                        aux = 'C';
                        if verbose >= 3, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument,aux); end
                        retval = retval - 273; % convert to C
                    end
                    if verbose >= 2, fprintf(1,'kpib/%s: Setpoint: %d %s\n',instrument,retval,aux); end
                else
                    if verbose >= 1, fprintf(1,'kpib/%s: "set" command error\n',instrument); end
                end % set

            case {'read','getdata'}
                if isnumeric(channel) && ~any(channel==[1 2]), channel = 1; end % default to channel 1
                if verbose >= 2, fprintf('kpib/%s: Reading the F%d temperature:',instrument,channel); end
                command = sprintf('?K%d',channel); fprintf(io,command); % query temperature
                retval = fscanf(io, '%f');
                % did the user specify temperature units?
                    if strcmpi(aux,'K')
                        if verbose >= 2, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument,aux); end
                    else
                        aux = 'C';
                        if verbose >= 3, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument,aux); end
                        retval = retval - 293; % convert to C
                    end
                if verbose >= 2, fprintf(1,' %.1f %s\n',retval,aux); end

            case 'stop'
                if verbose >= 2, fprintf('kpib/%s: Stopping the Temperature Controller\n',instrument); end
                fprintf(io, 'R0'); % "control off'.
                end

               
   else % catch incorrect address errors
      if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
      retval=0;
   end
   validInst = 1;
end
% %%%%% end 'CV_TIC304'


% %%%%%
%% 'AG_E5071B'   Agilent E5070B/E5071B RF Network Analyzer
% The Agilent E5071B Network Analyzer is a powerful 2-port analyzer.
% NOTE: Analyzer firmware update A.06.51 or higher is required for
%  averaging-related commands.

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% VALUE is typically the modifier to COMMAND.
% Valid Commands:
% 'init'      Resets the Analyzer. Returns the decimal value of the status
%              byte (should be zero for normal condition).
% 'label'     Writes 'VALUE' to the display. No spaces or punctuation.
% 'channel'   Makes channel VALUE the active channel. NOTE: 'channel'
%              (1-16) corresponds to Traces on the analyzer screen. See
%              Note below. To change the Channel, use the parameter 'aux'
%              (1-16). Default is 1.
% 'display'   Controls what is displayed on the Analyzer screen.
%              VALUE can be any of the four registers: 'a','b','c','d' and
%              CHANNEL is 'on' or 'off'.
% 'format'    Set the format of the active trac on the Analyzer display:
%              LogMag, Phase, etc. Use CHANNEL to select the active trace.
%              non-exponentially ('norm'). Exponentially is the default.
% 'scale'     Sets the scale of the display. VALUE is the scale in the
%              current units, or 'VALUE' = 'auto' for autoscale command. 
% 'ref line'  Sets the position of the reference line of the display.
%              VALUE is the position of the reference line in the current
%              units.
% 'average'   Turns averaging on or off, restarts averaging, or returns
%              the current number of averages taken.
%              VALUE='on','off','restart', or 'query'. For 'query', RETVAL
%              returns 0 (off) or the current number of averages (on).
% 'mark2peak' Finds the peak and sets the marker, or finds the peak and
%              sets the peak location to the center of the scan.
%              VALUE='off','center', or 'peak'.
% 'marker'    Turns the marker on or off, or returns the current
%              position of the marker. 'VALUE' = 'on','off', or 'query'.
%              The position is returned as retval.x, retval.y in current
%              units.
% 'center'    Set the center frequency to VALUE. Units of Hz.
%              Query with VALUE = 'query', returns center frequency in Hz.
% 'span'      Set the frequency span VALUE. Units of Hz.
%              Query with VALUE = 'query', returns span in Hz.
% 'sweep'     Sets sweep parameters
% 'source'    Set the source (stimulus output) signal level. VALUE is the
%              desired signal level. Units of dBm.
%              Query with VALUE = 'query', returns source power in dBm.
% 'power'     Same as 'source'.
% 'getdata'   Download the current data trace from the analyzer. Data is
%              returned as two columns, x and y, for the specified
%              CHANNEL. Default CHANNEL is not set. If VALUE is 'x' or 'y',
%              only that data is returned in a single column.
% 'units'     Returns the units of the data from the analyzer. Must
%              specify VALUE = 'x' or 'y' axis units.
% 'pause'     Pauses measurement. Not supported by 4195A.
% 'continue'  Continues paused measurement. Not supported by 4195A.
% 'complete'  Wait for the previous sweep to complete. This command
%              contains a loop that does not exit until the status byte shows
%              that the sweep is complete. Use with 'sweep','single' or
%              'complete','single'.
% 'wait'      Wait for the previous command to complete (*WAI)
%              
%NOTE: The E5070B/E5071B uses "Channels" and "Traces". Channels are a
% particular group of settings for measurement parameters. Traces are
% measurement data that is displayed on the screen. For example, for a
% typical resonator measurement, Channel 1 of the analyzer might be
% configured for a frequency sweep with 0 dBm stimulus power. Trace 1 of
% Channel 1 would show the response amplitude, and Trace 2 of Channel 1
% would show the phase response.
% In KPIB, the parameter CHANNELS refers to the Traces on the analyzer
% screen, and the analyzer is assumed to be configured as described in the
% example above. Use AUX to specify a different Analyzer Channel.
%
if (strcmpi(instrument, 'AG_E5070B') || strcmpi(instrument, 'AG_E5071B') || strcmpi(instrument, 'all'))
   baudrate = 0;  % buffer size for GPIB (0 for default), baud rate for serial port instruments
   io = port(GPIB, instrument, baudrate, verbose);
   if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command

            case 'init'
                if isnumeric(aux) && aux==0, aux=1; end
                %fprintf(io,'*RST');
                fprintf(io,'*CLS');
                fprintf(io,'*STB?');
                retval=fscanf(io,'%d');
                % set data transfer type to ascii
                fprintf(io,':FORM:DATA ASCII');
                % set trigger state to Continuous
                cmd = sprintf(':INIT%d:CONT ON',aux); fprintf(io,cmd);

                
                if verbose >= 2
                	fprintf(1, 'kpib/AG_E5071B: Initialize. Make sure instrument is configured.\n');
                end
                if verbose >= 3
                    fprintf(1,'kpib/AG_E5071B: Status byte: %s\n',dec2bin(retval,8));
                    fprintf(io,'*IDN?');
                    idstring = fscanf(io,'%s');
                    fprintf(1, 'kpib/AG_E5071B: %s\n',idstring);
                	
                end

            case 'label' % manual p477 
                if length(value) > 254
                    value=value(1:254); % 254 chars max
                end
                % no spaces or punctuation allowed
                value(isspace(value)) = '_';
                value(ismember(value,' ,.:;![]{}')) = [];
                if channel==0, channel=1; end
                if ~isnumeric(channel), channel = 1; end
                %cmd = sprintf(':DISP:WIND%d:TITL ON',channel); fprintf(io,cmd);
                cmd = sprintf(':DISP:WIND%d:TITL:DATA %s',channel,value); fprintf(io,cmd);

			case {'channel','CHAN'}
                % NOTE that "traces" are "channels" for our purposes
                %  so this command sets trace 'channel' (PAR) to active
                %  (manual p424)
                if isnumeric(aux) && aux==0, aux=1; end
                if isnumeric(channel) && channel==0 && isnumeric(value), channel=value; end
                cmd = sprintf(':CALC%d:PAR%d:SELECT',aux,channel); fprintf(io,cmd);
                if verbose >= 3
                    fprintf(1, 'kpib/AG_E5071B: Channel %d selected.\n', channel);
                end
                
            case {'display','trace'} %:DISP:WIND1:TRAC1:STAT?  :CALC{1-16}:PAR:COUN?
                if isnumeric(aux) && aux==0, aux=1; end
                switch value
            		case {'dual'} % for compatibility with res_meas
            			switch channel
            				case {'query','?'}
                                cmd = sprintf(':CALC%d:PAR:COUNT?',aux); fprintf(io,cmd);
            					dcount = fscanf(io,'%d'); % up to 16 possible
                                if verbose >= 3, fprintf(1, 'kpib/AG_E5071B: %d Traces displayed.\n', dcount); end
                                if dcount==2
                                    retval=1;
                                else
                                    retval=0;
                                end
                            otherwise
                                % turn on both traces
                                for i=1:2
                                    cmd = sprintf(':DISP:WIND%d:TRACE%d:STAT ON',aux,i); fprintf(io,cmd);
                                end
                                retval = 1;
                        end
                    case {'query','?'}
                        cmd = sprintf(':CALC%d:PAR:COUNT?',aux); fprintf(io,cmd);
                        retval = fscanf(io,'%f'); % up to 16 possible
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: %d Traces displayed.\n', dcount); end
                    case {'on','ON'}
                        if isnumeric(channel) && channel > 0
                            cmd = sprintf(':DISP:WIND%d:TRACE%d:STAT ON',aux,channel); fprintf(io,cmd);
                            if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Trace %d on.\n',channel); end
                        end
                    case {'off','OFF'}
                        if isnumeric(channel) && channel > 0
                            cmd = sprintf(':DISP:WIND%d:TRACE%d:STAT OFF',aux,channel); fprintf(io,cmd);
                            if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Trace %d off.\n',channel); end
                        end                       
                end

            case 'format'
                if isnumeric(aux) && aux==0, aux=1; end
                if isnumeric(channel) && channel ~= 0
                    kpib(instrument,GPIB,'channel',0,channel,aux,verbose);
                elseif channel == 0
                    channel = 1;
                end
                switch value
                    case {'MLOG','logmag','LogMag'}
                        fprintf(io,':CALC%d:FORM MLOG',aux);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Format of Channel [Trace] %d set to LogMag.\n',channel); end
                    case {'PHAS','phase','Phase'}
                        fprintf(io,':CALC%d:FORM PHAS',aux);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Format of Channel [Trace] %d set to Phase.\n',channel); end                       
                    case {'REAL','real','Real'}
                        fprintf(io,':CALC%d:FORM REAL',aux);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Format of Channel [Trace] %d set to Real.\n',channel); end
                    case {'IMAG','imaginary','Imaginary'}
                        fprintf(io,':CALC%d:FORM REAL',aux);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Format of Channel [Trace] %d set to Imaginary.\n',channel); end
                    case {'?','query'}
                        fprintf(io,':CALC%d:FORM?',aux);
                        retval = fscanf(io,'%s');
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Format of Channel [Trace] %d is %s.\n',retval); end
                end
                        
            case 'scale'
                if isnumeric(aux) && aux==0, aux=1; end % the "window" or "channel"
                if channel==0, channel = 1; end % the "trace"

                if isnumeric(value)
                    cmd = sprintf(':DISP:WIND%d:TRAC%d:Y:PDIV %e',aux,channel,value); fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Scale set to %g/division.\n',value); end
                else
                	switch value
                		case {'auto','AUTO'}
		                    cmd = sprintf(':DISP:WIND%d:TRAC%d:Y:AUTO',aux,channel); fprintf(io,cmd);
                    		if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Autoscale channel %d.\n',channel); end
                    	case {'?','query'}
		                	cmd = sprintf(':DISP:WIND%d:TRAC%d:Y:PDIV?',aux,channel); fprintf(io,cmd);
		                	retval = fscanf(io,'%f');
		                	if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Scale on channel %d is %g/division.\n',channel,retval); end
		                case {'lin','linear'}
		                	fprintf(io,'SCT1');
		                	if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Linear X scale.\n'); end
		                case {'log','logarithmic'}
		                	fprintf(io,'SCT2');
		                	if verbose >= 2, fprintf(1, 'kpib/HP_4195A: Logarithmic X scale.\n'); end
		                end
                end

            case {'ref line','refline'} % manual p483
                if isnumeric(aux) && aux==0, aux=1; end % the "window" or "channel"
                if channel==0, channel = 1; end % the "trace"
                if isnumeric(value)
    				cmd = sprintf(':DISP:WIND%d:TRACE%d:Y:RLEV %e',aux,channel,value); fprintf(io,cmd);
                 	if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Reference line set to %g dB.\n',value); end
                else
                    switch value
                        case{'?','query'}
                            cmd = sprintf(':DISP:WIND%d:TRACE%d:Y:RLEV?',aux,channel); fprintf(io,cmd);
                            retval = fscanf(io,'%f');
                    end
                end
                            
            case {'average','averaging'} % manual p543
                if isnumeric(aux) && aux==0, aux=1; end % the "window" or "channel"
                switch value
                    case {'on','ON','yes',1}
                        fprintf(io,':SENS%d:AVER ON',aux);
                        fprintf(io,':TRIG:AVER ON');
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Sweep Averaging on'); end
                        if isnumeric(channel) && channel > 1 && channel < 1000
                            cmd = sprintf(':SENS%d:AVER:COUN %d',aux,channel);
                            fprintf(io,cmd);
                            if verbose >= 2, fprintf(1, ', aver. factor: %d\n',channel); end
                        else
                            if verbose >= 2, fprintf(1, '\n'); end
                        end

                    case {'off','OFF','no',0}
                        fprintf(io,':SENS%d:AVER OFF',aux);
                        fprintf(io,':TRIGGER:AVERAGE OFF');
                        %retval = 0;
        				if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Averaging disabled\n'); end
                    case {'query','?'}
                        fprintf(io, ':SENS%d:AVER?',aux);
                        retval = fscanf(io,'%f');
                    case {'num','num?','number','number?','count','count?'} % return the current average count
                        fprintf(io, ':SENS%d:AVER:COUNT?',aux);
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1, 'kpib/AG_E5071B: Average count: %d\n',retval); end
                        
                    case {'finish','complete'}
                        kpib(instrument,GPIB,'complete','group',channel,aux,verbose);
                        
                    case {'restart','clear'}
                        fprintf(io,':SENS%d:AVER:CLEAR',aux);
                        
                    otherwise % set the number of measurements to average
                        if isnumeric(value) && value > 0
                            if value > 0
                                cmd = sprintf(':SENS%d:AVER:COUNT %d',aux,value); fprintf(io,cmd);
                                if verbose >=2, fprintf(1, 'kpib/AG_E5071B: Averaging factor set to %d\n',value); end
                            end
                        end
                end

            case 'center'
                if channel==0, channel = 1; end % default to channel 1
                switch value
                    case {'query','?'}
                        cmd=sprintf(':SENS%d:FREQ:CENTER?',channel);
                        fprintf(io,cmd);
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=sprintf(':SENS%d:FREQ:CENTER %f',channel,value);
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Center set to %d Hz\n',value); end
                end

            case 'span'
                if channel==0, channel = 1; end % default to channel 1
                switch value
                    case {'query','?'}
                        cmd=sprintf(':SENS%d:FREQ:SPAN?',channel);
                        fprintf(io,cmd);
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=sprintf(':SENS%d:FREQ:SPAN %f',channel,value);
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Span set to %d Hz\n',value); end
                end

            case 'start'
                if channel==0, channel = 1; end % default to channel 1
                switch value
                    case {'query','?'}
                        cmd=sprintf(':SENS%d:FREQ:START?',channel);
                        fprintf(io,cmd);
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=sprintf(':SENS%d:FREQ:START %f',channel,value);
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Start set to %f Hz\n',value); end
                end

            case 'stop'
                if channel==0, channel = 1; end % default to channel 1
                switch value
                    case {'query','?'}
                        cmd=sprintf(':SENS%d:FREQ:STOP?',channel);
                        fprintf(io,cmd);
                        retval = fscanf(io,'%f');
                    otherwise
                        cmd=sprintf(':SENS%d:FREQ:STOP %f',channel,value);
                        fprintf(io,cmd);
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Stop set to %f Hz\n',value); end
                end

            case {'power','source'} %ok
                if isnumeric(aux) && aux==0, aux=1; end
                if channel==0, channel = 1; end % default to channel 1
                if isnumeric(value)
                    cmd = sprintf(':SOUR%d:POW:PORT%d %d',aux,channel,value); fprintf(io,cmd);
                    if verbose >= 2, fprintf('kpib/AG_E5071B:  Source Source Power on Port %d set to %d dBm\n',channel,value); end
                else
                    switch value
                         case {'query','?'}
                            cmd = sprintf(':SOUR%d:POW:PORT%d?',aux,channel); fprintf(io,cmd);
                            retval = fscanf(io,'%f');
                            if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Source Power on Port %d is %d dBm\n',channel,retval); end
                    end
                end

            case {'power?','source?'} % alternate query form
                retval.level=kpib(instrument,GPIB,'source','?',channel,aux,verbose);
                retval.state = 'on';

            case {'marker','mkr'}
                % select the channel (for the marker command only)
                if channel == 0, channel = 1; end % default to channel 1
                if aux == 0, aux = 1; end % default to marker 1
				switch value
					case 'on'
						cmd=sprintf(':CALC%d:MARK%d ON',channel,aux); fprintf(io,cmd);
						if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Marker %d/%d on.\n',channel,aux); end
					case 'off'
						cmd=sprintf(':CALC%d:MARK%d OFF',channel,aux); fprintf(io,cmd);
						if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Marker %d/%d off.\n',channel,aux); end
					case {'query','?'}
						cmd=sprintf(':CALC%d:MARK%d:X?',channel,aux); fprintf(io,cmd);
						retval.x = fscanf(io,'%f');
                        cmd=sprintf(':CALC%d:MARK%d:Y?',channel,aux); fprintf(io,cmd);
						retval.y = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Marker %d on Trace %d at %g Hz, %g.\n',aux,channel,retval.x,retval.y); end
                    case {'center','m2c','mark2center'} % make the marker position the center freq
                        cmd=sprintf(':CALC%d:MARK%d:SET CENT',channel,aux); fprintf(io,cmd);
                        if verbose >= 2, fprintf(1,'kpib/AG_E5071B: Marker to Center\n'); end
                    case {'peak','searchpeak','mark2peak','m2p'}
                        cmd=sprintf(':CALC%d:MARK%d:FUNC:TYPE PEAK',channel,aux), fprintf(io,cmd);                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/AG_E5071B: Marker to Peak'); end
                        cmd=sprintf(':CALC%d:MARK%d:FUNC:EXEC',aux,channel); fprintf(io,cmd); % DO the search
                    case {'min','minimum','valley','antipeak'}
                        cmd=sprintf(':CALC%d:MARK%d:FUNC:TYPE MIN',channel,aux); fprintf(io,cmd);                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/AG_E5071B: Marker to Minimum'); end
                        cmd=sprintf(':CALC%d:MARK%d:FUNC:EXEC',aux,channel); fprintf(io,cmd); % DO the search
                    case {'max','maximum'}
                        cmd=sprintf(':CALC%d:MARK%d:FUNC:TYPE MAX',channel,aux); fprintf(io,cmd);                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/AG_E5071B: Marker to Maximum'); end
                        cmd=sprintf(':CALC%d:MARK%d:FUNC:EXEC',aux,channel); fprintf(io,cmd); % DO the search
                    case {'stop'}
                        cmd=sprintf(':CALC%d:MARK%d:SET STOP',channel,aux); fprintf(io,cmd);                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/AG_E5071B: Marker to Stop'); end
                    case {'start'}
                        cmd=sprintf(':CALC%d:MARK%d:SET START',channel,aux); fprintf(io,cmd);                        
                        if verbose >= 2, fprintf(1,'%s\n','kpib/AG_E5071B: Marker to Start'); end
                    otherwise
                    	if verbose >= 1, fprintf(1, 'kpib/AG_E5071B: Error at ''marker'' command (VALUE incorrect ["%s"]).\n',value); end
                           
                end

            case {'mark2peak','peaktrack'}
                if isnumeric(aux) && aux==0, aux=1; end
                if channel==0, channel = 1; end % default to channel 1                
                switch value
                    case 'center'
                        kpib(instrument,GPIB,'mark2peak','peak',channel,aux,verbose);
                        centerf = kpib(instrument,GPIB,'marker','?',channel,aux,verbose);
                        kpib(instrument,GPIB,'center',centerf.x,channel,aux,verbose);
                        if verbose >= 2, fprintf(1,'kpib/AG_E5071B: Marker to Center (%d Hz)\n',centerf.x); end
                    case 'peak' % choose between MAX or PEAK - which is best?
                        cmd=sprintf(':CALC%d:MARK1:FUNC:TYPE MAX',aux); fprintf(io,cmd);
                        %cmd=sprintf(':CALC%d:MARK%d:FUNC:TYPE PEAK',aux,channel); fprintf(io,cmd);
                        cmd=sprintf(':CALC%d:MARK%d:FUNC:EXEC',aux,channel); fprintf(io,cmd); % DO the search
                        if verbose >= 2, fprintf(1,'%s\n','kpib/AG_E5071B: Marker to Peak'); end
                end

            case {'mode','type'}  %  :CALC{1-16}:PAR{1-16}:DEFS11
                % set or get instrument mode
                % find out what mode the analyzer is in:
                %   Network or Spectrum
                retval = 'NA';
                if verbose >= 2, fprintf('kpib/AG_E5071B: Warning: Analyzer does not support mode query (kpib returns ''NA'').\n'); end

            case 'getdata'
                % Select the channel. For compatibility with old code, the
                %  channel is *not* set if it is not explicitly specified, i.e.,
                %  the default is to do nothing, rather than to select a channel.
                % The E5071 has multiple Traces and Channels. Usually, we
                %  want to download the data from Trace 1 and Trace 2 on
                %  Channel 1.

                % data format should be ASCII (see 'init')
                
                % Normally, we expect to work with Channel 1.
                if isnumeric(aux) && aux==0, aux=1; end
 
                % now, did the user specify a channel or not?
                if channel==0, channel = 1; end
                % Select the desired Trace.
                cmd=sprintf(':CALC%d:PAR%d:SEL',aux,channel); fprintf(io,cmd);
                if verbose >= 2, fprintf('kpib/AG_E5071B: Channel [Trace] %d selected for data download.\n',channel); end
                
                % get Y data
                if verbose >= 3, fprintf('kpib/AG_E5071B: Get Y points.\n'); end
                cmd=sprintf(':CALC%d:DATA:FDAT?',aux); fprintf(io,cmd);
                rawdata = fscanf(io);
                rawdata = [rawdata ',']; % append a comma so that the format matching works right
                retval.y = sscanf(rawdata,'%e,');
                % % Note: Data probably has two numbers per data point;
                % discard every other, depending on data format. See manual page 169
                
                
                % Get Y data units (What kind of data is this?)
                cmd=sprintf(':CALC%d:FORM?',aux); fprintf(io,cmd);
                data_format = fscanf(io,'%s');
                if verbose >= 3, fprintf('kpib/AG_E5071B: Data format is %s.\n',data_format); end
                %'MLOG','PHAS','GDEL','MLIN','SWR','REAL','IMAG','UPH'}
                switch data_format
                    case {'MLOG'}
                        retval.y=retval.y(1:2:end);
                        retval.units.y='dB';
                    case {'PHAS'}
                        retval.y=retval.y(1:2:end);
                        retval.units.y='deg';                           
                end
                
                % double-check the download
                fprintf(io,':SENS:SWEEP:POINTS?');
                numdatapoints = fscanf(io,'%i');
                if (length(retval.y) ~= numdatapoints)
                    if verbose >= 1, fprintf(1, 'kpib/AG_E5071B: WARNING: actual number of y points downloaded (%d)\n',length(retval.y));
                        fprintf(1,'                 does not equal expected number of points (%d).\n',numdatapoints);
                    end
                end
                
                % get the x data points
                if verbose >= 3, fprintf('kpib/AG_E5071B: Get X points.\n'); end
                fprintf(io,':SENS:FREQ:DATA?');
                rawdata = fscanf(io);
                rawdata = [rawdata ',']; % append a comma so that the format matching works right
                retval.x = sscanf(rawdata,'%e,');
                retval.units.x = 'Hz';
                
                % did we just want some numbers?
                switch value
                    case {'x','X'}
                        retval=retval.x;
                    case {'y','Y'}
                        retval=retval.y;
                end


			case 'sweep'
                if isnumeric(aux) && aux == 0, aux =1; end
                % enable the status byte for synchronization (manual p286)
                fprintf(io,'*CLS'); % clear the status registers

                if isnumeric(value) % set the sweep time
                    cmd = sprintf(':SENS%d:SWEEP:TIME %e',aux,value); fprintf(io,cmd);
                else
                    switch value
                        % set sweep type manual p696
                        case {'linear sweep','lin','linear'}
                            cmd = sprintf(':SENS%d:SWEEP:TYPE LIN',aux); fprintf(io,cmd);
                        case {'log sweep','log','logarithmic'}
                            cmd = sprintf(':SENS%d:SWEEP:TYPE LOG',aux); fprintf(io,cmd);
                        case {'segment'}
                            cmd = sprintf(':SENS%d:SWEEP:TYPE SEG',aux); fprintf(io,cmd);
                        case {'power','power sweep','osc','osclevel'} %
                            cmd = sprintf(':SENS%d:SWEEP:TYPE POW',aux); fprintf(io,cmd);
                        case {'query','?'}
                            cmd = sprintf(':SENS%d:SWEEP:TYPE?',aux); fprintf(io,cmd);
                            retval=fscanf(io,'%s');
                            
                        % perform sweep action
                        
                        case {'single'}
                            fprintf(io,':TRIGGER:SOURCE BUS');
                            fprintf(io,':TRIGGER:AVERAGE OFF');
                            %cmd = sprintf(':INIT%d:CONT OFF',aux); fprintf(io,cmd);
                            %cmd=sprintf(':INIT%d',aux); fprintf(io,cmd); % get out of "hold" state, into "wait" state
                            fprintf(io,':TRIGGER:SINGLE');
                            if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Begin single sweep.\n'); end
                        case {'continuous','cont'}
                            fprintf(io,':TRIGGER:SOURCE INTERNAL');
                            cmd = sprintf(':INIT%d:CONT ON',aux); fprintf(io,cmd);
                            if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Continuous sweep mode on.\n'); end
                        case {'hold'} % toggle hold state on or off
                            fprintf(io,':INIT%d:CONT?',aux);
                            holdstate = fscanf(io,'%d');
                            if holdstate == 0
                                cmd = sprintf(':INIT%d:CONT ON',aux); fprintf(io,cmd);
                                if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Continuous mode ON.\n'); end
                            elseif holdstate == 1
                                cmd = sprintf(':INIT%d:CONT OFF',aux); fprintf(io,cmd);
                                if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Continuous mode OFF ("Hold").\n'); end
                            else
                                if verbose >= 1, fprintf(1, 'kpib/AG_E5071B: WARNING: Hold State uncertain.\n'); end
                            end
                            %if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Continuous sweep mode off ("hold").\n'); end
                        % This command requires analyzer firmware update A.06.51+
                        % manual p803
                        case {'group','groups','number','N'}
                            fprintf(io,':TRIG:AVER ON');
                            %cmd=sprintf(':INIT%d',aux); fprintf(io,cmd);
                            fprintf(io,':TRIG:SING'); % this triggers a single group of measurements
                            if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Group sweep (averaging) started.\n'); end
                        case {'setpoints','set','numpoints'}
                            if isnumeric(channel) && channel >= 2 && channel <= 1601 % maximum points is 1601 (p693)
                                cmd = sprintf(':SENS%d:SWEEP:POINTS %d',aux,channel); fprintf(io,cmd);
                                if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Number of sweep points set to %d.\n',channel); end
                            else
                                if verbose >= 1, fprintf(1, 'kpib/AG_E5071B: Number of sweep points must be between 2 and 1601.\n'); end
                            end
                        case {'restart'}
                        	fprintf(io,':ABORT');
                        otherwise
                            if verbose >= 1, fprintf(1, 'kpib/AG_E5071B: Sweep sub-command not supported ["%s"]\n',num2str(value)); end
                    end
                end
                


            case 'complete'
                % complete uses the status byte to know when a sweep has completed.
                % The registers are enabled during the sweep command, above.

                % can issue a single command for a sweep and complete
                switch value
                    case {'single','sing','SING'}
                        kpib(instrument, GPIB, 'sweep', 'single', channel, aux, verbose);
                        if verbose >= 2, fprintf('kpib/AG_E5071B: Single Sweep & Complete\n'); end
                    case {'group','groups','number','N'}
                        kpib(instrument, GPIB, 'average', 'on', channel, aux, verbose);
                        num=kpib(instrument, GPIB, 'average', 'number?', channel, aux, verbose);
                        %num=fscanf(io,'%d');
                        kpib(instrument, GPIB, 'sweep', 'group', channel, aux, verbose);
                        if verbose >= 2, fprintf('kpib/AG_E5071B: Group Sweep (%d) & Complete\n',num); end
                    otherwise
                        if verbose >= 2, fprintf('kpib/AG_E5071B: Waiting for command to complete...\n'); end
                end
                % set status register when operation completes (manual p288)
                fprintf(io,'*OPC');
                
                if verbose >= 2, fprintf('kpib/AG_E5071B: Waiting for sweep to complete...\n'); end
                warning off instrument:fscanf:unsuccessfulRead
                
                retval=0;
                while 1
                    pause(1);
                    fprintf(io,'*ESR?'); % check the event status register byte (manual p879)
                    retval=fscanf(io,'%d');
                    esb=dec2bin(retval,8); % return binary value represents the status registers
                    if verbose >= 3, fprintf(1, 'kpib/AG_E5071B: Status Reg. Byte: %s.\n',esb); end
                    if esb(8) == '1' % Bit 1 indicates operation complete
                        if verbose >= 2, fprintf(1, 'kpib/AG_E5071B: Sweep complete.\n'); end
                       break;
                    end
                end
                %cmd=sprintf(':INIT%d',aux); fprintf(io,cmd); % get out of "hold" state, into "wait" state


			case 'units' % DEPRECATED
				switch value
					case {'x','X'}
						retval = 'Hz';
					case {'y','Y'}
						retval = 'dB';
					otherwise
						retval.x = 'Hz';
						retval.y = 'dB';
				end

			case 'wait'  % This doesn't usually have much effect
                fprintf(io,'*WAI');
                retval = 1;

			case 'continue'
                retval = 1;
                if verbose >= 3, fprintf('kpib/%s: WARNING: ''%s'' not supported by %s\n',command,instrument); end

			case 'pause'
                retval = 1;
                if verbose >= 2, fprintf('kpib/AG_E5071B: WARNING: ''pause'' not supported; maybe you want (''sweep'',''hold'')?\n'); end
                if verbose >= 3, fprintf('kpib/%s: WARNING: ''%s'' not supported by %s\n',command,instrument); end


           otherwise
               if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s"]\n',instrument,command); end
       end
               
   else % catch incorrect address errors
      if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
      retval=0;
   end
   validInst = 1;
end
% %%%%% end 'AG_E5071B'




%% 'SI_9700' Scientific Instruments model 9700 Temperature Controller
% The SI 9700 temperature controller maintains temperature at a setpoint.
%
%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'        make sure the controller is ready for operation.
% 'set','setT'  Set the temperature setpoint for automatic temperature
%                control. Use VALUE = 'query' or '?' to query. Can specify
%                temperature units (AUX == 'C' or 'K'), default to 'C'.
% 'sensor'      Specify which sensor channel (CHANNEL == 'A' or 'B') should
%                be used for controller input.
% 'manual'      Set the controller to manual mode and set the output to
%                VALUE percent. + = heating, - = cooling.
%                Note that in the documentation, "manual" means "normal PID
%                control", while "fixed" means "manual control of heater".
%                Also 'fixed'.
% 'read'        Read the current temperature from the feedback sensor.
%                Also 'getdata'.
% 'on','go'     Set the controller for automatic mode (control temperature).
% 'off','stop'   Stop controlling temperature (manual mode) and set output
%                power to zero.
% 'status'      Return an array with status information for the controller.
%                (See manual p8-5).
%
if (strcmpi(instrument, 'SI_9700') || strcmpi(instrument, 'all'))
    baudrate = 0;  % buffer size for GPIB (0 for default), baud rate for serial port instruments
    io = port(GPIB, instrument, baudrate, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
       
   
       lowlim = -100; % lower limit of input in C
       highlim = 300; % upper limit of temperature in C

        switch command
            case 'init'
                
                kpib(instrument,GPIB,'stop',value,channel,aux,verbose);
                retval=kpib(instrument,GPIB,'status',value,channel,aux,2);
             
            case {'set','setT'}
                % did the user specify temperature units?
                    if strcmpi(aux,'K')
                        if verbose >= 2, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument, aux); end
                        valueC = value - 273; % save value in C
                    else
                        aux = 'C'; % default to degrees celcius
                        if verbose >= 3, fprintf('kpib/%s: Temperature units of degrees %s (default)\n',instrument, aux); end
                        valueC = value;
                        value = value + 273; % convert to K                        
                    end
                
                if isnumeric(value)
                    % check input range (deg C)
                    if valueC < lowlim 
                        valueC = lowlim;
                        if verbose >= 1, fprintf('kpib/%s: Warning: Temperature setpoint below lower limit (%d K)\n',instrument,lowlim); end
                    end
                    if valueC > highlim
                        valueC = highlim;
                        if verbose >= 1, fprintf('kpib/%s: Warning: Temperature setpoint above upper limit (%d K)\n',instrument,highlim); end
                    end
                    
                    % set the temperature setpoint (K)
                    command = sprintf('SET %.2f',value); fprintf(io,command); % set setpoint for current channel
                    if verbose >= 2, fprintf('kpib/%s: Temperature setpoint set to %.3f C (%.3f K)\n',instrument,valueC,value); end
 
                elseif strcmpi(value,'query') || strcmpi(value,'?')
                    fprintf(io,'SET?'); % query temperature setpoint
                    retval = fscanf(io, 'SET %f',1);
                    %retval = sscanf(stringin,'%f')

                    % did the user specify temperature units?
                    if strcmpi(aux,'K')
                        if verbose >= 2, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument,aux); end
                    else
                        aux = 'C';
                        if verbose >= 3, fprintf('kpib/%s: Temperature units of degrees %s\n',instrument,aux); end
                        retval = retval - 273; % convert to C
                    end
                    if verbose >= 2, fprintf(1,'kpib/%s: Setpoint: %.2f %s\n',instrument,retval,aux); end
                
                else
                    if verbose >= 1, fprintf(1,'kpib/%s: "%s" command error\n',instrument,command); end
                end % set
    
            case {'manual','fixed'}
                if isnumeric(channel) % which channel for sensing?               
                	if channel == 1, channelname = 'A';
                    elseif channel == 2, channelname = 'B';
                    else channel = 1; channelname = 'A'; % default to channel 1
                    end                    
                elseif strcmpi(channel,'A')
                	channel = 1; channelname = 'A';
                elseif strcmpi(channel,'B')
                    channel = 2; channelname = 'B';
                else channel = 1; channelname = 'A';  % default to channel 1
                end
                
                if isnumeric(value) && value <= 100 && value >= 0
                    fprintf(io,'MODE 5'); % fixed output (percentage)
                    command = sprintf('FIXD %d,%f',channel,value); fprintf(io,command);
                    if verbose >= 2, fprintf('kpib/%s: Fixed heater output at %f %% :',instrument,value,channelname); end
                else
                    if verbose >= 1, fprintf(1,'kpib/%s: "%s" command error, check VALUE\n',instrument,command); end
                end
                
            case {'sensor','channel'}
                if isnumeric(channel) % which channel?            
                	if channel == 1, channelname = 'A';
                    elseif channel == 2, channelname = 'B';
                    else channel = 1; channelname = 'A'; % default to channel 1
                    end                    
                elseif strcmpi(channel,'A')
                	channel = 1; channelname = 'A';
                elseif strcmpi(channel,'B')
                    channel = 2; channelname = 'B';
                else channel = 1; channelname = 'A';  % default to channel 1
                end
                 
                if strcmpi(value,'query') || strcmpi(value,'?')
                    fprintf(io,'CSEN?');
                    sensechan = fscanf(io,'CSEN %d',1);
                    if verbose >= 2
                        fprintf(1, 'kpib:/%s: Sensor using ',instrument);
                        if sensechan == 1, fprintf(1, 'Channel A (1)\n');
                        elseif sensechan == 2, fprintf(1, 'Channel B (2)\n');
                        else fprintf(1, 'Channel XX (error)\n');
                        end
                    end
                elseif strcmpi(value,'A')
                    fprintf(io,'CSEN 1');
                    if verbose >= 2, fprintf('kpib/%s: Using sensor Channel A\n',instrument); end
                elseif strcmpi(value,'B')
                    fprintf(io,'CSEN 2');
                    if verbose >= 2, fprintf('kpib/%s: Using sensor Channel B\n',instrument); end
                else
                    command = sprintf('CSEN %d',channel); fprintf(io,command);
                    if verbose >= 2, fprintf('kpib/%s: Using sensor Channel %s\n',instrument,channelname); end
                end

                    
            case {'read','getdata'}
                if isnumeric(channel) % which channel?               
                	if channel == 1, channelname = 'A';
                    elseif channel == 2, channelname = 'B';
                    else channel = 1; channelname = 'A'; % default to channel 1
                    end                    
                elseif strcmpi(channel,'A')
                	channel = 1; channelname = 'A';
                elseif strcmpi(channel,'B')
                    channel = 2; channelname = 'B';
                else channel = 1; channelname = 'A';  % default to channel 1
                end
                    
                if verbose >= 2, fprintf('kpib/%s: Channel %s temperature:',instrument,channelname); end
                command = sprintf('T%s?',channelname); fprintf(io,command); % query temperature
                if channel == 1, retval = fscanf(io, 'TA %f',1); end
                if channel == 2, retval = fscanf(io, 'TB %f',1); end
                % did the user specify temperature units?
                    if strcmpi(aux,'K')
                        if verbose >= 3, fprintf('(%s: Temperature units of degrees %s) ',instrument,aux); end
                    else
                        aux = 'C';
                        if verbose >= 3, fprintf('(%s: Temperature units of degrees %s) ',instrument,aux); end
                        retval = retval - 273; % convert to C
                    end
                if verbose >= 2, fprintf(1,' %.3f %s\n',retval,aux); end

			
            case {'stop','off','STOP','OFF'}
                fprintf(io,'MODE 1'); % stop controlling
                if verbose >= 2, fprintf('(kpib:/%s: Controller STOP\n',instrument); end

            case {'go','on'}
                fprintf(io,'MODE 2'); % start controlling
                fprintf(io,'SET?'); % query temperature setpoint for current channel
                retval = fscanf(io, 'SET %f',1);
                fprintf(io,'CSEN?'); % which channel?
                sensechan = fscanf(io,'CSEN %d',1);
                if verbose >= 2
                    fprintf(1, 'kpib:/%s: Controller ON (Setpoint %.1f C, ',instrument,retval);
                    if sensechan == 1, fprintf(1, 'Channel A)\n');
                    elseif sensechan == 2, fprintf(1, 'Channel B)\n');
                    else fprintf(1, 'Channel XX)\n');
                    end
                end
                
            case {'status'}
                fprintf(io,'STA?');
			    retvalstring = fscanf(io, '%s');
                if verbose >= 3, disp(retvalstring); end
			    retval=sscanf(retvalstring,'STA%f,%f,%d,%d,%d,%d,%d');
                if verbose >= 2,
                    fprintf('kpib/%s:\n', instrument);
                    fprintf('  Setpoint: %f K\n',retval(1));
                    fprintf('  Heater Output: %f %%\n',retval(2));
                    fprintf('  Operating Mode: %d, ',retval(3));
                    switch retval(3)
                        case 1
                            fprintf('Stop\n');
                        case 2
                            fprintf('Manual (Normal Control)\n');
                        case 3
                            fprintf('Program\n');
                        case 4
                            fprintf('AutoTune\n');
                        case 5
                            fprintf('Fixed Output\n');
                    end
                    if retval(4)==0, fprintf('  WARNING: Heater Alarm\n');
                    elseif retval(4)==1, fprintf('  No Heater Alarm\n');
                    else fprintf('  WARNING: Heater Status: %d',retval(4));
                    end
                    if retval(5)==0, fprintf('  GUI Refresh required\n');
                    elseif retval(5)==1, fprintf('  GUI Refresh not required\n');
                    else fprintf('  WARNING: GUI Status: %d\n',retval(5));
                    end
                    if retval(6)==0, fprintf('  Normal PID control\n');
                    elseif retval(6)==1, fprintf('  Zone PID control\n');
                    else fprintf('  WARNING: PID Type: %d\n',retval(6));
                    end
                    fprintf('  PID Zone: %d\n',retval(7));
                end
                
                fprintf(io,'CSEN?');
                sensechan = fscanf(io,'CSEN %d',1);
                if sensechan == 1, fprintf(1, '  Sense Channel A\n');
                elseif sensechan == 2, fprintf(1, '  Sense Channel B\n');
                else fprintf(1, '  Sense Channel XX\n');
                end
                fprintf(1,'\n');
                 

           otherwise
               if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s"]\n',instrument,command); end
       end
               
   else % catch incorrect address errors
      if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
      retval=0;
   end
   validInst = 1;
end %%%%% end SI_9700


% %%%%%
%% 'FLK_294' Fluke 294 Waveform generator
% The Fluke 294 arbitrary waveform generator has 4 output channels.
% This version (kpib v4.8) does not include support for arbitrary
% waveforms.
%
% Note that the Fluke GPIB interface is a little sketchy, and appears to
% require that EOSMode is set to 'read&write', with EOSChar of 'LF'. This
% is handled in the PORT function.

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid commands:
%
% 'init'   Initializes instrument and makes ready for measurement ("*RST").
%
% 'sine' / 'square' / 'triangle' / 'ramp'
%           Set the output to the specified waveform. VALUE is the
%            frequency in Hz, CHANNEL is the output CHANNEL, and AUX is
%            the offset in volts.
%
% 'phase'   Set the output phase on CHANNEL to VALUE degrees.
% 'offset'  Set the DC offset to VALUE volts on CHANNEL.
% 'amplitude'
%           Set the output amplitude on CHANNEL to VALUE in units of AUX,
%           which can be ['Vpp' | 'Vrms' | 'dBm'] (default Vpp).
% 'on'      Enables output on CHANNEL
% 'off'     Disables output on CHANNEL
%
if (strcmpi(instrument, 'FLK_294') || strcmpi(instrument, 'all'))
    
    baudrate = 0;  % buffer size for GPIB (0 for default), baud rate for serial port instruments
    io = port(GPIB, instrument, baudrate, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        % This a multi-channel instrument, so CHANNEL should be specified.
        % If not, the command applies to the last-selected channel, or
        % channel 1 after power-up/reset/init.
        
        % check CHANNEL
        if any(channel == [1 2 3 4])
            fprintf(io, 'SETUPCH %d',channel);
        else
            if verbose >= 1, fprintf(1,'kpib/FLK_294: WARNING: no channel selected (''%s'')\n',command); end
        end
        
        switch command
            case 'init'
                fprintf(io,'*RST'); % reset the instrument
                
            case {'sin','sine'}
                fprintf(io,'WAVE SINE');
                if verbose >= 2, fprintf(1, 'kpib/FLK_294: Channel %d Sine wave; ',channel); end
                if isnumeric(value) && value > 0
                    fprintf(io,'FREQ %f',value);
                    if verbose >= 2, fprintf(1, 'Freq: %g Hz; ',value); end
                end
                if isnumeric(aux) && aux > 0
                    fprintf(io,'DCOFFS %f',aux);
                    if verbose >= 2, fprintf(1, 'Offset: %g V',aux); end
                end
                if verbose >= 2, fprintf(1, '\n'); end
                
            case {'square','SQUARE'}
                fprintf(io,'WAVE SQUARE');
                if verbose >= 2, fprintf(1, 'kpib/FLK_294: Channel %d Sine wave; ',channel); end
                if isnumeric(value) && value > 0
                    fprintf(io,'FREQ %f',value);
                    if verbose >= 2, fprintf(1, 'Freq: %g Hz; ',value); end
                end
                if isnumeric(aux) && aux > 0
                    fprintf(io,'DCOFFS %f',aux);
                    if verbose >= 2, fprintf(1, 'Offset: %g V',aux); end
                end
                if verbose >= 2, fprintf(1, '\n'); end
                
            case {'triangle','TRI'}
                fprintf(io,'WAVE TRIANG');
                if verbose >= 2, fprintf(1, 'kpib/FLK_294: Channel %d Triangle wave; ',channel); end
                if isnumeric(value) && value > 0
                    fprintf(io,'FREQ %f',value);
                    if verbose >= 2, fprintf(1, 'Freq: %g Hz; ',value); end
                end
                if isnumeric(aux) && aux > 0
                    fprintf(io,'DCOFFS %f',aux);
                    if verbose >= 2, fprintf(1, 'Offset: %g V',aux); end
                end
                if verbose >= 2, fprintf(1, '\n'); end                

            case {'ramp','RAMP','saw'}
                fprintf(io,'WAVE POSRMP');
                if verbose >= 2, fprintf(1, 'kpib/FLK_294: Channel %d Ramp (positive) wave; ',channel); end
                if isnumeric(value) && value > 0
                    fprintf(io,'FREQ %f',value);
                    if verbose >= 2, fprintf(1, 'Freq: %g Hz; ',value); end
                end
                if isnumeric(aux) && aux > 0
                    fprintf(io,'DCOFFS %f',aux);
                    if verbose >= 2, fprintf(1, 'Offset: %g V',aux); end
                end
                if verbose >= 2, fprintf(1, '\n'); end                 

            case {'amplitude', 'ampl', 'amp'}
                if ~any(strcmpi(aux,{'Vpp','Vrms','dBm'}))
                    aux='Vpp';
                end
                fprintf(io,'AMPUNIT %s',upper(aux));
                fprintf(io,'AMPL %f',value);
                if verbose >= 2, fprintf(1, 'kpib/FLK_294: Channel %d Amplitude: %g %s\n',channel,value,aux); end
            
            case {'offset','offs'}
                if isnumeric(value)
                    fprintf(io,'DCOFFS %f',value)
                    if verbose >= 2, fprintf(1, 'kpib/FLK_294: Channel %d DC offset: %g V\n',channel,value); end
                else
                    if verbose >= 0, fprintf(1, 'kpib/FLK_294: Error: Offset incorrectly specified (must be a number)\n'); end
                end

            case {'phase','phse'}
                if isnumeric(value)
                    fprintf(io,'PHASE %f',value)
                    if verbose >= 2, fprintf(1, 'kpib/FLK_294: Channel %d Phase: %d deg\n',channel,value); end
                else
                    if verbose >= 0, fprintf(1, 'kpib/FLK_294: Error: Phase incorrectly specified (must be a number)\n'); end
                end

            case {'channel','CH'} % set channel using VALUE
                if any(value == [1 2 3 4])
                    fprintf(io, 'SETUPCH %d',value);
                    if verbose >= 2, fprintf(1,'kpib/FLK_294: Channel %d selected\n',value'); end
                else
                    if verbose >= 0, fprintf(1, 'kpib/FLK_294: Error: Channel not set. Channel selection (VALUE) must be 1-4\n'); end
                end                        

            case {'off','OFF','stop','STOP'}
                fprintf(io, 'OUTPUT OFF'); % Disables output on selected channel.
                if verbose >= 2, fprintf(1, 'Channel %d output off.\n', channel); end
                
            case {'on','ON','go','GO'}
                fprintf(io, 'OUTPUT ON'); % Disables output on selected channel.
                if verbose >= 2, fprintf(1, 'Channel %d output on.\n', channel); end

            otherwise
               if verbose >= 1, fprintf(1,'kpib/%s: Error, command not supported. ["%s"]\n',instrument,command); end
        end
               
   else % catch incorrect address errors
      if verbose >= 1, fprintf(1,'kpib/%s: ERROR: No instrument at GPIB %s\n',instrument,num2str(GPIB)); end
      retval=0;
   end
   validInst = 1;
end
% %%%%% end <FLK_294>


% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
% % end of instrument drivers
% %  add new instruments above this line
% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%

% % Trap invalid instrument calls.  If the drivers above did not recognize
% % the instrument then we issue an error.

if validInst == 0;
    if verbose >= 1
        fprintf(1, 'kpib: ERROR, invalid instrument ["%s/%s"].\n',instrument,num2str(GPIB));
    end
    retval=0;
end

return

%% function port
function io = port(addressGPIB, instrument, value, verbose)
% IO = PORT(ADRESSGPIB, INSTRUMENT, VALUE, VERBOSE)
% PORT opens a GPIB or a serial port connection for a device. If
%  addressGPIB is a number, the connection is GPIB. If addressGPIB is a
%  string (e.g. 'COM1'), the connection is through a serial port. The
%  INSTRUMENT parameter allows port to adjust settings specific to each
%  instrument (mostly buffer size). VALUE is the buffer size for GPIB or
%  the baudrate for serial connections. VERBOSE level of 3 provides some
%  debugging details about the connection.
%
% PORT is hardwired to use a single National Instruments GPIB card.
%  If you are using different GPIB hardware, comment in/out the appropriate
%  section below.
%
% based on PORT by AP JUL2004
%

ioTimout           = 5;   % Seconds that we wait for an instrument to reply before giving up
ioInBuffsize       = 1000; % Minimum buffer size for GPIB inputs
serialTerminator   = 'LF'; % default value for serial port

% verbose defaults to on
if nargin < 4
    verbose = 2;
end
% input buffer defaultset above
if nargin < 3
    value = ioInBuffsize;
end

% certain instruments require minimum buffer sizes or other special treatment
%  if the user has specified a larger buffer size, use it, but not smaller
if isequal(instrument,'HP_89410A')  %Test to see whether or not to implement special case.
    ioInBuffsize       = 24*4097;   %Buffer size for 4097 numbers at 18 characters each.
    ioTimout           = 30;
end                                 % Note: I had to increase the buffer size to 24
                                    % to make it work. Don't know why.% MH AUG2005
if isequal(instrument,'HP_4395A')  %Test to see whether or not to implement special case.
    ioInBuffsize       = 64*4097;  %Buffer size for 4097 numbers at 18 characters each.
end
if isequal(instrument,'HP_8560A')  %Test to see whether or not to implement special case.
    ioInBuffsize       = 8*601;    %Buffer size for 601 numbers at 8 bytes each.
end
if isequal(instrument,'HP_4195A')  %Test to see whether or not to implement special case.
    ioInBuffsize       = 18*401;    %401 is max number of points?
end
if isequal(instrument,'AG_E5071B')  %Test to see whether or not to implement special case.
    ioInBuffsize       = 40*1601;    %1601 is max number of points
end
if isequal(instrument,'TEK_TDS') || isequal(instrument,'TDS_540')
    ioInBuffsize       = 50000;    %Buffer size for 50000 numbers of 1 byte each.
end
if isequal(instrument,'HP_54600') || isequal(instrument,'HP_54602B')
    ioInBuffsize       = 50000;    %Buffer size for 50000 numbers of 1 byte each.
end
if isequal(instrument,'HP_34420A') %Test to see whether or not to implement special case.
    ioInBuffsize       = 50000*16; %Buffer size for 50000 numbers of 1 byte each.
    ioTimout           = 10;       %100 % May need to increase timeout for automatic data collection.
end
if isequal(instrument,'HP_34401A')   %Test to see whether or not to implement special case.
    ioInBuffsize       = 50000*16;   %The 34401A can store a large number of measurements
                                     % and then download them later.
end
if isequal(instrument,'HP_8753ES')
    ioInBuffsize = 18*1601;         %1601 is max number of points
end
if isequal(instrument,'OH_EXP')
    serialTerminator   = 'CR/LF';   % The Ohaus Explorers require CR/LF terminator.

end

% if isequal(instrument,'writeread') && nargin > 2
%     ioInBuffsize       = value;    %This allows for 'writeread' to set buffersize.
% end

% maybe the user wants some arbitrary value
if value > ioInBuffsize
    ioInBuffsize = value;
end

%% port: serial port instrument
% is this a GPIB instrument or a serial instrument?

% if GPIB is not a number, then it must be a serial port
if ~isnumeric(addressGPIB)
	% check to see if the port exists already
    if isempty(instrfind('Type','serial','Port',addressGPIB))
        io = serial(addressGPIB,'BaudRate',value);
        %io.InputBufferSize = ioInBuffsize;
        io.Timeout = ioTimout;
        io.Terminator = serialTerminator;
        fopen(io);
        stopasync(io);
        if verbose >= 3
            fprintf(1,'kpib/port: Opening port %s',addressGPIB);
            b=get(io,'BaudRate');
            p=get(io,'Parity');
            s=get(io,'StopBit');
            t=get(io,'Terminator');
            fprintf(1,' with %d baud, Parity %s, %d stopbits, Terminator: %s  \n',b,p,s,t);
        end

    else
    io = instrfind('Type','serial','Port',addressGPIB);
        if ~isequal(io.Status,'open')
            fopen(io);
            if verbose >= 3, fprintf('kpib/port: Existing serial port is closed; open it (%s)\n',num2str(addressGPIB)); end
        end    
        if verbose >= 3
            fprintf(1,'kpib/port: Port %s is already open',addressGPIB);
            b=get(io,'BaudRate');
            p=get(io,'Parity');
            s=get(io,'StopBit');
            t=get(io,'Terminator');
            fprintf(1,' with %d baud, Parity %s, %d stopbits, Terminator: %s  \n',b,p,s,t);
        end
    end
        
%% port: GPIB instrument

% else if GPIB is a number, its a GPIB address
else 

    % % Choose between "regular" (PCI or similar) and USB (virtual serial port)
    % %   GPIB interface hardware by commenting in/out the appropriate section below

    % % Uncomment for regular GPIB interface card (e.g. PCI)
    
%% port: GPIB PCI
    if isempty(instrfind('Type','gpib','PrimaryAddress',addressGPIB))
        try    
            % CHANGE FOLLOWING LINE TO USE DIFFERENT GPIB CARD MANUFACTURER    GPIBMAN 
            %  See MATLAB documentation for list of supported manufacturers
            %  http://www.mathworks.com/products/instrument/supportedio13769.html
            % (If using USB with a COM port, then comment out this section and see below)
            gpib_interface_manufacturer = 'ni'; % 'ni'   National Instruments
                                                % 'ics'  ICS Electronics
            
            io = gpib(gpib_interface_manufacturer,0,addressGPIB);
            io.InputBufferSize = ioInBuffsize;
            io.Timeout = ioTimout;
            fopen(io);
            if verbose >= 3, fprintf('kpib/port: Create new GPIB port (%d).\n',addressGPIB); end

        catch
            if verbose >= 1
                fprintf('kpib/port: ERROR: cannot open GPIB address %d on interface %s\n',addressGPIB,gpib_interface_manufacturer);
                fprintf('           Use ''scan'' to see a list of available instruments.\n');
            end
            io = 0;
        end

    else
        io = instrfind('Type','gpib','PrimaryAddress',addressGPIB);
        if verbose >= 3, fprintf('kpib/port: Use existing GPIB port (%d).\n',addressGPIB); end
            if ~isequal(io.Status,'open')
                fopen(io);
                if verbose >= 3, fprintf('kpib/port: Existing port is closed; open it (%d).\n',addressGPIB); end
            end
    end

        % the End of Statement (EOS) setting is default none. The KTH_236
        %  often hangs, and it defaults to CRLF. The 'init' should set this,
        %  but maybe this helps also. Hard to say.
        % At least it doesn't seem to harm anything else... (MH, v3.2)
    if io ~= 0
        if any(strcmp(instrument,{'KTH_236' 'FLK_294' 'HP_8753ES'}))
            set(io,'EOSMode','read&write'); % this setting may cause problems with USB adapters such as ICS
            set(io,'EOSCharCode','LF'); % 'LF' is default
        end
        if verbose >= 3
            EOScc=get(io,'EOSCharCode');
            EOSmode=get(io,'EOSMode');
            TmOut=get(io,'Timeout');
            BufSz=get(io,'InputBufferSize');
            fprintf('kpib/port: EOSMode: %s; EOSCharCode: %s; Timeout: %d sec; Buffer Size: %d bytes\n',EOSmode,EOScc,TmOut,BufSz);
        end
    end

    % % End Regular GPIB interface card
 

%% port: GPIB serial
    
% 	  % % Begin Enable Prologix USB/GPIB controller or similar interface
% 	  %    that uses a COM port
%
%     % The Prologix may not interface smoothly with some equipment, see the Prologix documentation for details.
%     % USBPro_SPECIAL is the list of instruments that require special treatment
%     %  from the Prologix USB-Serial controller. Not all of the instruments supported by kpib have been tested with the Prologix,
%     %  so you may have to add instruments to this list...
%     USBPro_SPECIAL={'KTH_2400'};
% 		
%     % uncomment this section only if using Prologix USB-GPIB (or similiar)
%     %  get the COM port (COMx) from the USB driver installation process and
%     %  specify it below
% 
%     % Which virtual COM port for the USB? What baudrate? (9600 is standard)
%     USB_COM = 'COM9'; baud = 9600;
% 
% 
%     if ~isempty(instrfind('Type','serial','Port',USB_COM))
%         kpib('clear',0,0,0,0,0,1);
%       % NOTE: Re-using an open port does not seem to work for
%       %       Prologix, so if a port exists, destroy it and make a
%       %       new one
%     end
%     % create the port object
%     io = serial(USB_COM,'Baudrate',baud);
% 
%     % set the parameters for the serial port
% %     if any(strcmpi(instrument, USBPro_SPECIAL))
% %         io.Terminator = 'CR'; % required for KTH_2400
% %     else
%         io.Terminator = 'CR/LF'; % standard Prologix USB GPIB
% %     end        
%     io.InputBufferSize = ioInBuffsize;
%     io.Timeout = ioTimout;
%     fopen(io);
%     if verbose >= 3
%         %disp (io);
%         fprintf('kpib/port: Create new object for USB serial (%s/%s)\n',USB_COM,num2str(addressGPIB));
%     end
% 
%     % % Configure Prologix Controller (v4.2+)
%     % configure as controller (++mode 1)
%     fprintf(io, '++mode 1'); %pause(1);
%     % read-after-write mode enabled, except for KTH_2400
%     if any(strcmpi(instrument, USBPro_SPECIAL))
%         fprintf(io, '++auto 0');
%     else
%         fprintf(io, '++auto 1');
%     end
%     % set instrument address
%     fprintf(io, ['++addr ' num2str(addressGPIB)]);
% 
% 
%     if verbose >= 3,
%         % Send Prologix Controller query version command
%         fprintf(io, '++ver'); %pause(1);
%         % Read and display response
%         ver = fgetl(io);
% %         if any(strcmpi(instrument, USBPro_SPECIAL)), t=fgetl(io); end % clear the orphan LF
%         fprintf('kpib/port: %s\n',ver);
%         fprintf(io, '++addr');
%         addr = fgetl(io);
%         %if any(strcmpi(instrument, USBPro_SPECIAL)), t=fgetl(io); end % clear the orphan LF
%         fprintf('kpib/port: Prologix Serial USB Controller configured for GPIB %s\n',addr);
%     end
% 
%    % % End Prologix

       
end % open GPIB port

return

%% function truncx
function retval = truncx(raw)
%  RETVAL = TRUNCX(RAW)
%  This function is used to truncated the x data sent by the HP89410A.  The
%  truncations below are hardcoded from the manual to match the y data
%  output.  This function will take the x data in a column and will
%  truncate only the first column.
%
%  JTL JUL2004

[m,n] = size(raw);

%disp('truncX 89410')

switch m
    case {64,65}
        for i = 8:58
            retval(i-7,1) = raw(i);
        end
    case {128,129}
        for i = 15:115          
            retval(i-14,1) = raw(i);
        end
    case {256,257}
        for i = 29:229         
            retval(i-28,1) = raw(i);
        end
    case {512,513}
        for i = 57:457         
            retval(i-56,1) = raw(i);
        end
    case {1024,1025}
        for i = 113:913          
            retval(i-112,1) = raw(i);
        end
    case {2048,2049}
        for i = 225:1825         
            retval(i-224,1) = raw(i);
        end
    case {4096,4097}
        for i = 449:3649          
            retval(i-448,1) = raw(i);
        end
    otherwise
        fprintf(1,'kpib/truncX: data size error. m = %g\n',m);
        assignin('base','raw',raw);
        retval=raw;
end


% %% %% %
% % SERIAL COMMUNICATION FUNCTIONS
% %
% These functions handle serial communications-related crap.

%% function makeBytes
function retval = makeBytes(value)
% turns a decimal VALUE into a two-byte (decimal) array suitable for serial
%  transmission by fwrite
% uses twos-complement for negative values
% returns an array of numbers ordered for transmission:
%   retval(1) = high byte
%   retval(2) = low byte
%
% MH AUG2006
%

N = 16; % number of bits

if value < 0
    ndnum=bitcmp(abs(value),N);
    value=ndnum+1;
end

sp=dec2hex(value);

if length(sp) > 2
    sp1=sp(1:length(sp)-2);
    sp2=sp(length(sp)-1:length(sp));
else
    sp1=0;
    sp2=sp;
end
retval=[hex2dec(sp1) hex2dec(sp2)];

return


%% function makeDecimal
function retval = makeDecimal(value)
% turns a two-number decimal representation of a two-byte binary register
%  value into a single decimal value
%  (i.e., make byte hex value into decimal value)
% VALUE is an array of decimal numbers (as typically returned from serial
%  port communications)
% assumes twos-complement notation for negative numbers
% can handle arbitrary size registers
%
% MH AUG2006
%
N = 8; % how many bits per decimal value? (i.e., 1 byte registers)

% VALUE is two numbers that represent the high and low bytes of a
%  16-bit register. We need to combine them into a single binary number,
%  check for negative (twos complement) and then convert to a single
%  decimal number.
cmd=[];
sp=dec2bin(value,N);
numreg=size(sp);

for i=1:numreg(1)
    cmd=[cmd sprintf('sp(%d,1:N) ',i)];
end
%retval=hex2dec([sp(:,1:2)]);
bnum=eval(['[' cmd ']']);
dnum=bin2dec(bnum);

% now we have a 16-bit binary number as a string
% % check for negative
if bitget(dnum,N*numreg(1))==1
    ndnum=bitcmp(dnum,N*numreg(1));
    dnum=-1*(ndnum+1);
end
    
retval=dnum;

return


%% function makeCRC
function retval = makeCRC(message)
%RETVAL = MAKECRC(MESSAGE)
% Create a 16-bit CRC to append to a message for serial transmission.
% To create the CRC bytes, divide the message string by the CRC polynomial,
% 0xA001 (1010000000000001). This can be done by bit shifting left.
%
% MESSAGE can be an array of decimal or hex values. They must be listed
%  in the order of transmission. RETVAL is returned as an array of two
%  decimal values, in order of transmission.
%
% This is a little strange in MATLAB because we will work in decimal. Is
%  there a better way to do this?
%
% A byte-wise 16-bit CRC: process the bits in the order that they will be
%  transmitted. When we are done, reverse the byte order of our answer for
%  transmission.
%
% MH JUL2006
% v1.0
%

% is the message decimal or hex?
% (regardless it must be in order of transmission, left first)
if ~isnumeric(message)
    md=hex2dec(message);
else
    md=message;
end
% the CRC polynomial to divide our message by
%p='1010000000000001';
%pd=hex2dec('A001'); % hint: 40961
pd=40961;

% loop through the message, shifting through each byte bit by bit
%  proceed in the order of byte transmission

% initialize the result
xf='FFFF'; xfd=hex2dec(xf);
% loop over the bytes
for i=1:length(md)   % process message in byte chunks
    xfd=bitxor(md(i),xfd);     % XOR new byte with result
    for j=1:8 % process bitwise
        if bitand(xfd,1) % if the LSB is 1
            xfd=bitshift(xfd,-1);
            xfd=bitxor(xfd,pd);
        else
            xfd=bitshift(xfd,-1);
        end
    end
end

% we need to reverse the byte order of xfd for transmission
xfdb=dec2bin(xfd,16);
%xfdb(17:24)=xfdb(1:8); xfdb(1:8)=[];
retval(1)=bin2dec(xfdb(9:16));
retval(2)=bin2dec(xfdb(1:8));

return


%% function watwrite
function response=watwrite(io,packet,verbose)
% WATWRITE handles the writing to a register and reading the response
%  (interpreting any errors) using serial port. This is dedsigned for the
%  Watlow controller on the AO_800, but could be used for any Watlow
%  device that uses MODBUS registers.
%
% returns 0 for success
%
% MH AUG2006
%

% send the packet to the controller and read the response
% try
    fwrite(io,packet);
    confirm = fread(io,8);

    % confirm or deny? Handle errors
    if confirm(2)==134 && verbose >= 1  % command (0x06) is echoed with high bit is set to indicate error
        switch confirm(3) % see Watlow data communications manual p16 for error codes
            case 1
                fprintf(1, 'kpib/AO_800: ERROR: "illegal command" (%d)\n',confirm(3));
            case 2
                fprintf(1, 'kpib/AO_800: ERROR: "illegal data address" (%d)\n',confirm(3));
            case 3
                fprintf(1, 'kpib/AO_800: ERROR: "illegal data value" (%d)\n',confirm(3));
            otherwise
                fprintf(1, 'kpib/AO_800: ERROR: Unknown error (%d)\n',confirm(3));
        end
        fprintf(1,'        Sent: ');
        fprintf(1, ' %d',packet);
        fprintf(1,'\n');
        fprintf(1,'    Received: ');
        fprintf(1, ' %d',confirm);
        fprintf(1,'\n');
        response = confirm(3);

    elseif confirm(5:6)' ~= packet(5:6);
        if verbose >= 1
            fprintf(1, 'kpib/AO_800: WARNING: Controller did not confirm write. Returned:\n    ');
            fprintf(1, '  %d', confirm);
            fprintf(1, '\n');
            response = confirm(3);
        end
    else
        if verbose >= 3, fprintf(1, 'kpib/AO_800: Controller confirms register write\n'); end
        response = 0;
    end

% catch % if at first you don't succeed
%     if verbose >= 1, fprintf(1,'kpib/AO_800: WARNING: write error (watwrite). Retrying...\n'); end
%     pause(2);
%     response=watwrite(io,packet,verbose);
% end

return


%% function BitToFloat
function retval =  BitToFloat(numb)
% This function converts a bit representation of a double precision
% floating point number into a number. For more info, see 
% http://en.wikipedia.org/wiki/IEEE_floating-point_standard#Double-precision_64_bit
% RH AUG2006
signBit=bitget(numb(1),8);
expBit=[bitget(numb(1),7:-1:1) bitget(numb(2),8:-1:5)];
mantissaBit= [bitget(numb(2),4:-1:1) bitget(numb(3),8:-1:1) bitget(numb(4),8:-1:1) bitget(numb(5),8:-1:1) bitget(numb(6),8:-1:1) bitget(numb(7),8:-1:1) bitget(numb(8),8:-1:1)];
if(signBit==1)
    sign=-1;
else
    sign=1;
end
%find the exponent
exp=double(0);
for eind = 0:1:length(expBit)-1
    exp= exp + (2^eind)*double(expBit(length(expBit)-eind));
end
e=exp-1023;

%find the coefficent
man=double(0);
for mind = 1:1:length(mantissaBit)
    man= man + 2^(-1*mind)*double(mantissaBit(mind));
end
retval = sign*(1+man)*2^e;

return;

% %% %% %% %% %
% % END KPIB