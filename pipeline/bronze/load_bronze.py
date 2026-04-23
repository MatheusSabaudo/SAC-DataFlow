import csv
import json
import os
from pathlib import Path

import pymysql


def resolve_dataset_dir(base_dir):
    for folder_name in ("dataset", "Datasets"):
        candidate = base_dir / folder_name
        if candidate.exists():
            return candidate
    return base_dir / "dataset"


def preferred_csv_path(dataset_dir, raw_name):
    clean_name = raw_name.replace(".csv", "_clean.csv")
    clean_path = dataset_dir / clean_name
    if clean_path.exists():
        return clean_path, clean_name
    return dataset_dir / raw_name, raw_name


BASE_DIR = Path(__file__).resolve().parents[2]
DATASET_DIR = resolve_dataset_dir(BASE_DIR)

connection = pymysql.connect(
    host=os.getenv("MYSQL_HOST", "127.0.0.1"),
    port=int(os.getenv("MYSQL_PORT", "3306")),
    user=os.getenv("MYSQL_USER", "root"),
    password=os.getenv("MYSQL_PASSWORD", "root_password"),
    database=os.getenv("MYSQL_DATABASE", "sac"),
    charset="utf8mb4",
    autocommit=True,
)

cursor = connection.cursor()

cursor.execute("TRUNCATE TABLE bronze_clienti_raw")
cursor.execute("TRUNCATE TABLE bronze_farmacie_raw")
cursor.execute("TRUNCATE TABLE bronze_prodotti_raw")
cursor.execute("TRUNCATE TABLE bronze_vendite_raw")
cursor.execute("TRUNCATE TABLE bronze_fornitori_storico_raw")
cursor.execute("TRUNCATE TABLE bronze_prodotti_extra_raw")

clienti_path, clienti_source = preferred_csv_path(DATASET_DIR, "clienti.csv")
with clienti_path.open(encoding="utf-8-sig", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        cursor.execute(
            """
            INSERT INTO bronze_clienti_raw
            (id_cliente, eta, genere, citta, tessera_fedelta, source_file)
            VALUES (%s, %s, %s, %s, %s, %s)
            """,
            (
                row["id_cliente"] or None,
                row["età"] or None,
                row["genere"] or None,
                row["città"] or None,
                row["tessera_fedeltà"] or None,
                clienti_source,
            ),
        )

farmacie_path, farmacie_source = preferred_csv_path(DATASET_DIR, "farmacie.csv")
with farmacie_path.open(encoding="utf-8-sig", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        cursor.execute(
            """
            INSERT INTO bronze_farmacie_raw
            (id_farmacia, nome, citta, provincia, latitudine, longitudine, source_file)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                row["id_farmacia"] or None,
                row["nome"] or None,
                row["città"] or None,
                row["provincia"] or None,
                row["latitudine"] or None,
                row["longitudine"] or None,
                farmacie_source,
            ),
        )

prodotti_path, prodotti_source = preferred_csv_path(DATASET_DIR, "prodotti.csv")
with prodotti_path.open(encoding="utf-8-sig", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        cursor.execute(
            """
            INSERT INTO bronze_prodotti_raw
            (id_prodotto, nome, categoria, fornitore, prezzo_acquisto, prezzo_vendita, source_file)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (
                row["id_prodotto"] or None,
                row["nome"] or None,
                row["categoria"] or None,
                row["fornitore"] or None,
                row["prezzo_acquisto"] or None,
                row["prezzo_vendita"] or None,
                prodotti_source,
            ),
        )

vendite_path, vendite_source = preferred_csv_path(DATASET_DIR, "vendite.csv")
with vendite_path.open(encoding="utf-8-sig", newline="") as file:
    reader = csv.DictReader(file)
    for row in reader:
        cursor.execute(
            """
            INSERT INTO bronze_vendite_raw
            (id_vendita, data_vendita_raw, id_prodotto, id_farmacia, quantita, prezzo_unitario, id_cliente, source_file)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                row["id_vendita"] or None,
                row["data"] or None,
                row["id_prodotto"] or None,
                row["id_farmacia"] or None,
                row["quantità"] or None,
                row["prezzo_unitario"] or None,
                row["id_cliente"] or None,
                vendite_source,
            ),
        )

with (DATASET_DIR / "fornitori_storico.json").open(encoding="utf-8") as file:
    data = json.load(file)
    for row in data:
        cursor.execute(
            """
            INSERT INTO bronze_fornitori_storico_raw
            (record_data, source_file)
            VALUES (%s, %s)
            """,
            (json.dumps(row, ensure_ascii=False), "fornitori_storico.json"),
        )

with (DATASET_DIR / "prodotti_extra.json").open(encoding="utf-8") as file:
    data = json.load(file)
    for row in data:
        cursor.execute(
            """
            INSERT INTO bronze_prodotti_extra_raw
            (record_data, source_file)
            VALUES (%s, %s)
            """,
            (json.dumps(row, ensure_ascii=False), "prodotti_extra.json"),
        )

cursor.close()
connection.close()

print("Bronze load completato.")
