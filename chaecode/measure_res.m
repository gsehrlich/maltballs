function retval = measure_res(tools,center,spans,average,avenum,verbose)
% RETVAL = MEASURE_RES(TOOLS, CENTER, SPANS, 'AVERAGE', AVENUM, VERBOSE).
% MEASURE_RES performs a resonator measurement consisting of multiple
%  frequency sweeps. After each sweep, the frequency of the peak response is
%  determined, and this peak frequency becomes the center value for the next sweep.
%  Each sweep should be smaller than the previous, and the results (peak frequency,
%  amplitude, etc) are taken from the final sweep.
%
% TOOLS		The instruments that will be used for the measurement.
% CENTER	The starting value for the center frequency. Default is the current
%			 center frequency of the analyzer.
% SPANS		An array of the spans to be used in the "zoom in" series. Default
%			 is 5 kHz (i.e. one sweep with span 5 kHz). Three sweeps are typical.
% AVERAGE	('on' | 'off') The analyzers can average the results of multiple
%			 sweeps to get a single result. Often used with HP89410.
% AVENUM	The number of sweeps for averaging, if averaging is 'on'. If averaging
%			 is off, then wait AVENUM seconds for signal to stabilize (HP89410 only).
%			 Default is 5.
% VERBOSE   The level of messages reported in the command window (0-3). Default is 1.
%
% The results are returned in the structure RETVAL, which has the following
%  fields:
%
% retval.mark1.x        X position of marker on trace 1 (frequency peak)
% retval.mark1.y        Y position of marker on trace 1 (amplitude at peak)
% retval.mark2.x        X position of marker on trace 2
% retval.mark2.y        Y position of marker on trace 2
% retval.trace1.x       X data for trace 1 (frequency)
% retval.trace1.y       Y data for trace 1 (amplitude)
% retval.trace2.x       X data for trace 2 (frequency)
% retval.trace2.y       Y data for trace 1 (phase)
% retval.bandwidth      3db bandwidth of trace
% retval.Q              Q of resonator calculated from 3db bandwidth
% retval.equ_circuit    Rx and Cft estimated for default gain
% retval.db             the index of the 3db points
% retval.phase_shift    the total phase shift in degrees
% retval.clock          the time of the measurement
% retval.meas_span      the span used for the measurement saved in trace
%
%  The fields below are returned if the appropriate instruments are listed
%  in TOOLS:
%
% retval.Vbias_set      bias voltage, as reported by voltage supply
% retval.Vbias_read     bias voltage, as read by multimeter
% retval.Toven          Oven temperature from oven controller
% retval.Tsensor        temperature reported by temperature sensor
% retval.Vheat          Heating voltage
% retval.Aheat          Heating current
% retval.Pheat          Heating power (Vheat * Aheat)
% retval.Tcircuit       Measurement Circuit temperature
% retval.Troom          Room temperature
% 
%
% The "mark" fields contain the position of the peak in the amplitude
% response, "trace" fields contain the complete data set, suitable for
% plotting.
%
% requires: kpib.m (v3.98+), bandqr.m
%
%
% M.A. Hopcroft
%      matt.hopcroft@cantab.net
%
% MH MAY2007
% v3.8  added close commands
%       default channel for bias
%       fix bias read ('V')

versionstr = 'measure_res v3.8';

% MH FEB2007
% v3.72 fixed source level inconsistency
%       removed units as separate field
% MH JAN2007
% v3.7  consistent behaviour for optional tools (circuittemp)
%       fix help comments and verbose=3
% MH NOV2006
% v3.64 fix marker query for "slow sweep" analyzers
% MH OCT2006
% v3.6  fixed averaging for 89410A
%       disable screen labels
% v3.54 fixed verbose outputs
% MH AUG2006
% v3.52  all fields return values (1776 for no value)
% MH JUL2006
% v3.301
%  added 8753ES
% MH JUN2006
%  (based on measure 89410/4395A)
% v3.21 Made measure_res into general function to use either 89410, 4395
%       fixed 4395A str/num issue
%


% set defaults
if nargin < 6
    verbose = 1;
end
if nargin < 5
    avenum=5;
end
if nargin < 1
    tools.analyzer.instr = 'HP_89410A'; %'HP_89410A' or 'HP_4395A'
    tools.analyzer.gpib = 16; %16 = HP_89410A %17 = HP_4359A
    if verbose >= 1, fprintf(1,'measure_res: Default to %s\n',tools.analyzer.instr); end
end
if nargin < 4 % default averaging
    switch tools.analyzer.instr
        case {'HP_89410A'}
            average = 'on';
        case {'HP_4395A','HP_8753ES'}
            average = 'off';
        otherwise
            average = 'off';
    end
end
if nargin < 3
    spans = 5000;
end
if nargin < 2 || center <= 0
    center = kpib(tools.analyzer.instr,tools.analyzer.gpib,'center','query',0,0,verbose);
    if verbose >= 2, fprintf(1,'measure_res: Using center value from Analyzer: %g Hz\n',center); end
end


if verbose >= 1, fprintf(1,'measure_res: Resonator measurement using %s\n',tools.analyzer.instr); end


%% measure the sensor temperature before the sweep
% sensor temperature
if isfield(tools,'sensor');
	if verbose >= 3, fprintf(1,'measure_res: tools.sensor: %s/%s\n',tools.sensor.instr,num2str(tools.sensor.gpib)); end
    try
        retval.Tsensor1 = kpib(tools.sensor.instr,tools.sensor.gpib,'read','temp',0,0,verbose);
        kpib('close',tools.sensor.gpib,0,0,0,0,verbose);
    catch
        retval.Tsensor1 = 1776;
        if verbose >= 1, fprintf(1,'measure_res: Sensor temperature not available\n'); end
    end
else
    retval.Tsensor1 = 1776;
end

%% first, measure frequency. This is the most difficult part, involving
%% multiple steps.

switch tools.analyzer.instr
    %%%%%%%%
    %%%%%%%%
    case {'HP_89410A'}

    % Define the which channel is which on the Analyzer.
    ampchannel = 1;
    phasechannel = 2;

    % make sure that peak tracking is on
    kpib(tools.analyzer.instr,tools.analyzer.gpib,'peaktrack','on',ampchannel,0,verbose);

    % This labels the top of the HP 89410 screen.
    %rightlabel = ['Track Frequency: ',convertdate(clock)];
    %kpib(tools.analyzer.instr,tools.analyzer.gpib,'label','measure_res','left',0,verbose);

    % Set averaging 'on' or 'off'
    switch average
        case {'Average','average','On','on','Yes','yes'}
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','type','norm',0,verbose);
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','on',0,0,verbose);
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'average',avenum,0,0,verbose);
            retval.avenum=avenum;
            % clear the previous averaging values, if any
            %kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','restart',0,0,verbose);
            if verbose >= 2, fprintf(1,'measure_res: Averaging on with factor %d\n',avenum); end

        case {'Wait','wait','Off','off','No','no'}
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','off',0,0,verbose);
            if verbose >= 2, fprintf(1,'%s\n','measure_res: Averaging off'); end

        otherwise
            if verbose >= 2, fprintf(1,'%s\n','measure_res: Warning: Averaging command not understood'); end
    end

    %%%%
    %% Loop for taking measurements
    % loop over spans values
    % skip steps if a spans value is zero

    % first, set the center to the specified center value
    centfreq=center;
    numsweeps=length(spans); j=0;

    for spanit = spans
        if spanit ~= 0
            j=j+1;
            % pause to catch our breath
            kpib(tools.analyzer,'pause',0,0,verbose);
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','off',0,0,verbose);
            % set the center and span
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'center',centfreq,0,0,verbose);
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'span',spanit,0,0,verbose);
            if verbose >= 1, fprintf(1,'%s %.0f %s %.0f\n','measure_res: Center:',centfreq,'Span:',spanit); end
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'wait',0,0,0,verbose); pause(1); % the 'wait' should be enough, but its not...
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'continue',0,0,0,verbose);

            switch average
                case {'Average','average','On','on','Yes','yes'}
                    % num=0; ec=0; % ec is the event count
                    % er=kpib(tools.analyzer,'event?',0,0,0,verbose); % clear the event register
                    % start the averaging
                    kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','on',0,0,verbose);
                    kpib(tools.analyzer.instr,tools.analyzer.gpib,'wait',0,0,0,verbose); pause(1); % the 'wait' should be enough, but its not...
                    % Wait until the averaging sweeps are done
                    kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','finish',0,0,verbose);
                    if verbose >= 2, num=kpib(tools.analyzer,'average','count?',0,0,verbose); fprintf(1,'measure_res: Averaging done (%d).\n',num); end

                case {'Wait','wait','Off','off','No','no'}
                    %if verbose >= 1, fprintf(1,'measure_res: Wait %d seconds for data to stabilize\n',avenum); end
                    pause(avenum);
                    pause(4);
                    
                    if spanit<500
                        pause(14-spanit/50); % 2013.12.24 added to stabilize the measurement -Chae
                    end
            end
            % autoscale the display
            kpib(tools.analyzer.instr,tools.analyzer.gpib,'auto y','once',0,0,verbose);

            drawnow;

            if j < numsweeps
                % find the peak... (peak tracking is on, so no command is necessary)
                % ...and make it the new center value
                markerpos = kpib(tools.analyzer.instr,tools.analyzer.gpib,'marker?',ampchannel,'auto',0,verbose);
                centfreq=markerpos.x;
                if verbose >= 2, fprintf(1,'measure_res: New Center value: %.2f\n',centfreq); end
            end

        end
    end       


    %%%%
    % Format output data

    %(peak tracking is on, so no "peak to center" command is necessary)
    kpib(tools.analyzer.instr,tools.analyzer.gpib,'pause',0,0,0,verbose);
    kpib(tools.analyzer.instr,tools.analyzer.gpib,'auto y','once',0,0,verbose);

    % time check
    retval.clock=clock;

    retval.mark1 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'marker?',ampchannel,0,0,verbose);
    retval.trace1 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'getdata',0,ampchannel,'pow',verbose);
    retval.mark2 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'marker?',phasechannel,0,0,verbose);
    retval.trace2 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'getdata',0,phasechannel,'angl',verbose);

    % NB: units are being phased out. Units are now part of the trace field
    % commented out in v3.72
%     retval.units1.x = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','x',ampchannel,0,verbose);
%     retval.units1.y = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','y',ampchannel,'pow',verbose);
%     retval.units2.x = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','x',phasechannel,0,verbose);
%     retval.units2.y = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','y',phasechannel,'angl',verbose);
    
    retval.meas_span = spans(end);

    source = kpib(tools.analyzer.instr,tools.analyzer.gpib,'source?',0,0,0,verbose);
    retval.source = source.level;
    %[retval.bandwidth retval.Q retval.equ_circuit retval.db retval.phase_shift]=bandqr(retval);

    % pause the instrument
    kpib(tools.analyzer.instr,tools.analyzer.gpib,'pause',0,0,0,verbose);

    
    
    
    
    %%%%%%%%
    %%%%%%%%
    case {'HP_4395A','HP_8753ES'}
        kpib(tools.analyzer.instr,tools.analyzer.gpib,'init',0,0,0,verbose);

        % Define the which channel is which on the Analyzer.
        ampchannel = 1;
        phasechannel = 2;

        % Initializing
        % Set the Analyzer screen message
        %label = ['measure_res: ',convertdate(clock)];
        %kpib(tools.analyzer.instr,tools.analyzer.gpib,'label',label,0,0,verbose);
        % turn on markers
        kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',ampchannel,0,0,verbose);
        kpib(tools.analyzer.instr,tools.analyzer.gpib,'marker','on',0,0,verbose);


        %This turns 'On' averaging for the alloted AVENUM or single sweep
        switch average
            case {'Average','average','On','on','Yes','yes'}
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','on',avenum,0,verbose);
                warning off instrument:fscanf:unsuccessfulRead
                if verbose >= 1, fprintf(1,'%s %d\n','measure_res: Averaging on, factor:',avenum); end
            case {'Wait','wait','Off','off','No','no'}
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'average','off',0,0,verbose);
                if verbose >= 2, fprintf(1,'%s \n','measure_res: Averaging off'); end
                
            otherwise
                if verbose >= 2, fprintf(1,'%s\n','measure_res: Warning: Averaging command not understood'); end
        end


        %%%%
        %% Loop for taking measurements
        % loop over span values
        % skip steps if a span value is zero

        % first, set the center to the specified center value
        centfreq=center;
        numsweeps=length(spans); j=0;
        
        for spanit = spans
            if spanit ~= 0
                j=j+1;

                kpib(tools.analyzer.instr,tools.analyzer.gpib,'center',centfreq,0,0,verbose);
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'span',spanit,0,0,verbose);
                if verbose >= 1, fprintf(1,'%s %.0f %s %.0f\n','measure_res: Center:',centfreq,'Span:',spanit); end

                % Determines the number of sweeps that are needed.
                if j < numsweeps
                    kpib(tools.analyzer.instr,tools.analyzer.gpib,'sweep','single',0,0,verbose);
                else
                    switch average
                        case {'Average','average','On','on','Yes','yes'}
                            kpib(tools.analyzer.instr,tools.analyzer.gpib,'sweep','group',avenum,0,verbose);
                        case {'Wait','wait','Off','off','No','no'}
                            kpib(tools.analyzer.instr,tools.analyzer.gpib,'sweep','single',0,0,verbose);
                        otherwise
                            kpib(tools.analyzer.instr,tools.analyzer.gpib,'sweep','single',0,0,verbose);
                    end
                end
                % wait until sweep is finished
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'complete',0,0,0,verbose);

                %Auto scales both channels
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'scale','auto',0,0,verbose);
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',phasechannel,0,0,verbose);
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'scale','auto',0,0,verbose);
                kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',ampchannel,0,0,verbose);

                % wait until previous command is finished
                while(~kpib(tools.analyzer.instr,tools.analyzer.gpib,'wait',0,0,0,verbose))
                   pause(.1);
                end

                drawnow;

                if j < numsweeps
                    % move peak to center...
                    kpib(tools.analyzer.instr,tools.analyzer.gpib,'mark2peak','center',0,0,verbose);
                    % ...and get the new center value
                    centfreq=kpib(tools.analyzer.instr,tools.analyzer.gpib,'center','query',0,0,verbose);
                    if verbose >= 2, fprintf(1,'measure_res: New Center value: %.2f\n',centfreq); end
                end

            end
        end


        

        %%%%
        % Format output data

        % where is the peak?
        kpib(tools.analyzer.instr,tools.analyzer.gpib,'mark2peak','peak',0,0,verbose);

        % time check
        retval.clock=clock;

        %kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',ampchannel,0,0,verbose);
        retval.mark1 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'marker','query',ampchannel,0,verbose);
        retval.trace1 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'getdata',0,ampchannel,0,verbose);

        %kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',phasechannel,0,0,verbose);
        retval.mark2 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'marker','query',phasechannel,0,verbose);
        retval.trace2 = kpib(tools.analyzer.instr,tools.analyzer.gpib,'getdata',0,phasechannel,0,verbose);
        
        % reset the  active channel
        kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',ampchannel,0,0,verbose);

%         retval.source = kpib(tools.analyzer.instr,tools.analyzer.gpib,'power?',0,0,0,verbose);
        source = kpib(tools.analyzer.instr,tools.analyzer.gpib,'source?',0,0,0,verbose);
        retval.source = source.level;
        %[retval.bandwidth retval.Q retval.motional]=bandq(retval.trace1.x,retval.trace1.y,retval.mark1.x);
        %[retval.bandwidth retval.Q retval.equ_circuit retval.db retval.phase_shift]=bandqr(retval);

        % get the units
        % NB: units are being phased out. Units are now part of the trace field
        % commented out in v3.72
%         retval.units1.x = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','x',ampchannel,0,verbose);
%         retval.units1.y = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','y',ampchannel,0,verbose);
%         retval.units2.x = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','x',phasechannel,0,verbose);
%         retval.units2.y = kpib(tools.analyzer.instr,tools.analyzer.gpib,'units','y',phasechannel,0,verbose);
        
        % reset the active channel
        kpib(tools.analyzer.instr,tools.analyzer.gpib,'channel',ampchannel,0,0,verbose);
        
        retval.meas_span = spans(end);
      
        
    %%%%
    %%%%
    otherwise
        error('measure_res: Analyzer not specified properly or not supported.\n');
        
end
% print the result
if verbose >= 1
    fprintf(1,'%s%s%s %.2f %s\n', 'measure_res(',tools.analyzer.instr,'): Final Marker Position:', retval.mark1.x, 'Hz');
end


%% Now we can measure other stuff (bias, oven, etc)

% oven temperature
if isfield(tools,'oven');
	if verbose >= 3, fprintf(1,'measure_res: tools.oven: %s/%s\n',tools.oven.instr,num2str(tools.oven.gpib)); end
    try
        retval.Toven = kpib(tools.oven.instr,tools.oven.gpib,'read','temp',0,0,verbose);
    catch
        retval.Toven = 1776;
        if verbose >= 1, fprintf(1,'measure_res: Oven temperature not available\n'); end
    end
else
    retval.Toven = 1776;
end


% sensor temperature
if isfield(tools,'sensor');
	if verbose >= 3, fprintf(1,'measure_res: tools.sensor: %s/%s\n',tools.sensor.instr,num2str(tools.sensor.gpib)); end
    try
        retval.Tsensor2 = kpib(tools.sensor.instr,tools.sensor.gpib,'read','temp',0,0,verbose);
        kpib('close',tools.sensor.gpib,0,0,0,0,verbose);
    catch
        retval.Tsensor2 = 1776;
        if verbose >= 1, fprintf(1,'measure_res: Sensor temperature not available\n'); end
    end
else
    retval.Tsensor2 = 1776;
end



% bias voltage read and set
if isfield(tools,'biasset');
    if ~isfield(tools.biasset,'channel'), tools.biasset.channel=1; end
	if verbose >= 3, fprintf(1,'measure_res: tools.biasset: %s/%s/%d\n',tools.biasset.instr,num2str(tools.biasset.gpib),tools.biasset.channel); end
    try
        Vbs = kpib(tools.biasset,'read',0,0,verbose);
        retval.Vbias_set = Vbs.volt;
        retval.V_bias = retval.Vbias_set; % old format, deprecated
        kpib('close',tools.biasset.gpib,0,0,0,0,verbose);
    catch
        retval.Vbias_set = 0.0;
        if verbose >= 1, fprintf(1,'measure_res: Bias set voltage not available\n'); end
    end
else
    retval.Vbias_set = 1776;
end

if isfield(tools,'biasread');
	if verbose >= 3, fprintf(1,'measure_res: tools.biasread: %s/%s\n',tools.biasread.instr,num2str(tools.biasread.gpib)); end
    try
        Vbs = kpib(tools.biasread,'read','V',0,0,verbose);
        retval.Vbias_read = Vbs;
        kpib('close',tools.biasread.gpib,0,0,0,0,verbose);
    catch
        retval.Vbias_read=retval.Vbias_set;
        if verbose >= 1, fprintf(1,'measure_res: Bias read voltage not available\n'); end
    end
else
    retval.Vbias_read=retval.Vbias_set;
end




% % heater voltage
% if isfield(tools,'heater');
% 	if verbose >= 3, fprintf(1,'measure_res: tools.heater: %s/%s\n',tools.heater.instr,num2str(tools.heater.gpib)); end
%     try
%         heater = kpib(tools.heater.instr,tools.heater.gpib,'read',0,tools.heater.channel,0,verbose);
%     catch
%         heater.volt = 1776; heater.curr = 0;
%         if verbose >= 1, fprintf(1,'measure_res: Heater voltage not available\n'); end
%     end
%     retval.Vheat = heater.volt;
%     retval.Aheat = heater.curr;
%     retval.Pheat = heater.volt*heater.curr;
% else
%     heater.volt = 1776; heater.curr = 0;
%     retval.Vheat = heater.volt;
%     retval.Aheat = heater.curr;
%     retval.Pheat = heater.volt*heater.curr;
% end
% 
% 
% % circuit temperature
% if isfield(tools,'circuittemp');
%     if verbose >= 3, fprintf(1,'measure_res: tools.circuittemp: %s/%s\n',tools.circuittemp.instr,num2str(tools.circuittemp.gpib)); end
%     try
%         retval.Tcircuit = kpib(tools.circuittemp.instr,tools.circuittemp.gpib,'read','temp',0,0,verbose);
%     catch
%         retval.Tcircuit = 1776;
%         if verbose >= 1, fprintf(1,'measure_osc: Circuit temperature not available\n'); end
%     end
% end
% 
% 
% % room temperature
% if isfield(tools,'roomtemp');
% 	if verbose >= 3, fprintf(1,'measure_res: tools.roomtemp: %s/%s\n',tools.roomtemp.instr,num2str(tools.roomtemp.gpib)); end
%     try
%         retval.Troom = kpib(tools.roomtemp.instr,tools.roomtemp.gpib,'read','temp',0,0,verbose);
%     catch
%         retval.Troom = 1776;
%         if verbose >= 1, fprintf(1,'measure_res: Room temperature not available\n'); end
%     end
% else
%     retval.Troom = 1776;
% end

retval.version=versionstr;

retval.Tsensor = (retval.Tsensor1+retval.Tsensor2)/2;

retval.peakfreq  = retval.mark1.x;
retval.peakval   = retval.mark1.y;
retval.peakphase = retval.mark2.y;

[retval.peakval index] = max(retval.trace1.y);
retval.peakfreq  = retval.trace1.x(index);
retval.peakphase = retval.trace2.y(index);

return
    

