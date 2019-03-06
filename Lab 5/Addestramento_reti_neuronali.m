%% ADDESTRAMENTO DI RETI NEURALI 05.12.2018

% Definiamo una funzione non lineare con rumore e la rete neurale deve
% identificarla

clear all
close all
clc


%% Definisco la funzione con rumore

x = 0 : 4/100 : 4;                            % Range di ingressi
f0 = 4.26*(exp(-x)-4*exp(-2*x)+3*exp(-3*x));  % f0(x) è la funzione che vogliamo identificare;  
                                              % conoscendo x, ce ne calcoliamo alcuni valori

dev_stand = 0.2;                              % Deviazione standard del rumore
f = f0 + dev_stand*randn(size(f0));           % Ai dati otenuti dalla funzione f0 aggiungiamo il rumore bianco

figure(1), plot(x, f0, '--', x, f)
legend('Funzione f0 non lineare senza rumore', 'Funzione f non lineare con rumore bianco')


%% Definiamo la rete neurale

net = newff(x, f, 4);    % ff sta per feed forward, 4 è il numero di neuroni per strato; 
                         % In questo caso abbiamo un solo strato nascosto
                         % Se avevamo due strati nascosti dovevamo mettere [4, 10]
                         % Non conviene aumentare i neuroni altrimenti vado in overtraining
% I dati forniti dalla rete vengono suddivisi direttamente dal matlab in training, validation e testing

y = sim(net, x);         % Simula la rete con il set di ingresso x

figure(2), plot(x, y), title('Output della rete non addestrata')     % I pesi sono tarati in modo random


%% Effettuiamo il training della rete

net.trainParam.epochs = 200;   % Modifico il n° di epoche. Le epoche sono il n° di volte che la rete 
                               % fa la back propagation su tutti i dati (di default era 1000)
                               % "Prendi i parametri di training, in particolare le epoche e ponilo a 200"
[net, tr] = train(net, x, f);  % Effettuo il train della rete sui dati x f. tr serve per vedere le performance
y1 = sim(net, x);

figure(3), plot(x, y1, 'o-g'), title('Output della rete addestrata con i dati di training') 
figure(4), plotperform(tr)     % Grafico delle performance
% Delle 200 epoche si è fermato alla quinta perchè ha trovato il minimo
% locale in quanto il sistema è andato in overtraining


%% Aumentiamo il numero di neuroni e/o degli strati

net1 = newff(x, f, [30 30]); %Due strati nascosti di 30 neuroni a strato
[net1, tr1] = train(net1, x, f);
y2 = sim(net1, x);

figure(5), plot(x, y1, x, y2, x, f,'+', x, f0, '--')
legend('Output rete 1', 'Output rete 2', 'Funzione f', 'Funzione f senza rumore')  
% La seconda rete segue sempre di più il rumore e non la f0
% Se ho molti neuroni e/o molti strati nascosti, però, il risultato peggiora perchè va in overtraining