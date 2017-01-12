function sig = bandfiltfilt(s, fs, order, lowBand, highBand)
  
lowFreq = lowBand * (2/fs);
highFreq = highBand * (2/fs);

[B A] = butter(order, [lowFreq highFreq]);

sig = filtfilt(B, A, s);

end