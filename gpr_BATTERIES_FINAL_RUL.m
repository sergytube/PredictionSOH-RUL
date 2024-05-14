
%% PREDIZIONE RUL PER BATTERIA 

% Carica i dati delle batterie  e le previsioni della SOH
data_B5 = load('B5_features.mat');
data_B6 = load('B6_features.mat');
data_B7 = load('B7_features.mat');
data_B18 = load('B18_features.mat');

prediction_SOH_B5 = load('prediction_SOH_B5.mat'); % Carica il vettore delle previsioni della SOH
prediction_SOH_B6 = load('prediction_SOH_B6.mat'); % Carica il vettore delle previsioni della SOH
prediction_SOH_B7 = load('prediction_SOH_B7.mat'); % Carica il vettore delle previsioni della SOH
prediction_SOH_B18 = load('prediction_SOH_B18.mat'); % Carica il vettore delle previsioni della SOH



% Estrai il vettore delle previsioni della SOH dalla struttura caricata
predictions_SOH_B5 = prediction_SOH_B5.predictions
predictions_SOH_B6 = prediction_SOH_B6.predictions
predictions_SOH_B7 = prediction_SOH_B7.predictions
predictions_SOH_B18 = prediction_SOH_B18.predictions


% Genera un vettore di numeri di ciclo corrispondenti alle previsioni della SOH
cycles_B5 = (1:length(predictions_SOH_B5)).'; 
cycles_B6 = (1:length(predictions_SOH_B6)).'; 
cycles_B7 = (1:length(predictions_SOH_B7)).'; 
cycles_B18 = (1:length(predictions_SOH_B18)).'; 

%% PREPARAZIONE DEI DATI PER L'ADDESTRAMENTO DEL MODELLO GPR

% Concatena le previsioni della SOH e i numeri di ciclo per le batterie B18, B6 e B7
X_train_RUL_B5 = [predictions_SOH_B18, cycles_B18; predictions_SOH_B6, cycles_B6; predictions_SOH_B7, cycles_B7];
y_train_RUL_B5 = [data_B18.B18.TOTAL_TIME; data_B6.B6.TOTAL_TIME; data_B7.B7.TOTAL_TIME];

% Addestra il modello GPR
gprMdl_RUL_B5 = fitrgp(X_train_RUL_B5, y_train_RUL_B5, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');

% Utilizza le previsioni della SOH e i numeri di ciclo come feature per la previsione del RUL su B18
X_test_B5 = [predictions_SOH_B5, cycles_B5];
y_test_B5 = data_B5.B5.TOTAL_TIME;

%% VALUTAZIONE DEL MODELLO SU B5

% Effettua previsioni del RUL su B18 utilizzando le previsioni della SOH come feature
predictions_RUL_B5_with_predicted_SOH = predict(gprMdl_RUL_B5, X_test_B5);

% Calcolo dell'errore per la batteria B5
mseError_B5_with_predicted_SOH = mean((predictions_RUL_B5_with_predicted_SOH - y_test_B5).^2);
disp(['MSE Error for Battery B5 with predicted SOH: ', num2str(mseError_B5_with_predicted_SOH)]);

% Calcolo della RMSE per Batteria B5
rmse_B5 = sqrt(mseError_B5_with_predicted_SOH);
disp(['RMSE for Battery B5: ', num2str(rmse_B5)]);

% Calcolo della MAE per Batteria B5
mae_B5 = mean(abs(predictions_RUL_B5_with_predicted_SOH - y_test_B5));
disp(['MAE for Battery B5: ', num2str(mae_B5)]);

index_SOH_below_threshold_B5 = find(predictions_SOH_B5 < 80, 1, 'first');
mseError_B5_with_predicted_SOH_Until_80 = mean((predictions_RUL_B5_with_predicted_SOH(1:index_SOH_below_threshold_B5, :) - y_test_B5(1:index_SOH_below_threshold_B5, :)).^2);
rmseError_B5_with_predicted_SOH_Until_80 = sqrt(mseError_B5_with_predicted_SOH_Until_80);
maeError_B5_with_predicted_SOH_Until_80 = mean(abs((predictions_RUL_B5_with_predicted_SOH(1:index_SOH_below_threshold_B5, :) - y_test_B5(1:index_SOH_below_threshold_B5, :))));

disp(['Il punto in cui la SOH è inferiore al 80% per la batteria B5 è al ciclo numero: ', num2str(index_SOH_below_threshold_B5)]);
disp(['La MSE della batteria fino a quel punto è: ', num2str(mseError_B5_with_predicted_SOH_Until_80)]);
disp(['La RMSE della batteria fino a quel punto è: ', num2str(rmseError_B5_with_predicted_SOH_Until_80)]);
disp(['La MAE della batteria fino a quel punto è: ', num2str(maeError_B5_with_predicted_SOH_Until_80)]);



% % Plot delle previsioni del RUL rispetto ai valori reali per la batteria B5
% figure;
% plot(y_test_B5, predictions_RUL_B5_with_predicted_SOH, 'bo');
% hold on;
% plot([min(y_test_B5), max(y_test_B5)], [min(y_test_B5), max(y_test_B5)], 'r--');
% hold off;
% 
% % Aggiungi etichette e titoli al grafico
% xlabel('Real RUL');
% ylabel('Predicted RUL');
% title('Predicted RUL vs. Real RUL for Battery B18');
% legend('Predicted vs. Real', 'Ideal line');
% 
% % Visualizza il grafico
% grid on;
% 
% prediction_error_B5 = predictions_RUL_B5_with_predicted_SOH - y_test_B5;
% 
% 
% % Plot dell'errore di previsione rispetto al numero di ciclo
% figure;
% plot(cycles_B5, prediction_error_B5, 'b-');
% xlabel('Cycle Number');
% ylabel('Prediction Error');
% title('Prediction Error vs. Cycle Number for Battery B18');
% 
% % Visualizza il grafico
% grid on;

figure;
plot(y_test_B5, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(predictions_RUL_B5_with_predicted_SOH, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
line([index_SOH_below_threshold_B5, index_SOH_below_threshold_B5], [min(y_test_B5), max(y_test_B5)], 'Color', 'k', 'LineStyle', '--');

legend('Real RUL', 'Predicted RUL', 'SOH < 80%', 'Location', 'best');

title('Confronto della RUL reale con la RUL prevista nella Batteria B5');
xlabel('Campioni');
ylabel('RUL');


% Concatena le previsioni della SOH e i numeri di ciclo per le batterie B5, B7 e B18
X_train_RUL_B6 = [predictions_SOH_B5, cycles_B5; predictions_SOH_B7, cycles_B7; predictions_SOH_B18, cycles_B18];
y_train_RUL_B6 = [data_B5.B5.TOTAL_TIME; data_B7.B7.TOTAL_TIME; data_B18.B18.TOTAL_TIME];

% Addestra il modello GPR
gprMdl_RUL_B6 = fitrgp(X_train_RUL_B6, y_train_RUL_B6, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');

% Utilizza le previsioni della SOH e i numeri di ciclo come feature per la previsione del RUL su B18
X_test_B6 = [predictions_SOH_B6, cycles_B6];
y_test_B6 = data_B6.B6.TOTAL_TIME;

%% VALUTAZIONE DEL MODELLO SU B6

% Effettua previsioni del RUL su B18 utilizzando le previsioni della SOH come feature
predictions_RUL_B6_with_predicted_SOH = predict(gprMdl_RUL_B6, X_test_B5);

% Calcolo dell'errore per la batteria B6
mseError_B6_with_predicted_SOH = mean((predictions_RUL_B6_with_predicted_SOH - y_test_B6).^2);
disp(['MSE Error for Battery B6 with predicted SOH: ', num2str(mseError_B6_with_predicted_SOH)]);

% Calcolo della RMSE per la batteria B6
rmse_B6 = sqrt(mseError_B6_with_predicted_SOH);
disp(['RMSE for Battery B6: ', num2str(rmse_B6)]);

% Calcolo della MAE per la batteria B6
mae_B6 = mean(abs(predictions_RUL_B6_with_predicted_SOH - y_test_B6));
disp(['MAE for Battery B6: ', num2str(mae_B6)]);

index_SOH_below_threshold_B6 = find(predictions_SOH_B6 < 80, 1, 'first');
mseError_B6_with_predicted_SOH_Until_80 = mean((predictions_RUL_B6_with_predicted_SOH(1:index_SOH_below_threshold_B6, :) - y_test_B6(1:index_SOH_below_threshold_B6, :)).^2);
rmseError_B6_with_predicted_SOH_Until_80 = sqrt(mseError_B6_with_predicted_SOH_Until_80);
maeError_B6_with_predicted_SOH_Until_80 = mean(abs((predictions_RUL_B6_with_predicted_SOH(1:index_SOH_below_threshold_B6, :) - y_test_B6(1:index_SOH_below_threshold_B6, :))));

disp(['Il punto in cui la SOH è inferiore al 80% per la batteria B6 è al ciclo numero: ', num2str(index_SOH_below_threshold_B6)]);
disp(['La MSE della batteria fino a quel punto è: ', num2str(mseError_B6_with_predicted_SOH_Until_80)]);
disp(['La RMSE della batteria fino a quel punto è: ', num2str(rmseError_B6_with_predicted_SOH_Until_80)]);
disp(['La MAE della batteria fino a quel punto è: ', num2str(maeError_B6_with_predicted_SOH_Until_80)]);

figure;
plot(y_test_B6, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(predictions_RUL_B6_with_predicted_SOH, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
line([index_SOH_below_threshold_B6, index_SOH_below_threshold_B6], [min(y_test_B6), max(y_test_B6)], 'Color', 'k', 'LineStyle', '--');

legend('Real RUL', 'Predicted RUL', 'SOH < 80%', 'Location', 'best');

title('Confronto della RUL reale con la RUL prevista nella Batteria B6');
xlabel('Campioni');
ylabel('RUL');



% Concatena le previsioni della SOH e i numeri di ciclo per le batterie B5, B6 e B18
X_train_RUL_B7 = [predictions_SOH_B5, cycles_B5; predictions_SOH_B6, cycles_B6; predictions_SOH_B18, cycles_B18];
y_train_RUL_B7 = [data_B5.B5.TOTAL_TIME; data_B6.B6.TOTAL_TIME; data_B18.B18.TOTAL_TIME];

% Addestra il modello GPR
gprMdl_RUL_B7 = fitrgp(X_train_RUL_B7, y_train_RUL_B7, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');

% Utilizza le previsioni della SOH e i numeri di ciclo come feature per la previsione del RUL su B18
X_test_B7 = [predictions_SOH_B7, cycles_B7];
y_test_B7 = data_B7.B7.TOTAL_TIME;

%% VALUTAZIONE DEL MODELLO SU B7

% Effettua previsioni del RUL su B18 utilizzando le previsioni della SOH come feature
predictions_RUL_B7_with_predicted_SOH = predict(gprMdl_RUL_B7, X_test_B7);

% Calcolo dell'errore per la batteria B7
mseError_B7_with_predicted_SOH = mean((predictions_RUL_B7_with_predicted_SOH - y_test_B7).^2);
disp(['MSE Error for Battery B7 with predicted SOH: ', num2str(mseError_B7_with_predicted_SOH)]);

% Calcolo della RMSE per la batteria B7
rmse_B7 = sqrt(mseError_B7_with_predicted_SOH);
disp(['RMSE for Battery B7: ', num2str(rmse_B7)]);

% Calcolo della MAE per la batteria B7
mae_B7 = mean(abs(predictions_RUL_B7_with_predicted_SOH - y_test_B7));
disp(['MAE for Battery B7: ', num2str(mae_B7)]);

index_SOH_below_threshold_B7 = find(predictions_SOH_B7 < 80, 1, 'first');
mseError_B7_with_predicted_SOH_Until_80 = mean((predictions_RUL_B7_with_predicted_SOH(1:index_SOH_below_threshold_B7, :) - y_test_B7(1:index_SOH_below_threshold_B7, :)).^2);
rmseError_B7_with_predicted_SOH_Until_80 = sqrt(mseError_B7_with_predicted_SOH_Until_80);
maeError_B7_with_predicted_SOH_Until_80 = mean(abs((predictions_RUL_B7_with_predicted_SOH(1:index_SOH_below_threshold_B7, :) - y_test_B7(1:index_SOH_below_threshold_B7, :))));

disp(['Il punto in cui la SOH è inferiore al 80% per la batteria B7 è al ciclo numero: ', num2str(index_SOH_below_threshold_B7)]);
disp(['La MSE della batteria fino a quel punto è: ', num2str(mseError_B7_with_predicted_SOH_Until_80)]);
disp(['La RMSE della batteria fino a quel punto è: ', num2str(rmseError_B7_with_predicted_SOH_Until_80)]);
disp(['La MAE della batteria fino a quel punto è: ', num2str(maeError_B7_with_predicted_SOH_Until_80)]);

figure;
plot(y_test_B7, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(predictions_RUL_B7_with_predicted_SOH, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
line([index_SOH_below_threshold_B7, index_SOH_below_threshold_B7], [min(y_test_B7), max(y_test_B7)], 'Color', 'k', 'LineStyle', '--');

legend('Real RUL', 'Predicted RUL', 'SOH < 80%', 'Location', 'best');

title('Confronto della RUL reale con la RUL prevista nella Batteria B7');
xlabel('Campioni');
ylabel('RUL');



% Concatena le previsioni della SOH e i numeri di ciclo per le batterie B5, B6 e B7
X_train_RUL_B18 = [predictions_SOH_B5, cycles_B5; predictions_SOH_B6, cycles_B6; predictions_SOH_B7, cycles_B7];
y_train_RUL_B18 = [data_B5.B5.TOTAL_TIME; data_B6.B6.TOTAL_TIME; data_B7.B7.TOTAL_TIME];

% Addestra il modello GPR
gprMdl_RUL_B18 = fitrgp(X_train_RUL_B18, y_train_RUL_B18, 'Basis', 'linear', 'FitMethod', 'exact', 'PredictMethod', 'exact');

% Utilizza le previsioni della SOH e i numeri di ciclo come feature per la previsione del RUL su B18
X_test_B18 = [predictions_SOH_B18, cycles_B18];
y_test_B18 = data_B18.B18.TOTAL_TIME;

%% VALUTAZIONE DEL MODELLO SU B18

% Effettua previsioni del RUL su B18 utilizzando le previsioni della SOH come feature
predictions_RUL_B18_with_predicted_SOH = predict(gprMdl_RUL_B18, X_test_B18);

% Calcolo dell'errore per la batteria B18
mseError_B18_with_predicted_SOH = mean((predictions_RUL_B18_with_predicted_SOH - y_test_B18).^2);
disp(['MSE Error for Battery B18 with predicted SOH: ', num2str(mseError_B18_with_predicted_SOH)]);

% Calcolo della RMSE per la batteria B18
rmse_B18 = sqrt(mseError_B18_with_predicted_SOH);
disp(['RMSE for Battery B18: ', num2str(rmse_B18)]);

% Calcolo della MAE per la batteria B18
mae_B18 = mean(abs(predictions_RUL_B18_with_predicted_SOH - y_test_B18));
disp(['MAE for Battery B18: ', num2str(mae_B18)]);

index_SOH_below_threshold_B18 = find(predictions_SOH_B18 < 80, 1, 'first');
mseError_B18_with_predicted_SOH_Until_80 = mean((predictions_RUL_B18_with_predicted_SOH(1:index_SOH_below_threshold_B18, :) - y_test_B18(1:index_SOH_below_threshold_B18, :)).^2);
rmseError_B18_with_predicted_SOH_Until_80 = sqrt(mseError_B18_with_predicted_SOH_Until_80);
maeError_B18_with_predicted_SOH_Until_80 = mean(abs((predictions_RUL_B18_with_predicted_SOH(1:index_SOH_below_threshold_B18, :) - y_test_B18(1:index_SOH_below_threshold_B18, :))));

disp(['Il punto in cui la SOH è inferiore al 80% per la batteria B18 è al ciclo numero: ', num2str(index_SOH_below_threshold_B18)]);
disp(['La MSE della batteria fino a quel punto è: ', num2str(mseError_B18_with_predicted_SOH_Until_80)]);
disp(['La RMSE della batteria fino a quel punto è: ', num2str(rmseError_B18_with_predicted_SOH_Until_80)]);
disp(['La MAE della batteria fino a quel punto è: ', num2str(maeError_B18_with_predicted_SOH_Until_80)]);

figure;
plot(y_test_B18, 're-', 'LineWidth', 1.5); % Dati reali
hold on;
plot(predictions_RUL_B18_with_predicted_SOH, 'bl-', 'LineWidth', 1.5); % Predizioni
hold on;
line([index_SOH_below_threshold_B18, index_SOH_below_threshold_B18], [min(y_test_B18), max(y_test_B18)], 'Color', 'k', 'LineStyle', '--');

legend('Real RUL', 'Predicted RUL', 'SOH < 80%', 'Location', 'best');

title('Confronto della RUL reale con la RUL prevista nella Batteria B18');
xlabel('Campioni');
ylabel('RUL');