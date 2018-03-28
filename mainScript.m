%% add paths and load channel location and laplacian matrix
addpath(genpath('biosig')) %genpath to add all the subfolders
addpath(genpath('data'))
addpath(genpath('eeglab_current'))

load('channel_location_16_10-20_mi.mat')
load('laplacian_16_10-20_mi.mat')


%% select whose data

testPerson = 'Marine'; % options: 'Marine', 'Simona','Henrik'

switch testPerson
    case 'Marine'
       filename = 'ak3_run4_offlineMIterm_20181303103309.gdf'; 
    case 'Simona'
        filename = 'ak1_run1_offlineMIterm_20181403160843.gdf';
    case 'Henrik'
        error ('Not available yet')
end


[s, h] = sload(filename); % s = signal: matrix sample (rows) x channels (columns)
% h = header, event is the most important field
% chanlocs16.labels: correspond to an electrode
% Sample rate: allows determine how many sec: divide size of sample by the frequency

%Create structure session
session_event.TYP = h.EVENT.TYP;
session_event.POS = h.EVENT.POS;

session.SR = h.SampleRate;
session.DATA = s';
session.ChINFO = chanlocs16;
session.EVENT = session_event;

%% Temporal Filtering
% useful for the p-welch figures comparison

n = 2; %order*2 --> = 4
f_min = 5; %Hz
f_max = 40;
NumChannels = 16;
[B, A] = butter(n, [f_min, f_max]/session.SR/n);
filtered_s = zeros(size(s));
for ch = 1:NumChannels
    filtered_s(:,ch) = filter(B,A,s(:,ch));
end
session.DATA_temporalFiltered = filtered_s';

%% Spatial filtering: CAR
mean_data = mean(session.DATA(1:16,:),1);
for ch = 1:16
    session.DATA_CAR(ch,:) = session.DATA(ch,:)-mean_data;
end     

%% Spatial filtering: Laplacian
session_data_laplacian = lap*session.DATA(1:16,:); 
session.DATA_laplacien = session_data_laplacian;

%% Create structure session_epoching 
eventID = 200; %Baseline, fixation cross
time_window = [0,3];
[Epoch200] = epoching(session, eventID, time_window); %Calling the function epoching

eventID = 400; %Motor imagery 
time_window = [0,3]; 
[Epoch400] = epoching(session, eventID, time_window); 

eventID = 555; %Stop
time_window = [-2,4];
[Epoch555] = epoching(session, eventID, time_window);

%% Power spectral density estimate
% WelchPower(session.SR, Epoch200, '200')
% WelchPower(session.SR, Epoch400, '400')
% %WelchPower(session.SR, Epoch555, 'Stop');

%% Spectrogram
[f,t, pMiMeanOverTrials] = spectrogramPerChannel(session.SR, Epoch200, Epoch400);
%[power400, powerAverage400] = spectrogramPerChannel(session.SR, Epoch400);
%[power555, powerAverage555] = spectrogramPerChannel(session.SR, Epoch555);


%% Topoplot
% prepare data
time = 1;
freqMin = 17;
%freqMax = 30;
idxF = find(f>=freqMin);
idxT = find(t==time);
topoplotData = pMiMeanOverTrials(idxF,idxT,:);
dataVector(:) = mean(topoplotData,1);

figure()
topoplot([],chanlocs16,'style','blank','electrodes','labelpoint','chaninfo',session.ChINFO);
figure()
 topoplot(dataVector,chanlocs16);%,'style','blank','electrodes','labelpoint','chaninfo',session.ChINFO);
% figure()
% topoplot(session.DATA_laplacien(:,100),chanlocs16);
% figure()
% topoplot(session.DATA_CAR(:,100),chanlocs16);




