function [y, envFast, envSlow, envDiff] = transientShaper(x, fs, attackFastMs, attackSlowMs, releaseMs)
    % params
    gAttackFast = exp(-1/(fs*attackFastMs/1000));
    gAttackSlow = exp(-1/(fs*attackSlowMs/1000));
    gRelease = exp(-1/(fs*releaseMs/1000));

    fbFast = 0; % feedback terms
    fbSlow = 0;

    N = length(x);

    envFast = zeros(N, 1);
    envSlow = zeros(N, 1);

    xPower = zeros(N, 1);
    powerMemoryMs = 1;
    gPowerMem = exp(-1/(fs*powerMemoryMs/1000));
    fbPowerMem = 0; % feedback term

    % signal power
    for n = 1:N
        xPower(n, 1) = (1 - gPowerMem)* x(n) * x(n) + gPowerMem*fbPowerMem;
        fbPowerMem = xPower(n, 1);
    end

    % derivative of signal power with simple 1-sample differentiator
    xDerivativePower = zeros(N, 1);

    xDerivativePower(1, 1) = xPower(1, 1);

    for n = 2:N
        xDerivativePower(n, 1) = xPower(n, 1) - xPower(n-1, 1);
    end

    envDiff = zeros(N, 1);

    for n = 1:N
        if fbFast > xDerivativePower(n, 1)
            envFast(n, 1) = (1 - gRelease) * xDerivativePower(n, 1) + gRelease * fbFast;
        else
            envFast(n, 1) = (1 - gAttackFast) * xDerivativePower(n, 1) + gAttackFast * fbFast;
        end
        fbFast = envFast(n, 1);

        if fbSlow > xDerivativePower(n, 1)
            envSlow(n, 1) = (1 - gRelease) * xDerivativePower(n, 1) + gRelease * fbSlow;
        else
            envSlow(n, 1) = (1 - gAttackSlow) * xDerivativePower(n, 1) + gAttackSlow * fbSlow;
        end
        fbSlow = envSlow(n, 1);

        envDiff(n, 1) = envFast(n, 1) - envSlow(n, 1);
    end
    
    y = x.*envDiff;
    y = y/max(abs(y));
end