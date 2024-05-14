load('dataset.mat', 'dataset')
h1 = dataset.HI1;
h2 = dataset.HI2;
h3 = dataset.HI3;
% Tolgo valori NaN
h1 = h1(~isnan(h1));
h2 = h2(~isnan(h2));
h3 = h3(~isnan(h3));
% Tolgo valori nulli
h1 = h1(h1 ~= 0);
h2 = h2(h2 ~= 0);
h3 = h3(h3 ~= 0);

% Crea un nuovo grafico per h1
figure;
plot(1:numel(h1), h1, 'r', 'LineWidth', 2); % Linea rossa
xlabel('Indice');
ylabel('Valore');
title('Plot di h1');
grid on;
box on;

% Crea un nuovo grafico per h2
figure;
plot(1:numel(h2), h2, 'g', 'LineWidth', 2); % Linea verde
xlabel('Indice');
ylabel('Valore');
title('Plot di h2');
grid on;
box on;

% Crea un nuovo grafico per h3
figure;
plot(1:numel(h3), h3, 'b', 'LineWidth', 2); % Linea blu
xlabel('Indice');
ylabel('Valore');
title('Plot di h3');
grid on;
box on;

% Attributi da estrarre
attributi = {'avgVoltage', 'minVoltage', 'maxVoltage', 'varVoltage', 'avgCurrent', 'minCurrent', 'maxCurrent', 'varCurrent'};

% Per ciascun attributo
for attributo_idx = 1:numel(attributi)
    % Estrai i dati
    dati = dataset.(attributi{attributo_idx});
    
    % Rimuovi i valori nulli (0)
    dati = dati(dati ~= 0);
    
    % Crea un nuovo grafico
    figure;
    
    % Plotta i dati
    plot(1:numel(dati), dati, 'b', 'LineWidth', 2); % Linea blu
    
    % Etichette e titolo
    xlabel('Indice');
    ylabel('Valore');
    title(['Plot di ', attributi{attributo_idx}]);
    
    % Mostra la griglia
    grid on;
    
    % Fai il box di tutto il grafico
    box on;
end

stackedplot(dataset);
