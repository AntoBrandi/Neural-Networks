%% ANALISI ASINTOTICA (Aumentare i dati) 15.10.2018

% Supponiamo di non conscere il sistema (che creeremo noi) e scegliamo il
% predittore; vedremo che, se il predittore scelto non è uguale al sistema
% usato, otterremo una stima inconsistente anche se aumentiamo il numero di 
% dati, mentre se il predittore è esatto otterremo sempre una stima quanto 
% più esatta tanto più aumentiamo i dati

clc
clear all
close all


%% Creazione del sistema

Ts = 0.01;                % Passo campionamento
Tend = 10000*Ts;
t = (0:Ts:Tend)';
Nmax = length(t);         % Dimensione dei dati

G = zpk([10], [-20 -20 -50 -100], -400*50*10) %zero, poli, guadagno
Gz = c2d(G, Ts)           % Discretizziamo la G

figure(1), impulse(Gz)    % Sistema a fase non minima, ha uno zero positivo
figure(2), pzmap(Gz)      % Luogo delle radici nel discreto

[num,den] = tfdata(Gz, 'v')

% Arrotondiamo i parametri per semplicità di calcolo comput
B = [0 -0.02 -0.03 0.05 0.01] %num approssimato
A = [1.00 -2.61 2.49 -1.02 0.15] %den approssimato


%% Scegliamo l'ingresso U che utilizzeremo per l'identificazione dei dati

U = randn(Nmax,1); % Ci restituisce un segnale random a media nulla di dimensione Nmax x 1 -> persistentemente eccitante


%% Scegliamo il rumore E che vorremo eliminare

E = randn(Nmax,1); 
noise_variance = 1e-6;

%% Creiamo il MDG (Meccanismo di Generazione dei Dati)

S = idpoly(A,B,[],[],[],noise_variance,Ts);    % Genera un modello ancora più generale di quello di Box-Jenkins
                                               % In questo caso stiamo creando un ARX perchè D E F sono vuote
  % idpoly(A,B,C,D,E,F,noise_variance,Ts) con A*y=[B/F]*u+[C/D]*e
                                               
Y = sim(S, [U, E])                              % Simula il modello S, dando in ingresso U ed E


%% Estrapoliamo i dati

Dati = iddata(Y,U,Ts);
figure(3), plot(Dati)

Dati.InputName = 'Ingresso';
Dati.OutputName = 'Uscita';

% Suddividiamo i dati in set che hanno un numero di dati via via più grande; 
% su tali set faremo il training e la validazione
Dati50 = Dati(1:50);
Dati100 = Dati(1:100);
Dati200 = Dati(1:200);
Dati500 = Dati(1:500);
DatiInf = Dati(1:9500);
ValiData = Dati(9500:10000);


%% Definiamo il modello del predittore (identifichiamo) e validiamo

% Ne defiamo 5 perchè abbiamo 5 set di training
m50 = arx(Dati50, [4 4 1]) %[4 4 1] è il vettore dei parametri teta, che non è detto sia quello ottimo
m100 = arx(Dati100, [4 4 1])
m200 = arx(Dati200, [4 4 1])
m500 = arx(Dati500, [4 4 1])
mInf = arx(DatiInf, [4 4 1])

figure(4), compare(ValiData, m50, m100, m200, m500, mInf)  
% Notiamo che i modelli offrono via via una stima migliore del MGD perchè
% ho scelto come famiglia proprio un ARX, cioè proprio la stessa famiglia
% del MGD

%% Capiamo la bontà dei modelli 
% A noi interessa vedere quanto varia la differenza fra il teta che
% conosciamo e quello che identifichiamo

[B_50, A_50] = tfdata(m50, 'v');
[B_100, A_100] = tfdata(m100, 'v');
[B_200, A_200] = tfdata(m200, 'v');
[B_500, A_500] = tfdata(m500, 'v');
[B_Inf, A_Inf] = tfdata(mInf, 'v');

% Valutiamo il massimo errore commesso sui parametri
MaxErr_m50 = max([abs(B_50-B) abs(A_50-A)]);
MaxErr_m100 = max([abs(B_100-B) abs(A_100-A)]);
MaxErr_m200 = max([abs(B_200-B) abs(A_200-A)]);
MaxErr_m500 = max([abs(B_500-B) abs(A_500-A)]);
MaxErr_mInf = max([abs(B_Inf-B) abs(A_Inf-A)]);

Parameter_Error = [MaxErr_m50 MaxErr_m100 MaxErr_m200 MaxErr_m500 MaxErr_mInf];

figure(5), plot([50 100 200 500 1000], Parameter_Error)
% Vediamo che all'aumentare del numero dei dati, diminuisce l'errore sui teta


%% Proviamo a vedere cosa accade con un modello sbagliato

mWrong1 = arx(Dati200, [2 2 1]); %Scegliamo un vettore dei parametri diverso (peggiore)
mWrong2 = arx(DatiInf, [2 2 1]);
figure(6), compare(ValiData, mWrong1, mWrong2)

[B_mWrong1, A_mWrong1] = tfdata(mWrong1, 'v');
[B_mWrong2, A_mWrong2] = tfdata(mWrong2, 'v');
MaxErr_mWrong1 = max([abs(B_mWrong1 - B(1:3)) abs(A_mWrong1 - A(1:3))]);
MaxErr_mWrong2 = max([abs(B_mWrong2 - B(1:3)) abs(A_mWrong2 - A(1:3))]);      % Prendiamo i primi tre parametri di B ed A
                                                                              % perchè così arriviamo a grado 2, 
                                                                              %altrimenti non potremmo comparare 
                                                                              % un modello di grado 4 (sistema) ed uno di grado 2 (modello)
Parameter_Error = [MaxErr_m50 MaxErr_m100 MaxErr_m200 MaxErr_m500 MaxErr_mInf MaxErr_mWrong1 MaxErr_mWrong2];

figure(7), plot([50 100 200 500 1000 1500 2000], Parameter_Error)
% Vediamo che la differenza fra il teta noto e il teta trovato cresce di
% molto fino a rimanere quasi costante (per il set di DatiInf), non dandoci
% nessun contributo