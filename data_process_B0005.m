%% Caricamento del dataset 
load('B0005.mat'); 

%% Calcolo numero cicli 

numCicli = numel(B0005.cycle);

%% Inizializzazione delle strutture 

% Inizializzazione della tabella finale per i dati 

dataset = table([],[],[],[],'VariableNames',{'type','ambient_temperature','time','data'});

%% Estrazione dei dati 

%Estrazione dei dati dalla struttura originale per il popolamento della
%tabella dichiarata precedentemente 

for i = 1: numCicli
    cycleType = B0005.cycle(i).type;
    cycleData = B0005.cycle(i).data;
    cycleTime = B0005.cycle(i).time; 
    cycleAmbient = B0005.cycle(i).ambient_temperature;

%% Divisione dei dati per tipologia di ciclo e popolamento delle strutture corrispondenti 

    switch cycleType
        case 'charge'
            % Inizializzazione dell'array di strutture per i dati di questo ciclo
            dataStructArray = struct('Time', {}, 'Voltage_measured', {}, 'Current_measured', {}, ...
                                     'Temperature_measured', {}, 'Current_charge', {}, 'Voltage_charge', {});
            % Popolamento l'array di strutture
            for j = 1:length(cycleData.Time)
                dataStructArray(j).Time = cycleData.Time(j);
                dataStructArray(j).Voltage_measured = cycleData.Voltage_measured(j);
                dataStructArray(j).Current_measured = cycleData.Current_measured(j);
                dataStructArray(j).Temperature_measured = cycleData.Temperature_measured(j);
                dataStructArray(j).Current_charge = cycleData.Current_charge(j);
                dataStructArray(j).Voltage_charge = cycleData.Voltage_charge(j);
            end
            % Conversione di dataStructArray in una tabella
            dataTable = struct2table(dataStructArray);

            % Creazione di una nuova riga per il dataset
            newRow = {cycleType, cycleAmbient, datetime(cycleTime, 'Format', 'yyyy-MM-dd HH:mm:ss'), dataTable};
            dataset = [dataset; newRow];
            

        case 'discharge'
             % Inizializza l'array di strutture per i dati di questo ciclo
             dataStructArray = struct('Time', {},'Capacity', {}, 'Voltage_measured', {}, 'Current_measured', {}, ...
                                 'Temperature_measured', {}, 'Current_load', {}, 'Voltage_load', {});
        
            % Popolamento l'array di strutture
            for j = 1:length(cycleData.Time)
                %Inserimento dei dati nella struttura 
                dataStructArray(j).Time = cycleData.Time(j); 
                dataStructArray(j).Capacity = cycleData.Capacity; 
                dataStructArray(j).Voltage_measured = cycleData.Voltage_measured(j);  
                dataStructArray(j).Current_measured = cycleData.Current_measured(j); 
                dataStructArray(j).Temperature_measured = cycleData.Temperature_measured(j); 
                dataStructArray(j).Current_load = cycleData.Current_load(j); 
                dataStructArray(j).Voltage_load = cycleData.Voltage_load(j); 
            end
            
            % Conversione di dataStructArray in una tabella
            dataTable = struct2table(dataStructArray);

            % Creazione di una nuova riga per il dataset
            newRow = {cycleType, cycleAmbient, datetime(cycleTime, 'Format', 'yyyy-MM-dd HH:mm:ss'), dataTable};
            dataset = [dataset; newRow];

        case 'impedance'
            % Inizializza l'array di strutture per i dati di questo ciclo
            dataStructArray = struct('Sense_current', {},'Battery_current', {}, 'Current_ratio', {}, 'Battery_impedance', {}, ...
                                 'Rectified_impedance', {}, 'Re', {}, 'Rct', {});
        
            % Popolamento l'array di strutture
            for j = 1:length(cycleData.Sense_current)
                %Inserimento dei dati nella struttura 
                dataStructArray(j).Sense_current = cycleData.Sense_current(j);
                dataStructArray(j).Battery_current = cycleData.Battery_current(j); 
                dataStructArray(j).Current_ratio = cycleData.Current_ratio(j); 
                dataStructArray(j).Battery_impedance = cycleData.Battery_impedance(j); 
                % Normalizzazione dimensione dei vari vettori 
                if j > length(cycleData.Rectified_Impedance)
                    dataStructArray(j).Rectified_impedance = NaN;
                else
                    dataStructArray(j).Rectified_impedance = cycleData.Rectified_Impedance(j);
                end
                dataStructArray(j).Re = cycleData.Re; 
                dataStructArray(j).Rct= cycleData.Rct; 
            end
            
            % Conversione di dataStructArray in una tabella
            dataTable = struct2table(dataStructArray);

            % Creazione di una nuova riga per il dataset
            newRow = {cycleType, cycleAmbient, datetime(cycleTime, 'Format', 'yyyy-MM-dd HH:mm:ss'), dataTable};
            dataset = [dataset; newRow];
    end
end
%% Creazione delle colonne per SOH, FAULT_CODE, TIME_CYCLE, RUL, TOTAL_TIME

% Nomi delle nuove colonne
newVars = {'SOH', 'FAULT_CODE', 'TIME_CYCLE', 'RUL', 'TOTAL_TIME'};

% Creazione e aggiunta delle nuove colonne 
for var = newVars
    dataset.(var{1}) = zeros(height(dataset), 1);
end

%% Divisione dei dati per tipologia di ciclo e popolamento delle strutture corrispondenti 

% Eliminazione delle righe di impedenza
    rows_to_remove = strcmp(dataset.type, 'impedance');
    dataset(rows_to_remove, :) = [];

numCicli = height(dataset);

for i = 1: numCicli
    cycleType = dataset.type{i};
        switch cycleType
            case 'charge'
                if (i==1)
                    dataset.SOH(i)= 100;
                else
                    dataset.SOH(i)= dataset.SOH(i-1);
                end
            case 'discharge'
                    dataTable = dataset.data{i};
                    capacity_value = dataTable.Capacity(1);  % Accedi al valore di capacità dalla colonna 'Capacity' della tabella
                    cn = 2;  % Capacità nominale, aggiusta questo valore se necessario
                    soh = (capacity_value / cn) * 100;  % Calcola il SOH
                    dataset.SOH(i) = soh;  % Assegna il SOH calcolato  
                    dataTable = 0;
       end
end
%% Creazione del plot temporale per SOH 

SOH_PLOT= dataset.SOH;
tempo = 1:size(SOH_PLOT);
% Crea il grafico
plot(tempo, SOH_PLOT);
% Aggiungi etichette agli assi e un titolo
xlabel('Tempo');
ylabel('SOH (State of Health)');
title('Grafico dello State of Health-SOH');

%% Calcolo e aggiunta del Fault code ( 1 quando SOH>80% , 0 quando SOH < 80%) 

for i = 1: numCicli
    soh = dataset.SOH(i); 
    if (soh >80.0)
        dataset.FAULT_CODE(i)= 1;
    else
        dataset.FAULT_CODE(i)= 0;            
   end
end

%% Calcolo e aggiunta valore TIME_CYCLE

% Ciclo attraverso ogni ciclo
for i = 1:numCicli
    % Estrai i dati relativi al ciclo corrente
    data = dataset.data{i};
    data_type = dataset(i,:).type; 
    % Estrai l'ultimo tempo registrato nel ciclo e convertilo in ore
    time = data.Time;
    time = time(end); % Prendi l'ultimo valore di tempo
    time = time / 3600; % Converti il tempo in ore
    
    % Assegna il tempo calcolato al campo TIME_CYCLE del dataset per il ciclo corrente
    dataset.TIME_CYCLE(i) = time; % oppure 0 per ore zero
end

% Ciclo attraverso ogni ciclo per aggiornare il campo TIME_CYCLE
for i = 1:numCicli
    % Estrai i dati relativi al ciclo corrente
    data = dataset.data{i};
    data_type = dataset(i,:).type;
    
    % Controlla se il tipo di dati è 'charge' e se l'indice i è inferiore all'altezza del dataset
    if strcmp(data_type, 'charge') && i < height(dataset)
        % Se la condizione è soddisfatta, aggiorna il campo TIME_CYCLE sommando i tempi dei due cicli consecutivi
        time_cycle_i = dataset.TIME_CYCLE(i);
        time_cycle_j = dataset.TIME_CYCLE(i+1);
        dataset.TIME_CYCLE(i) = time_cycle_i + time_cycle_j; 
    end
end


%% CALCOLO PER TOTAL_TIME 

for i = 1 : numCicli
    if i == 1
        dataset.TOTAL_TIME(i)= dataset.TIME_CYCLE(i);
    else
    dataset.TOTAL_TIME(i)= dataset.TOTAL_TIME(i-1) + dataset.TIME_CYCLE(i);   
    end
end

%% Rimozione dei cicli discharge 

rows_to_remove = strcmp(dataset.type, 'discharge');
% Rimuovi le righe dal dataset
dataset(rows_to_remove, :) = [];

%% Aggiunta della colonna 'Num_cycle'

for i = 1 : height(dataset)
    dataset.Num_cycle(i) = i;
end

%% Calcolo RUL
CycleGood = 77;
for j = 1:CycleGood
    dataset.RUL(j) = CycleGood;
    CycleGood = CycleGood - 1;
end

CycleBad = 78;
% Imposta a zero solo gli elementi successivi a CycleBad
dataset.RUL(CycleBad:end) = 0;

%% Salvataggio dataset 

%Rinomina del dataset con la batteria corrispondente

B5 = dataset; 

save ("B5_finito.mat","B5");
 






