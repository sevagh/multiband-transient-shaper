b = hz2bark([20, 20000]);
barkVect = linspace(b(1), b(2), 40);
hzVect = bark2hz(barkVect);

[x, fs] = audioread('simple_mix.wav');

plot(x); grid on; hold on;

y_reconstruct = zeros(size(x));

for bands = 1:1:size(hzVect, 2)-1
   band_edges = hzVect(bands:bands+1);
   display(band_edges)
   y = bandpass(x, band_edges, fs);
   plot(y);
   y_reconstruct = y_reconstruct + y;
end

audiowrite('reconstructed.wav', y_reconstruct, fs);