%% IDENTIFICAZIONE DI UNA FUNZIONE NON LINEARE TRAMITE RETE NEURALE 10.12.2018

clear all
close all
clc


%% Creiamo il MGD

u1 = 3*(rand(1,200)-0.5);     % Ingresso rumoroso (rumore bianco)
u2 = sin(2*pi*[201:400]/25);  % Ingresso sinusoidale
u = [u1 u2];

% Definiamo alcuni valori della funzione che vogliamo identificare
f = zeros(1,400);
f(1:2) = u(1:2);

for k = 3:1:400
    f(k) = nonlinDE(f(k-1),f(k-2)) + u(k); %MGD da identificare con NN, supponiamo rumore assente
end

figure(1)
subplot(4,1,1), plot(u), axis([0 400 -2 2]), title('Segnale di ingresso')
subplot(4,1,2), plot(f), axis([0 400 -2 2]), title('Segnale di uscita')

% Riorganizziamo gli ingressi
% La rete deve avere 3 ingressi [come il MGD che ha come ingressi f(k-1),
% f(k-2) e u(k)
input = zeros(3,400);
input(1,:) = [0 f(1:399)]; %f(k-1)
input(2,:) = [0 0 f(1:398)]; %f(k-2)
input(3,:) = u; %u(k)
Xin = input;
Xout = f;


%% Creo la rete

net = newff(Xin, Xout, [20 10]);     % 3 ingressi x 1 uscita -> creazione rete neurale iniziale
net.trainParam.epochs = 1000;    
net = train(net, Xin, Xout);         % rete neurale addestrata
yhat = sim(net, Xin);                % Uscita della rete addestrata

figure(1)
subplot(4,1,3), plot(1:400,f,1:400,yhat), title('Confronto fra MGD e predizione della rete neurale')
subplot(4,1,4), plot(1:400, f-yhat), title('Errore di predizione')