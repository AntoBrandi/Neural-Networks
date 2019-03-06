%ESERCIZIO X CASA
%Identificare G(z) che approssimi in maniera migliore i dati contenuti
%in "Dati_caso2.mat"

clear all
close all
clc

load Dati_caso2 %Carico la forma d'onda dell'ingresso (random) e quello dell'uscita

dati=iddata(Y,U,t); %creo un oggetto "dati" che contiene sia ingressi che uscite
figure(1)
plot(dati)

%% Prima identificazione della fdt G(z) che approssima i dati con metodo ARX

% Scomposizione dei punti in "training" e "validation"
Zc=400; %punti per training
train=dati(1:Zc)
valid=dati(Zc+1:Zc*2)

Model_1=arx(train,[2 2 1])
figure(2)
compare(valid,Model_1)
%Si nota una buona approssimazione

%% Seconda identificazione: aumento il numero dei coefficienti eq diff

Model_2=arx(train,[3 3 1])
figure(3)
compare(valid,Model_1,Model_2)
%Approssimazione pressoché uguale alla precedente

%% Terza identificazione: effettuo detrend delle uscite, portando il valor medio a 0

new_train=detrend(train,0);
new_valid=detrend(valid,0);
Model_3=arx(new_train,[2 2 1])
figure(4)
compare(new_valid,Model_3)
%è possibile notare un deciso miglioramento nel fitting

%% Quarta identificazione: aumento numero dei ritardi

figure(5)
impulse(new_train,'sd',3,'fill')
%dal grafico si nota che la prima uscita apprezzabile è in ritardo di 1
%campione rispetto allo zero (istante di applicazione dell'ingresso).
%Avendo già considerato questa situazione, non c'è bisogno di aumentare
%ancora di più il dato sul ritardo.
Model_4=arx(new_train,[2 2 3]) %aumentato il ritardo, da 1 a 3 campioni
figure(5)
compare(new_valid,Model_4)
%si può infatti notare un  deciso peggioramento nel fitting in seguito 
%all'aumento del ritardo

