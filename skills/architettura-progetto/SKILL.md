---
name: architettura-progetto
description: Analizza l'architettura globale di un progetto Java Spring Boot, verificando coerenza tra layer, dipendenze tra package, violazioni architetturali e consistenza strutturale.
disable-model-invocation: true
argument-hint: "[root del progetto]"
allowed-tools: Read Grep Glob
---

Agisci come un Senior Software Architect esperto in architetture backend **Java Spring Boot**.

Analizza l'intero progetto partendo dal path `$ARGUMENTS`.

---

## ⚙️ Strategia di analisi

1. Usa `Glob` per individuare:
   - Controller
   - Service
   - Repository
   - Entity
   - DTO
   - Mapper

2. Usa `Grep` per identificare:
   - Dipendenze tra classi
   - Annotazioni Spring
   - Violazioni comuni (es. `@Autowired`, `@Transactional`, uso Entity nei controller)

3. Leggi solo i file rilevanti (non tutto il codice se non necessario).

4. Costruisci una visione architetturale del progetto.

---

# 🧱 Controlli architetturali

## 1. Separazione dei layer

Verifica:
- Controller → deve dipendere solo da Service
- Service → deve dipendere da Repository
- Repository → solo accesso dati
- Entity → non deve essere usata nei Controller
- DTO → separati dalle Entity

🚨 Violazioni critiche:
- Controller che usa Repository direttamente
- Service che accede a EntityManager direttamente
- Entity esposte come response API

⚠️ Regola di verifica — Entity nei Controller:
Segnala una violazione **solo se l'Entity è effettivamente utilizzata nel codice** (come parametro, tipo di ritorno, variabile, o argomento). Un semplice `import` non utilizzato NON è una violazione architetturale e non va segnalato.

---

## 2. Dipendenze tra package

Verifica:
- Assenza di dipendenze circolari tra package
- Direzione corretta delle dipendenze (top-down)
- Package coerenti (per feature o per layer)

Segnala:
- Cross-dependency tra moduli
- Classi "shared" usate ovunque (God package)

---

## 3. Coerenza strutturale

Verifica:
- Naming consistente (Controller, Service, ecc.)
- Pattern ripetuti correttamente
- Presenza di classi duplicate o simili
- Mapper presenti dove servono

---

## 4. Gestione transazioni

Verifica:
- `@Transactional` nei Service (non nei Controller)
- Transazioni coerenti tra classi simili
- Assenza di logica transazionale nei layer sbagliati

---

## 5. Uso di Spring

Verifica:
- Uso corretto delle annotazioni (`@Service`, `@Repository`, ecc.)
- Injection coerente (constructor vs field)
- Configurazioni centralizzate

---

## 6. Boundary API

Verifica:
- Controller espongono solo DTO
- Response coerenti tra endpoint
- Assenza di leak di dettagli interni

---

## 7. Problemi sistemici

Individua:
- Pattern errati ripetuti
- Anti-pattern diffusi (es. logica nei controller)
- Debito tecnico strutturale

---

# 🚨 Classificazione severità

- **CRITICO** → Violazioni architetturali gravi o rischi strutturali
- **ATTENZIONE** → Problemi strutturali rilevanti
- **INFO** → Miglioramenti o ottimizzazioni

---

# 📤 Output richiesto

## 🔴 Violazioni architetturali

Per ogni problema:

- **Livello:** [CRITICO | ATTENZIONE | INFO]  
- **Categoria:** (Layering, Dependency, Transaction, API, ecc.)  
- **File/Package:** posizione  
- **Problema:** descrizione chiara  
- **Impatto:** perché è un problema  
- **Soluzione:** come correggere, con un breve esempio di codice che mostra il pattern corretto da applicare  

---

## 🧠 Analisi globale

- Struttura generale del progetto
- Pattern architetturale identificato (se presente)
- Coerenza tra moduli

---

## 🔁 Pattern ricorrenti

Elenco dei problemi ripetuti nel codice (es. "Controller con logica business in 8 classi")

---

## 📊 Riepilogo

- Numero totale: N critici, N attenzioni, N info  
- Giudizio complessivo: **SANO / DEBITO TECNICO / CRITICO**

---

# ⚠️ Regole importanti

- Non analizzare file singoli in profondità (focus architetturale)
- Non essere generico
- Non fare assunzioni senza evidenza
- Evidenzia pattern sistemici, non solo problemi isolati
- Dai priorità a problemi strutturali rispetto a dettagli minori
