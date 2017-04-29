function dAngle = minArc(angle, reference)

dAngle = min( mod(angle-reference,2*pi), mod(reference-angle,2*pi) );
