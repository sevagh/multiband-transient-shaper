function multibandTransientShaper(path)
    [x, fs] = audioread(path);
    
    b = hz2bark([20, 20000]);
    barkVect = linspace(b(1), b(2), 24);
    hzVect = bark2hz(barkVect);

    yEnhanced = zeros(size(x));
    ySuppressed = zeros(size(x));

    attackFastMs = 1;
    attackSlowMs = 10;
    releaseMs = 30;

    for bands = 1:1:size(hzVect, 2)-1
        bandEdges = hzVect(bands:bands+1);
        fprintf("band %s - %s Hz\n", bandEdges(1), bandEdges(2));
        
        y = bandpass(x, bandEdges, fs);
       
        [fast, slow, attack, sustain] = transientShaper(y, fs,...
            attackFastMs, attackSlowMs, releaseMs);
        
        %figure;
        %plot(fast); hold on; plot(slow); plot(attack);
        %legend('fast', 'slow', 'attack');
        %title(sprintf("Envelopes, band %f-%f Hz", bandEdges(1),...
        %    bandEdges(2)));
        
        yTransientEnhanced = y .* attack;
        yTransientSuppressed = y .* sustain;
        
        %figure;
        %plot(y); hold on; plot(yTransientEnhanced);
        %title(sprintf("Waveforms, band %f-%f Hz", bandEdges(1),...
        %    bandEdges(2)));
        
        yEnhanced = yEnhanced + yTransientEnhanced;
        ySuppressed = ySuppressed + yTransientSuppressed;
    end
    
    yEnhanced = yEnhanced/max(abs(yEnhanced));
    ySuppressed = ySuppressed/max(abs(ySuppressed));

    audiowrite('enhanced.wav', yEnhanced, fs);
    audiowrite('suppressed.wav', ySuppressed, fs);
end
