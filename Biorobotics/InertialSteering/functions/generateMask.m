function Imask = generateMask(locMin, dim)

Imask = ones(dim);

for i=1:dim(2)
    Imask(1:locMin(i)-1,i) = 0;
end
