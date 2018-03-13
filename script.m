clear all

% gdf : general format
% namesubject_date_time_online/offline

addpath(genpath('biosig'))
help sload
load('channel_location_16_10-20_mi.mat')
filename = 's_run1_offlineMIterm_20180703154501.gdf';
[s, h] = sload(filename);
% s = signal: matrix sample (rows) x channels (columns)
% h = header, event is the most important field
% e = h.EVENT; % TYPE --> at which point of the protocol we were 
%(coded by a number)
% POS and DUR: position and how many samples it lasts
% Samplerate: allows determine how many sec : divide size of sample by the
% frequency

% session = struct
session_event.TYP = h.EVENT.TYP;
session_event.POS = h.EVENT.POS;

session.SR = h.SampleRate;
session.DATA = s';
session.ChINFO = chanlocs16;
session.EVENT = session_event;

% EVENT IDs
% 200 = FIXATION CROSS
% 400 = MOTOR IMAGERY
% 555 = STOP
% 700 = RELAX

eventID = 400;%Motor imagery ID
time_window = [-1,3];%1s before the event and 3s after

%Calling the function epoching
[Epoch400] = epoching(session,eventID,time_window);

%% Just for vizualisation, plotting all trials for each Chs for motor imagery
close all
figure()

S = size(Epoch400.TIME);
D = zeros(1,S(2));
time = time_window(1):(1/512):time_window(2);
for k = 1:1:16 %for each channel
    subplot(4,4,k)
    for i = 1:1:S(1)%for each trial
        D(1,:) = Epoch400.DATA(i,k,:);
        plot(time,D) % plots signal against time window
        hold on
    end
    y = -100:0.1:100;
    s = size(y);
    x = zeros(1,s(2));
    plot(x,y,'r--')
    xlabel('Time [s]')
    ylabel('V [mV]')
end










