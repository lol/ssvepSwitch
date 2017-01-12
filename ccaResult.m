function result = ccaResult(x, y)

%idx = ccaResult(SSVEPdata(:, 1:TW_p(tw_length), run, j), refSignals(:, 1:TW_p(tw_length), :), n_sti);
n_sti = size(y, 3);
for i = 1:n_sti
    [wx(:, :, i), wy(:, :, i), r(:, i)] = cca(x, y(:, :, i));
end

if(size(r, 1) == 1)
    [v, result] = max(r);
else
    [v, result] = max(max(r));
end

end