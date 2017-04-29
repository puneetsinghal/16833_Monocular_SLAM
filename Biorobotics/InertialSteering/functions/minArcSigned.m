function dAngleSigned = minArcSigned(angle, reference)

alpha1 = mod(angle-reference,2*pi);
alpha2 = mod(reference-angle,2*pi);
I = (alpha1 < alpha2);

dAngleSigned = - alpha1.*I + alpha2.*not(I);
