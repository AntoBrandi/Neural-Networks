clear all
close all
clc

load eser4

data=data0;

figure, plot(data)
train=data(1:400);
valid=data(401:500);

for k=1:30
    M=arx(train,[1 1 1]); %creo modello
    [terr,tcor]=resid(train,M); %errori di predizione su dati di train, mi aspetto che decresca all'aumentare di k
    [verr,vcor]=resid(valid,M); %errori di predizione su dati di valid, utili per trovare ordine ottimo
    
    Nt=size(terr);
    Nv=size(verr);
    
    for i=1:Nt(1)
        
    end
    
end