USE sac;

-- QUERY 1: Top 5 prodotti per fatturato totale.
SELECT
    p.id_prodotto,
    p.nome,
    ROUND(SUM(v.quantita * v.prezzo_unitario), 2) AS fatturato_totale
FROM silver_vendite v
INNER JOIN silver_prodotti p
    ON p.id_prodotto = v.id_prodotto
GROUP BY
    p.id_prodotto,
    p.nome
ORDER BY fatturato_totale DESC
LIMIT 5;

-- QUERY 2: Fatturato per farmacia in ordine decrescente.
SELECT
    f.id_farmacia,
    f.nome,
    ROUND(SUM(v.quantita * v.prezzo_unitario), 2) AS fatturato_totale
FROM silver_vendite v
INNER JOIN silver_farmacie f
    ON f.id_farmacia = v.id_farmacia
GROUP BY
    f.id_farmacia,
    f.nome
ORDER BY fatturato_totale DESC;

-- QUERY 3: Categoria di prodotto piu venduta per quantita, con gestione dei pari merito.
WITH categoria_quantita AS (
    SELECT
        p.categoria,
        SUM(v.quantita) AS quantita_venduta
    FROM silver_vendite v
    INNER JOIN silver_prodotti p
        ON p.id_prodotto = v.id_prodotto
    GROUP BY p.categoria
),
categoria_ranked AS (
    SELECT
        categoria,
        quantita_venduta,
        DENSE_RANK() OVER (ORDER BY quantita_venduta DESC) AS posizione
    FROM categoria_quantita
)
SELECT
    categoria,
    quantita_venduta
FROM categoria_ranked
WHERE posizione = 1;

-- QUERY 4: Mese con il maggior numero di vendite considerando tutti gli anni.
WITH vendite_per_mese AS (
    SELECT
        MONTH(data_vendita) AS numero_mese,
        COUNT(*) AS numero_vendite
    FROM silver_vendite
    GROUP BY MONTH(data_vendita)
),
mesi_ranked AS (
    SELECT
        numero_mese,
        numero_vendite,
        DENSE_RANK() OVER (ORDER BY numero_vendite DESC) AS posizione
    FROM vendite_per_mese
)
SELECT
    numero_mese,
    CASE numero_mese
        WHEN 1 THEN 'Gennaio'
        WHEN 2 THEN 'Febbraio'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Aprile'
        WHEN 5 THEN 'Maggio'
        WHEN 6 THEN 'Giugno'
        WHEN 7 THEN 'Luglio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Settembre'
        WHEN 10 THEN 'Ottobre'
        WHEN 11 THEN 'Novembre'
        WHEN 12 THEN 'Dicembre'
    END AS nome_mese,
    numero_vendite
FROM mesi_ranked
WHERE posizione = 1;

-- QUERY 5: Quantita media acquistata per clienti con e senza tessera fedelta.
SELECT
    CASE
        WHEN c.tessera_fedelta = 1 THEN 'Con tessera fedelta'
        ELSE 'Senza tessera fedelta'
    END AS segmento_cliente,
    ROUND(AVG(v.quantita), 2) AS quantita_media_acquistata,
    COUNT(*) AS numero_vendite
FROM silver_vendite v
INNER JOIN silver_clienti c
    ON c.id_cliente = v.id_cliente
GROUP BY c.tessera_fedelta
ORDER BY c.tessera_fedelta DESC;

-- QUERY 6: Fornitori con margine medio piu alto.
SELECT
    fornitore,
    ROUND(AVG(prezzo_vendita - prezzo_acquisto), 2) AS margine_medio
FROM silver_prodotti
GROUP BY fornitore
ORDER BY margine_medio DESC;

-- QUERY 7: Vendite per farmacia e trimestre.
SELECT
    YEAR(v.data_vendita) AS anno,
    QUARTER(v.data_vendita) AS trimestre,
    f.id_farmacia,
    f.nome,
    COUNT(*) AS numero_vendite,
    SUM(v.quantita) AS totale_pezzi,
    ROUND(SUM(v.quantita * v.prezzo_unitario), 2) AS fatturato_trimestrale
FROM silver_vendite v
INNER JOIN silver_farmacie f
    ON f.id_farmacia = v.id_farmacia
GROUP BY
    YEAR(v.data_vendita),
    QUARTER(v.data_vendita),
    f.id_farmacia,
    f.nome
ORDER BY
    anno,
    trimestre,
    fatturato_trimestrale DESC;
