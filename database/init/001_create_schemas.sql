CREATE DATABASE IF NOT EXISTS sac;
USE sac;

CREATE TABLE IF NOT EXISTS bronze_clienti_raw (
    ingest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_row_number INT NOT NULL,
    id_cliente VARCHAR(64),
    eta VARCHAR(64),
    genere VARCHAR(32),
    citta VARCHAR(255),
    tessera_fedelta VARCHAR(32),
    raw_record JSON,
    source_file VARCHAR(255) NOT NULL DEFAULT 'clienti.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_farmacie_raw (
    ingest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_row_number INT NOT NULL,
    id_farmacia VARCHAR(64),
    nome VARCHAR(255),
    citta VARCHAR(255),
    provincia VARCHAR(64),
    latitudine VARCHAR(64),
    longitudine VARCHAR(64),
    raw_record JSON,
    source_file VARCHAR(255) NOT NULL DEFAULT 'farmacie.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_prodotti_raw (
    ingest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_row_number INT NOT NULL,
    id_prodotto VARCHAR(64),
    nome VARCHAR(255),
    categoria VARCHAR(255),
    fornitore VARCHAR(255),
    prezzo_acquisto VARCHAR(64),
    prezzo_vendita VARCHAR(64),
    raw_record JSON,
    source_file VARCHAR(255) NOT NULL DEFAULT 'prodotti.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_vendite_raw (
    ingest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_row_number INT NOT NULL,
    id_vendita VARCHAR(64),
    data_vendita_raw VARCHAR(64),
    id_prodotto VARCHAR(64),
    id_farmacia VARCHAR(64),
    quantita VARCHAR(64),
    prezzo_unitario VARCHAR(64),
    id_cliente VARCHAR(64),
    raw_record JSON,
    source_file VARCHAR(255) NOT NULL DEFAULT 'vendite.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_fornitori_storico_raw (
    ingest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_record_number INT NOT NULL,
    record_data JSON NOT NULL,
    source_file VARCHAR(255) NOT NULL DEFAULT 'fornitori_storico.json',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_prodotti_extra_raw (
    ingest_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_record_number INT NOT NULL,
    record_data JSON NOT NULL,
    source_file VARCHAR(255) NOT NULL DEFAULT 'prodotti_extra.json',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_clienti (
    id_cliente INTEGER PRIMARY KEY,
    eta INTEGER,
    genere VARCHAR(32),
    citta VARCHAR(255),
    tessera_fedelta BOOLEAN,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_farmacie (
    id_farmacia INTEGER PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    citta VARCHAR(255),
    provincia VARCHAR(64),
    latitudine DECIMAL(9, 6),
    longitudine DECIMAL(9, 6),
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_prodotti (
    id_prodotto INTEGER PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    categoria VARCHAR(255),
    fornitore VARCHAR(255),
    prezzo_acquisto DECIMAL(10, 2),
    prezzo_vendita DECIMAL(10, 2),
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_vendite (
    id_vendita INTEGER PRIMARY KEY,
    data_vendita DATE,
    id_prodotto INTEGER,
    id_farmacia INTEGER,
    quantita INTEGER,
    prezzo_unitario DECIMAL(10, 2),
    id_cliente INTEGER,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_fornitori_storico (
    fornitore VARCHAR(255) NOT NULL,
    anno INTEGER NOT NULL,
    mese INTEGER NOT NULL,
    ordini_effettuati INTEGER,
    consegne_in_ritardo INTEGER,
    giorni_medi_ritardo DECIMAL(10, 2),
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fornitore, anno, mese)
);

CREATE TABLE IF NOT EXISTS silver_prodotti_extra (
    id_prodotto INTEGER PRIMARY KEY,
    descrizione TEXT,
    principio_attivo VARCHAR(255),
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_prodotto_tags (
    id_prodotto INTEGER NOT NULL,
    tag VARCHAR(255) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_prodotto, tag)
);

CREATE TABLE IF NOT EXISTS silver_prodotto_controindicazioni (
    id_prodotto INTEGER NOT NULL,
    controindicazione VARCHAR(255) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_prodotto, controindicazione)
);

CREATE TABLE IF NOT EXISTS gold_vendite_farmacia_giornaliere (
    data_vendita DATE NOT NULL,
    id_farmacia INTEGER NOT NULL,
    totale_scontrini INTEGER,
    totale_pezzi INTEGER,
    ricavi DECIMAL(12, 2),
    PRIMARY KEY (data_vendita, id_farmacia)
);
