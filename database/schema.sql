CREATE DATABASE IF NOT EXISTS sac
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sac;

CREATE TABLE IF NOT EXISTS bronze_clienti_raw (
    ingest_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_cliente VARCHAR(64),
    eta VARCHAR(64),
    genere VARCHAR(32),
    citta VARCHAR(255),
    tessera_fedelta VARCHAR(32),
    source_file VARCHAR(255) NOT NULL DEFAULT 'clienti.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_farmacie_raw (
    ingest_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_farmacia VARCHAR(64),
    nome VARCHAR(255),
    citta VARCHAR(255),
    provincia VARCHAR(64),
    latitudine VARCHAR(64),
    longitudine VARCHAR(64),
    source_file VARCHAR(255) NOT NULL DEFAULT 'farmacie.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_prodotti_raw (
    ingest_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_prodotto VARCHAR(64),
    nome VARCHAR(255),
    categoria VARCHAR(255),
    fornitore VARCHAR(255),
    prezzo_acquisto VARCHAR(64),
    prezzo_vendita VARCHAR(64),
    source_file VARCHAR(255) NOT NULL DEFAULT 'prodotti.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_vendite_raw (
    ingest_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_vendita VARCHAR(64),
    data_vendita_raw VARCHAR(64),
    id_prodotto VARCHAR(64),
    id_farmacia VARCHAR(64),
    quantita VARCHAR(64),
    prezzo_unitario VARCHAR(64),
    id_cliente VARCHAR(64),
    source_file VARCHAR(255) NOT NULL DEFAULT 'vendite.csv',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_fornitori_storico_raw (
    ingest_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    record_data JSON NOT NULL,
    source_file VARCHAR(255) NOT NULL DEFAULT 'fornitori_storico.json',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_prodotti_extra_raw (
    ingest_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    record_data JSON NOT NULL,
    source_file VARCHAR(255) NOT NULL DEFAULT 'prodotti_extra.json',
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_fornitori (
    nome VARCHAR(255) PRIMARY KEY,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver_clienti (
    id_cliente INT UNSIGNED PRIMARY KEY,
    eta TINYINT UNSIGNED NOT NULL,
    genere ENUM('F', 'M') NOT NULL,
    citta VARCHAR(255) NOT NULL,
    tessera_fedelta BOOLEAN NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (eta BETWEEN 0 AND 120)
);

CREATE TABLE IF NOT EXISTS silver_farmacie (
    id_farmacia INT UNSIGNED PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    citta VARCHAR(255) NOT NULL,
    provincia CHAR(2) NOT NULL,
    latitudine DECIMAL(9, 6) NOT NULL,
    longitudine DECIMAL(9, 6) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_silver_farmacie_nome (nome),
    CHECK (latitudine BETWEEN -90 AND 90),
    CHECK (longitudine BETWEEN -180 AND 180)
);

CREATE TABLE IF NOT EXISTS silver_prodotti (
    id_prodotto INT UNSIGNED PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    categoria VARCHAR(255) NOT NULL,
    fornitore VARCHAR(255) NOT NULL,
    prezzo_acquisto DECIMAL(10, 2) NOT NULL,
    prezzo_vendita DECIMAL(10, 2) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_silver_prodotti_fornitore
        FOREIGN KEY (fornitore) REFERENCES silver_fornitori (nome),
    CHECK (prezzo_acquisto >= 0),
    CHECK (prezzo_vendita >= 0),
    CHECK (prezzo_vendita >= prezzo_acquisto)
);

CREATE TABLE IF NOT EXISTS silver_vendite (
    id_vendita INT UNSIGNED PRIMARY KEY,
    data_vendita DATE NOT NULL,
    id_prodotto INT UNSIGNED NOT NULL,
    id_farmacia INT UNSIGNED NOT NULL,
    quantita INT UNSIGNED NOT NULL,
    prezzo_unitario DECIMAL(10, 2) NOT NULL,
    id_cliente INT UNSIGNED NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_silver_vendite_prodotto
        FOREIGN KEY (id_prodotto) REFERENCES silver_prodotti (id_prodotto),
    CONSTRAINT fk_silver_vendite_farmacia
        FOREIGN KEY (id_farmacia) REFERENCES silver_farmacie (id_farmacia),
    CONSTRAINT fk_silver_vendite_cliente
        FOREIGN KEY (id_cliente) REFERENCES silver_clienti (id_cliente),
    KEY idx_silver_vendite_data (data_vendita),
    KEY idx_silver_vendite_farmacia (id_farmacia),
    KEY idx_silver_vendite_prodotto (id_prodotto),
    CHECK (quantita > 0),
    CHECK (prezzo_unitario >= 0)
);

CREATE TABLE IF NOT EXISTS silver_fornitori_storico (
    fornitore VARCHAR(255) NOT NULL,
    anno SMALLINT UNSIGNED NOT NULL,
    mese TINYINT UNSIGNED NOT NULL,
    ordini_effettuati INT UNSIGNED NOT NULL,
    consegne_in_ritardo INT UNSIGNED NOT NULL,
    giorni_medi_ritardo DECIMAL(10, 2) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (fornitore, anno, mese),
    CONSTRAINT fk_silver_fornitori_storico_fornitore
        FOREIGN KEY (fornitore) REFERENCES silver_fornitori (nome),
    CHECK (mese BETWEEN 1 AND 12),
    CHECK (giorni_medi_ritardo >= 0)
);

CREATE TABLE IF NOT EXISTS silver_prodotti_extra (
    id_prodotto INT UNSIGNED PRIMARY KEY,
    descrizione TEXT NOT NULL,
    principio_attivo VARCHAR(255) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_silver_prodotti_extra_prodotto
        FOREIGN KEY (id_prodotto) REFERENCES silver_prodotti (id_prodotto)
);

CREATE TABLE IF NOT EXISTS silver_prodotto_tags (
    id_prodotto INT UNSIGNED NOT NULL,
    tag VARCHAR(255) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_prodotto, tag),
    CONSTRAINT fk_silver_prodotto_tags_prodotto
        FOREIGN KEY (id_prodotto) REFERENCES silver_prodotti (id_prodotto)
);

CREATE TABLE IF NOT EXISTS silver_prodotto_controindicazioni (
    id_prodotto INT UNSIGNED NOT NULL,
    controindicazione VARCHAR(255) NOT NULL,
    source_file VARCHAR(255) NOT NULL,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_prodotto, controindicazione),
    CONSTRAINT fk_silver_prodotto_controindicazioni_prodotto
        FOREIGN KEY (id_prodotto) REFERENCES silver_prodotti (id_prodotto)
);

CREATE TABLE IF NOT EXISTS gold_vendite_farmacia_giornaliere (
    data_vendita DATE NOT NULL,
    id_farmacia INT UNSIGNED NOT NULL,
    totale_scontrini INT UNSIGNED NOT NULL,
    totale_pezzi INT UNSIGNED NOT NULL,
    ricavi DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (data_vendita, id_farmacia),
    CONSTRAINT fk_gold_vendite_farmacia_giornaliere_farmacia
        FOREIGN KEY (id_farmacia) REFERENCES silver_farmacie (id_farmacia),
    CHECK (totale_scontrini >= 0),
    CHECK (totale_pezzi >= 0),
    CHECK (ricavi >= 0)
);
