---
name: git-pr-workflows-git-workflow
description: "Orchestra un flusso di lavoro Git completo, dalla revisione del codice alla creazione di pull request, sfruttando agenti specializzati per la garanzia della qualità, i test e la preparazione alla distribuzione. Questo flusso di lavoro implementa Git moderno."
risk: critical
source: community
date_added: "2026-02-27"
---

# Workflow Git Completo con Orchestrazione Multi-Agente

Gestisci un workflow git completo dalla revisione del codice alla creazione della PR, sfruttando agenti specializzati per la qualità del codice, i test e la verifica pre-produzione. Il workflow implementa le best practice git moderne: Conventional Commits, esecuzione automatica dei test e creazione strutturata delle PR.

[Extended thinking: Questo workflow coordina più agenti specializzati per garantire la qualità del codice prima di eseguire i commit. L'agente code-reviewer esegue i controlli iniziali di qualità e il deployment-engineer controlla la prontezza per la produzione. Orchestrando questi agenti in sequenza con passaggio di contesto, si evita che codice rotto entri nel repository mantenendo alta la velocità di sviluppo. Il workflow supporta sia la strategia trunk-based che quella feature-branch, con opzioni configurabili per esigenze diverse.]

## Quando usare questa skill

- Per gestire un workflow git completo con orchestrazione multi-agente
- Per avere guida, best practice o checklist sul workflow git

## Quando NON usare questa skill

- Se il task non riguarda il workflow git
- Se hai bisogno di un dominio o strumento diverso

## Istruzioni

- Chiarisci obiettivi, vincoli e input necessari.
- Applica le best practice pertinenti e verifica i risultati.
- Fornisci passi concreti e verificabili.

## Configurazione

**Branch di destinazione**: $ARGUMENTS (default: 'main' se non specificato)

**Flag supportati**:
- `--draft-pr`: Crea la PR come bozza (work-in-progress)
- `--no-push`: Esegue tutti i controlli ma non fa il push sul remote

---

## Fase 1: Revisione Pre-Commit e Analisi

### 1. Valutazione della qualità del codice
- Usa il tool Task con subagent_type="code-reviewer"
- Prompt: "Rivedi tutte le modifiche non committate per problemi di qualità del codice. Controlla: 1) Violazioni dello stile, 2) Vulnerabilità di sicurezza, 3) Problemi di performance, 4) Gestione degli errori mancante, 5) Implementazioni incomplete. Genera un report dettagliato con livelli di severità (critical/high/medium/low) e feedback riga per riga. Formato output: JSON con {issues: [], summary: {critical: 0, high: 0, medium: 0, low: 0}, recommendations: []}"
- Output atteso: Report strutturato di code review per la fase successiva

### 2. Analisi dipendenze e breaking change
- Usa il tool Task con subagent_type="code-reviewer"
- Prompt: "Analizza le modifiche per: 1) Nuove dipendenze o cambi di versione, 2) Breaking change alle API, 3) Modifiche allo schema del database, 4) Cambi di configurazione, 5) Problemi di retrocompatibilità. Contesto dalla revisione precedente: [insert issues summary]. Identifica eventuali modifiche che richiedono script di migrazione o aggiornamenti alla documentazione."
- Contesto dalla fase precedente: Problemi di qualità che potrebbero indicare breaking change
- Output atteso: Valutazione dei breaking change e requisiti di migrazione

### 3. Secret e credenziali (CRITICO)
Cerca pattern pericolosi nel diff:
- Password hardcoded: `password\s*=\s*["'][^"']+["']`, `pwd\s*=`, `passwd\s*=`
- Token/API key: `token\s*=\s*["'][A-Za-z0-9_\-]{16,}["']`, `api[_-]?key\s*=`
- Chiavi private: `BEGIN (RSA|EC|DSA|OPENSSH) PRIVATE KEY`
- Connection string con credenziali: `jdbc:mysql://[^:]+:[^@]+@`, `mongodb://[^:]+:[^@]+@`
- Secret hardcoded in `@Value` o `application.properties`

Se trovati → segnala CRITICO, indica la riga esatta, suggerisci di spostare in variabile d'ambiente o vault. **Non procedere con il commit.**

---

## Fase 2: Generazione del Messaggio di Commit

### 1. Analisi e categorizzazione delle modifiche
- Usa il tool Task con subagent_type="code-reviewer"
- Prompt: "Analizza tutte le modifiche e categorizzale secondo la specifica Conventional Commits. Identifica il tipo di modifica principale (feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert) e lo scope. Per le modifiche: [insert file list and summary], stabilisci se fare un singolo commit o più commit atomici. Considera i risultati dei test: [insert test summary]."
- Contesto dalla fase precedente: Risultati dei test, riepilogo della code review
- Output atteso: Raccomandazione sulla struttura dei commit

### 2. Creazione del messaggio di commit in formato Conventional Commits
- Usa il tool Task con subagent_type="llm-application-dev::prompt-engineer"
- Prompt: "Crea messaggi di commit in formato Conventional Commits basandoti sulla categorizzazione: [insert categorization]. Formato: <type>(<scope>): <subject> con riga vuota, poi <body> che spiega cosa e perché (non come), poi <footer> con BREAKING CHANGE: se applicabile. Includi: 1) Riga subject chiara (max 50 caratteri), 2) Body dettagliato con la motivazione, 3) Riferimenti a issue/ticket, 4) Co-autori se necessario. Considera l'impatto: [insert breaking changes if any]."
- Contesto dalla fase precedente: Categorizzazione delle modifiche, breaking change
- Output atteso: Messaggio/i di commit formattati correttamente

---

## Pausa 1 — Conferma prima del commit

**STOP. Non eseguire git add o git commit senza conferma esplicita dell'utente.**

Presentare all'utente:
- Elenco dei file che verranno inclusi nel commit
- Messaggio di commit proposto
- Eventuali warning su breaking change o problemi critici rilevati

Attendere che l'utente dica esplicitamente di procedere prima di eseguire qualsiasi comando git.

---

## Fase 3: Preparazione Branch e Push

### 1. Gestione del branch
- Usa il tool Task con subagent_type="cicd-automation::deployment-engineer"
- Prompt: "In base al tipo di workflow [--trunk-based o --feature-branch], prepara la strategia di branch. Per feature branch: verifica che il nome segua il pattern (feature|bugfix|hotfix)/<ticket>-<descrizione>. Per trunk-based: prepara il push diretto su main con feature flag se necessario. Branch corrente: [insert branch], target: [insert target branch]. Verifica assenza di conflitti con il branch di destinazione."
- Output atteso: Comandi di preparazione del branch e stato dei conflitti

### 2. Validazione pre-push
- Usa il tool Task con subagent_type="cicd-automation::deployment-engineer"
- Prompt: "Esegui i controlli finali pre-push: 1) Verifica che tutti i check CI passeranno, 2) Conferma assenza di dati sensibili nei commit, 3) Valida le firme dei commit se richiesto, 4) Controlla le regole di protezione del branch, 5) Assicurati che tutti i commenti di review siano stati risolti. Riepilogo test: [insert test results]. Stato review: [insert review summary]."
- Contesto dalla fase precedente: Tutti i risultati di validazione precedenti
- Output atteso: Conferma di prontezza al push o problemi bloccanti

---

## Pausa 2 — Conferma prima del push

**STOP. Non eseguire git push senza conferma esplicita dell'utente.**

Presentare all'utente:
- Branch sorgente e branch di destinazione
- Riepilogo dei commit che verranno pushati
- Risultato dei controlli pre-push

Attendere che l'utente dica esplicitamente di procedere prima di eseguire git push.

---

## Fase 4: Creazione della Pull Request

**Questa fase è opzionale e separata. Inizia solo se l'utente la richiede esplicitamente dopo il push.**

### Pausa 3 — Conferma prima di creare la PR

**STOP. Non creare la PR senza conferma esplicita dell'utente.**

Chiedere all'utente se vuole procedere con la creazione della PR e verso quale branch di destinazione.

### 1. Generazione della descrizione della PR
- Usa il tool Task con subagent_type="documentation-generation::docs-architect"
- Prompt: "Crea una descrizione completa per la PR includendo: 1) Riepilogo delle modifiche (cosa e perché), 2) Checklist del tipo di modifica, 3) Riepilogo dei test eseguiti da [insert test results], 4) Screenshot/registrazioni se ci sono modifiche UI, 5) Note di deploy da [insert deployment considerations], 6) Issue/ticket correlati, 7) Sezione breaking change se applicabile: [insert breaking changes], 8) Checklist per i revisori. Formato: GitHub-flavored Markdown."
- Contesto dalla fase precedente: Tutti i risultati di validazione, esiti dei test, breaking change
- Output atteso: Descrizione completa della PR in Markdown

### 2. Configurazione metadata e automazione della PR
- Usa il tool Task con subagent_type="cicd-automation::deployment-engineer"
- Prompt: "Configura i metadata della PR: 1) Assegna i revisori appropriati in base a CODEOWNERS, 2) Aggiungi label (tipo, priorità, componente), 3) Collega le issue correlate, 4) Imposta la milestone se applicabile, 5) Configura la strategia di merge (squash/merge/rebase), 6) Imposta l'auto-merge se tutti i check passano. Considera lo stato draft: [--draft-pr flag]. Includi lo stato dei test: [insert test summary]."
- Contesto dalla fase precedente: Descrizione PR, risultati test, stato review
- Output atteso: Comandi di configurazione della PR e regole di automazione

---

## Criteri di Successo

- Tutti i problemi critici e ad alta severità risolti
- Copertura dei test mantenuta o migliorata (obiettivo: >80%)
- Tutti i test passano (unit, integration, e2e)
- Messaggi di commit nel formato Conventional Commits
- Nessun conflitto di merge con il branch di destinazione
- Descrizione PR completa con tutte le sezioni richieste
- Regole di protezione del branch soddisfatte
- Scansione di sicurezza completata senza vulnerabilità critiche
- Benchmark di performance entro soglie accettabili
- Documentazione aggiornata per eventuali modifiche alle API

## Procedure di Rollback

In caso di problemi dopo il merge:

1. **Revert immediato**: Crea una PR di revert con `git revert <commit-hash>`
2. **Disattivazione feature flag**: Se si usano feature flag, disattivarli immediatamente
3. **Branch hotfix**: Per problemi critici, crea un branch hotfix da main
4. **Comunicazione**: Notifica il team attraverso i canali designati
5. **Analisi della causa radice**: Documenta il problema nel template di postmortem

## Best Practice di Riferimento

- **Frequenza dei commit**: Committa spesso, ma assicurati che ogni commit sia atomico
- **Naming del branch**: `(feature|bugfix|hotfix|docs|chore)/<ticket-id>-<breve-descrizione>`
- **Dimensione delle PR**: Mantieni le PR sotto le 400 righe per una revisione efficace
- **Risposta ai commenti**: Risolvi i commenti di review entro 24 ore
- **Strategia di merge**: Squash per i feature branch, merge per i release branch
- **Approvazioni**: Richiedi almeno 2 approvazioni per le modifiche al branch main

## Limitazioni
- Usa questa skill solo quando il task rientra chiaramente nello scopo descritto sopra.
- Non trattare l'output come sostituto di validazione specifica per l'ambiente, test o revisione da parte di esperti.
- Fermati e chiedi chiarimenti se mancano input richiesti, permessi, limiti di sicurezza o criteri di successo.
