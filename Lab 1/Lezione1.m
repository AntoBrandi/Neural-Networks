%Per identificare un sistema devo raccogliere la maggior parte dei dati
%variando gli input (impulso, gradino, seno, random...)
%Il modello generico che rappresenta un black box è quello di BOX-JENKINS
%di cui alcuni esempi sono (OE, ARMAX, ARX), ciascuna
%caratterizzata da una certa tipologia di equazione differenziale (o alle
%differenze). I coefficienti che caratterizzano tali eq differenziali e che
%quindi possono caratterizzare la black box si trovano con metodi di 
%identificazione (es. per ARX si usa minimi quadrati)

clear all
close all
clc

%help ident --> help su SYSTEM IDENTIFICATION TOOLBOX
load Dati_caso1 %caricamento degli ingressi e delle uscite e tempo di camp
plot(U) %ingresso RANDOM
plot(Y)%uscita in corrispondenza dell'ingresso

%il comando iddata permette di creare un oggetto che contenga input/output
dati=iddata(Y,U,t); %ho creato un oggetto che ha raccolto i dati
plot(dati);

%alcuni dati li salviamo per il training e altri per la validazione
Zc=200; %numero di dati da utilizzare x il training
train=dati(1:Zc);
valid=dati(Zc+1:Zc*2);%i restanti N-Zc per la validazione

%scegliamo la famiglia di modelli (nel nostro caso scegliamo ARX)
% SYS = arx(DATA, ORDERS), con data=iddata(..) e orders=[2 2 1] (ci sono
% particolare tecniche per trovare il miglior valore di orders) in cui
% orders contiene il numero di coefficienti legati dell'eq diff legati a
% dy, dx ed il numero di campioni di ritardo ingresso-uscita.
%Ad esempio [2 2 1] significa che l'eq diff è del tipo
%y(k)=a1*y(k-1)+a2(yk-2)+b1*u(k-1)+b2*u(k-2) mentre il ritardo con cui si manifesta
%l'uscita è di 1 campione rispetto a quando c'è stato l'ingresso
%corrispondente

m1=arx(train,[2 2 1]) %ottengo il num e il den della fdt G(z) della black box supponendo che il sistema sia un ARX
figure(1)
compare(valid,m1) %compare(punti validazione, arx) permette di comparare
%l'andamento reale delle uscite con quello della fdt

%Dal grafico si ottiene che questa identificazione non va bene perché il fitting
%è troppo basso (-111%) più si avvicina al 100% e meglio è
%Proviamo ad incrementare il valore di orders

m2=arx(train,[3 3 1])
figure(2)
compare(valid,m1,m2)
%anche il secondo fitting è scadente (-145%), ovvero non è detto che
%aggiungendo più informazioni (coefficienti dell'eq diff) si ottenga un
%modello migliore

%Se studiamo bene la variazione del tempo degli ingressi e delle uscite mi
%accorgo che l'ipotesi di sistema lineare non va bene perché l'uscita non è
%solo amplificata ma shiftata di un certo livello. Se mi accorgo di questo
%posso usare il comando detrend in cui posso sottrarre un segnale da un
%altro
%detrend(X,constant) -> se constant =0 tolgo il valor medio X=X-media(X)
%se constant=1 tolgo una rampa
new_train=detrend(train,0);
new_valid=detrend(valid,0);
figure(3)
plot(train)
hold on
plot(new_train) %si vede che in uscita al segnale è stato tolto la media

%Ripeto identificazione con i nuovi dati di train e valid
m3=arx(new_train,[3 3 1]);
figure(4)
compare(m3,new_valid);
%come si può notare il fitting è di gran lunga migliore. Tuttavia mi devo
%ricordare che la fdt G(z) ottenuta si riferisce al segnale senza il suo
%valor medio. Devo ricordarmi quindi di addizionare il valor medio in
%uscita dalla G(z)

%se aumento il numero di ritardo tra input e output posso migliorare il
%fitting. Di quanto devo aumentare i campioni di ritardo nk?
%il comando impulse valuta la risposta all'impulso a partire dagli output e
%input. Dal grafico si intuisce che il primo segnale viene si ottiene al
%terzo passo di campionamento, quindi il valore di nk è 3
figure(5)
impulse(new_train,'sd',3,'fill') %si mettono sempre questi argomenti

m4=arx(new_train,[3 3 3]);
figure(6)
compare(m4,new_valid);
%il fitting è leggermente migliorato di oltre il 10%