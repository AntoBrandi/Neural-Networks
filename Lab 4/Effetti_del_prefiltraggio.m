%% EFFETTI DEL PREFILTRAGGIO 15.10.2018

% Definiremo tre tipi di rumore:
% 1. Rumore bianco
% 2. Rumore colorato a banda stretta
% 3. Rumore colorato a banda larga

clc
close all
clear all


%% Creo il sistema

Ts = 1;
Ao = [1 -1.5 0.7];
Bo = [0 1 0.5];
U = randn(500,1);   
Yo = filter(Bo,Ao,U);    % La funzione filtra il terzo argomento con un filtro Bo/Ao. Yo è l'uscita ideale del sistema
G = tf(Bo,Ao,Ts);        % Sistema reale da identificare


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  RUMORE BIANCO %%%%%%%%%%%%%%%%%%%%%%%%%%
%% Identificazione

Vw = randn(500,1);                    % Rumore bianco
Vw = Vw/std(Vw)*std(Yo)*sqrt(0.1);    % Normalizzo il rumore rispetto ad Yo: scalo il rumore in modo  
                                      % che la sua potenza sia il 10% di quella del segnale Yo
                                      % La funzione 'std' mi calcola la deviazione standard
                                      % std(x) -> deviazione standard segnale x

Yw = Yo + Vw;                         % Yw è la misura di Yo, per cui è affetta da rumore

% Identifico con un arx
Dw = iddata(Yw,U);
m1 = arx(Dw, [2 2 1]);
figure(1), compare(m1, Dw)            % Abbiamo un FIT del 46%
% Utilizzo per la validazione i dati di train (che in realtà comprendono
% tutti i dati) perchè sono interessato solo al prefiltraggio


%% Risposta in frequenza di m1

figure(2), step(m1, G)
legend('Risposta al gradino del modello stimato', 'Risposta al gradino del modello da stimare')   
% Abbiamo un errore del guadagno statico (a regime ho un ep =!0) e notiamo  
% che il sistema stimato è del 1° ordine, mentre quello reale è del 2°

figure(3), bode(m1, G)
legend('Diagramma di Bode del modello stimato', 'Diagramma di Bode del modello da stimare') 
% L'offset alle basse frequenze si ripercuote sulla risposta a gradino, notiamo anche 
% la differenza di ordine fra i modelli dalla presenza dell'effetto di risonanza


%% Prefiltraggio di m1

A_stimato = m1.A;                      % Polinomio stimato A del modello m1
U_filtrato = filter(1,A_stimato,U);    % Filtro U con una funzione L(z) = 1/A_stimato
Y_filtrato = filter(1,A_stimato,Yw);

% Identifico
Dw_filtrato = iddata(Y_filtrato, U_filtrato);
m1_filtrato = arx(Dw_filtrato, [2 2 1]);

figure(4), step(m1_filtrato, m1, G)
legend('Risposta al gradino del modello stimato filtrato', 'Risposta al gradino del modello stimato', 'Risposta al gradino del modello da stimare') 

figure(5), bode(m1_filtrato, m1, G)
legend('Diagramma di Bode del modello stimato filtrato', 'Diagramma di Bode del modello da stimato', 'Diagramma di Bode del modello da stimare') 


%% Secondo prefiltraggio di m1 basato su quello precedente

A_stimato2 = m1_filtrato.A;
U_filtrato2 = filter(1,A_stimato2,U);    
Y_filtrato2 = filter(1,A_stimato2,Yw);

% Identifico
Dw_filtrato2 = iddata(Y_filtrato2, U_filtrato2);
m1_filtrato2 = arx(Dw_filtrato2, [2 2 1]);

figure(6), step(m1_filtrato2, m1_filtrato, m1, G)
legend('Risposta al gradino del modello stimato filtrato (2 iter.)', 'Risposta al gradino del modello stimato filtrato (1 iter.)', 'Risposta al gradino del modello da stimato', 'Risposta in frequenza del modello da stimare') 

figure(7), bode(m1_filtrato2, m1_filtrato, m1, G)
legend('Diagramma di Bode del modello stimato filtrato (2 iter.)', 'Diagramma di Bode del modello da stimato filtrato (1 iter.)', 'Diagramma di Bode del modello da stimato', 'Diagramma di Bode del modello da stimare')

figure(8), compare(m1_filtrato2, Dw)    % Miglioramento del FIT: 70%


%% Terzo prefiltraggio di m1

A_stimato3 = m1_filtrato2.A;
U_filtrato3 = filter(1,A_stimato3,U);    
Y_filtrato3 = filter(1,A_stimato3,Yw);

% Identifico
Dw_filtrato3 = iddata(Y_filtrato3, U_filtrato3);
m1_filtrato3 = arx(Dw_filtrato3, [2 2 1]);

figure(9), step(m1_filtrato3, m1_filtrato2, m1_filtrato, m1, G)
legend('Risposta al gradino del modello stimato filtrato (3 iter.)', 'Risposta al gradino del modello stimato filtrato (2 iter.)', 'Risposta al gradino del modello stimato filtrato (1 iter.)', 'Risposta in frequenza del modello stimato', 'Risposta in frequenza del modello da stimare') 

figure(10), bode(m1_filtrato2, m1_filtrato, m1, G)
legend('Diagramma di Bode del modello stimato filtrato (3 iter.)', 'Diagramma di Bode del modello stimato filtrato (2 iter.)', 'Diagramma di Bode del modello stimato filtrato (1. iter)', 'Diagramma di Bode del modello stimato', 'Diagramma di Bode del modello da stimare')

figure(11), compare(m1_filtrato3, Dw)
% Poichè il FIT aumenta di poco possiamo terminare le iterazioni


%%%%%%%%%%%%%%%%%%%%%%%%%%%%  RUMORE A BANDA STRETTA E LARGA %%%%%%%%%%%%%%%%%%%%%%%%%%
%% Creo i rumori a banda stretta e larga 
% Frequenze di taglio: f =0.52 banda larga, f =0.001 banda stretta
% H(z) = (1 - alfa)/(1 - alfa*z^-1)

alfaBandaLarga = 0.6;
Vc1 = filter(1 - alfaBandaLarga, [1 -alfaBandaLarga], randn(500,1));   
% Filtro un rumore bianco con un filtro a banda larga

alfaBandaStretta = 0.999;
Vc2 = filter(1 - alfaBandaStretta, [1 -alfaBandaStretta], randn(500,1));

filtroBandaLarga = tf(1 -alfaBandaLarga, [1 -alfaBandaLarga], Ts);
filtroBandaStretta = tf(1 - alfaBandaStretta, [1 -alfaBandaStretta], Ts);

figure(12), bode(filtroBandaLarga, filtroBandaStretta)
legend('Diagramma di Bode del filtro banda larga', 'Diagramma di Bode del filtro banda stretta')

f1 = bandwidth(filtroBandaLarga)     % 0.521 rad/s
f2 = bandwidth(filtroBandaStretta)

% Normalizzo il rumore 
Vc1 = Vc1/std(Vc1)*std(Yo)*sqrt(0.1);    
Vc2 = Vc2/std(Vc2)*std(Yo)*sqrt(0.1); 

%Uscite misurate affetta da rumore colorato
Yc1 = Yo + Vc1;
Yc2 = Yo + Vc2;

% Creo i modelli
Dc1 = iddata(Yc1, U);
Dc2 = iddata(Yc2, U);

mc1 = arx(Dc1, [2 2 1]);
mc2 = arx(Dc2, [2 2 1]);


%% Prefiltraggio di mc1 e mc2

A_stimato_c1 = mc1.A;
A_stimato_c2 = mc2.A;

U_filtrato_c1 = filter(1,A_stimato_c1,U);    
Y_filtrato_c1 = filter(1,A_stimato_c1,Yc1);

U_filtrato_c2 = filter(1,A_stimato_c2,U);    
Y_filtrato_c2 = filter(1,A_stimato_c2,Yc2);

Dc1_filtrato = iddata(Y_filtrato_c1, U_filtrato_c1);
Dc2_filtrato = iddata(Y_filtrato_c2, U_filtrato_c2);

mc1_filtrato = arx(Dc1_filtrato, [2 2 1]);
mc2_filtrato = arx(Dc2_filtrato, [2 2 1]);

figure(13), step(mc1_filtrato, mc1, G)
legend('Risposta la gradino del modello a banda larga stimato filtrato', 'Risposta al gradino del modello a banda larga stimato', 'Risposta la gradino del modello da stimare')
% Il prefiltraggio funziona molto meglio con un rumore a banda larga

figure(14), step(mc2_filtrato, mc2, G)
legend('Risposta la gradino del modello a banda stretta stimato filtrato', 'Risposta al gradino del modello a banda stretta stimato', 'Risposta la gradino del modello da stimare')
% A banda stretta è più difficile identificare perchè limitiamo l'area e
% quindi necessitiamo di funzioni peso molto specifiche

figure(15), step(mc1_filtrato, mc2_filtrato, G)
legend('Risposta al gradino del modello a banda larga stimato filtrato', 'Risposta al gradino del modello a banda stretta stimato filtrato', 'Risposta al gradino del modello da stimare')