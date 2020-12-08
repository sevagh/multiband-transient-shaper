[x, fs] = audioread('drum.wav');

% params
attackFastMs = 1;
attackSlowMs = 20;
releaseMs = 50;
attackFactor = 1.0;
sustainFactor = 0.0;

gAttackFast = exp(-1/(fs*attackFastMs/1000));
gAttackSlow = exp(-1/(fs*attackSlowMs/1000));
gRelease = exp(-1/(fs*releaseMs/1000));

fbFast = 0; % feedback terms
fbSlow = 0;

N = length(x);

envFast = zeros(N, 1);
envSlow = zeros(N, 1);
transientShaper = zeros(N, 1);

for n = 1:N
    if fbFast > in(n, 1)
        envFast(n, 1) = (1 - gRelease) * in(n, 1) + gRelease * fbFast;
    else
        envFast(n, 1) = (1 - gAttackFast) * in(n, 1) + gAttackFast * fbFast;
    end
    fbFast = envFast(n, 1);
    
    if fbSlow > in(n, 1)
        envSlow(n, 1) = (1 - gRelease) * in(n, 1) + gRelease * fbSlow;
    else
        envSlow(n, 1) = (1 - gAttackSlow) * in(n, 1) + gAttackSlow * fbSlow;
    end
    fbSlow = envSlow(n, 1);
    
    transientShaper(n, 1) = envFast(n, 1) - envSlow(n, 1);
end

figure(1);
plot(envFast); hold on;
plot(envSlow); 
plot(transientShaper);
hold off;
legend({num2str(attackFastMs), num2str(attackSlowMs), ...
    'envFast - envSlow'});
axis([1 length(in) -0.5 1]);

attack = zeros(N,1);
sustain = zeros(N,1);
for n = 1:N
   
    if transientShaper(n,1) > 0
        
        attack(n,1) = (attackFactor * transientShaper(n,1)) + 1;
        sustain(n,1) = 1;
    else
        
        attack(n,1) = 1;
        sustain(n,1) = (sustainFactor * transientShaper(n,1)) + 1;
        
    end
    
end

figure(2);
subplot(2,1,1);  % Plot the detected attack envelope
plot(attack); title('Attack Envelope', 'FontSize',14);
axis([1 length(in) 0.5 1.5]);
subplot(2,1,2);  % Plot the detected sustain envelope
plot(sustain); title('Sustain Envelope', 'FontSize',14);
axis([1 length(in) 0.5 1.5]);

% Apply the Attack and Sustain Envelopes
out = (in .* attack) .* sustain;
out = out/max(abs(out)); % normalize between -1 and 1

audiowrite('transient_shaped.wav', out, Fs);

figure(3);
subplot(2,1,1);
plot(in); title('Input waveform');
subplot(2,1,2);
plot(out); title('Output waveform');

% This source code is provided without any warranties as published in 
% "Hack Audio: An Introduction to Computer Programming and Digital Signal
% Processing in MATLAB" � 2019 Taylor & Francis.
% 
% It may be used for educational purposes, but not for commercial 
% applications, without further permission.
%
% Book available here (uncomment):
% url = ['https://www.routledge.com/Hack-Audio-An-Introduction-to-'...
% 'Computer-Programming-and-Digital-Signal/Tarr/p/book/9781138497559'];
% web(url,'-browser');
% 
% Companion website resources (uncomment):
% url = 'http://www.hackaudio.com'; 
% web(url,'-browser');
