clear all; close all; clc;

% gdf : general format
% namesubject_date_time_online/offline

addpath(genpath('biosig'))
load('/Users/marinevancampenhoudt/myCloud/MA_2/BCI/Project/Program/Mats/channel_location_16_10-20_mi.mat')
load('/Users/marinevancampenhoudt/myCloud/MA_2/BCI/Project/Program/Mats/laplacian_16_10-20_mi.mat')
filename = '/Users/marinevancampenhoudt/myCloud/MA_2/BCI/Project/Program/Runs/ak3_run4_offlineMIterm_20181303103309.gdf'; 
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
NumChannels = 16;

session.SR = h.SampleRate;
session.ChINFO = chanlocs16;
session.EVENT = session_event;
session.DATA = s';

% EVENT IDs
% 200 = FIXATION CROSS
% 400 = MOTOR IMAGERY
% 555 = STOP
% 700 = RELAX

%% Temporal Filtering
% comment the following section in order to cancel temporal filtering:
% useful for the p-welch figures comparison
f_min = 5;
f_max = 40;
order = 4;% must be even --> will be divided by 2
session.DATA = TempFilter(s,f_min, f_max, order, session.SR, NumChannels);

%% Spatial filtering:
Spat_type = 'CAR';
session.DATA = SpatFilter(session.DATA, Spat_type, lap, NumChannels);

%% Epoching

%Baseline
time_window = [0,3];
%Calling the function epoching
[EpochBL] = epoching(session,200,time_window);

%Motor imagery
time_window = [0,3];%0s before the event and 3s after
[EpochMI] = epoching(session,400,time_window);

%Stop
time_window = [-2 4];
[EpochSTOP] = epoching(session,555,time_window);


%% Power estimates 
%for each channels, plotting mean power estimate for the following events.
eventMI = 'Motor Imagery';
eventBL = 'Baseline';

figure
    for ch = 1:1:16
        [pxxMI,fMI] = WelchPower(session.SR,EpochMI, ch);
        [pxxBL,fBL] = WelchPower(session.SR,EpochBL, ch);
        subplot(4,4,ch)
        plot(fMI, 10*log10(mean(pxxMI,2)), '-r')
        hold on
        plot(fBL, 10*log10(mean(pxxBL,2)), '-b')
        t = ['P(f) - Channel: ' num2str(ch)];
        title(t)
        axis([0 40 -50 20])
        xlabel('frequency [Hz]')
        ylabel('power [dB]')
        legend(eventMI, eventBL)
    end
    

%% Topoplot
time = 100;
figure()
subplot(1,3,1)
topoplot([],chanlocs16,'style','blank','electrodes','labelpoint','chaninfo',session.ChINFO);
title('Channels location')
subplot(1,3,2)
topoplot(s(time,:)',chanlocs16);%,'style','blank','electrodes','labelpoint','chaninfo',session.ChINFO);
title('No spatial filtering')
subplot(1,3,3)
topoplot(session.DATA(:,time),chanlocs16);
t = [Spat_type ' filtering'];
title(t)

%% spectogram: x-axis:Hz, y-axis: channel


figure
    for ch = 1:1:16
       [f,pw] = Specto(EpochsBL, EpochsMI, ch, SR)
    end


