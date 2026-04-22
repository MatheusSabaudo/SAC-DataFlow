USE sac;

TRUNCATE TABLE gold_vendite_farmacia_giornaliere;

-- Aggrega le vendite per data e farmacia direttamente dalla tabella silver.
INSERT INTO gold_vendite_farmacia_giornaliere (
    data_vendita,
    id_farmacia,
    totale_scontrini,
    totale_pezzi,
    ricavi
)
SELECT
    data_vendita,
    id_farmacia,
    COUNT(*) AS totale_scontrini,
    SUM(COALESCE(quantita, 0)) AS totale_pezzi,
    ROUND(SUM(COALESCE(quantita, 0) * COALESCE(prezzo_unitario, 0)), 2) AS ricavi
FROM silver_vendite
WHERE data_vendita IS NOT NULL
  AND id_farmacia IS NOT NULL
GROUP BY
    data_vendita,
    id_farmacia;
