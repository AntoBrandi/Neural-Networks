%% IDENTIFICAZIONE QUANDO MGD NON APPARTIENE ALLA FAMIGLIA SCELTA 22.10.2018

% Viene generato un sistema ARMAX ma lo proviamo ad identificare tramite un ARX

clc
clear all
close all


%% Creazione del sistema (Genero un ARMAX)

Ts = 0.01;
Tend = 10000*Ts;
t = (0:Ts:Tend)';
Nmax = length(t);                                   % Dimensione dei dati, numero di osservazioni sperimentali

G = zpk([10], [-20 -20 -50 -100], -400*50*10)
Gz = c2d(G, Ts)                                     % Discretizziamo la G

figure(1)
subplot(2,1,1), impulse(Gz)    
subplot(2,1,2), pzmap(Gz)                           % Sistema a fase non minima, ha uno zero positivo

[num,den] = tfdata(Gz, 'v')

% Arrotondo i parametri 
B = [0 -0.02 -0.03 0.05 0.01]
A = [1.00 -2.61 2.49 -1.02 0.15]
C = [1 1.9 0.4]                                     % Rappresenta la media mobile del rumore

% Definisco alcuni parametri
noice_variance1 = 1e-4;
noice_variance2 = 1e-7;                             % Più diventa piccola, più l'arx è confondibile con l'armax 
                                                    % perchè il peso di C (e quindi dell'incertezza) diminuisce
S1 = idpoly(A, B, C, [], [], noice_variance1, Ts);  
S2 = idpoly(A, B, C, [], [], noice_variance2, Ts);

Errors_arx1 = [];
Errors_arx2 = [];
Errors_armax1 = [];
Errors_armax2 = [];

%% Genero i dati e stimo con un ARX

for k = 1:10 %Ripeto 10 volte la simulazione ogni volta con un ingresso random diverso per poi valutare in media la qualità del modello
    
    % Creo i dati
    U = randn(10000,1); %Ingressi
    E = randn(10000,1); %Disturbi
    Y1 = sim(S1, [U E]); 
    Y2 = sim(S2, [U E]);
    Data1 = iddata(Y1,U,Ts);
    Data2 = iddata(Y2, U, Ts);
    
    % Creo i set di dati
    Data1_50 = Data1(1:50);
    Data1_100 = Data1(1:100);
    Data1_200 = Data1(1:200);
    Data1_500 = Data1(1:500);
    Data1_9000 = Data1(1:9000);
    
    Data2_50 = Data2(1:50);
    Data2_100 = Data2(1:100);
    Data2_200 = Data2(1:200);
    Data2_500 = Data2(1:500);
    Data2_9000 = Data2(1:9000);
    
    % Genero i modelli ARX con cui stimare un ARMAX
    m1_50 = arx(Data1_50, [4 4 1]);
    m1_100 = arx(Data1_100, [4 4 1]);
    m1_200 = arx(Data1_200, [4 4 1]);
    m1_500 = arx(Data1_500, [4 4 1]);
    m1_9000 = arx(Data1_9000, [4 4 1]);
    
    m2_50 = arx(Data2_50, [4 4 1]);
    m2_100 = arx(Data2_100, [4 4 1]);
    m2_200 = arx(Data2_200, [4 4 1]);
    m2_500 = arx(Data2_500, [4 4 1]);
    m2_9000 = arx(Data2_9000, [4 4 1]);
    
    % Calcolo gli errori sui parametri
    [B1_50,A1_50] = tfdata(m1_50, 'v');
    e1_50 = sqrt(sum([A-A1_50 B-B1_50].^2));
    
    [B1_100,A1_100] = tfdata(m1_100, 'v');
    e1_100 = sqrt(sum([A-A1_100 B-B1_100].^2));
    
    [B1_200,A1_200] = tfdata(m1_200, 'v');
    e1_200 = sqrt(sum([A-A1_200 B-B1_200].^2));
    
    [B1_500,A1_500] = tfdata(m1_500, 'v');
    e1_500 = sqrt(sum([A-A1_500 B-B1_500].^2));
    
    [B1_9000,A1_9000] = tfdata(m1_9000, 'v');
    e1_9000 = sqrt(sum([A-A1_9000 B-B1_9000].^2));
    
    [B2_50,A2_50] = tfdata(m2_50, 'v');
    e2_50 = sqrt(sum([A-A2_50 B-B2_50].^2));
    
    [B2_100,A2_100] = tfdata(m2_100, 'v');
    e2_100 = sqrt(sum([A-A2_100 B-B2_100].^2));
    
    [B2_200,A2_200] = tfdata(m2_200, 'v');
    e2_200 = sqrt(sum([A-A2_200 B-B2_200].^2));
    
    [B2_500,A2_500] = tfdata(m2_500, 'v');
    e2_500 = sqrt(sum([A-A2_500 B-B2_500].^2));
    
    [B2_9000,A2_9000] = tfdata(m2_9000, 'v');
    e2_9000 = sqrt(sum([A-A2_9000 B-B2_9000].^2));
    
    E1 = [e1_50 e1_100 e1_200 e1_500 e1_9000];
    E2 = [e2_50 e2_100 e2_200 e2_500 e2_9000];
    
    Errors_arx1 = [Errors_arx1;E1];
    Errors_arx2 = [Errors_arx2;E2];
end

% Media degli errori (colonna per colonna)
avgE_arx1 = mean(Errors_arx1);
avgE_arx2 = mean(Errors_arx2);

figure(2), plot([50 100 200 500 9000], avgE_arx1, [50 100 200 500 9000], avgE_arx2)
legend('Media considerando varianza 1e-4', 'Media considerando varianza 1e-7') 
title('Media degli errori di un predittore ARX')


%% Genero i dati e stimo con un ARMAX

for k = 1:10
    
   % Creo i dati
    U = randn(10000,1);
    E = randn(10000,1);
    Y1 = sim(S1, [U E]);
    Y2 = sim(S2, [U E]);
    Data1 = iddata(Y1,U,Ts);
    Data2 = iddata(Y2, U, Ts);
    
    % Creo i set di dati
    Data1_50 = Data1(1:50);
    Data1_100 = Data1(1:100);
    Data1_200 = Data1(1:200);
    Data1_500 = Data1(1:500);
    Data1_9000 = Data1(1:9000);
    
    Data2_50 = Data2(1:50);
    Data2_100 = Data2(1:100);
    Data2_200 = Data2(1:200);
    Data2_500 = Data2(1:500);
    Data2_9000 = Data2(1:9000);
    
    % Genero i modelli ARX con cui stimare un ARMAX
    m1_50 = armax(Data1_50, [4 4 3 1]);
    m1_100 = armax(Data1_100, [4 4 3 1]);
    m1_200 = armax(Data1_200, [4 4 3 1]);
    m1_500 = armax(Data1_500, [4 4 3 1]);
    m1_9000 = armax(Data1_9000, [4 4 3 1]);
    
    m2_50 = armax(Data2_50, [4 4 3 1]);
    m2_100 = armax(Data2_100, [4 4 3 1]);
    m2_200 = armax(Data2_200, [4 4 3 1]);
    m2_500 = armax(Data2_500, [4 4 3 1]);
    m2_9000 = armax(Data2_9000, [4 4 3 1]);
    
    % Calcolo gli errori sui parametri
    [B1_50,A1_50] = tfdata(m1_50, 'v');
    e1_50 = sqrt(sum([A-A1_50 B-B1_50].^2));
    
    [B1_100,A1_100] = tfdata(m1_100, 'v');
    e1_100 = sqrt(sum([A-A1_100 B-B1_100].^2));
    
    [B1_200,A1_200] = tfdata(m1_200, 'v');
    e1_200 = sqrt(sum([A-A1_200 B-B1_200].^2));
    
    [B1_500,A1_500] = tfdata(m1_500, 'v');
    e1_500 = sqrt(sum([A-A1_500 B-B1_500].^2));
    
    [B1_9000,A1_9000] = tfdata(m1_9000, 'v');
    e1_9000 = sqrt(sum([A-A1_9000 B-B1_9000].^2));
    
    [B2_50,A2_50] = tfdata(m2_50, 'v');
    e2_50 = sqrt(sum([A-A2_50 B-B2_50].^2));
    
    [B2_100,A2_100] = tfdata(m2_100, 'v');
    e2_100 = sqrt(sum([A-A2_100 B-B2_100].^2));
    
    [B2_200,A2_200] = tfdata(m2_200, 'v');
    e2_200 = sqrt(sum([A-A2_200 B-B2_200].^2));
    
    [B2_500,A2_500] = tfdata(m2_500, 'v');
    e2_500 = sqrt(sum([A-A2_500 B-B2_500].^2));
    
    [B2_9000,A2_9000] = tfdata(m2_9000, 'v');
    e2_9000 = sqrt(sum([A-A2_9000 B-B2_9000].^2));
    
    E1 = [e1_50 e1_100 e1_200 e1_500 e1_9000];
    E2 = [e2_50 e2_100 e2_200 e2_500 e2_9000];
    
    Errors_armax1 = [Errors_armax1;E1];
    Errors_armax2 = [Errors_armax2;E2];
end

% Media degli errori (colonna per colonna)
avgE_armax1 = mean(Errors_armax1);
avgE_armax2 = mean(Errors_armax2);

figure(3), plot([50 100 200 500 9000], avgE_armax1, [50 100 200 500 9000], avgE_armax2)
title('Media degli errori di un predittore ARMAX')
legend('Media considerando varianza 1e-4', 'Media considerando varianza 1e-7')

figure(4), plot([50 100 200 500 9000], avgE_arx1, [50 100 200 500 9000], avgE_armax1)
title('Confronto fra errori considerando varianza 1e-4')
legend('Media degli errori con ARX', 'Media degli errori con ARMAX')

figure(5), plot([50 100 200 500 9000], avgE_arx2, [50 100 200 500 9000], avgE_armax2)
title('Confronto fra errori considerando varianza 1e-7')
legend('Media degli errori con ARX', 'Media degli errori con ARMAX')


%% Calcolare il resid del modello migliore

figure(6), resid(m2_9000, Data2_9000)
