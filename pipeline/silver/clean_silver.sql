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
SELECT
    CAST(TRIM(id_cliente) AS SIGNED),
    CAST(TRIM(eta) AS SIGNED),
    UPPER(TRIM(genere)),
    TRIM(citta),
    LOWER(TRIM(tessera_fedelta)) IN ('si', 'sì', 'true', '1', 'yes'),
    source_file
FROM bronze_clienti_raw
WHERE TRIM(id_cliente) <> ''
  AND TRIM(eta) <> ''
  AND TRIM(genere) <> ''
  AND TRIM(citta) <> '';

INSERT INTO silver_farmacie (
    id_farmacia,
    nome,
    citta,
    provincia,
    latitudine,
    longitudine,
    source_file
)
SELECT
    CAST(TRIM(id_farmacia) AS SIGNED),
    TRIM(nome),
    TRIM(citta),
    UPPER(TRIM(provincia)),
    CAST(TRIM(latitudine) AS DECIMAL(9, 6)),
    CAST(TRIM(longitudine) AS DECIMAL(9, 6)),
    source_file
FROM bronze_farmacie_raw
WHERE TRIM(id_farmacia) <> ''
  AND TRIM(nome) <> ''
  AND TRIM(citta) <> ''
  AND TRIM(provincia) <> '';

INSERT INTO silver_fornitori (nome)
SELECT DISTINCT nome
FROM (
    SELECT TRIM(fornitore) AS nome
    FROM bronze_prodotti_raw
    WHERE TRIM(fornitore) <> ''

    UNION

    SELECT TRIM(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.fornitore'))) AS nome
    FROM bronze_fornitori_storico_raw
    WHERE TRIM(JSON_UNQUOTE(JSON_EXTRACT(record_data, '$.fornitore'))) <> ''
) AS fornitori;

INSERT INTO silver_prodotti (
    id_prodotto,
    nome,
    categoria,
    fornitore,
    prezzo_acquisto,
    prezzo_vendita,
    source_file
)
SELECT
    CAST(TRIM(p.id_prodotto) AS SIGNED),
    TRIM(p.nome),
    TRIM(p.categoria),
    TRIM(p.fornitore),
    CAST(TRIM(p.prezzo_acquisto) AS DECIMAL(10, 2)),
    CAST(TRIM(p.prezzo_vendita) AS DECIMAL(10, 2)),
    p.source_file
FROM bronze_prodotti_raw p
INNER JOIN silver_fornitori f
    ON f.nome = TRIM(p.fornitore)
WHERE TRIM(p.id_prodotto) <> ''
  AND TRIM(p.nome) <> ''
  AND TRIM(p.categoria) <> ''
  AND TRIM(p.fornitore) <> ''
  AND TRIM(p.prezzo_acquisto) <> ''
  AND TRIM(p.prezzo_vendita) <> '';

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
SELECT
    v.id_vendita,
    v.data_vendita,
    v.id_prodotto,
    v.id_farmacia,
    v.quantita,
    v.prezzo_unitario,
    v.id_cliente,
    v.source_file
FROM (
    SELECT
        CAST(TRIM(id_vendita) AS SIGNED) AS id_vendita,
        CASE
            WHEN data_vendita_raw LIKE '____-__-__' THEN STR_TO_DATE(data_vendita_raw, '%Y-%m-%d')
            WHEN data_vendita_raw LIKE '__/__/____' THEN STR_TO_DATE(data_vendita_raw, '%d/%m/%Y')
            WHEN data_vendita_raw LIKE '__-__-____' THEN STR_TO_DATE(data_vendita_raw, '%d-%m-%Y')
        END AS data_vendita,
        CAST(TRIM(id_prodotto) AS SIGNED) AS id_prodotto,
        CAST(TRIM(id_farmacia) AS SIGNED) AS id_farmacia,
        CAST(TRIM(quantita) AS SIGNED) AS quantita,
        CAST(TRIM(prezzo_unitario) AS DECIMAL(10, 2)) AS prezzo_unitario,
        CAST(TRIM(id_cliente) AS SIGNED) AS id_cliente,
        source_file
    FROM bronze_vendite_raw
    WHERE TRIM(id_vendita) <> ''
      AND TRIM(id_prodotto) <> ''
      AND TRIM(id_farmacia) <> ''
      AND TRIM(quantita) <> ''
      AND TRIM(prezzo_unitario) <> ''
      AND TRIM(id_cliente) <> ''
) v
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
SELECT
    TRIM(JSON_UNQUOTE(JSON_EXTRACT(fs.record_data, '$.fornitore'))),
    CAST(JSON_UNQUOTE(JSON_EXTRACT(fs.record_data, '$.anno')) AS SIGNED),
    CAST(JSON_UNQUOTE(JSON_EXTRACT(fs.record_data, '$.mese')) AS SIGNED),
    CAST(JSON_UNQUOTE(JSON_EXTRACT(fs.record_data, '$.ordini_effettuati')) AS SIGNED),
    CAST(JSON_UNQUOTE(JSON_EXTRACT(fs.record_data, '$.consegne_in_ritardo')) AS SIGNED),
    CAST(JSON_UNQUOTE(JSON_EXTRACT(fs.record_data, '$.giorni_medi_ritardo')) AS DECIMAL(10, 2)),
    fs.source_file
FROM bronze_fornitori_storico_raw fs
INNER JOIN silver_fornitori f
    ON f.nome = TRIM(JSON_UNQUOTE(JSON_EXTRACT(fs.record_data, '$.fornitore')));

INSERT INTO silver_prodotti_extra (
    id_prodotto,
    descrizione,
    principio_attivo,
    source_file
)
SELECT
    CAST(JSON_UNQUOTE(JSON_EXTRACT(pe.record_data, '$.id_prodotto')) AS SIGNED),
    JSON_UNQUOTE(JSON_EXTRACT(pe.record_data, '$.descrizione')),
    JSON_UNQUOTE(JSON_EXTRACT(pe.record_data, '$.principio_attivo')),
    pe.source_file
FROM bronze_prodotti_extra_raw pe
INNER JOIN silver_prodotti p
    ON p.id_prodotto = CAST(JSON_UNQUOTE(JSON_EXTRACT(pe.record_data, '$.id_prodotto')) AS SIGNED);

INSERT INTO silver_prodotto_tags (
    id_prodotto,
    tag,
    source_file
)
SELECT
    CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS SIGNED),
    jt.tag,
    b.source_file
FROM bronze_prodotti_extra_raw b
CROSS JOIN JSON_TABLE(
    b.record_data,
    '$.tags[*]' COLUMNS (
        tag VARCHAR(255) PATH '$'
    )
) AS jt
INNER JOIN silver_prodotti p
    ON p.id_prodotto = CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS SIGNED);

INSERT INTO silver_prodotto_controindicazioni (
    id_prodotto,
    controindicazione,
    source_file
)
SELECT
    CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS SIGNED),
    jt.controindicazione,
    b.source_file
FROM bronze_prodotti_extra_raw b
CROSS JOIN JSON_TABLE(
    b.record_data,
    '$.controindicazioni[*]' COLUMNS (
        controindicazione VARCHAR(255) PATH '$'
    )
) AS jt
INNER JOIN silver_prodotti p
    ON p.id_prodotto = CAST(JSON_UNQUOTE(JSON_EXTRACT(b.record_data, '$.id_prodotto')) AS SIGNED);
