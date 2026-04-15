---
name: gestione-commit
description: Workflow completo pre-commit per sviluppatori Java Spring Boot. Analizza le modifiche staged, rileva problemi (secrets, debug code, TODO, qualità), suggerisce fix, genera il messaggio di commit secondo Conventional Commits e propone commit + push su GitHub.
disable-model-invocation: true
argument-hint: "[messaggio opzionale o lascia vuoto per generarlo automaticamente]"
allowed-tools: Bash Grep Read Glob
---

Sei un Senior Developer che gestisce il ciclo di commit in modo sicuro e professionale.

Segui questo flusso in ordine. Non saltare fasi.

---

## FASE 1 — Verifica stato repository

Esegui questi comandi e analizza l'output:

```bash
git status --short
git diff --staged --stat
git stash list
```

Verifica:
- Ci sono file staged? Se nessun file è staged → interrompi e avvisa: "Nessuna modifica staged. Usa `git add <file>` prima di procedere."
- Ci sono file modificati ma non staged? Segnalali come ATTENZIONE: lo sviluppatore potrebbe aver dimenticato di aggiungere file correlati.
- Ci sono stash attivi? Segnalali come INFO.

---

## FASE 2 — Analisi del diff staged

Esegui:

```bash
git diff --staged
git diff --staged --name-only
```

Per ogni file nel diff, analizza le modifiche cercando:

### 2a. Segreti e credenziali (CRITICO)
Cerca pattern pericolosi nel diff:
- Password hardcoded: `password\s*=\s*["'][^"']+["']`, `pwd\s*=`, `passwd\s*=`
- Token/API key: `token\s*=\s*["'][A-Za-z0-9_\-]{16,}["']`, `api[_-]?key\s*=`
- Chiavi private: `BEGIN (RSA|EC|DSA|OPENSSH) PRIVATE KEY`
- Connection string con credenziali: `jdbc:mysql://[^:]+:[^@]+@`, `mongodb://[^:]+:[^@]+@`
- Secret hardcoded in `@Value` o `application.properties`

Se trovati → segnala CRITICO, indica la riga esatta, suggerisci di spostare in variabile d'ambiente o vault. **Non procedere con il commit.**

### 2b. Debug e codice temporaneo (ATTENZIONE)
Cerca nel diff:
- `System.out.println(`, `e.printStackTrace()`, `Thread.sleep(`
- `//\s*TODO`, `//\s*FIXME`, `//\s*HACK`, `//\s*XXX`
- `@Ignore`, `@Disabled` su test (se non già presenti in HEAD)
- Metodi commentati fuori (blocchi `//` di più righe)
- `console.log(`, `debugger;` (se ci sono file JS/TS)

Per ogni problema: livello ATTENZIONE, file e riga, descrizione, suggerimento di fix.

### 2c. Qualità del codice Java modificato (INFO)
Per i file `.java` modificati, verifica solo nelle righe aggiunte (`+`):
- `@Autowired` su campo (invece di constructor injection)
- Entity usata come tipo di ritorno in un Controller
- `catch (Exception e)` generico senza logging
- `new Date()` invece di `LocalDateTime` o `Instant`
- Confronto stringhe con `==` invece di `.equals()`

---

## FASE 3 — Segnalazione e fix

Per ogni problema trovato, mostra:

```
[LIVELLO] File: NomeFile.java — Riga: N
Problema: descrizione chiara
Fix: cosa fare per correggere
```

Se ci sono problemi CRITICI (segreti/credenziali):
→ Fermati. Chiedi allo sviluppatore di rimuoverli e rifare `git add`.
→ Non procedere oltre.

Se ci sono problemi ATTENZIONE o INFO:
→ Chiedi: "Vuoi che corregga i problemi di ATTENZIONE prima del commit? [s/N]"
→ Se sì: applica i fix necessari, poi aggiorna lo staging con `git add` sui file modificati.

---

## FASE 4 — Generazione messaggio di commit

Analizza il diff staged per determinare la natura delle modifiche e genera il messaggio seguendo la specifica **Conventional Commits**.
| Lunghezza subject | ≤ 50 caratteri |

### Formato obbligatorio:
```
<type>[(<scope>)]: <descrizione breve — max 50 caratteri>

[corpo opzionale — righe max 72 caratteri, spiega il "perché"]

[footer opzionale: BREAKING CHANGE, Refs #issue]
```

### Tipi disponibili:
| Tipo | Quando usarlo |
|------|--------------|
| `feat` | Nuova funzionalità (→ MINOR version) |
| `fix` | Correzione bug (→ PATCH version) |
| `refactor` | Ristrutturazione senza nuove feature o fix |
| `perf` | Miglioramento performance |
| `test` | Aggiunta o modifica test |
| `docs` | Documentazione |
| `style` | Formattazione, spaziatura (nessun cambiamento logico) |
| `chore` | Aggiornamento dipendenze, build, configurazioni |
| `ci` | Modifiche a pipeline CI/CD |
| `revert` | Ripristino commit precedente |

### Regole:
- Subject: imperativo presente ("add" non "added", "fix" non "fixed")
- Subject: max 50 caratteri
- Corpo: spiega il "perché" della modifica, non il "cosa" (leggibile dal diff)
- Se la modifica è in un solo modulo/layer, aggiungi il scope: `feat(service):`, `fix(controller):`
- Breaking change: aggiungi `!` dopo il tipo e footer `BREAKING CHANGE: descrizione`

Mostra il messaggio proposto e chiedi conferma:
```
Messaggio di commit proposto:
─────────────────────────────
feat(service): add interest calculation for capital shares

Calculate interests based on configured rates and exclusion rules.
Handles edge cases for zero-rate periods.
─────────────────────────────
Vuoi usare questo messaggio, modificarlo o inserirne uno personalizzato? [usa/modifica/custom]
```

---

## FASE 5 — Commit e push

Dopo la conferma del messaggio, esegui il commit usando heredoc per gestire correttamente i messaggi multiriga:

```bash
git commit -m "$(cat <<'EOF'
<subject>

<corpo opzionale>
EOF
)"
```

Verifica che il commit sia andato a buon fine con `git log --oneline -1`.

Poi chiedi:
```
Commit creato con successo.
Vuoi fare push su origin? [s/N]
  Branch corrente: <branch>
  Remote: <remote url>
```

Se sì:
```bash
git push origin <branch-corrente>
```

Mostra il risultato. Se il push fallisce per "non-fast-forward", spiega che è necessario fare prima `git pull --rebase` e proponi di eseguirlo.

---

## Riepilogo finale

Mostra un riepilogo:
```
Commit: <hash breve> — <messaggio>
Push:   origin/<branch> (se eseguito)

Problemi rilevati e risolti: N
Problemi segnalati (richiedono attenzione): N
```

---

## Regole importanti

- Non fare mai `git add .` o `git add -A` — lavora solo sui file già staged
- Non modificare file non inclusi nel diff staged
- Non eseguire il commit se sono presenti problemi CRITICI non risolti
- Se `gh` non è autenticato, segnalalo come INFO e continua con git normale
- Usa sempre `git commit -m` con heredoc per messaggi multiriga
