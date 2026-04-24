CREATE DATABASE IF NOT EXISTS medistore_dwh;

USE medistore_dwh;

DELETE FROM fatto_vendite;
DELETE FROM dim_tempo;
DELETE FROM dim_prodotto;
DELETE FROM dim_farmacia;
DELETE FROM dim_cliente;

INSERT INTO dim_tempo (
    id_tempo,
    data,
    giorno,
    mese,
    nome_mese,
    trimestre,
    anno,
    giorno_settimana,
    e_weekend
)
SELECT DISTINCT
    CAST(DATE_FORMAT(v.data_vendita, '%Y%m%d') AS UNSIGNED) AS id_tempo,
    v.data_vendita AS data,
    DAY(v.data_vendita) AS giorno,
    MONTH(v.data_vendita) AS mese,
    CASE MONTH(v.data_vendita)
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
    QUARTER(v.data_vendita) AS trimestre,
    YEAR(v.data_vendita) AS anno,
    CASE WEEKDAY(v.data_vendita)
        WHEN 0 THEN 'Lunedi'
        WHEN 1 THEN 'Martedi'
        WHEN 2 THEN 'Mercoledi'
        WHEN 3 THEN 'Giovedi'
        WHEN 4 THEN 'Venerdi'
        WHEN 5 THEN 'Sabato'
        WHEN 6 THEN 'Domenica'
    END AS giorno_settimana,
    WEEKDAY(v.data_vendita) IN (5, 6) AS e_weekend
FROM sac.silver_vendite v;

INSERT INTO dim_cliente (
    id_cliente,
    eta,
    fascia_eta,
    genere,
    citta,
    tessera_fedelta
)
SELECT
    c.id_cliente,
    c.eta,
    CASE
        WHEN c.eta <= 17 THEN '0-17'
        WHEN c.eta <= 35 THEN '18-35'
        WHEN c.eta <= 50 THEN '36-50'
        WHEN c.eta <= 65 THEN '51-65'
        ELSE '66+'
    END AS fascia_eta,
    c.genere,
    c.citta,
    c.tessera_fedelta
FROM sac.silver_clienti c;

INSERT INTO dim_farmacia (
    id_farmacia,
    nome,
    citta,
    provincia,
    latitudine,
    longitudine
)
SELECT
    f.id_farmacia,
    f.nome,
    f.citta,
    f.provincia,
    f.latitudine,
    f.longitudine
FROM sac.silver_farmacie f;

INSERT INTO dim_prodotto (
    id_prodotto,
    nome,
    categoria,
    fornitore,
    prezzo_acquisto,
    prezzo_vendita,
    margine_unitario,
    principio_attivo,
    descrizione,
    ordini_fornitore,
    pct_consegne_ritardo,
    giorni_medi_ritardo_fornitore
)
SELECT
    p.id_prodotto,
    p.nome,
    p.categoria,
    p.fornitore,
    p.prezzo_acquisto,
    p.prezzo_vendita,
    p.prezzo_vendita - p.prezzo_acquisto AS margine_unitario,
    pe.principio_attivo,
    pe.descrizione,
    COALESCE(fs.ordini_fornitore, 0) AS ordini_fornitore,
    COALESCE(fs.pct_consegne_ritardo, 0.00) AS pct_consegne_ritardo,
    COALESCE(fs.giorni_medi_ritardo_fornitore, 0.00) AS giorni_medi_ritardo_fornitore
FROM sac.silver_prodotti p
LEFT JOIN sac.silver_prodotti_extra pe
    ON pe.id_prodotto = p.id_prodotto
LEFT JOIN (
    SELECT
        fornitore,
        SUM(ordini_effettuati) AS ordini_fornitore,
        ROUND(SUM(consegne_in_ritardo) / NULLIF(SUM(ordini_effettuati), 0) * 100, 2) AS pct_consegne_ritardo,
        ROUND(AVG(giorni_medi_ritardo), 2) AS giorni_medi_ritardo_fornitore
    FROM sac.silver_fornitori_storico
    GROUP BY fornitore
) fs
    ON fs.fornitore = p.fornitore;

INSERT INTO fatto_vendite (
    id_fatto,
    id_tempo,
    id_prodotto,
    id_farmacia,
    id_cliente,
    quantita,
    prezzo_unitario,
    fatturato,
    margine
)
SELECT
    v.id_vendita AS id_fatto,
    t.id_tempo,
    v.id_prodotto,
    v.id_farmacia,
    v.id_cliente,
    v.quantita,
    v.prezzo_unitario,
    ROUND(v.quantita * v.prezzo_unitario, 2) AS fatturato,
    ROUND(v.quantita * (v.prezzo_unitario - p.prezzo_acquisto), 2) AS margine
FROM sac.silver_vendite v
INNER JOIN dim_tempo t
    ON t.data = v.data_vendita
INNER JOIN dim_prodotto p
    ON p.id_prodotto = v.id_prodotto
INNER JOIN dim_farmacia f
    ON f.id_farmacia = v.id_farmacia
INNER JOIN dim_cliente c
    ON c.id_cliente = v.id_cliente;
