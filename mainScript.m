%% add paths and load channel location and laplacian matrix
addpath(genpath('biosig')) %genpath to add all the subfolders
addpath(genpath('data'))

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
[epochBaseline] = epoching(session, eventID, time_window); %Calling the function epoching

eventID = 400; %Motor imagery 
time_window = [0,3]; 
[epochMotorImagery] = epoching(session, eventID, time_window); 

eventID = 555; %Stop
time_window = [-2,4];
[epochStop] = epoching(session, eventID, time_window);

%% Power spectral density estimate

eventMI = 'Motor Imagery';
eventBL = 'Baseline';

figure
for ch = 1:1:16
    [pxxMI,fMI] = WelchPower(session.SR,epochMotorImagery,ch);
    [pxxBL,fBL] = WelchPower(session.SR,epochBaseline, ch);
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
    

%% Spectrogram

[f,t, pMiMeanOverTrials] = spectrogramPerChannel(session.SR, epochBaseline, epochMotorImagery);



%% Topoplot

addpath(genpath('eeglab13_4_4b')) % added path to topoplot function (can not be done before, because it shadows pwelch)

% prepare data
time = 2;
freqMin = 17;
%freqMax = 30;
idxF = find(f>=freqMin);
idxT = find(t==time);
topoplotData = pMiMeanOverTrials(idxF,idxT,:);
dataVector(:) = mean(topoplotData,1);

figure()
topoplot([],chanlocs16,'style','blank','electrodes','labelpoint','chaninfo',session.ChINFO);
figure()
topoplot(dataVector,chanlocs16);
% figure()
% topoplot(session.DATA_laplacien(:,100),chanlocs16);
% figure()
% topoplot(session.DATA_CAR(:,100),chanlocs16);

rmpath(genpath('eeglab13_4_4b')); % remove this path again



