function [R,S] = medfilter(X, h)

N = length(X);

if nargin < 2
    h = 20;
end

R = zeros(1,N);
S = zeros(1,N);

for i=1:N
    R(i) = mean(X(max(1,i-h):min(N,i+h)));
    S(i) = std(X(max(1,i-h):min(N,i+h)));
end
