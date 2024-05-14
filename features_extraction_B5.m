%% Features extraction per il dataset B5

% Caricamento del dataset 

load("B5_finito.mat");

dataset = B5; 

% Numero di cicli nel dataset
numCicli = height(dataset);  

% Preallocazione per velocità
dataset.HI1 = zeros(numCicli, 1);
dataset.HI2 = zeros(numCicli, 1);
dataset.HI3 = zeros(numCicli, 1);
dataset.avgVoltage = zeros(numCicli, 1);
dataset.minVoltage = zeros(numCicli, 1);
dataset.maxVoltage = zeros(numCicli, 1);
dataset.varVoltage = zeros(numCicli, 1);
dataset.avgCurrent = zeros(numCicli, 1);
dataset.minCurrent = zeros(numCicli, 1);
dataset.maxCurrent = zeros(numCicli, 1);
dataset.varCurrent = zeros(numCicli, 1);

for i = 1:numCicli
    current_data = dataset.data{i};

    % Calcolo delle metriche di tensione
    dataset.avgVoltage(i) = mean(current_data.Voltage_measured);
    dataset.minVoltage(i) = min(current_data.Voltage_measured);
    dataset.maxVoltage(i) = max(current_data.Voltage_measured);
    dataset.varVoltage(i) = var(current_data.Voltage_measured);

    % Calcolo delle metriche di corrente
    dataset.avgCurrent(i) = mean(current_data.Current_measured);
    dataset.minCurrent(i) = min(current_data.Current_measured);
    dataset.maxCurrent(i) = max(current_data.Current_measured);
    dataset.varCurrent(i) = var(current_data.Current_measured);
        
            
    % % HI1:Calcolo degli Health Indices; Trova gli indici per 3.9V e 4.2V
    idx_3_9 = find(current_data.Voltage_measured >= 3.9, 1, 'first');
    idx_4_2 = find(current_data.Voltage_measured >= 4.2, 1, 'first');

    if ~isempty(idx_3_9) && ~isempty(idx_4_2)
        t_3_9 = current_data.Time(idx_3_9);
        t_4_2 = current_data.Time(idx_4_2);
        dataset.HI1(i) = t_4_2 - t_3_9;

        % HI2: Differenza di tensione a tempo specifico dopo 500s da 3.9V
        idx_500s = find(current_data.Time >= t_3_9 + 500, 1, 'first');
        if ~isempty(idx_500s)
            dataset.HI2(i) = current_data.Voltage_measured(idx_500s) - current_data.Voltage_measured(idx_3_9);
        else
            dataset.HI2(i) = NaN;
        end

        % HI3: Caduta di corrente in un intervallo specifico
        % Supponiamo 1000 secondi dopo t_3_9 e il valore di corrente a 1.5A
        idx_1000s = find(current_data.Time >= t_3_9 + 1000, 1, 'first');
        idx_1_5A = find(current_data.Current_measured >= 1.5, 1, 'first');
        if ~isempty(idx_1000s) && ~isempty(idx_1_5A)
            dataset.HI3(i) = current_data.Current_measured(idx_1_5A) - current_data.Current_measured(idx_1000s);
        else
            dataset.HI3(i) = NaN;
        end
    else
        dataset.HI1(i) = NaN;
        dataset.HI2(i) = NaN;
        dataset.HI3(i) = NaN;
    end
end

B5 = dataset;

save('B5_features.mat', "B5"); 

close all; 
clear all; 