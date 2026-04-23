# G2 - Note di consegna

## File principali

- `database/schema.sql`: schema MySQL aggiornato con vincoli e chiavi esterne.
- `pulizia.py`: legge i CSV originali, stampa i problemi, applica le correzioni e salva i file `*_clean.csv`.
- `query_business.sql`: contiene le 7 query SQL richieste dalla traccia.
- `mongodb/query_g2.js`: contiene le 3 query MongoDB richieste.
- `docs/g2_problem_log.md`: tabella dei problemi dati compilata dal processo di pulizia.

## Motivazione Query Mongo libera

La query M3 aggrega i `tags` dei prodotti per capire quali etichette di catalogo
sono piu presenti. E utile per leggere rapidamente il mix assortimentale e per
supportare decisioni commerciali o promozionali.
