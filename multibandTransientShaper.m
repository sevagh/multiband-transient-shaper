function multibandTransientShaper(path)
    [x, fs] = audioread(path);

    b = hz2bark([20, 20000]);
    barkVect = linspace(b(1), b(2), 40);
    hzVect = bark2hz(barkVect);

    yReconstruct = zeros(size(x));
    yBands = zeros(size(x, 1), size(hzVect, 2));

    transientBandParams = zeros(3, size(hzVect, 2));

    attackFastMs = 1;
    attackSlowMs = 10;
    releaseMs = 30;

    % adjust attack and release per band if you want
    for bands = 1:1:size(hzVect, 2)-1
        transientBandParams(:, bands) = [attackFastMs attackSlowMs releaseMs];
    end

    for bands = 1:1:size(hzVect, 2)-1
        bandEdges = hzVect(bands:bands+1);
        display(bandEdges)
        y = bandpass(x, bandEdges, fs);

        aFast = transientBandParams(1, bands);
        aSlow = transientBandParams(2, bands);
        release = transientBandParams(3, bands);

        [yShaped, envFast, envSlow, envDiff] = transientShaper(y, fs,...
            aFast, aSlow, release);

        yBands(:, bands) = yShaped;
        yReconstruct = yReconstruct + yShaped;

        %figure(1);
        %plot(envFast); hold on;
        %plot(envSlow); 
        %plot(envDiff);
        %hold off;
        %legend({num2str(attackFastMs), num2str(attackSlowMs), ...
        %    'envFast - envSlow'});
        %title(sprintf("Band %s envelopes", mat2str(band_edges)));

        %audiowrite('transient_shaped.wav', y, fs);

        %figure(3);
        %subplot(2,1,1);
        %plot(x); title(sprintf('Band %s input waveform', mat2str(band_edges)));
        %subplot(2,1,2);
        %plot(y); title(sprintf('Band %s output waveform', mat2str(band_edges)));
    end

    % normalize
    yReconstruct = yReconstruct/max(abs(yReconstruct));

    [yUnbandedShaped, a, b, c] = transientShaper(x, fs,...
        attackFastMs, attackSlowMs, releaseMs);

    audiowrite('banded_shaped.wav', yReconstruct, fs);
    audiowrite('unbanded_shaped.wav', yUnbandedShaped, fs);
end
%figure; plot(x); hold on; plot(y_reconstruct);