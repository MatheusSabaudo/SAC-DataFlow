# 💊 SAC DataFlow — MediStore Data Platform

## 🚀 From Raw CSV Chaos to Business Insights

![Data Engineering](https://img.shields.io/badge/Data%20Engineering-End--to--End-blue)
![Architecture](https://img.shields.io/badge/Architecture-ELT%20%7C%20Medallion-orange)
![Status](https://img.shields.io/badge/Status-Completed-success)
![Team](https://img.shields.io/badge/Team-Agile%20Project-informational)

---

## 🧠 Project Overview

Questo progetto rappresenta un incarico simulato di consulenza dati sviluppato durante il percorso **Junior Data Engineer** presso **Generation Italy**.

Non è un semplice esercizio: è un progetto di gruppo costruito per replicare un contesto aziendale reale, con:

* metodologia **Agile**
* organizzazione in **sprint**
* assegnazione task per ruolo
* collaborazione continua e delivery incrementali

Il cliente simulato, **MediStore S.r.l.**, è una catena di farmacie che lavora con dati frammentati (CSV isolati, nessuna integrazione).

### 🎯 Mission

* strutturare i dati
* costruire una pipeline ripetibile
* generare insight per il CDA

⏱️ Deadline reale: **4 giorni** 

> “Non siete più studenti. Siete consulenti.” — CTO DataFlow

---

## 💡 Why This Project Stands Out

✔ End-to-end Data Engineering project
✔ Real-world simulation (consulting scenario)
✔ Strong focus on **data quality & modeling**
✔ SQL + NoSQL integration
✔ Agile team execution

👉 Questo è esattamente il tipo di progetto che dimostra **job readiness**

---

## 🏗️ Architecture (Medallion)

```text
        ┌──────────────┐
        │ CSV / JSON   │
        └──────┬───────┘
               ↓
        ┌──────────────┐
        │  BRONZE      │  Raw ingestion
        └──────┬───────┘
               ↓
        ┌──────────────┐
        │  SILVER      │  Cleaning & validation
        └──────┬───────┘
               ↓
        ┌──────────────┐
        │   GOLD       │  Business-ready data
        └──────┬───────┘
               ↓
        📊 SQL Analysis / Dashboard
```

---

## 🧰 Tech Stack

![MySQL](https://img.shields.io/badge/MySQL-Relational-blue)
![MongoDB](https://img.shields.io/badge/MongoDB-NoSQL-green)
![Python](https://img.shields.io/badge/Python-Data%20Cleaning-yellow)
![Docker](https://img.shields.io/badge/Docker-Containerization-blue)
![Git](https://img.shields.io/badge/Git-Versioning-orange)

---

## 📊 Data Modeling

### 🔹 OLTP — Entity Relationship

Database progettato con:

* Primary Keys
* Foreign Keys
* Vincoli di integrità

👉 focus su consistenza e affidabilità

---

### 🔹 OLAP — Star Schema

* **Fact Table**

  * `fatto_vendite` → quantità, fatturato, margine

* **Dimension Tables**

  * tempo
  * prodotto
  * farmacia
  * cliente

👉 separazione tra **misure e contesto** 

---

## 🧹 Data Cleaning Pipeline

I dati iniziali presentavano problemi reali:

* formati data inconsistenti
* valori mancanti
* duplicati
* incoerenze

### 🔄 Pipeline

```text
Raw CSV → Analysis → Cleaning → Validation → Clean CSV
```

Output:

* dataset puliti `_clean.csv`
* log problemi documentato

👉 base fondamentale per analisi corrette 

---

## 📈 Business Queries

Query progettate per il management:

* Top prodotti per fatturato
* Performance per farmacia
* Trend vendite nel tempo
* Analisi clienti (loyalty)
* Margini per fornitore

👉 ogni query risponde a una domanda reale

---

## 🍃 NoSQL (MongoDB)

Utilizzato per dati semi-strutturati:

* `prodotti_extended`

Esempi:

* controindicazioni farmaci
* aggregazioni per principio attivo

👉 scelta guidata dalla natura del dato

---

## ⚡ Agile Workflow

### Sprint Structure

* **Sprint 1** → Analisi & Modeling
* **Sprint 2** → Database & Cleaning
* **Sprint 3** → Query & Insights

### 👥 Team

* **Sabaudo** → Data Engineering & Infrastructure
* **Sgobba** → Data Modeling
* **Zoncheddu** → Business Analysis

---

## 🏁 Final Outcome

Da file CSV isolati a:

✔ sistema dati strutturato
✔ pipeline replicabile
✔ insight pronti per decisioni

👉 **Data → Insight → Decision**

---

## 🔥 Recruiter Takeaways

Se stai leggendo questo repo per valutare il profilo:

* ✔ progettazione completa (OLTP + OLAP)
* ✔ gestione data quality reale
* ✔ integrazione SQL + NoSQL
* ✔ approccio Agile
* ✔ mindset da consulente

👉 pronto per lavorare su progetti reali di Data Engineering
