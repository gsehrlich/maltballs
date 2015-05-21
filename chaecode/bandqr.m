function [bandwidth, Q, EE, varargout]=bandqr(res)
%[BANDWIDTH, Q, EE, DB, PHASESHIFT, HN, DBFREQ]=BANDQR(RES)
%
% BANDQ calculates the 3db bandwidth and the Q for a given resonator
%  measurement. The data is assumed to be frequency and magnitude
%  sweep from a network analyzer or similar.
% If no 3db bandwidth exists, the function returns -1 for bandwidth and Q.
%  the output argument DB is optional; it contains the index of the 3dB
%  bandwidth points in the data array. PHASESHIFT is also optional; it
%  contains the difference between the phase values at the beginning and
%  end of the data set. HN is the "Hopcroft Number", which indicates the
%  amount of nonlinearity present in the sweep measurement:
%    Hn = 0 means no nonlinearity
%    Hn = 1 indicates mechanical bifurcation
%    Hn = -1 indicates electrical bifurcation.
%  DBFREQ is the frequency values at the 3dB points.
%
%
% M.A. Hopcroft
%      hopcroft at mems stanford edu
%
% MH HKL MAR2008
% v1.42  combine MH & HKL versions
%         3dB freq are now varargout(4)
%

% MH FEB2008
% v1.4  add Hn output
%
% MH MAY2007
% v1.3  handle empty res
%
% MH MAR2007
% v1.24 fix gain bug in C_feed estimate
%       round Q output
%       amp_gain defaults to 0
% MH JUN2006
% v1.23 still works if marker == 0
%       added variable amplifier gain for Rx calculation
%       mag=mag(1) for cases of multiple points at max
% MH MAR2006
%  v1.1r added phase shift
% MH AUG2005
%  v1.0 (r) version uses res structure as input
%
% MH AUG 2004
%  v2.0 APR 2005 added electrical equivalent circuit parameters
%  v1.1 OCT 2004 added case for no 3db bandwidth
%

% check for empty res (no data)
if isempty(res)
    bandwidth=-1;
    Q=-1;
    EE(1)=0; EE(2)=0;
    return
end

% extract relevant data from res structure
if ~(isfield(res,'amp_gain'))
    res.amp_gain=0; % no gain specified
end
datax=res.trace1.x;
datay=res.trace1.y;
% peakx=res.mark1.x;
peakx=max(res.trace1.x);
peaky=max(res.trace1.y);
% phasex=res.trace2.x;
phasey=res.trace2.y;
gain=res.amp_gain;

%%%%
% find 3db bandwidth
mag=find(datax==peaky);
% peak may not fall exactly on a stored data point(?)
if isempty(mag) || (peaky<=0)
    mag=find(datay==max(datay));
end
mag=mag(1); % in case there is more than one point at max
magy=datay(mag);

%db=find(datay==(magy-3))
% find the two -3db points. They may not be exactly on a data point, so we
% search for them iteratively.

j=1; db=[0 0];
while 1
    if j>=length(datay)
        break;
    elseif datay(j) < magy-3
        j=j+1;
    elseif datay(j) >= magy-3
        db(1)=j;
        break;
    end
end
j=mag;
while 1
    if j>=length(datay)
        break;
    elseif datay(j) > magy-3
        j=j+1;
    elseif datay(j) <= magy-3
        db(2)=j;
        break;
    end
end

% assign outputs. If the 3db points were not found, then return -1
if db(1)>0 && db(2)>0
    bandwidth=datax(db(2))-datax(db(1));
    Q=round(peakx/bandwidth);
    % return the frequency value between the two 3 db points
    db(3)=(round((db(2)-db(1))/2))+db(1);
else
    bandwidth=-1;
    Q=-1;
end

% calculate electrical equivalents if Q is available
% store answers in the vector EE
% NOTE: amplifier gain must be specified in res.amp_gain
%
% MA writes:
% 1) Assumption 1- C_f >> C_x. If you see values which are less than 1 order
%    of magnitude different, discard them!
% 2) Assumption 2- Model accurate a decade or so near the resonant frequency. 
% 3) As on April 22, get good matches for R_x and C_f (peak magnitude and magnitude away from the peak).
%

% estimate equivalent circuit parameters
%if ((Q ~= -1) && (bandwidth ~= -1) && (isequal(res.units1.y,'DB')))
if (Q ~= -1) && (bandwidth ~= -1) && (gain ~= 0)
    % All circuit parameter calculations assume a transimpedance gain
    %  as for MH_Amp sweep boards - not valid for picoprobe measurements!
    % EE(1) is motional resistance R_x 
    EE(1)=10^(log10(gain)-magy/20);
    % feedthrough capacitance C_f
    EE(2)=(10^(datay(1)/20))/(2*pi*datax(1)*gain);
    % equivalent capacitance C_x
    EE(3)=1/(2*pi*EE(1)*Q*peakx);
    % equivalent inductance L_x
    EE(4)=(EE(1)*Q)/(2*pi*peakx);
else
    EE(1)=0;
    EE(2)=0;
    EE(3)=0;
    EE(4)=0;
end


%% Set the variable output arguments (varargout)
if nargout >= 4
    % return the 3db points
    varargout(1)={db};
end
if nargout >= 5
    % calculate the phase shift
    varargout(2)={max(phasey)-min(phasey)};
end
if nargout >= 6
    % calculate the Hopcroft number, Hn
    if (db(1)>0 && db(2)>0)
        varargout(3)={((peakx-datax(db(1)))-(datax(db(2))-peakx))/bandwidth};
    else
        varargout{3} = 1776;
    end
end
if nargout >= 7
    % return the frequency values at 3db points
    % get 3db frequencies
    if( db(1)>0 && db(2)>0)
        % 3db point(left)
        dbfreq(1) = datax(db(1));
        % 3db point(right)
        dbfreq(2) = datax(db(2));
        % center of above two
        dbfreq(3) = datax(db(3));
    else %when it does not exist
        dbfreq(1) = 0;
        dbfreq(2) = 0;
        dbfreq(3) = 0;
    end
    varargout(4)={dbfreq};
end

return
