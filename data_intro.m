addpath(genpath('data'));
addpath(genpath('biosig'));

%load('header1.mat');
%load('header2.mat')

filename = 's1_offlineMIterm_20181402112838.gdf';
[s, h] = sload(filename);
event = h.EVENT;

%% Compare power using pwelch
% formula 10xlog(A/B)
channelData = load('C:\Users\Henrik\Documents\Master\Semester2\BrainCompIA\Project\Common\channel_location_16_10-20_mi.mat');

session = struct('fs',512,'data',s','channelInfo',channelData.chanlocs16,'event',h.EVENT); % change s to (channel x time)

%% ToDo
% 1. Create epoching function
% 2. create epoching structure
epochs = struct('data',0,'fs',session.fs,'channel',0);

