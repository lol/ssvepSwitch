function mat = epoch(signal, window_time, fs, overlap_factor)
mat = buffer(signal, window_time*fs, ceil(overlap_factor * window_time * fs));           %create a matrix with overlapped segments, also called 'Time Based Epoching'. 1 sec segments every 0.1 secs.
end