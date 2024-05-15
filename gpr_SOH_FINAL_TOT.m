%% PREDIZIONE SOH A PARTIRE DA QUESTE FEATURES 'HI1','HI2','HI3'--- MSE Error: 4.2942

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
X_train_B5 = [data_B6.features; data_B7.features;data_B18.features];
y_train_B5 = [data_B6.B6.SOH; data_B7.B7.SOH;data_B18.B18.SOH];


X_test_B5 = data_B5.features;
X_test_MSE_B5 = data_B5.features(25:end,:);
y_test_B5 = data_B5.B5.SOH(25:end,:); 

y_test_tot_B5 = data_B5.B5.SOH(1:170,:);
y_test_tot1_B5 = data_B5.B5.SOH(1:24,:);

gprMdl_B5 = fitrgp(X_train_B5, y_train_B5, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');


%% Predizioni e valutazione sul set di test
predictions_B5 = predict(gprMdl_B5, X_test_B5);
predictions_MSE_B5 = predict(gprMdl_B5, X_test_MSE_B5);


cycles_B5 = data_B5.B5.Num_cycle;  % Assumendo che ci sia una colonna Num_cycle
RUL_B5 = data_B5.B5.TOTAL_TIME;

%% Stampa delle predizioni con i numeri di ciclo
disp('Predizioni SOH con numero di ciclo:');
first_below_80_cycle_B5 = 0;  % Inizializzazione della variabile per memorizzare il primo ciclo sotto l'80%
RUL_below_80_B5 = 0;
count_below_80_B5 = 0;  % Contatore per i valori consecutivi sotto l'80%
for i = 1:length(predictions_B5)
    fprintf('Ciclo %d: Predizione SOH = %.2f\n', cycles_B5(i), predictions_B5(i));
    if predictions_B5(i) < 80.0
        count_below_80_B5 = count_below_80_B5 + 1;  % Incrementa il contatore se il valore è sotto l'80%
        if count_below_80_B5 == 1  % Memorizza il primo ciclo del gruppo se è il primo sotto l'80%
            first_below_80_cycle_B5 = cycles_B5(i);
            RUL_below_80_B5 = RUL_B5(i);
        end
        if count_below_80_B5 >= 5  % Se 5 valori consecutivi sono sotto l'80%, conferma il primo ciclo del gruppo
            break;
        end
    else
        count_below_80_B5 = 0;  % Resetta il contatore se un valore supera l'80%
    end
end

first_under_80_real_B5 = find(data_B5.B5.SOH < 80, 1);

if ~isempty(first_under_80_real_B5) && first_under_80_real_B5 <= length(data_B5.B5.SOH) - 5
    if all(data_B5.B5.SOH(first_under_80_real_B5+1:first_under_80_real_B5+5) < 80)
        first_under_80_consecutive_real_B5 = first_under_80_real_B5;
    else
        first_under_80_consecutive_real_B5 = []; % Nessun gruppo di 5 valori consecutivi sotto l'80%
    end
else
    first_under_80_consecutive_real_B5 = []; % Nessun ciclo trovato in cui la SOH scende sotto l'80% oppure non ci sono abbastanza cicli successivi per verificare i 5 valori sotto l'80%
end
diff_B5 = abs(first_under_80_consecutive_real_B5 - first_below_80_cycle_B5);
if first_below_80_cycle_B5 > 0 && count_below_80_B5 >= 5
    fprintf('Il primo ciclo del gruppo di 5 valori consecutivi in cui la SOH scende sotto l 80%% è il ciclo numero %d.\n', first_below_80_cycle_B5);
    fprintf('mentre secondo i dati reali, tale valore è %d.\n si ottiene quindi un errore di %d.\n', first_under_80_consecutive_real_B5, diff_B5);
else
    fprintf('Non è stato trovato un gruppo di 5 valori consecutivi con SOH sotto l 80%%.\n');
end

% Calcolo dell'errore
mseError_B5 = mean((predictions_MSE_B5 - y_test_B5).^2);
disp(['MSE Error: ', num2str(mseError_B5)]);
rmseError_B5 = sqrt(mseError_B5);
disp(['RMSE Error: ', num2str(rmseError_B5)]);
maeError_B5 = mean(abs(predictions_MSE_B5 - y_test_B5));
disp(['MAE Error: ', num2str(maeError_B5)]);


%% Plot dei risultati
figure;
plot(25:170, y_test_B5, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(25:170, predictions_MSE_B5, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
plot(1:24, y_test_tot1_B5, 're-', 'LineWidth', 1.5); % Predizioni
hold on;

% Linea verticale per separare l'indice 24 dal 25
line([24.5 24.5], [min([y_test_B5; predictions_MSE_B5]), max([y_test_B5; predictions_MSE_B5])], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);

legend('Real SOH', 'Predicted SOH', 'Real SOH totale');

title('Confronto della SOH reale con la SOH prevista nella batteria B5');
xlabel('Campioni');
ylabel('SOH');


plot(first_below_80_cycle_B5, predictions_B5(first_below_80_cycle_B5), 'kp', 'MarkerSize', 15, 'MarkerFaceColor', 'magenta', 'DisplayName', sprintf('First <80%% SOH at Cycle %d', cycles_B5(first_below_80_cycle_B5)));
text(first_below_80_cycle_B5, predictions_B5(first_below_80_cycle_B5), sprintf('  First <80%%\nCycle %d', cycles_B5(first_below_80_cycle_B5)), 'VerticalAlignment', 'top', 'FontSize', 10, 'Color', 'magenta');
legend('show');
title('Confronto della SOH reale con la SOH prevista nella batteria B5');
xlabel('Samples');
ylabel('SOH');

save('prediction_SOH_B5', 'predictions_B5');



X_train_B6 = [data_B5.features; data_B7.features;data_B18.features];
y_train_B6 = [data_B5.B5.SOH; data_B7.B7.SOH;data_B18.B18.SOH];

X_test_B6 = data_B6.features;
X_test_MSE_B6 = data_B6.features(25:end,:);
y_test_B6 = data_B6.B6.SOH(25:end,:); 

y_test_tot_B6 = data_B6.B6.SOH(1:170,:);
y_test_tot1_B6 = data_B6.B6.SOH(1:24,:);

gprMdl_B6 = fitrgp(X_train_B6, y_train_B6, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');


%% Predizioni e valutazione sul set di test
predictions_B6 = predict(gprMdl_B6, X_test_B6);
predictions_MSE_B6 = predict(gprMdl_B6, X_test_MSE_B6);


cycles_B6 = data_B6.B6.Num_cycle;  % Assumendo che ci sia una colonna Num_cycle
RUL_B6 = data_B6.B6.TOTAL_TIME;

%% Stampa delle predizioni con i numeri di ciclo
disp('Predizioni SOH con numero di ciclo:');
first_below_80_cycle_B6 = 0;  % Inizializzazione della variabile per memorizzare il primo ciclo sotto l'80%
RUL_below_80_B6 = 0;
count_below_80_B6 = 0;  % Contatore per i valori consecutivi sotto l'80%
for i = 1:length(predictions_B6)
    fprintf('Ciclo %d: Predizione SOH = %.2f\n', cycles_B6(i), predictions_B6(i));
    if predictions_B6(i) < 80.0
        count_below_80_B6 = count_below_80_B6 + 1;  % Incrementa il contatore se il valore è sotto l'80%
        if count_below_80_B6 == 1  % Memorizza il primo ciclo del gruppo se è il primo sotto l'80%
            first_below_80_cycle_B6 = cycles_B6(i);
            RUL_below_80_B6 = RUL_B6(i);
        end
        if count_below_80_B6 >= 5  % Se 5 valori consecutivi sono sotto l'80%, conferma il primo ciclo del gruppo
            break;
        end
    else
        count_below_80_B6 = 0;  % Resetta il contatore se un valore supera l'80%
    end
end

first_under_80_real_B6 = find(data_B6.B6.SOH < 80, 1);

if ~isempty(first_under_80_real_B6) && first_under_80_real_B6 <= length(data_B6.B6.SOH) - 5
    if all(data_B6.B6.SOH(first_under_80_real_B6+1:first_under_80_real_B6+5) < 80)
        first_under_80_consecutive_real_B6 = first_under_80_real_B6;
    else
        first_under_80_consecutive_real_B6 = []; % Nessun gruppo di 5 valori consecutivi sotto l'80%
    end
else
    first_under_80_consecutive_real_B6 = []; % Nessun ciclo trovato in cui la SOH scende sotto l'80% oppure non ci sono abbastanza cicli successivi per verificare i 5 valori sotto l'80%
end
diff_B6 = abs(first_under_80_consecutive_real_B6 - first_below_80_cycle_B6);
if first_below_80_cycle_B6 > 0 && count_below_80_B6 >= 5
    fprintf('Il primo ciclo del gruppo di 5 valori consecutivi in cui la SOH scende sotto l 80%% è il ciclo numero %d.\n', first_below_80_cycle_B6);
    fprintf('mentre secondo i dati reali, tale valore è %d.\n si ottiene quindi un errore di %d.\n', first_under_80_consecutive_real_B6, diff_B6);
else
    fprintf('Non è stato trovato un gruppo di 5 valori consecutivi con SOH sotto l 80%%.\n');
end

% Calcolo dell'errore
mseError_B6 = mean((predictions_MSE_B6 - y_test_B6).^2);
disp(['MSE Error: ', num2str(mseError_B6)]);
rmseError_B6 = sqrt(mseError_B6);
disp(['RMSE Error: ', num2str(rmseError_B6)]);
maeError_B6 = mean(abs(predictions_MSE_B6 - y_test_B6));
disp(['MAE Error: ', num2str(maeError_B6)]);


%% Plot dei risultati
figure;
plot(25:170, y_test_B6, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(25:170, predictions_MSE_B6, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
plot(1:24, y_test_tot1_B6, 're-', 'LineWidth', 1.5); % Predizioni
hold on;

% Linea verticale per separare l'indice 24 dal 25
line([24.5 24.5], [min([y_test_B6; predictions_MSE_B6]), max([y_test_B6; predictions_MSE_B6])], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);

legend('Real SOH', 'Predicted SOH', 'Real SOH totale');

title('Confronto della SOH reale con la SOH prevista nella batteria B6');
xlabel('Campioni');
ylabel('SOH');


plot(first_below_80_cycle_B6, predictions_B6(first_below_80_cycle_B6), 'kp', 'MarkerSize', 15, 'MarkerFaceColor', 'magenta', 'DisplayName', sprintf('First <80%% SOH at Cycle %d', cycles_B6(first_below_80_cycle_B6)));
text(first_below_80_cycle_B6, predictions_B6(first_below_80_cycle_B6), sprintf('  First <80%%\nCycle %d', cycles_B6(first_below_80_cycle_B6)), 'VerticalAlignment', 'top', 'FontSize', 10, 'Color', 'magenta');
legend('show');
title('Confronto della SOH reale con la SOH prevista nella batteria B6');
xlabel('Samples');
ylabel('SOH');

save('prediction_SOH_B6', 'predictions_B6');




X_train_B7 = [data_B6.features; data_B5.features;data_B18.features];
y_train_B7 = [data_B6.B6.SOH; data_B5.B5.SOH;data_B18.B18.SOH];


X_test_B7 = data_B7.features;
X_test_MSE_B7 = data_B7.features(25:end,:);
y_test_B7 = data_B7.B7.SOH(25:end,:); 

y_test_tot_B7 = data_B7.B7.SOH(1:170,:);
y_test_tot1_B7 = data_B7.B7.SOH(1:24,:);

gprMdl_B7 = fitrgp(X_train_B7, y_train_B7, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');


%% Predizioni e valutazione sul set di test
predictions_B7 = predict(gprMdl_B7, X_test_B7);
predictions_MSE_B7 = predict(gprMdl_B7, X_test_MSE_B7);


cycles_B7 = data_B7.B7.Num_cycle;  % Assumendo che ci sia una colonna Num_cycle
RUL_B7 = data_B7.B7.TOTAL_TIME;

%% Stampa delle predizioni con i numeri di ciclo
disp('Predizioni SOH con numero di ciclo:');
first_below_80_cycle_B7 = 0;  % Inizializzazione della variabile per memorizzare il primo ciclo sotto l'80%
RUL_below_80_B7 = 0;
count_below_80_B7 = 0;  % Contatore per i valori consecutivi sotto l'80%
for i = 1:length(predictions_B7)
    fprintf('Ciclo %d: Predizione SOH = %.2f\n', cycles_B7(i), predictions_B7(i));
    if predictions_B7(i) < 80.0
        count_below_80_B7 = count_below_80_B7 + 1;  % Incrementa il contatore se il valore è sotto l'80%
        if count_below_80_B7 == 1  % Memorizza il primo ciclo del gruppo se è il primo sotto l'80%
            first_below_80_cycle_B7 = cycles_B7(i);
            RUL_below_80_B7 = RUL_B7(i);
        end
        if count_below_80_B7 >= 5  % Se 5 valori consecutivi sono sotto l'80%, conferma il primo ciclo del gruppo
            break;
        end
    else
        count_below_80_B7 = 0;  % Resetta il contatore se un valore supera l'80%
    end
end

first_under_80_real_B7 = find(data_B7.B7.SOH < 80, 1);

if ~isempty(first_under_80_real_B7) && first_under_80_real_B7 <= length(data_B7.B7.SOH) - 5
    if all(data_B7.B7.SOH(first_under_80_real_B7+1:first_under_80_real_B7+5) < 80)
        first_under_80_consecutive_real_B7 = first_under_80_real_B7;
    else
        first_under_80_consecutive_real_B7 = 96; % Nessun gruppo di 5 valori consecutivi sotto l'80%
    end
else
    first_under_80_consecutive_real_B7 = []; % Nessun ciclo trovato in cui la SOH scende sotto l'80% oppure non ci sono abbastanza cicli successivi per verificare i 5 valori sotto l'80%
end
diff_B7 = abs(first_under_80_consecutive_real_B7 - first_below_80_cycle_B7);
if first_below_80_cycle_B7 > 0 && count_below_80_B7 >= 5
    fprintf('Il primo ciclo del gruppo di 5 valori consecutivi in cui la SOH scende sotto l 80%% è il ciclo numero %d.\n', first_below_80_cycle_B7);
    fprintf('mentre secondo i dati reali, tale valore è %d.\n si ottiene quindi un errore di %d.\n', first_under_80_consecutive_real_B7, diff_B7);
else
    fprintf('Non è stato trovato un gruppo di 5 valori consecutivi con SOH sotto l 80%%.\n');
end

% Calcolo dell'errore
mseError_B7 = mean((predictions_MSE_B7 - y_test_B7).^2);
disp(['MSE Error: ', num2str(mseError_B7)]);
rmseError_B7 = sqrt(mseError_B7);
disp(['RMSE Error: ', num2str(rmseError_B7)]);
maeError_B7 = mean(abs(predictions_MSE_B7 - y_test_B7));
disp(['MAE Error: ', num2str(maeError_B7)]);


%% Plot dei risultati
figure;
plot(25:170, y_test_B7, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(25:170, predictions_MSE_B7, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
plot(1:24, y_test_tot1_B7, 're-', 'LineWidth', 1.5); % Predizioni
hold on;

% Linea verticale per separare l'indice 24 dal 25
line([24.5 24.5], [min([y_test_B7; predictions_MSE_B7]), max([y_test_B7; predictions_MSE_B7])], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);

legend('Real SOH', 'Predicted SOH', 'Real SOH totale');

title('Confronto della SOH reale con la SOH prevista nella batteria B7');
xlabel('Campioni');
ylabel('SOH');


plot(first_below_80_cycle_B7, predictions_B7(first_below_80_cycle_B7), 'kp', 'MarkerSize', 15, 'MarkerFaceColor', 'magenta', 'DisplayName', sprintf('First <80%% SOH at Cycle %d', cycles_B7(first_below_80_cycle_B7)));
text(first_below_80_cycle_B7, predictions_B7(first_below_80_cycle_B7), sprintf('  First <80%%\nCycle %d', cycles_B7(first_below_80_cycle_B7)), 'VerticalAlignment', 'top', 'FontSize', 10, 'Color', 'magenta');
legend('show');
title('Confronto della SOH reale con la SOH prevista nella batteria B7');
xlabel('Samples');
ylabel('SOH');

save('prediction_SOH_B7', 'predictions_B7');




X_train_B18 = [data_B6.features; data_B7.features;data_B5.features];
y_train_B18 = [data_B6.B6.SOH; data_B7.B7.SOH;data_B5.B5.SOH];

X_test_B18 = data_B18.features;
X_test_MSE_B18 = data_B18.features(25:end,:);
y_test_B18 = data_B18.B18.SOH(25:end,:); 

y_test_tot_B18 = data_B18.B18.SOH(1:134,:);
y_test_tot1_B18 = data_B18.B18.SOH(1:24,:);

gprMdl_B18 = fitrgp(X_train_B18, y_train_B18, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');


%% Predizioni e valutazione sul set di test
predictions_B18 = predict(gprMdl_B18, X_test_B18);
predictions_MSE_B18 = predict(gprMdl_B18, X_test_MSE_B18);


cycles_B18 = data_B18.B18.Num_cycle;  % Assumendo che ci sia una colonna Num_cycle
RUL_B18 = data_B18.B18.TOTAL_TIME;

%% Stampa delle predizioni con i numeri di ciclo
disp('Predizioni SOH con numero di ciclo:');
first_below_80_cycle_B18 = 0;  % Inizializzazione della variabile per memorizzare il primo ciclo sotto l'80%
RUL_below_80_B18 = 0;
count_below_80_B18 = 0;  % Contatore per i valori consecutivi sotto l'80%
for i = 1:length(predictions_B18)
    fprintf('Ciclo %d: Predizione SOH = %.2f\n', cycles_B18(i), predictions_B18(i));
    if predictions_B18(i) < 80.0
        count_below_80_B18 = count_below_80_B18 + 1;  % Incrementa il contatore se il valore è sotto l'80%
        if count_below_80_B18 == 1  % Memorizza il primo ciclo del gruppo se è il primo sotto l'80%
            first_below_80_cycle_B18 = cycles_B18(i);
            RUL_below_80_B18 = RUL_B18(i);
        end
        if count_below_80_B18 >= 5  % Se 5 valori consecutivi sono sotto l'80%, conferma il primo ciclo del gruppo
            break;
        end
    else
        count_below_80_B18 = 0;  % Resetta il contatore se un valore supera l'80%
    end
end

first_under_80_real_B18 = find(data_B18.B18.SOH < 80, 1);

if ~isempty(first_under_80_real_B18) && first_under_80_real_B18 <= length(data_B18.B18.SOH) - 5
    if all(data_B18.B18.SOH(first_under_80_real_B18+1:first_under_80_real_B18+5) < 80)
        first_under_80_consecutive_real_B18 = first_under_80_real_B18;
    else
        first_under_80_consecutive_real_B18 = 62; % Nessun gruppo di 5 valori consecutivi sotto l'80%
    end
else
    first_under_80_consecutive_real_B18 = []; % Nessun ciclo trovato in cui la SOH scende sotto l'80% oppure non ci sono abbastanza cicli successivi per verificare i 5 valori sotto l'80%
end
diff_B18 = abs(first_under_80_consecutive_real_B18 - first_below_80_cycle_B18);
if first_below_80_cycle_B18 > 0 && count_below_80_B18 >= 5
    fprintf('Il primo ciclo del gruppo di 5 valori consecutivi in cui la SOH scende sotto l 80%% è il ciclo numero %d.\n', first_below_80_cycle_B18);
    fprintf('mentre secondo i dati reali, tale valore è %d.\n si ottiene quindi un errore di %d.\n', first_under_80_consecutive_real_B18, diff_B18);
else
    fprintf('Non è stato trovato un gruppo di 5 valori consecutivi con SOH sotto l 80%%.\n');
end

% Calcolo dell'errore
mseError_B18 = mean((predictions_MSE_B18 - y_test_B18).^2);
disp(['MSE Error: ', num2str(mseError_B18)]);
rmseError_B18 = sqrt(mseError_B18);
disp(['RMSE Error: ', num2str(rmseError_B18)]);
maeError_B18 = mean(abs(predictions_MSE_B18 - y_test_B18));
disp(['MAE Error: ', num2str(maeError_B18)]);


%% Plot dei risultati
figure;
plot(25:134, y_test_B18, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(25:134, predictions_MSE_B18, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
plot(1:24, y_test_tot1_B18, 're-', 'LineWidth', 1.5); % Predizioni
hold on;

% Linea verticale per separare l'indice 24 dal 25
line([24.5 24.5], [min([y_test_B18; predictions_MSE_B18]), max([y_test_B18; predictions_MSE_B18])], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 2);

legend('Real SOH', 'Predicted SOH', 'Real SOH totale');

title('Confronto della SOH reale con la SOH prevista nella batteria B18');
xlabel('Campioni');
ylabel('SOH');


plot(first_below_80_cycle_B18, predictions_B18(first_below_80_cycle_B18), 'kp', 'MarkerSize', 15, 'MarkerFaceColor', 'magenta', 'DisplayName', sprintf('First <80%% SOH at Cycle %d', cycles_B18(first_below_80_cycle_B18)));
text(first_below_80_cycle_B18, predictions_B18(first_below_80_cycle_B18), sprintf('  First <80%%\nCycle %d', cycles_B18(first_below_80_cycle_B18)), 'VerticalAlignment', 'top', 'FontSize', 10, 'Color', 'magenta');
legend('show');
title('Confronto della SOH reale con la SOH prevista nella batteria B18');
xlabel('Samples');
ylabel('SOH');

save('prediction_SOH_B18', 'predictions_B18');


% Calcolare gli errori medi per ciascun modello
mseError_avg = (mseError_B5 + mseError_B6 + mseError_B7 + mseError_B18) / 4;
rmseError_avg = (rmseError_B5 + rmseError_B6 + rmseError_B7 + rmseError_B18) / 4;
maeError_avg = (maeError_B5 + maeError_B6 + maeError_B7 + maeError_B18) / 4;

% Stampare gli errori medi
disp(['Media MSE Error: ', num2str(mseError_avg)]);
disp(['Media RMSE Error: ', num2str(rmseError_avg)]);
disp(['Media MAE Error: ', num2str(maeError_avg)]);

% Creazione dei vettori contenenti gli errori MSE, RMSE e MAE per ogni testing
mseErrors = [mseError_B5, mseError_B6, mseError_B7, mseError_B18];
rmseErrors = [rmseError_B5, rmseError_B6, rmseError_B7, rmseError_B18];
maeErrors = [maeError_B5, maeError_B6, maeError_B7, maeError_B18];

% Creazione del grafico
figure;
bar([mseErrors', rmseErrors', maeErrors']);
hold on;
% Aggiungi le linee per le medie degli errori MSE, RMSE e MAE
plot([1, 2, 3, 4], [mseError_avg, mseError_avg, mseError_avg, mseError_avg], 'LineWidth', 2, 'Color', 'r');
plot([1, 2, 3, 4], [rmseError_avg, rmseError_avg, rmseError_avg, rmseError_avg], 'LineWidth', 2, 'Color', 'g');
plot([1, 2, 3, 4], [maeError_avg, maeError_avg, maeError_avg, maeError_avg], 'LineWidth', 2, 'Color', 'b');
hold off;
xlabel('Testing');
ylabel('Errore');
title('Errori MSE, RMSE e MAE per ogni testing');
legend('MSE', 'RMSE', 'MAE', 'Media MSE', 'Media RMSE', 'Media MAE');
xticklabels({'B5', 'B6', 'B7', 'B18'});

