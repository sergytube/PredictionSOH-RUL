%% Features correlation per la features correlation 

load('B7_features.mat');  

dataset = B7;

% extraction feature
featureNames = {'avgVoltage', 'minVoltage', 'maxVoltage', 'varVoltage', 'avgCurrent', 'minCurrent', 'maxCurrent', 'varCurrent'};
soh = dataset.SOH;  % Replace 'SOH' with the actual column name for SOH in your dataset
results = struct();


% Elimina le righe con valori NaN nei calcoli di HI per garantire la validità della correlazione
validIndices = ~isnan(dataset.HI1) & ~isnan(dataset.HI2) & ~isnan(dataset.HI3);
filteredData = dataset(validIndices, :);

%% Calcolo e stampa correlazione tra HI1, HI2, HI3 e SOH 

% Calcolo delle correlazioni Pearson
correlationHI1_SOH = corr(filteredData.HI1, filteredData.SOH, 'Rows', 'complete','type', 'Pearson');
correlationHI2_SOH = corr(filteredData.HI2, filteredData.SOH, 'Rows', 'complete','type', 'Pearson');
correlationHI3_SOH = corr(filteredData.HI3, filteredData.SOH, 'Rows', 'complete','type', 'Pearson');

% Calcolo delle correlazioni kendall
correlationHI1_SOH_Kendall = corr(filteredData.HI1, filteredData.SOH, 'Rows', 'complete','type', 'Kendall');
correlationHI2_SOH_Kendall = corr(filteredData.HI2, filteredData.SOH, 'Rows', 'complete','type', 'Kendall');
correlationHI3_SOH_Kendall = corr(filteredData.HI3, filteredData.SOH, 'Rows', 'complete','type', 'Kendall');

% Calcolo delle correlazioni Sperman
correlationHI1_SOH_Spearman = corr(filteredData.HI1, filteredData.SOH, 'Rows', 'complete','type', 'Spearman');
correlationHI2_SOH_Spearman = corr(filteredData.HI2, filteredData.SOH, 'Rows', 'complete','type', 'Spearman');
correlationHI3_SOH_Spearman = corr(filteredData.HI3, filteredData.SOH, 'Rows', 'complete','type', 'Spearman');

% Stampa 

% Visualizzazione dei risultati
fprintf('----------Pearson----------\n');
fprintf('Correlation HI1 - SOH: %f\n', correlationHI1_SOH);
fprintf('Correlation HI2 - SOH: %f\n', correlationHI2_SOH);
fprintf('Correlation HI3 - SOH: %f\n', correlationHI3_SOH);
% Visualizzazione dei risultati
fprintf('----------Kendall ----------\n');
fprintf('Correlation HI1 - SOH: %f\n', correlationHI1_SOH_Kendall);
fprintf('Correlation HI2 - SOH: %f\n', correlationHI2_SOH_Kendall);
fprintf('Correlation HI3 - SOH: %f\n', correlationHI3_SOH_Kendall);
% Visualizzazione dei risultati
fprintf('----------Spearman ----------\n');
fprintf('Correlation HI1 - SOH: %f\n', correlationHI1_SOH_Spearman);
fprintf('Correlation HI2 - SOH: %f\n', correlationHI2_SOH_Spearman);
fprintf('Correlation HI3 - SOH: %f\n', correlationHI3_SOH_Spearman);


%% Calcolo e stampa delle correlazione tra HI1, HI2, HI3 e RUL 
% Calcolo delle correlazioni Pearson
correlationHI1_RUL = corr(filteredData.HI1, filteredData.RUL, 'Rows', 'complete','type', 'Pearson');
correlationHI2_RUL = corr(filteredData.HI2, filteredData.RUL, 'Rows', 'complete','type', 'Pearson');
correlationHI3_RUL= corr(filteredData.HI3, filteredData.RUL, 'Rows', 'complete','type', 'Pearson');

    % Calcolo delle correlazioni kendall
correlationHI1_RUL_Kendall = corr(filteredData.HI1, filteredData.RUL, 'Rows', 'complete','type', 'Kendall');
correlationHI2_RUL_Kendall = corr(filteredData.HI2, filteredData.RUL, 'Rows', 'complete','type', 'Kendall');
correlationHI3_RUL_Kendall = corr(filteredData.HI3, filteredData.RUL, 'Rows', 'complete','type', 'Kendall');

% Calcolo delle correlazioni Pearson
correlationHI1_RUL_Spearman = corr(filteredData.HI1, filteredData.RUL, 'Rows', 'complete','type', 'Spearman');
correlationHI2_RUL_Spearman = corr(filteredData.HI2, filteredData.RUL, 'Rows', 'complete','type', 'Spearman');
correlationHI3_RUL_Spearman = corr(filteredData.HI3, filteredData.RUL, 'Rows', 'complete','type', 'Spearman');

% Visualizzazione dei risultati
fprintf('----------Pearson----------\n');
fprintf('Correlation HI1 - RUL: %f\n', correlationHI1_RUL);
fprintf('Correlation HI2 - RUL: %f\n', correlationHI2_RUL);
fprintf('Correlation HI3 - RUL: %f\n', correlationHI3_RUL);

% Visualizzazione dei risultati
fprintf('----------Kendall ----------\n');
fprintf('Correlation HI1 - RUL: %f\n', correlationHI1_RUL_Kendall);
fprintf('Correlation HI2 - RUL: %f\n', correlationHI2_RUL_Kendall);
fprintf('Correlation HI3 - RUL: %f\n', correlationHI3_RUL_Kendall);

% Visualizzazione dei risultati
fprintf('----------Spearman ----------\n');
fprintf('Correlation HI1 - RUL: %f\n', correlationHI1_RUL_Spearman);
fprintf('Correlation HI2 - RUL: %f\n', correlationHI2_RUL_Spearman);
fprintf('Correlation HI3 - RUL: %f\n', correlationHI3_RUL_Spearman);


%% Calcolo e stampa delle correlazioni tra TOTAL TIME E H1,H2,H3

% Calcolo delle correlazioni Pearson
correlationHI1_TOT = corr(filteredData.HI1, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Pearson');
correlationHI2_TOT = corr(filteredData.HI2, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Pearson');
correlationHI3_TOT= corr(filteredData.HI3, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Pearson');

% Calcolo delle correlazioni kendall
correlationHI1_TOT_Kendall = corr(filteredData.HI1, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Kendall');
correlationHI2_TOT_Kendall = corr(filteredData.HI2, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Kendall');
correlationHI3_TOT_Kendall = corr(filteredData.HI3, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Kendall');

% Calcolo delle correlazioni Pearson
correlationHI1_TOT_Spearman = corr(filteredData.HI1, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Spearman');
correlationHI2_TOT_Spearman = corr(filteredData.HI2, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Spearman');
correlationHI3_TOT_Spearman = corr(filteredData.HI3, filteredData.TOTAL_TIME, 'Rows', 'complete','type', 'Spearman');


fprintf('----------Pearson----------\n');
fprintf('Correlation HI1 - TOTAL_TIME: %f\n', correlationHI1_TOT);
fprintf('Correlation HI2 - TOTAL_TIME: %f\n', correlationHI2_TOT);
fprintf('Correlation HI3 - TOTAL_TIME: %f\n', correlationHI3_TOT);

% Visualizzazione dei risultati
fprintf('----------Kendall ----------\n');
fprintf('Correlation HI1 - TOTAL_TIME: %f\n', correlationHI1_TOT_Kendall);
fprintf('Correlation HI2 - TOTAL_TIME: %f\n', correlationHI2_TOT_Kendall);
fprintf('Correlation HI3 - TOTAL_TIME: %f\n', correlationHI3_TOT_Kendall);

% Visualizzazione dei risultati
fprintf('----------Spearman ----------\n');
fprintf('Correlation HI1 - TOTAL_TIME: %f\n', correlationHI1_TOT_Spearman);
fprintf('Correlation HI2 - TOTAL_TIME: %f\n', correlationHI2_TOT_Spearman);
fprintf('Correlation HI3 - TOTAL_TIME: %f\n', correlationHI3_TOT_Spearman);

%% Calcolo e stampa delle correlazioni tra SOH e RUL 
% Calcolo delle correlazioni Pearson
correlationSOH_RUL1 = corr(filteredData.RUL, filteredData.SOH, 'Rows', 'complete','type', 'Pearson');

% Calcolo delle correlazioni Kendall
correlationSOH_RUL_Kendall1 = corr(filteredData.RUL, filteredData.SOH, 'Rows', 'complete','type', 'Kendall');

% Calcolo delle correlazioni Spearman
correlationSOH_RUL_Spearman1 = corr(filteredData.RUL, filteredData.SOH, 'Rows', 'complete','type', 'Spearman');

% Visualizzazione dei risultati
fprintf('----------Pearson----------\n');
fprintf('Correlation SOH - RUL: %f\n', correlationSOH_RUL1);

% Visualizzazione dei risultati
fprintf('----------Kendall ----------\n');
fprintf('Correlation SOH - RUL: %f\n', correlationSOH_RUL_Kendall1);

% Visualizzazione dei risultati
fprintf('----------Spearman ----------\n');
fprintf('Correlation SOH - RUL: %f\n', correlationSOH_RUL_Spearman1);

%% Calcolo delle correlazioni tra varie colonne del dataset

% Calcolo delle correlazioni Pearson
avgVoltage_SOH_pearson = corr(dataset.avgVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');
minVoltage_SOH_pearson = corr(dataset.minVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');
maxVoltage_SOH_pearson = corr(dataset.maxVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');
varVoltage_SOH_pearson = corr(dataset.varVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');
avgCurrent_SOH_pearson = corr(dataset.avgCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');
minCurrent_SOH_pearson = corr(dataset.minCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');
maxCurrent_SOH_pearson = corr(dataset.maxCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');
varCurrent_SOH_pearson = corr(dataset.varCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Pearson');

% Calcolo delle correlazioni Kendall
avgVoltage_SOH_kendall = corr(dataset.avgVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');
minVoltage_SOH_kendall = corr(dataset.minVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');
maxVoltage_SOH_kendall = corr(dataset.maxVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');
varVoltage_SOH_kendall = corr(dataset.varVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');
avgCurrent_SOH_kendall = corr(dataset.avgCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');
minCurrent_SOH_kendall = corr(dataset.minCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');
maxCurrent_SOH_kendall = corr(dataset.maxCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');
varCurrent_SOH_kendall = corr(dataset.varCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Kendall');

% Calcolo delle correlazioni Spearman
avgVoltage_SOH_spearman = corr(dataset.avgVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');
minVoltage_SOH_spearman = corr(dataset.minVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');
maxVoltage_SOH_spearman = corr(dataset.maxVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');
varVoltage_SOH_spearman = corr(dataset.varVoltage, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');
avgCurrent_SOH_spearman = corr(dataset.avgCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');
minCurrent_SOH_spearman = corr(dataset.minCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');
maxCurrent_SOH_spearman = corr(dataset.maxCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');
varCurrent_SOH_spearman = corr(dataset.varCurrent, dataset.SOH, 'Rows', 'complete', 'type', 'Spearman');


fprintf('----------Pearson----------\n');
fprintf('Correlation avgVoltage - SOH (Pearson): %f\n', avgVoltage_SOH_pearson);
fprintf('Correlation minVoltage - SOH (Pearson): %f\n', minVoltage_SOH_pearson);
fprintf('Correlation maxVoltage - SOH (Pearson): %f\n', maxVoltage_SOH_pearson);
fprintf('Correlation varVoltage - SOH (Pearson): %f\n', varVoltage_SOH_pearson);
fprintf('Correlation avgCurrent - SOH (Pearson): %f\n', avgCurrent_SOH_pearson);
fprintf('Correlation minCurrent - SOH (Pearson): %f\n', minCurrent_SOH_pearson);
fprintf('Correlation maxCurrent - SOH (Pearson): %f\n', maxCurrent_SOH_pearson);
fprintf('Correlation varCurrent - SOH (Pearson): %f\n', varCurrent_SOH_pearson);
fprintf('----------Kendall ----------\n');
fprintf('Correlation avgVoltage - SOH (Kendall): %f\n', avgVoltage_SOH_kendall);
fprintf('Correlation minVoltage - SOH (Kendall): %f\n', minVoltage_SOH_kendall);
fprintf('Correlation maxVoltage - SOH (Kendall): %f\n', maxVoltage_SOH_kendall);
fprintf('Correlation varVoltage - SOH (Kendall): %f\n', varVoltage_SOH_kendall);
fprintf('Correlation avgCurrent - SOH (Kendall): %f\n', avgCurrent_SOH_kendall);
fprintf('Correlation minCurrent - SOH (Kendall): %f\n', minCurrent_SOH_kendall);
fprintf('Correlation maxCurrent - SOH (Kendall): %f\n', maxCurrent_SOH_kendall);
fprintf('Correlation varCurrent - SOH (Kendall): %f\n', varCurrent_SOH_kendall);
fprintf('----------Spearman ----------\n');
fprintf('Correlation avgVoltage - SOH (Spearman): %f\n', avgVoltage_SOH_spearman);
fprintf('Correlation minVoltage - SOH (Spearman): %f\n', minVoltage_SOH_spearman);
fprintf('Correlation maxVoltage - SOH (Spearman): %f\n', maxVoltage_SOH_spearman);
fprintf('Correlation varVoltage - SOH (Spearman): %f\n', varVoltage_SOH_spearman);
fprintf('Correlation avgCurrent - SOH (Spearman): %f\n', avgCurrent_SOH_spearman);
fprintf('Correlation minCurrent - SOH (Spearman): %f\n', minCurrent_SOH_spearman);
fprintf('Correlation maxCurrent - SOH (Spearman): %f\n', maxCurrent_SOH_spearman);
fprintf('Correlation varCurrent - SOH (Spearman): %f\n', varCurrent_SOH_spearman);

%% Plot dei risultati delle varie colonne del dataset 

% Definisci i valori delle correlazioni
correlations = [avgVoltage_SOH_pearson, minVoltage_SOH_pearson, maxVoltage_SOH_pearson, varVoltage_SOH_pearson, ...
                avgCurrent_SOH_pearson, minCurrent_SOH_pearson, maxCurrent_SOH_pearson, varCurrent_SOH_pearson;
                avgVoltage_SOH_kendall, minVoltage_SOH_kendall, maxVoltage_SOH_kendall, varVoltage_SOH_kendall, ...
                avgCurrent_SOH_kendall, minCurrent_SOH_kendall, maxCurrent_SOH_kendall, varCurrent_SOH_kendall;
                avgVoltage_SOH_spearman, minVoltage_SOH_spearman, maxVoltage_SOH_spearman, varVoltage_SOH_spearman, ...
                avgCurrent_SOH_spearman, minCurrent_SOH_spearman, maxCurrent_SOH_spearman, varCurrent_SOH_spearman];

% Definisci i nomi delle features
features = {'avgVoltage', 'minVoltage', 'maxVoltage', 'varVoltage', 'avgCurrent', 'minCurrent', 'maxCurrent', 'varCurrent'};

% Definisci i tipi di correlazione
correlation_types = {'Pearson', 'Kendall', 'Spearman'};

% Configura la figura
figure;

% Itera su ciascun tipo di correlazione
for i = 1:numel(correlation_types)
    % Crea un subplot per il tipo di correlazione corrente
    subplot(3, 1, i);
    
    % Visualizza l'istogramma delle correlazioni per il tipo corrente
    bar(correlations(i,:));
    
    % Imposta il titolo del subplot
    title(sprintf('Correlation Distribution (%s)', correlation_types{i}));
    
    % Imposta le etichette sugli assi
    xlabel('Feature');
    ylabel('Correlation Value');
    
    % Imposta le etichette sull'asse x con i nomi delle features
    xticks(1:numel(features));
    xticklabels(features);
    xtickangle(45);
    
    % Mostra la legenda
    legend('Correlation');
end

% Imposta il titolo della figura
sgtitle('Correlation Distributions for Each Feature');

%% Plot dei risultati tra HI1, HI2, HI3, SOH, RUL

% Definisci i valori delle correlazioni per ogni tipo
correlation_values = [correlationHI1_SOH, correlationHI2_SOH, correlationHI3_SOH;
                      correlationHI1_RUL_Kendall, correlationHI2_RUL_Kendall, correlationHI3_SOH_Kendall;
                      correlationHI1_SOH_Spearman, correlationHI2_SOH_Spearman, correlationHI3_SOH_Spearman];

% Definisci i nomi delle correlazioni
correlation_names = {'Pearson', 'Kendall', 'Spearman'};

% Definisci i nomi delle feature
feature_names = {'HI1', 'HI2', 'HI3'};

% Configura la figura
figure;

% Itera su ciascun tipo di correlazione
for i = 1:numel(correlation_names)
    % Crea un subplot per il tipo di correlazione corrente
    subplot(1, 3, i);
    
    % Visualizza l'istogramma delle correlazioni per il tipo corrente
    bar(correlation_values(i,:));
    
    % Imposta il titolo del subplot
    title(sprintf('Correlation Distribution (%s)', correlation_names{i}));
    
    % Imposta le etichette sugli assi
    xlabel('Feature');
    ylabel('Correlation Value');
    
    % Imposta le etichette sull'asse x con i nomi delle features
    xticks(1:numel(feature_names));
    xticklabels(feature_names);
    xtickangle(45);
    
    % Mostra la legenda
    legend('Correlation');
end

% Imposta il titolo della figura
sgtitle('Correlation Distributions for HI1, HI2, and HI3');

