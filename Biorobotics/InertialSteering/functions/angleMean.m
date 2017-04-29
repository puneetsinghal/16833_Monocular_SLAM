function mu = angleMean(CFHposes,currentHeading)

% means
mu1 = angle( mean(exp(1i * CFHposes)) );
mu2 = mod(mu1,2*pi) - pi;

% standard deviations
std1 = mean( minArcSigned(CFHposes,mu1).^2 );
std2 = mean( minArcSigned(CFHposes,mu2).^2 );

% final mean -> corresponding to min std
mu = mu1;
if std2 < std1
    mu = mu2;
end
