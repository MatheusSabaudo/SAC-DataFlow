# G2 - Tabella problemi dati

| # | File | Colonna | Problema | Soluzione | Record coinvolti |
| --- | --- | --- | --- | --- | --- |
| 1 | vendite.csv | data | Date presenti in piu formati. | Convertite tutte nel formato ISO YYYY-MM-DD. | 780 righe normalizzate |
| 2 | vendite.csv | prezzo_unitario | Prezzo unitario mancante. | Riempito con il prezzo_vendita del catalogo prodotto gia pulito. | 36 righe: 45, 80, 81, 121, 153, 192, 208, 215, 254, 291... |
| 3 | prodotti.csv | prezzo_vendita | Prezzo di vendita negativo. | Sostituito con la media dei prezzi di vendita osservati nelle vendite dello stesso prodotto. | id_prodotto=5 |
| 4 | prodotti.csv | prezzo_acquisto, prezzo_vendita | Prezzi mancanti nel catalogo prodotto. | Prezzo acquisto imputato con la mediana del fornitore; prezzo vendita imputato con la media delle vendite dello stesso prodotto. | id_prodotto=13 |
