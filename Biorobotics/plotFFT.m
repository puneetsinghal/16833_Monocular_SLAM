function [f, power] = plotFFT(module)
    fs = 200;                                % Sample frequency (Hz)
    t = (0 : 1 : length(log.torque(:, 1) - 1)) / fs;
    x = log.torque(:, module);
    m = length(x);          % Window length
    n = pow2(nextpow2(m));  % Transform length
    y = fft(x,n);           % DFT
    f = (0:n-1)*(fs/n);     % Frequency range
    power = y.*conj(y)/n;   % Power of the DFT

