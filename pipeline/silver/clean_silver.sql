USE sac;

TRUNCATE TABLE silver_prodotto_controindicazioni;
TRUNCATE TABLE silver_prodotto_tags;
TRUNCATE TABLE silver_prodotti_extra;
TRUNCATE TABLE silver_fornitori_storico;
TRUNCATE TABLE silver_vendite;
TRUNCATE TABLE silver_prodotti;
TRUNCATE TABLE silver_farmacie;
TRUNCATE TABLE silver_clienti;

-- CTE clienti: prende i dati bronze e normalizza eta e tessera_fedelta.
INSERT INTO silver_clienti (
    id_cliente,
    eta,
    genere,
    citta,
    tessera_fedelta,
    source_file
)
WITH raw_clienti AS (
    SELECT
        id_cliente,
        eta,
        genere,
        citta,
        tessera_fedelta,
        source_file
    FROM bronze_clienti_raw
),
clean_clienti AS (
    SELECT
        CASE
            WHEN id_cliente IS NULL OR id_cliente = '' THEN NULL
            ELSE CAST(id_cliente AS UNSIGNED)
        END AS id_cliente,
        CASE
            WHEN eta IS NULL OR eta = '' THEN NULL
            ELSE CAST(eta AS UNSIGNED)
        END AS eta,
        genere,
        citta,
        CASE
            WHEN LOWER(tessera_fedelta) IN ('si', 'sì', 'true', '1', 'yes') THEN 1
            WHEN LOWER(tessera_fedelta) IN ('no', 'false', '0') THEN 0
            ELSE NULL
        END AS tessera_fedelta,
        source_file
    FROM raw_clienti
    WHERE id_cliente IS NOT NULL
      AND id_cliente <> ''
)
SELECT
    id_cliente,
    eta,
    genere,
    citta,
    tessera_fedelta,
    source_file
FROM clean_clienti;

-- CTE farmacie: converte gli identificativi e le coordinate in tipi numerici.
INSERT INTO silver_farmacie (
    id_farmacia,
    nome,
    citta,
    provincia,
    latitudine,
    longitudine,
    source_file
)
WITH raw_farmacie AS (
    SELECT
        id_farmacia,
        nome,
        citta,
        provincia,
        latitudine,
        longitudine,
        source_file
    FROM bronze_farmacie_raw
),
clean_farmacie AS (
    SELECT
        CASE
            WHEN id_farmacia IS NULL OR id_farmacia = '' THEN NULL
            ELSE CAST(id_farmacia AS UNSIGNED)
        END AS id_farmacia,
        nome,
        citta,
        provincia,
        CASE
            WHEN latitudine IS NULL OR latitudine = '' THEN NULL
            ELSE CAST(latitudine AS DECIMAL(9, 6))
        END AS latitudine,
        CASE
            WHEN longitudine IS NULL OR longitudine = '' THEN NULL
            ELSE CAST(longitudine AS DECIMAL(9, 6))
        END AS longitudine,
        source_file
    FROM raw_farmacie
    WHERE id_farmacia IS NOT NULL
      AND id_farmacia <> ''
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

-- CTE prodotti: pulisce gli ID e trasforma i prezzi non validi in NULL.
INSERT INTO silver_prodotti (
    id_prodotto,
    nome,
    categoria,
    fornitore,
    prezzo_acquisto,
    prezzo_vendita,
    source_file
)
WITH raw_prodotti AS (
    SELECT
        id_prodotto,
        nome,
        categoria,
        fornitore,
        prezzo_acquisto,
        prezzo_vendita,
        source_file
    FROM bronze_prodotti_raw
),
clean_prodotti AS (
    SELECT
        CASE
            WHEN id_prodotto IS NULL OR id_prodotto = '' THEN NULL
            ELSE CAST(id_prodotto AS UNSIGNED)
        END AS id_prodotto,
        nome,
        categoria,
        fornitore,
        CASE
            WHEN prezzo_acquisto IS NULL OR prezzo_acquisto = '' THEN NULL
            WHEN CAST(prezzo_acquisto AS DECIMAL(10, 2)) < 0 THEN NULL
            ELSE CAST(prezzo_acquisto AS DECIMAL(10, 2))
        END AS prezzo_acquisto,
        CASE
            WHEN prezzo_vendita IS NULL OR prezzo_vendita = '' THEN NULL
            WHEN CAST(prezzo_vendita AS DECIMAL(10, 2)) < 0 THEN NULL
            ELSE CAST(prezzo_vendita AS DECIMAL(10, 2))
        END AS prezzo_vendita,
        source_file
    FROM raw_prodotti
    WHERE id_prodotto IS NOT NULL
      AND id_prodotto <> ''
)
SELECT
    id_prodotto,
    nome,
    categoria,
    fornitore,
    prezzo_acquisto,
    prezzo_vendita,
    source_file
FROM clean_prodotti;

-- CTE vendite: riconosce i formati data e converte chiavi e misure.
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
WITH raw_vendite AS (
    SELECT
        id_vendita,
        data_vendita_raw,
        id_prodotto,
        id_farmacia,
        quantita,
        prezzo_unitario,
        id_cliente,
        source_file
    FROM bronze_vendite_raw
),
clean_vendite AS (
    SELECT
        CASE
            WHEN id_vendita IS NULL OR id_vendita = '' THEN NULL
            ELSE CAST(id_vendita AS UNSIGNED)
        END AS id_vendita,
        CASE
            WHEN data_vendita_raw IS NULL OR data_vendita_raw = '' THEN NULL
            WHEN data_vendita_raw LIKE '____-__-__' THEN STR_TO_DATE(data_vendita_raw, '%Y-%m-%d')
            WHEN data_vendita_raw LIKE '__-__-____' THEN STR_TO_DATE(data_vendita_raw, '%d-%m-%Y')
            WHEN data_vendita_raw LIKE '__/__/____' THEN STR_TO_DATE(data_vendita_raw, '%d/%m/%Y')
            ELSE NULL
        END AS data_vendita,
        CASE
            WHEN id_prodotto IS NULL OR id_prodotto = '' THEN NULL
            ELSE CAST(id_prodotto AS UNSIGNED)
        END AS id_prodotto,
        CASE
            WHEN id_farmacia IS NULL OR id_farmacia = '' THEN NULL
            ELSE CAST(id_farmacia AS UNSIGNED)
        END AS id_farmacia,
        CASE
            WHEN quantita IS NULL OR quantita = '' THEN NULL
            ELSE CAST(quantita AS UNSIGNED)
        END AS quantita,
        CASE
            WHEN prezzo_unitario IS NULL OR prezzo_unitario = '' THEN NULL
            ELSE CAST(prezzo_unitario AS DECIMAL(10, 2))
        END AS prezzo_unitario,
        CASE
            WHEN id_cliente IS NULL OR id_cliente = '' THEN NULL
            ELSE CAST(id_cliente AS UNSIGNED)
        END AS id_cliente,
        source_file
    FROM raw_vendite
    WHERE id_vendita IS NOT NULL
      AND id_vendita <> ''
)
SELECT
    id_vendita,
    data_vendita,
    id_prodotto,
    id_farmacia,
    quantita,
    prezzo_unitario,
    id_cliente,
    source_file
FROM clean_vendite;

-- CTE fornitori_storico: estrae i campi dal JSON bronze in forma relazionale.
INSERT INTO silver_fornitori_storico (
    fornitore,
    anno,
    mese,
    ordini_effettuati,
    consegne_in_ritardo,
    giorni_medi_ritardo,
    source_file
)
WITH raw_fornitori_storico AS (
    SELECT
        record_data,
        source_file
    FROM bronze_fornitori_storico_raw
),
clean_fornitori_storico AS (
    SELECT
        JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.fornitore')) AS fornitore,
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.anno')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.anno')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.anno')) AS UNSIGNED)
        END AS anno,
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.mese')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.mese')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.mese')) AS UNSIGNED)
        END AS mese,
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.ordini_effettuati')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.ordini_effettuati')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.ordini_effettuati')) AS UNSIGNED)
        END AS ordini_effettuati,
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.consegne_in_ritardo')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.consegne_in_ritardo')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.consegne_in_ritardo')) AS UNSIGNED)
        END AS consegne_in_ritardo,
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.giorni_medi_ritardo')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.giorni_medi_ritardo')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.giorni_medi_ritardo')) AS DECIMAL(10, 2))
        END AS giorni_medi_ritardo,
        source_file
    FROM raw_fornitori_storico
)
SELECT
    fornitore,
    anno,
    mese,
    ordini_effettuati,
    consegne_in_ritardo,
    giorni_medi_ritardo,
    source_file
FROM clean_fornitori_storico;

-- CTE prodotti_extra: estrae gli attributi principali del prodotto dal JSON.
INSERT INTO silver_prodotti_extra (
    id_prodotto,
    descrizione,
    principio_attivo,
    source_file
)
WITH raw_prodotti_extra AS (
    SELECT
        record_data,
        source_file
    FROM bronze_prodotti_extra_raw
),
clean_prodotti_extra AS (
    SELECT
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.id_prodotto')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.id_prodotto')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.id_prodotto')) AS UNSIGNED)
        END AS id_prodotto,
        JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.descrizione')) AS descrizione,
        JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.principio_attivo')) AS principio_attivo,
        source_file
    FROM raw_prodotti_extra
)
SELECT
    id_prodotto,
    descrizione,
    principio_attivo,
    source_file
FROM clean_prodotti_extra;

-- CTE prodotto_tags: esplode l'array tags in una tabella relazionale.
INSERT INTO silver_prodotto_tags (
    id_prodotto,
    tag,
    source_file
)
WITH raw_prodotto_tags AS (
    SELECT
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS UNSIGNED)
        END AS id_prodotto,
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
    id_prodotto,
    tag,
    source_file
FROM raw_prodotto_tags;

-- CTE prodotto_controindicazioni: esplode l'array controindicazioni in righe.
INSERT INTO silver_prodotto_controindicazioni (
    id_prodotto,
    controindicazione,
    source_file
)
WITH raw_prodotto_controindicazioni AS (
    SELECT
        CASE
            WHEN JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) IS NULL
              OR JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) = '' THEN NULL
            ELSE CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS UNSIGNED)
        END AS id_prodotto,
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
    id_prodotto,
    controindicazione,
    source_file
FROM raw_prodotto_controindicazioni;
