USE sac;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE silver_prodotto_controindicazioni;
TRUNCATE TABLE silver_prodotto_tags;
TRUNCATE TABLE silver_prodotti_extra;
TRUNCATE TABLE silver_fornitori_storico;
TRUNCATE TABLE silver_vendite;
TRUNCATE TABLE silver_prodotti;
TRUNCATE TABLE silver_farmacie;
TRUNCATE TABLE silver_clienti;
TRUNCATE TABLE silver_fornitori;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO silver_clienti (
    id_cliente,
    eta,
    genere,
    citta,
    tessera_fedelta,
    source_file
)
WITH clean_clienti AS (
    SELECT
        CAST(TRIM(id_cliente) AS UNSIGNED) AS id_cliente,
        CAST(TRIM(eta) AS UNSIGNED) AS eta,
        UPPER(TRIM(genere)) AS genere,
        TRIM(citta) AS citta,
        CASE
            WHEN LOWER(TRIM(tessera_fedelta)) IN ('si', 'sì', 'true', '1', 'yes') THEN 1
            ELSE 0
        END AS tessera_fedelta,
        source_file
    FROM bronze_clienti_raw
    WHERE TRIM(id_cliente) REGEXP '^[0-9]+$'
      AND TRIM(eta) REGEXP '^[0-9]+$'
      AND TRIM(genere) <> ''
      AND TRIM(citta) <> ''
)
SELECT
    id_cliente,
    eta,
    genere,
    citta,
    tessera_fedelta,
    source_file
FROM clean_clienti;

INSERT INTO silver_farmacie (
    id_farmacia,
    nome,
    citta,
    provincia,
    latitudine,
    longitudine,
    source_file
)
WITH clean_farmacie AS (
    SELECT
        CAST(TRIM(id_farmacia) AS UNSIGNED) AS id_farmacia,
        TRIM(nome) AS nome,
        TRIM(citta) AS citta,
        UPPER(TRIM(provincia)) AS provincia,
        CAST(TRIM(latitudine) AS DECIMAL(9, 6)) AS latitudine,
        CAST(TRIM(longitudine) AS DECIMAL(9, 6)) AS longitudine,
        source_file
    FROM bronze_farmacie_raw
    WHERE TRIM(id_farmacia) REGEXP '^[0-9]+$'
      AND TRIM(nome) <> ''
      AND TRIM(citta) <> ''
      AND TRIM(provincia) <> ''
)
SELECT
    id_farmacia,
    nome,
    citta,
    provincia,
    latitudine,
    longitudine,
    source_file
FROM clean_farmacie;

INSERT INTO silver_fornitori (nome)
SELECT DISTINCT fornitore
FROM (
    SELECT TRIM(fornitore) AS fornitore
    FROM bronze_prodotti_raw
    WHERE TRIM(fornitore) <> ''
    UNION
    SELECT TRIM(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.fornitore'))) AS fornitore
    FROM bronze_fornitori_storico_raw
    WHERE TRIM(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.fornitore'))) <> ''
) AS fornitori_distinti;

INSERT INTO silver_prodotti (
    id_prodotto,
    nome,
    categoria,
    fornitore,
    prezzo_acquisto,
    prezzo_vendita,
    source_file
)
WITH clean_prodotti AS (
    SELECT
        CAST(TRIM(id_prodotto) AS UNSIGNED) AS id_prodotto,
        TRIM(nome) AS nome,
        TRIM(categoria) AS categoria,
        TRIM(fornitore) AS fornitore,
        CAST(TRIM(prezzo_acquisto) AS DECIMAL(10, 2)) AS prezzo_acquisto,
        CAST(TRIM(prezzo_vendita) AS DECIMAL(10, 2)) AS prezzo_vendita,
        source_file
    FROM bronze_prodotti_raw
    WHERE TRIM(id_prodotto) REGEXP '^[0-9]+$'
      AND TRIM(nome) <> ''
      AND TRIM(categoria) <> ''
      AND TRIM(fornitore) <> ''
      AND TRIM(prezzo_acquisto) <> ''
      AND TRIM(prezzo_vendita) <> ''
)
SELECT
    p.id_prodotto,
    p.nome,
    p.categoria,
    p.fornitore,
    p.prezzo_acquisto,
    p.prezzo_vendita,
    p.source_file
FROM clean_prodotti p
INNER JOIN silver_fornitori f
    ON f.nome = p.fornitore;

INSERT INTO silver_vendite (
    id_vendita,
    data_vendita,
    id_prodotto,
    id_farmacia,
    quantita,
    prezzo_unitario,
    id_cliente,
    source_file
)
WITH clean_vendite AS (
    SELECT
        CAST(TRIM(id_vendita) AS UNSIGNED) AS id_vendita,
        CASE
            WHEN data_vendita_raw LIKE '____-__-__' THEN STR_TO_DATE(data_vendita_raw, '%Y-%m-%d')
            WHEN data_vendita_raw LIKE '__/__/____' THEN STR_TO_DATE(data_vendita_raw, '%d/%m/%Y')
            WHEN data_vendita_raw LIKE '__-__-____' THEN STR_TO_DATE(data_vendita_raw, '%d-%m-%Y')
            ELSE NULL
        END AS data_vendita,
        CAST(TRIM(id_prodotto) AS UNSIGNED) AS id_prodotto,
        CAST(TRIM(id_farmacia) AS UNSIGNED) AS id_farmacia,
        CAST(TRIM(quantita) AS UNSIGNED) AS quantita,
        CAST(TRIM(prezzo_unitario) AS DECIMAL(10, 2)) AS prezzo_unitario,
        CAST(TRIM(id_cliente) AS UNSIGNED) AS id_cliente,
        source_file
    FROM bronze_vendite_raw
    WHERE TRIM(id_vendita) REGEXP '^[0-9]+$'
      AND TRIM(id_prodotto) REGEXP '^[0-9]+$'
      AND TRIM(id_farmacia) REGEXP '^[0-9]+$'
      AND TRIM(quantita) REGEXP '^[0-9]+$'
      AND TRIM(prezzo_unitario) <> ''
      AND TRIM(id_cliente) REGEXP '^[0-9]+$'
)
SELECT
    v.id_vendita,
    v.data_vendita,
    v.id_prodotto,
    v.id_farmacia,
    v.quantita,
    v.prezzo_unitario,
    v.id_cliente,
    v.source_file
FROM clean_vendite v
INNER JOIN silver_prodotti p
    ON p.id_prodotto = v.id_prodotto
INNER JOIN silver_farmacie f
    ON f.id_farmacia = v.id_farmacia
INNER JOIN silver_clienti c
    ON c.id_cliente = v.id_cliente
WHERE v.data_vendita IS NOT NULL;

INSERT INTO silver_fornitori_storico (
    fornitore,
    anno,
    mese,
    ordini_effettuati,
    consegne_in_ritardo,
    giorni_medi_ritardo,
    source_file
)
WITH clean_fornitori_storico AS (
    SELECT
        TRIM(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.fornitore'))) AS fornitore,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.anno')) AS UNSIGNED) AS anno,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.mese')) AS UNSIGNED) AS mese,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.ordini_effettuati')) AS UNSIGNED) AS ordini_effettuati,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.consegne_in_ritardo')) AS UNSIGNED) AS consegne_in_ritardo,
        CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.giorni_medi_ritardo')) AS DECIMAL(10, 2)) AS giorni_medi_ritardo,
        source_file
    FROM bronze_fornitori_storico_raw
)
SELECT
    fs.fornitore,
    fs.anno,
    fs.mese,
    fs.ordini_effettuati,
    fs.consegne_in_ritardo,
    fs.giorni_medi_ritardo,
    fs.source_file
FROM clean_fornitori_storico fs
INNER JOIN silver_fornitori f
    ON f.nome = fs.fornitore;

INSERT INTO silver_prodotti_extra (
    id_prodotto,
    descrizione,
    principio_attivo,
    source_file
)
WITH clean_prodotti_extra AS (
    SELECT
        CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.id_prodotto')) AS UNSIGNED) AS id_prodotto,
        JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.descrizione')) AS descrizione,
        JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.principio_attivo')) AS principio_attivo,
        source_file
    FROM bronze_prodotti_extra_raw
)
SELECT
    pe.id_prodotto,
    pe.descrizione,
    pe.principio_attivo,
    pe.source_file
FROM clean_prodotti_extra pe
INNER JOIN silver_prodotti p
    ON p.id_prodotto = pe.id_prodotto;

INSERT INTO silver_prodotto_tags (
    id_prodotto,
    tag,
    source_file
)
WITH raw_prodotto_tags AS (
    SELECT
        CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS UNSIGNED) AS id_prodotto,
        jt.tag AS tag,
        b.source_file AS source_file
    FROM bronze_prodotti_extra_raw b
    CROSS JOIN JSON_TABLE(
        b.record_data,
        '$.tags[*]' COLUMNS (
            tag VARCHAR(255) PATH '$'
        )
    ) AS jt
)
SELECT
    t.id_prodotto,
    t.tag,
    t.source_file
FROM raw_prodotto_tags t
INNER JOIN silver_prodotti p
    ON p.id_prodotto = t.id_prodotto;

INSERT INTO silver_prodotto_controindicazioni (
    id_prodotto,
    controindicazione,
    source_file
)
WITH raw_prodotto_controindicazioni AS (
    SELECT
        CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS UNSIGNED) AS id_prodotto,
        jt.controindicazione AS controindicazione,
        b.source_file AS source_file
    FROM bronze_prodotti_extra_raw b
    CROSS JOIN JSON_TABLE(
        b.record_data,
        '$.controindicazioni[*]' COLUMNS (
            controindicazione VARCHAR(255) PATH '$'
        )
    ) AS jt
)
SELECT
    c.id_prodotto,
    c.controindicazione,
    c.source_file
FROM raw_prodotto_controindicazioni c
INNER JOIN silver_prodotti p
    ON p.id_prodotto = c.id_prodotto;
