%% PREDIZIONE SOH A PARTIRE DA QUESTE FEATURES 'HI1','HI2','HI3'--- MSE Error: 28.8073

%% Caricamento  dei dataset
data_B5 = load('B5_features.mat');
data_B6 = load('B6_features.mat');
data_B7 = load('B7_features.mat');
data_B18 = load('B18_features.mat');

%% Preparazione dei dati
data_B5.features = data_B5.B5(:, {'HI1','HI2','minCurrent', 'maxCurrent', 'avgCurrent', 'varCurrent', 'minVoltage', 'avgVoltage'});
data_B6.features = data_B6.B6(:, {'HI1','HI2','minCurrent', 'maxCurrent', 'avgCurrent', 'varCurrent', 'minVoltage', 'avgVoltage'});
data_B7.features = data_B7.B7(:, {'HI1','HI2','minCurrent', 'maxCurrent', 'avgCurrent', 'varCurrent', 'minVoltage', 'avgVoltage'});
data_B18.features = data_B18.B18(:, {'HI1','HI2','minCurrent', 'maxCurrent', 'avgCurrent', 'varCurrent', 'minVoltage', 'avgVoltage'});

% Assumendo che i dati abbiano campi comuni come 'features' e 'RUL'
X_train = [data_B5.features; data_B7.features;data_B18.features];
y_train = [data_B5.B5.SOH; data_B7.B7.SOH;data_B18.B18.SOH];


X_test = data_B6.features;
X_test_MSE = data_B6.features(25:end,:);
y_test = data_B6.B6.SOH(25:end,:); 

y_test_tot = data_B6.B6.SOH(1:170,:);
y_test_tot1 = data_B6.B6.SOH(1:24,:);
y_test_tot2 = data_B6.B6.SOH(51:100,:);

gprMdl = fitrgp(X_train, y_train, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');


%{


%% Setup della cross-validation
rng(1); % Imposta il seed per la riproducibilità
numFolds = 20; % Numero di fold per la cross-validation

% Crea una partizione per la cross-validation
cvp = cvpartition(size(X_train, 1), 'KFold', numFolds);

%% Esegui la cross-validation
mseErrors = zeros(numFolds, 1);
for i = 1:numFolds
    % Seleziona gli indici dei dati per il fold corrente
    trainIdx = cvp.training(i);
    testIdx = cvp.test(i);
    
    % Dati di addestramento e test per il fold corrente
    X_train_fold = X_train(trainIdx, :);
    y_train_fold = y_train(trainIdx);
    X_test_fold = X_train(testIdx, :);
    y_test_fold = y_train(testIdx);
    
    % Addestra il modello sul fold di addestramento
    gprMdl = fitrgp(X_train_fold, y_train_fold, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');
    
    % Predici sul fold di test
    predictions = predict(gprMdl, X_test_fold);
    
    % Calcola l'errore MSE per il fold corrente
    mseErrors(i) = mean((predictions - y_test_fold).^2);
end

% Calcola la media degli errori MSE su tutti i fold
meanMSE = mean(mseErrors);
disp(['Mean MSE Error: ', num2str(meanMSE)]);

%}

%% Predizioni e valutazione sul set di test
predictions = predict(gprMdl, X_test);
predictions_MSE = predict(gprMdl, X_test_MSE);

% Calcolo dell'errore
mseError = mean((predictions_MSE - y_test).^2);
disp(['MSE Error: ', num2str(mseError)]);

cycles = data_B6.B6.Num_cycle;  % Assumendo che ci sia una colonna Num_cycle

%% Stampa delle predizioni con i numeri di ciclo
disp('Predizioni SOH con numero di ciclo:');
first_below_80_cycle = 0;  % Inizializzazione della variabile per memorizzare il primo ciclo sotto l'80%
count_below_80 = 0;  % Contatore per i valori consecutivi sotto l'80%
for i = 1:length(predictions)
    fprintf('Ciclo %d: Predizione SOH = %.2f\n', cycles(i), predictions(i));
    if predictions(i) < 80.0
        count_below_80 = count_below_80 + 1;  % Incrementa il contatore se il valore è sotto l'80%
        if count_below_80 == 1  % Memorizza il primo ciclo del gruppo se è il primo sotto l'80%
            first_below_80_cycle = cycles(i);
        end
        if count_below_80 >= 5  % Se 5 valori consecutivi sono sotto l'80%, conferma il primo ciclo del gruppo
            break;
        end
    else
        count_below_80 = 0;  % Resetta il contatore se un valore supera l'80%
    end
end

first_under_80_real = find(data_B6.B6.SOH < 80, 1);

if ~isempty(first_under_80_real) && first_under_80_real <= length(data_B6.B6.SOH) - 5
    if all(data_B6.B6.SOH(first_under_80_real+1:first_under_80_real+5) < 80)
        first_under_80_consecutive_real = first_under_80_real;
    else
        first_under_80_consecutive_real = []; % Nessun gruppo di 5 valori consecutivi sotto l'80%
    end
else
    first_under_80_consecutive_real = []; % Nessun ciclo trovato in cui la SOH scende sotto l'80% oppure non ci sono abbastanza cicli successivi per verificare i 5 valori sotto l'80%
end
diff = abs(first_under_80_consecutive_real - first_below_80_cycle);
if first_below_80_cycle > 0 && count_below_80 >= 5
    fprintf('Il primo ciclo del gruppo di 5 valori consecutivi in cui la SOH scende sotto l 80%% è il ciclo numero %d.\n', first_below_80_cycle);
    fprintf('mentre secondo i dati reali, tale valore è %d.\n si ottiene quindi un errore di %d.\n', first_under_80_consecutive_real, diff);
else
    fprintf('Non è stato trovato un gruppo di 5 valori consecutivi con SOH sotto l 80%%.\n');
end

% Calcolo dell'errore
mseError = mean((predictions_MSE - y_test).^2);
disp(['MSE Error: ', num2str(mseError)]);
rmseError = sqrt(mseError);
disp(['RMSE Error: ', num2str(rmseError)]);
maeError = mean(abs(predictions_MSE - y_test));
disp(['MAE Error: ', num2str(maeError)]);

%% Plot dei risultati
figure;
plot(25:170, y_test, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(25:170, predictions_MSE, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
plot(1:24, y_test_tot1, 're-', 'LineWidth', 1.5); % Predizioni
hold on; 

line([24.5 24.5], [min([y_test; predictions_MSE]), max([y_test; predictions_MSE])], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);


legend('Real SOH', 'Predicted SOH', 'Real SOH totale');

title('Confronto della SOH reale con la SOH prevista');
xlabel('Campioni');
ylabel('SOH');


plot(first_below_80_cycle, predictions(first_below_80_cycle), 'kp', 'MarkerSize', 15, 'MarkerFaceColor', 'magenta', 'DisplayName', sprintf('First <80%% SOH at Cycle %d', cycles(first_below_80_cycle)));
text(first_below_80_cycle, predictions(first_below_80_cycle), sprintf('  First <80%%\nCycle %d', cycles(first_below_80_cycle)), 'VerticalAlignment', 'top', 'FontSize', 10, 'Color', 'magenta');


legend('show');
title('Comparison of Real and Predicted SOH');
xlabel('Samples');
ylabel('SOH');



save('prediction_SOH_B6', 'predictions');


