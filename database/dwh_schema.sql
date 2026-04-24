CREATE DATABASE IF NOT EXISTS medistore_dwh;

USE medistore_dwh;

CREATE TABLE IF NOT EXISTS dim_tempo (
    id_tempo INT PRIMARY KEY AUTO_INCREMENT,
    data DATE NOT NULL UNIQUE,
    giorno TINYINT UNSIGNED NOT NULL,
    mese TINYINT UNSIGNED NOT NULL,
    nome_mese VARCHAR(20) NOT NULL,
    trimestre TINYINT UNSIGNED NOT NULL,
    anno YEAR NOT NULL,
    giorno_settimana VARCHAR(15) NOT NULL,
    e_weekend BOOLEAN NOT NULL,
    CHECK (giorno BETWEEN 1 AND 31),
    CHECK (mese BETWEEN 1 AND 12),
    CHECK (trimestre BETWEEN 1 AND 4)
);

CREATE TABLE IF NOT EXISTS dim_prodotto (
    id_prodotto INT UNSIGNED PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    categoria VARCHAR(255) NOT NULL,
    fornitore VARCHAR(255) NOT NULL,
    prezzo_acquisto DECIMAL(10, 2) NOT NULL,
    prezzo_vendita DECIMAL(10, 2) NOT NULL,
    margine_unitario DECIMAL(10, 2) NOT NULL,
    principio_attivo VARCHAR(255),
    descrizione TEXT,
    ordini_fornitore INT UNSIGNED,
    pct_consegne_ritardo DECIMAL(5, 2),
    giorni_medi_ritardo_fornitore DECIMAL(10, 2),
    CHECK (prezzo_acquisto >= 0),
    CHECK (prezzo_vendita >= 0),
    CHECK (margine_unitario >= 0)
);

CREATE TABLE IF NOT EXISTS dim_farmacia (
    id_farmacia INT UNSIGNED PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    citta VARCHAR(255) NOT NULL,
    provincia CHAR(2) NOT NULL,
    latitudine DECIMAL(9, 6) NOT NULL,
    longitudine DECIMAL(9, 6) NOT NULL,
    CHECK (latitudine BETWEEN -90 AND 90),
    CHECK (longitudine BETWEEN -180 AND 180)
);

CREATE TABLE IF NOT EXISTS dim_cliente (
    id_cliente INT UNSIGNED PRIMARY KEY,
    eta TINYINT UNSIGNED NOT NULL,
    fascia_eta VARCHAR(20) NOT NULL,
    genere CHAR(1) NOT NULL,
    citta VARCHAR(255) NOT NULL,
    tessera_fedelta BOOLEAN NOT NULL,
    CHECK (eta BETWEEN 0 AND 120),
    CHECK (genere IN ('F', 'M'))
);

CREATE TABLE IF NOT EXISTS fatto_vendite (
    id_fatto INT PRIMARY KEY AUTO_INCREMENT,
    id_tempo INT NOT NULL,
    id_prodotto INT UNSIGNED NOT NULL,
    id_farmacia INT UNSIGNED NOT NULL,
    id_cliente INT UNSIGNED NOT NULL,
    quantita INT UNSIGNED NOT NULL,
    prezzo_unitario DECIMAL(10, 2) NOT NULL,
    fatturato DECIMAL(10, 2) NOT NULL,
    margine DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_tempo) REFERENCES dim_tempo (id_tempo),
    FOREIGN KEY (id_prodotto) REFERENCES dim_prodotto (id_prodotto),
    FOREIGN KEY (id_farmacia) REFERENCES dim_farmacia (id_farmacia),
    FOREIGN KEY (id_cliente) REFERENCES dim_cliente (id_cliente),
    KEY idx_fatto_vendite_tempo (id_tempo),
    KEY idx_fatto_vendite_prodotto (id_prodotto),
    KEY idx_fatto_vendite_farmacia (id_farmacia),
    KEY idx_fatto_vendite_cliente (id_cliente),
    CHECK (quantita > 0),
    CHECK (prezzo_unitario >= 0),
    CHECK (fatturato >= 0)
);
