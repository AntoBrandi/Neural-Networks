function [f] = nonlinDE(f1, f2)
f = (f1*f2*(f1 - 0.5)/(1 + (f1^2)*f2^2));
return

% Funzione di un sistema dinamico che vogliamo identificare con reti
% neurali