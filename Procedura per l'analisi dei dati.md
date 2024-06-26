# Procedura per l'analisi dei dati delle batterie

Questo repository contiene i programmi necessari per l'analisi dei dati delle batterie. Seguire l'ordine di esecuzione dei programmi per ottenere i risultati desiderati.

## Batteria B5

1. **Data_process_B0005:** Questo script elabora i dati della batteria B5 per prepararli all'estrazione delle caratteristiche.
2. **features_extraction_B5:** Estrae le caratteristiche dai dati elaborati della batteria B5.
3. **features_correlation_B5:** Calcola la correlazione tra le caratteristiche estratte per identificare quelle più significative.
4. **gpr_B5_FINAL:** Addestra e valuta il modello GPR per la stima della SOH (State of Health) della batteria B5.

## Batteria B6

1. **Data_process_B0006:** Elabora i dati della batteria B6 per prepararli all'estrazione delle caratteristiche.
2. **features_extraction_B6:** Estrae le caratteristiche dai dati elaborati della batteria B6.
3. **features_correlation_B6:** Calcola la correlazione tra le caratteristiche estratte per identificare quelle più significative.
4. **gpr_B6_FINAL:** Addestra e valuta il modello GPR per la stima della SOH (State of Health) della batteria B6.

## Batteria B7

1. **Data_process_B0007:** Elabora i dati della batteria B7 per prepararli all'estrazione delle caratteristiche.
2. **features_extraction_B7:** Estrae le caratteristiche dai dati elaborati della batteria B7.
3. **features_correlation_B7:** Calcola la correlazione tra le caratteristiche estratte per identificare quelle più significative.
4. **gpr_B7_FINAL:** Addestra e valuta il modello GPR per la stima della SOH (State of Health) della batteria B7.

## Batteria B18

1. **Data_process_B0018:** Elabora i dati della batteria B18 per prepararli all'estrazione delle caratteristiche.
2. **features_extraction_B18:** Estrae le caratteristiche dai dati elaborati della batteria B18.
3. **features_correlation_B18:** Calcola la correlazione tra le caratteristiche estratte per identificare quelle più significative.
4. **gpr_B18_FINAL:** Addestra e valuta il modello GPR per la stima della SOH (State of Health) della batteria B18.

## Batterie Finali

1. **gpr_BATTERIES_FINAL_RUL:** Combina i risultati dei modelli GPR (cioè della predizione della SOH) per ottenere una stima finale della RUL per tutte le batterie, quindi prevedere tutta la durata in ore delle batterie.

Assicurarsi di eseguire i programmi nell'ordine specificato per ottenere i risultati corretti.

