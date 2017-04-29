function R = majfilter(X, h, thres)

if nargin < 3
    thres = h/2;
end

% majority window algorithm
% X: binary vector
% h: window length
% thres: majority thres

N = length(X);

if nargin < 2
    h = 20;
end

R = zeros(1,N);

for i=1:N
    R(i) = mean(X(max(1,i-h):min(N,i+h))) > thres;
end
