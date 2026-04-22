import csv
import json
from pathlib import Path

import pymysql

base_dir = Path(__file__).resolve().parents[2]
datasets_dir = base_dir / "Datasets"

connection = pymysql.connect(
    host="127.0.0.1",
    port=3306,
    user="root",
    password="root_password",
    database="sac",
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

with open(datasets_dir / "clienti.csv", encoding="utf-8-sig", newline="") as file:
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
                "clienti.csv",
            ),
        )

with open(datasets_dir / "farmacie.csv", encoding="utf-8-sig", newline="") as file:
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
                "farmacie.csv",
            ),
        )

with open(datasets_dir / "prodotti.csv", encoding="utf-8-sig", newline="") as file:
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
                "prodotti.csv",
            ),
        )

with open(datasets_dir / "vendite.csv", encoding="utf-8-sig", newline="") as file:
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
                "vendite.csv",
            ),
        )

with open(datasets_dir / "fornitori_storico.json", encoding="utf-8") as file:
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

with open(datasets_dir / "prodotti_extra.json", encoding="utf-8") as file:
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
