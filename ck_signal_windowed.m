function refSignal = ck_signal_windowed(sti_f, windowTime, fs)
%% constract first and second harmonic wave
TP = 1/fs : 1/fs : windowTime;
% h means harmonics
for j=1:length(sti_f)
    Sin_h1 = sin(2*pi*sti_f(j)*TP);
    Cos_h1 = cos(2*pi*sti_f(j)*TP);
    Sin_h2 = sin(2*pi*2*sti_f(j)*TP);
    Cos_h2 = cos(2*pi*2*sti_f(j)*TP);
    refSignal(:, :, j) = [Sin_h1; Cos_h1; Sin_h2; Cos_h2];
    %refSignal(:, :, j) = [Sin_h1; Cos_h1];
end