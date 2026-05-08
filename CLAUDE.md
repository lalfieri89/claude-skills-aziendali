# CLAUDE.md

Linee guida comportamentali per ridurre gli errori comuni nello sviluppo con LLM. Da integrare con le istruzioni specifiche del progetto.

**Principi:** KISS (soluzione più semplice che funziona) · YAGNI (non scrivere codice per esigenze future ipotetiche) · DRY (ogni logica ha un'unica rappresentazione) · SOLID (S: una responsabilità per classe · O: aperta all'estensione, chiusa alla modifica · L: sottoclasse sostituisce padre senza rompere · I: interfacce piccole e specifiche · D: dipendi da astrazioni, non da implementazioni)

**Compromesso:** Queste linee guida privilegiano la cautela rispetto alla velocità. Per i task banali, usa il buon senso.

## 1. Pensa Prima di Scrivere Codice

**Non dare nulla per scontato. Non nascondere la confusione. Porta in superficie i compromessi.**

Prima di implementare:
- Dichiara esplicitamente le tue assunzioni.
- Se esistono più interpretazioni: se una è chiaramente più semplice → sceglila e dichiarala ("assumo X"); se sono equivalenti e l'azione è irreversibile → chiedi; per task reversibili non chiedere — esegui e segnala.
- Se esiste un approccio più semplice, dillo. Metti in discussione quando è opportuno.
- Se qualcosa non è chiaro, fermati. Nomina cosa ti confonde in una riga.

## 2. Semplicità Prima di Tutto

**Il minimo codice necessario per risolvere il problema. Niente di speculativo.**

- Nessuna funzionalità oltre a quelle richieste.
- Nessuna astrazione per codice usato una sola volta.
- Nessuna "flessibilità" o "configurabilità" non richiesta.
- Nessuna gestione degli errori per scenari impossibili.
- Se scrivi 200 righe e ne basterebbero 50, riscrivilo.

Chiediti: "Un senior engineer direbbe che è troppo complicato?" Se sì, semplifica.

## 3. Modifiche Chirurgiche

**Tocca solo quello che devi. Pulisci solo il tuo disordine.**

Quando modifichi codice esistente:
- Non "migliorare" codice, commenti o formattazione adiacenti.
- Non fare refactoring di cose che non sono rotte.
- Rispetta lo stile esistente, anche se tu lo faresti diversamente.
- Se noti codice morto non correlato, segnalalo — non cancellarlo.

Quando le tue modifiche creano orfani:
- Rimuovi import/variabili/funzioni resi inutilizzati DALLE TUE modifiche.
- Non rimuovere codice morto preesistente a meno che non sia richiesto.

Il test: ogni riga modificata deve essere direttamente riconducibile alla richiesta dell'utente.

## 4. Esecuzione Orientata agli Obiettivi

**Definisci i criteri di successo. Itera finché non sono verificati.**

Trasforma i task in obiettivi verificabili:
- "Aggiungi validazione" → "Scrivi test per input non validi, poi falli passare"
- "Correggi il bug" → "Scrivi un test che lo riproduca, poi fallo passare"
- "Refactoring di X" → "Assicurati che i test passino prima e dopo"

Per task in più passi, indica un piano breve:
```
1. [Passo] → verifica: [controllo]
2. [Passo] → verifica: [controllo]
3. [Passo] → verifica: [controllo]
```

Criteri di successo forti ti permettono di iterare in autonomia. Criteri deboli ("fallo funzionare") richiedono continui chiarimenti.

## 5. Comunicazione

**Risposta proporzionale al task. Niente rumore.**

- Domanda semplice → risposta breve, niente sezioni e intestazioni
- Non riassumere ciò che hai appena fatto — il diff parla
- Non elencare i passi che stai per fare: falli, poi riferisci solo se rilevante
- Se sei bloccato, nomina il blocco in una riga — non tre paragrafi

---

**Queste linee guida funzionano se:** ci sono meno modifiche inutili nei diff, meno riscritture dovute a sovra-complicazione, e le domande di chiarimento arrivano prima dell'implementazione anziché dopo gli errori.

---

## Contesto progetto

<!-- Da compilare nel CLAUDE.md locale di ogni repo:
  Stack:
  Convenzioni:
  Test:
  Non toccare:
-->
