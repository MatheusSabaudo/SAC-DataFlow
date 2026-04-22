from pathlib import Path

import pymysql


sql_path = Path(__file__).with_name("clean_silver.sql")
sql_text = sql_path.read_text(encoding="utf-8")

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

for query in sql_text.split(";"):
    query = query.strip()
    if query:
        cursor.execute(query)

cursor.close()
connection.close()

print("Silver completato.")
