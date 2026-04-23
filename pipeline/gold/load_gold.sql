USE sac;

TRUNCATE TABLE gold_vendite_farmacia_giornaliere;

INSERT INTO gold_vendite_farmacia_giornaliere (
    data_vendita,
    id_farmacia,
    totale_scontrini,
    totale_pezzi,
    ricavi
)
SELECT
    v.data_vendita,
    v.id_farmacia,
    COUNT(*) AS totale_scontrini,
    SUM(v.quantita) AS totale_pezzi,
    ROUND(SUM(v.quantita * v.prezzo_unitario), 2) AS ricavi
FROM silver_vendite v
GROUP BY
    v.data_vendita,
    v.id_farmacia;
