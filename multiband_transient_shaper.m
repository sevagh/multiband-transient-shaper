b = hz2bark([20, 20000]);
barkVect = linspace(b(1), b(2), 40);
hzVect = bark2hz(barkVect);

[x, fs] = audioread('simple_mix.wav');

y_reconstruct = zeros(size(x));
y_bands = zeros(size(x, 1), size(hzVect, 2));

attackFastMs = 1;
attackSlowMs = 20;
releaseMs = 50;

for bands = 1:1:size(hzVect, 2)-1
   band_edges = hzVect(bands:bands+1);
   display(band_edges)
   y = bandpass(x, band_edges, fs);
   [y_trans, envFast, envSlow, envDiff] = transientShaper(y, fs, attackFastMs, attackSlowMs, releaseMs);
   y_bands(:, bands) = y_trans;
   y_reconstruct = y_reconstruct + y_trans;
   
   figure(1);
   plot(envFast); hold on;
   plot(envSlow); 
   plot(envDiff);
   hold off;
   legend({num2str(attackFastMs), num2str(attackSlowMs), ...
       'envFast - envSlow'});
   title(sprintf("Band %s envelopes", mat2str(band_edges)));

   %audiowrite('transient_shaped.wav', y, fs);

   figure(3);
   subplot(2,1,1);
   plot(x); title(sprintf('Band %s input waveform', mat2str(band_edges)));
   subplot(2,1,2);
   plot(y); title(sprintf('Band %s output waveform', mat2str(band_edges)));
end

%audiowrite('reconstructed.wav', y_reconstruct, fs);

%figure; plot(x); hold on; plot(y_reconstruct);