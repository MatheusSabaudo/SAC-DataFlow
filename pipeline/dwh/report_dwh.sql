SELECT '=== ETL PIPELINE REPORT ===' AS report
UNION ALL
SELECT CONCAT(
    'Record letti: ',
    (SELECT COUNT(*) FROM sac.bronze_vendite_raw)
)
UNION ALL
SELECT CONCAT(
    'Record scartati: ',
    (SELECT COUNT(*) FROM sac.bronze_vendite_raw)
    - (SELECT COUNT(*) FROM medistore_dwh.fatto_vendite)
)
UNION ALL
SELECT CONCAT(
    'Record duplicati: ',
    (
        SELECT COUNT(*) - COUNT(DISTINCT TRIM(id_vendita))
        FROM sac.bronze_vendite_raw
    )
)
UNION ALL
SELECT CONCAT(
    'Record caricati nel DWH: ',
    (SELECT COUNT(*) FROM medistore_dwh.fatto_vendite)
)
UNION ALL
SELECT '===========================';
