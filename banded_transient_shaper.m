b = hz2bark([20, 20000]);
barkVect = linspace(b(1), b(2), 40);
hzVect = bark2hz(barkVect);

display(hzVect)

[x, fs] = audioread('simple_mix.wav');

plot(x); grid on; hold on;

for bands = 1:1:size(hzVect, 2)-1
   band_edges = hzVect(bands:bands+1);
   display(band_edges)
   y = bandpass(x, band_edges, fs);
   plot(y);
   pause();
end