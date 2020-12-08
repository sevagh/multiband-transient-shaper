b = hz2bark([20, 20000]);
barkVect = linspace(b(1), b(2), 40);
hzVect = bark2hz(barkVect);

[x, fs] = audioread('bad_thing_drum_mono.wav');
[horig, porig] = HPSS(x, fs);

y_reconstruct = zeros(size(x));
y_bands = zeros(size(x, 1), size(hzVect, 2));

for bands = 1:1:size(hzVect, 2)-1
   band_edges = hzVect(bands:bands+1);
   display(band_edges)
   y = bandpass(x, band_edges, fs);
   y_trans = transientDesigner(y, 0, -1);
   y_bands(:, bands) = y_trans;
   y_reconstruct = y_reconstruct + y_trans;
end

audiowrite('reconstructed.wav', y_reconstruct, fs);

%figure; plot(x); hold on; plot(y_reconstruct);