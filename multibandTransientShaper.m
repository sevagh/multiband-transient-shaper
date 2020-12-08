function multibandTransientShaper(path)
    [x, fs] = audioread(path);

    b = hz2bark([20, 20000]);
    barkVect = linspace(b(1), b(2), 40);
    hzVect = bark2hz(barkVect);

    yEnhanced = zeros(size(x));
    ySuppressed = zeros(size(x));

    attackFastMs = 1;
    attackSlowMs = 10;
    releaseMs = 30;

    for bands = 1:1:size(hzVect, 2)-1
        bandEdges = hzVect(bands:bands+1);
        display(bandEdges)
        y = bandpass(x, bandEdges, fs);

        [attack, sustain] = transientShaper(y, fs,...
            attackFastMs, attackSlowMs, releaseMs);

        yEnhanced = yEnhanced + y .* attack;
        ySuppressed = ySuppressed + y .* sustain;
    end
    
    yEnhanced = yEnhanced/max(abs(yEnhanced));
    ySuppressed = ySuppressed/max(abs(ySuppressed));

    audiowrite('enhanced.wav', yEnhanced, fs);
    audiowrite('suppressed.wav', ySuppressed, fs);
end
