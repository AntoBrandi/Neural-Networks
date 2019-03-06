%% Esercizio analisi asintotica

clear all
close all
clc

%% Dati

Ts=0.1;
t=[0:Ts:100];
N=length(t); %# istanti di tempo
noise_variance=1e-6;
%% Creazione sistema

G=zpk([-2 2],[-3 -10 -30],10); %Sistema t.c.
Gz=c2d(G,Ts); %Sistema equivalente t.d.
[num,den]=tfdata(Gz,'v')

S=idpoly(den,num,[],[],[],noise_variance,Ts) %Ho creato il MGD, che per come l'ho impostato è un ARX

%% Identificazione p.1 -> scelta dell'ingresso

U=randn(N,1); %genero segnale ingresso persistentemente eccitante
E=randn(N,1); %rumore in ingresso

%% Identificazione p.2 -> Creo set di uscite

Y=sim(S,[U,E]);

%% Identificazione p.3 -> Interpretazione dei dati

data=iddata(Y,U,Ts);
plot(data)

%% Identificazione p.4 -> Creazione punti di training e validation

train50=data(1:50);
train250=data(1:250);
train500=data(1:500);
train900=data(1:900);
valid=data(901:1001);

%% Identificazione p.5 -> Creo modello del predittore

%Decido di utilizzare un predittore ARX(3,3,1)
m50=arx(train50,[3,3,1]);
m250=arx(train250,[3,3,1]);
m500=arx(train500,[3,3,1]);
m900=arx(train900,[3,3,1]);

figure(2), compare(valid,m50,m250,m500,m900)

%% Stima della bontà dei modelli

%Mi aspetto che all'aumentare di N l'errore tende a zero

[num50,den50]=tfdata(m50,'v');
[num250,den250]=tfdata(m250,'v');
[num500,den500]=tfdata(m500,'v');
[num900,den900]=tfdata(m900,'v');

max_e50=max([abs(num-num50) abs(den-den50)]);
max_e250=max([abs(num-num250) abs(den-den250)]);
max_e500=max([abs(num-num500) abs(den-den500)]);
max_e900=max([abs(num-num900) abs(den-den900)]);

figure(3), plot([50 250 500 900],[max_e50 max_e250 max_e500 max_e900])
%All'aumentare di N l'errore diminuisce perché ho utilizzato il modello
%corretto

%Cosa succede se utilizzo un modello di predittore sbagliato?

%% Identificazione p.6 ->Creo predittore ARX di ordine inferiore

ms250=arx(train250,[2 2 1]);
ms900=arx(train900,[2 2 1]);

figure(4), compare(valid,ms250,ms900)