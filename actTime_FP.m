clc;
clear all;
close all;

<<<<<<< HEAD
%% 20 Hz
sti_f_ref = 60 ./ [3:5, 7:8];
%file = 'ssvep-switch-train-20Hz-Shiva-[2017.01.12-19.08.41].gdf'; sti_f = 20;
%file = 'ssvep-switch-train-20Hz-Shiva-[2017.01.12-20.39.58].gdf'; sti_f = 20;
%file = 'ssvep-switch-train-20Hz-Shiva-[2017.01.12-20.47.47].gdf'; sti_f = 20;
%file = 'ssvep-switch-train-20Hz-Shiva-[2017.01.12-20.59.43].gdf'; sti_f = 20;

%% 15 Hz
%sti_f_ref = 60 ./ [3:12];
%file = 'ssvep-switch-train-15Hz-Indra-train-[2016.12.07-16.03.31].gdf'; sti_f = 15;
%file = 'ssvep-switch-train-15Hz-Shiva-[2017.01.10-21.18.54].gdf'; sti_f = 15;
%file = 'ssvep-switch-train-15Hz-Shiva-[2017.01.10-21.33.50].gdf'; sti_f = 15;
%file = 'ssvep-switch-train-15Hz-Shiva-[2017.01.12-19.59.36].gdf'; sti_f = 15;

%% 12 Hz
%sti_f_ref = 60 ./ [3:12];
%file = 'ssvep-switch-train-12Hz-Indra-train-[2016.12.07-15.11.04].gdf'; sti_f = 12;
%file = 'ssvep-switch-train-12Hz-Indra-[2017.01.12-18.33.54].gdf'; sti_f = 12; % Not Good
%file = 'ssvep-switch-train-12Hz-Shiva-[2017.01.10-20.45.21].gdf'; sti_f = 12;
%file = 'ssvep-switch-train-12Hz-Shiva-[2017.01.12-20.24.08].gdf'; sti_f = 12;
%file = 'ssvep-switch-train-12Hz-Shiva-[2017.01.12-19.16.35].gdf'; sti_f = 12; % Not Good
%file = 'ssvep-switch-train-12Hz-Shiva-[2017.01.12-19.32.10].gdf'; sti_f = 12;
%file = 'ssvep-switch-train-12Hz-Shiva-mag[2017.01.12-19.24.04].gdf'; sti_f = 12; % Not Good

%%
=======
%file = 'ssvep-switch-train-15Hz-Indra-train-[2016.12.07-16.03.31].gdf';
%file = 'ssvep-switch-train-12Hz-Indra-train-[2016.12.07-15.11.04].gdf';
%file = 'ssvep-switch-train-8Hz-Indra-train-[2016.12.07-18.19.00].gdf';
%file = 'ssvep-switch-train-15Hz-Shiva-[2017.01.10-21.33.50].gdf';
%file = 'ssvep-switch-train-12Hz-Shiva-[2017.01.10-20.45.21].gdf';
%file = 'ssvep-switch-train-8Hz-Shiva-[2017.01.10-21.26.42].gdf';
% Jan 12
%file = 'ssvep-switch-train-12Hz-Shiva-[2017.01.12-20.24.08].gdf';
%file = 'ssvep-switch-train-10Hz-Shiva-[2017.01.12-20.11.36].gdf';
file = 'ssvep-switch-train-15Hz-Shiva-[2017.01.12-19.59.36].gdf';
%sti_f = 10;
sti_f = 15;
%sti_f = 12;
%sti_f = 60/7;
>>>>>>> origin/master
% 5s NC, 5s rest, 5s IC, 5s rest
% 32779+33024/25 at the same time, 32780 after 5s
%sti_f_ref = 60 ./ [3:12];
% 1 to 100 = Look for False Positives (NC)
% 101 to 150 = Look for Detections (IC)
% 151 to 170 = Classification NOT accounted.
% 171 to 300 = Look for False Positives (NC)
% 301 to 350 = Look for Detections (IC)
% 351 to 370 = Classification NOT accounted.
% 370 to 500 = Look for False Positives (NC)

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
%sti_f_ref = 60 ./ [4:10, 14]; % use this only for 60/7 = 8.57 Hz flicker
<<<<<<< HEAD
=======
sti_f_ref = 60 ./ [3:12];
>>>>>>> origin/master
targetFlickerIndex = find(ismember(sti_f_ref, sti_f));
refSignals = ck_signal_windowed(sti_f_ref, windowTime, fs);

IC_marker = h.EVENT.WIN_NUM(h.EVENT.TYP == 33025);
IC_marker = [IC_marker; IC_marker(end) + IC_marker(2) - IC_marker(1)];
IC_endMarker = [IC_marker + 70];

%NC_marker = h.EVENT.WIN_NUM(h.EVENT.TYP == 33024);
%NC_marker = [NC_marker; numWindows + 1];

% 130 Windows before the next IC
NC_period_start = IC_marker - 130;


% 5 is the IC time duration
%numWindowsInOneTrial = (5 + windowTime) / jumpTime; %5 second trial, 2 second
numWindowsInOneTrial = 5 / jumpTime;
j = 1;
k = 1;
m = 1;
n = 1;
prevFP = 0;
startDetection = 0;
alreadyDetected = 0;
falsePositive = [];
%startFlicker(1) = 1;
for i = 1:numWindows
    if i >= IC_marker(j) && i < IC_marker(j) + numWindowsInOneTrial
        true_label(i) = sti_f_ref(targetFlickerIndex);
        if alreadyDetected == 0 && startDetection == 0
            startDetection = 1;
            startFlickerWin(j) = i;  % Window# of flicker start
            n = n + 1; % for False positive checking in NC period. Look for NC_period_start(n)
        end
    else
        % Place a zero in the detectionWin array if no detection was made
        if startDetection == 1 && alreadyDetected == 0
            detectionWin(k) = 0;
            k = k + 1;
        end
        true_label(i) = 0;
        startDetection = 0;
        alreadyDetected = 0;
        if i == IC_marker(j) + numWindowsInOneTrial + 20
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
    elseif i-4 > 0 && i-4 > NC_period_start(n) && startDetection == 0 && all(result(i-4:i) == sti_f) && prevFP < i-4
        if i ~= prevFP + 5
            falsePositive(m) = i;
        end
        prevFP = i;
        m = m + 1;
    end
           
end

%startFlickerWin
%detectionWin
compareTrueWithResult = [true_label', result'];

falsePositive

numFalsePositives = length(falsePositive(falsePositive > 0));
fprintf(1, 'Number of False Positives = %d\n\n', numFalsePositives);

% Negative act_time means missed detection for that trial.
act_time = 0.1 * (detectionWin - IC_marker(1:end-1)') + jumpTime

numDetections = length(act_time(act_time > 0));
fprintf(1, 'Number of Detections = %d\n\n', numDetections);
if(numDetections ~= 15)
    fprintf(1, 'Number of Detections missed = %d\n\n', 15 - numDetections);
<<<<<<< HEAD
end
=======
end
>>>>>>> origin/master
