// M1: Tutti i prodotti che hanno "gravidanza" tra le controindicazioni.
db.prodotti_extended.find(
  { controindicazioni: "gravidanza" },
  { _id: 0, id_prodotto: 1, principio_attivo: 1, descrizione: 1, controindicazioni: 1 }
);

// M2: Quanti prodotti per principio attivo.
db.prodotti_extended.aggregate([
  {
    $group: {
      _id: "$principio_attivo",
      totale_prodotti: { $sum: 1 }
    }
  },
  { $sort: { totale_prodotti: -1, _id: 1 } }
]);

// M3: Query libera.
// Motivazione: capire quali tag ricorrono di piu aiuta a leggere il mix di catalogo
db.prodotti_extended.aggregate([
  { $unwind: "$tags" },
  {
    $group: {
      _id: "$tags",
      totale_prodotti: { $sum: 1 }
    }
  },
  { $sort: { totale_prodotti: -1, _id: 1 } }
]);
