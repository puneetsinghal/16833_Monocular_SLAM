function [X,Y] = plotPotential()

X = -pi:0.1:pi;
qsr_beta1 = -pi/2; qsr_beta2 = 0; qsr_beta3 = pi/2;
landscape = @(X) 1/12.*X.*(-12.*qsr_beta1.*qsr_beta2.*qsr_beta3 + 6.*(qsr_beta2.*qsr_beta3 + qsr_beta1.*(qsr_beta2 + qsr_beta3)).*X - 4.*(qsr_beta1 + qsr_beta2 + qsr_beta3).*X.^2 + 3.*X.^3);
Y = landscape(X);

figure(1)
plot(X,Y,'black','linewidth',3)
xlabel('\alpha')
ylabel('V(\alpha)')
title('Landscape Function V(\alpha)')
axis([-1.5*pi/2 1.5*pi/2 -2 2]);
set(gca,'FontSize',24,'Xtick',[-pi/2 0 pi/2],'XTickLabel',{'-\theta_{lim}','0','\theta_{lim}'});
