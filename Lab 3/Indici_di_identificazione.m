%% Indici di identificazione 22.10.2018

% L'errore di simulazione si usa quando abbiamo pochi dati

clc
close all
clear all

%% Carico i dati

load eser4
dati = data2;


%% Creo i set di dati

valid = dati(1:150);
train = dati(151:500);
train_d = detrend(train, 0);
valid_d = detrend(valid, 0);


%% Stimo il ritardo nk

figure(1), impulse(train_d, 'sd', 3, 'fill')         % Noto che nk = 1


%% Vettore degli indici J di aderenza

J_index_T = [];     % Funzionale di costo sui dati di training (1/N*sommatoria (errore predizione)^2) usando il modello del sistema
J_index_V = [];     % Funzionale di costo sui dati di validation usando il modello del sistema
J_index_ST = [];    % Funzionale di costo sui dati di training usando il sistema stesso (in genere non è possibile)
J_index_SV = [];    % Errori ottenuti utilizzando il sistema stesso
Jfpe = [];          % Final Prediction Error
Javic = [];
Jmdl = [];


%% Creiamo il modello

% Creiamo degli arx

for k = 1:30
    
    modello_k = arx(train_d, [k k 1])
    
    % Test di bianchezza
    E = resid(modello_k, train_d);        % E' il residuo, cioè il vettore degli errori di predizione epsilon di train
    % Se voglio plottare il residuo devo scrivere figure(2), resid(..).
    % Plottando noteremmo che:
    % 1. L'autocorrelazione è impulsiva
    % 2. La correlazione è nulla (tutti i valori dei campioni sono all'interno della fascia di incertezza) 
 
    V = resid(modello_k, valid_d);       % Errori di predizione di validazione
   
    size_V = size(V.OutputData);        % size è utilizzato per calcolare la lunghezza di una matrice oltre che 
                                        % di un vettore; in questo caso avremmo potuto usare anche lenght
    size_E = size(E.OutputData);        % Il motivo di 'OutputData' è perchè E è una struttura. 
                                        % Nel command scrivendo E. e poi premendo tab vediamo i campi di E
   
    % Calcolo la covarianza degli errori di predizione
    JT = 0;                             % Conterrà i quadrati dell'errore di predizione di train
    JV = 0;
   
   for i = 1:size_E(1)
       JT = JT + E.OutputData(i).^2;
   end
   
   for i = 1:size_V(1)
       JV = JV + V.OutputData(i).^2;
   end
   
   JT = JT/size_E(1);                  % E' la covarianza di E
   JV = JV/size_V(1);
   
   J_index_T = [J_index_T; JT];        % Matrice delle covarianze per ogni k         
   J_index_V = [J_index_V; JV];       
   
   
   % Calcolo della covarianza degli errori di simulazione
   ysim = sim(modello_k, dati.U);
   y = dati.y;
   
   Es = y - ysim;                      % Errore di simulazione, quindi non uso l'uscita del predittore (come resid), 
                                       % ma proprio le uscite del modello stesso simulato
   
   JSV = cov(Es(1:150));
   JST = cov(Es(151:500));
   
   J_index_ST = [J_index_ST; JST];     
   J_index_SV = [J_index_SV; JSV];
   
   % Calcolo degli indici di validazione surrogati
   Jfpe(k) = fpe(modello_k);
   Javic(k) = aic(modello_k);
   
   n = k + k;                         % n = size(modello_k.Report.Parameters.ParaVector, 1);    
                                      % Lo posso calcolare anche come k+k visto che è la lunghezza di k
   N = length(train);
   Jmdl(k) = log10(N)*n/N + log(JT);
end  


%% Plot

figure(2), plot(J_index_T, 'b')
hold on
plot(J_index_V , 'r')  
legend('Indice di train JT', 'Indice di validazione JV')
title('Indici di predizione')
% Intorno a 23/24 la validazione inizia a crescere, quindi l'ordine ottimale è 23, altrimenti il sistema è 
% sovraparametrizzato

figure(3), plot(J_index_ST, 'b')
hold on
plot(J_index_SV, 'r')
legend('Indice J di train in simulazione', 'Indice J di validazione in simulazione') 
title('Indici di simulazione')
% La simulazione ci dice che l'indice di validazione cresce da 13 in poi, per cui il vero n ottimale è 13

figure(4), plot(Jfpe, 'b')
hold on
plot(Javic, 'r')
hold on
plot(Jmdl, 'g')
legend('FPE', 'AIC', 'MDL')   % L'AIC inizia a crescere intorno a 15
title('Indici di validazione surrogati')

% Quindi in conclusione l'ordine ottimale è da 13 a 15