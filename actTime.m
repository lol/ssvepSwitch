clc;
clear all;
close all;

file = 'ssvep-switch-train-15Hz-Indra-train-[2016.12.07-16.03.31].gdf';
%file = 'ssvep-switch-train-12Hz-Indra-train-[2016.12.07-15.11.04].gdf';
%file = 'ssvep-switch-train-8Hz-Indra-train-[2016.12.07-18.19.00].gdf';
sti_f = 15;
%sti_f = 12;
%sti_f = 60/7;
% 5s NC, 5s rest, 5s IC, 5s rest
% 32779+33024/25 at the same time, 32780 after 5s
[s, h] = sload(file);
fs = h.SampleRate;
SSVEPdata = bandfiltfilt(s(h.EVENT.POS(2):end, :), fs, 4, 1, 40);
numChannels = size(SSVEPdata, 2);


stimCodes = [33024, 33025];

stimCodeSubset = find(ismember(h.EVENT.TYP, [33024, 33025]));

h.EVENT.TYP = h.EVENT.TYP(stimCodeSubset);
h.EVENT.POS = h.EVENT.POS(stimCodeSubset) - h.EVENT.POS(2) + 1;

numTotalSamples = length(SSVEPdata);

windowTime = 2;              % in seconds
jumpTime = 0.1;              % in seconds
jump = jumpTime * fs;         %In samples, time in seconds * fs
windowSize = windowTime * fs; %In samples
%numWindows = 1 + floor((length(SSVEPdata) - windowSize) / jump);
overlapFactor = 1 - (jumpTime / windowTime);


for i = 1:numChannels
    SSVEPdataEpoch(i, :, :) = epoch(SSVEPdata(:, i), windowTime, fs, overlapFactor);
end
%SSVEPdataEpoch = 4 x 500 x 2994

numWindows = size(SSVEPdataEpoch, 3);
%skipSampleCount = fs;
%skipSampleCount = 0;
%firstIC_sampleStart = 10*fs + skipSampleCount + 1 ;% first IC start 2501+250
%firstIC_sampleEnd = 15*fs - windowSize ;% first IC end 3750-500

h.EVENT.WIN_NUM = 1 + (h.EVENT.POS - 1) / jump;

% generate reference signals from 1 to 20 Hz.
%sti_f_ref = 1:20;
sti_f_ref = 60 ./ [4:9];
targetFlickerIndex = find(ismember(sti_f_ref, sti_f));
refSignals = ck_signal_windowed(sti_f_ref, windowTime, fs);

IC_marker = h.EVENT.WIN_NUM(h.EVENT.TYP == 33025);
IC_marker = [IC_marker; numWindows + 1];


% 5 is the IC time duration
%numWindowsInOneTrial = (5 + windowTime) / jumpTime; %5 second trial, 2 second
numWindowsInOneTrial = 5 / jumpTime;
j = 1;
k = 1;
startDetection = 0;
alreadyDetected = 0;
%startFlicker(1) = 1;
for i = 1:numWindows
    if i >= IC_marker(j) && i < IC_marker(j) + numWindowsInOneTrial
        true_label(i) = sti_f_ref(targetFlickerIndex);
        if alreadyDetected == 0 && startDetection == 0
            startDetection = 1;
            startFlickerWin(j) = i;  % Window# of flicker start
        end
    else
        true_label(i) = 0;
        startDetection = 0;
        alreadyDetected = 0;
        if i == IC_marker(j) + numWindowsInOneTrial
            j = j + 1;
        end
    end
    
    % pass chunks from SSVEPdataEpoch(,) to ccaResult
    % ccaResult returns the resIndex
    % sti_f_result(resIndex) goes into result(i)
    resIndex = ccaResult(SSVEPdataEpoch(:, :, i), refSignals(:, :, :));
    result(i) = sti_f_ref(resIndex);
       
    if alreadyDetected == 0 && startDetection == 1 && all(result(i-4:i) == sti_f) && i-4 >= startFlickerWin(j)
        detectionWin(k) = i;    
        alreadyDetected = 1;
        k = k + 1;
    end
           
end

%startFlickerWin
%detectionWin
compareTrueWithResult = [true_label', result'];


% there can be a dimension mismatch between the number of detections and
% IC_marker
act_time = 0.1 * (detectionWin' - IC_marker(1:end-1)) + jumpTime
% act_Time = 0.1 * (detectionWin'+20 - IC_marker(1:end-1))

