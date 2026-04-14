---
name: revisione-commit
description: Skill per Team Leader. Dato un commit hash o un PR number su GitHub, recupera l'elenco dei file modificati, legge ogni file per intero ed esegue una code review completa (come revisione-codice), poi valida il messaggio di commit secondo Conventional Commits. Restituisce un report strutturato con verdetto di approvazione.
disable-model-invocation: true
argument-hint: "<commit-hash | PR-number>"
allowed-tools: Bash Read Grep Glob
---

Sei un Senior Software Architect che esegue la code review di un commit o PR specifico su GitHub.

L'argomento passato (`$ARGUMENTS`) può essere:
- Un **commit hash** (es. `a1b2c3d` o hash completo a 40 caratteri)
- Un **numero di PR** (es. `42` o `#42`)

Segui questo flusso **nell'ordine indicato**. Non invertire le fasi.

---

## FASE 1 — Recupero delle modifiche

### 1a. Verifica autenticazione GitHub

```bash
gh auth status
```

Se non autenticato → interrompi e mostra:
```
GitHub CLI non autenticato.
Esegui: gh auth login
Poi riprova.
```

### 1b. Recupera repo corrente

```bash
git remote get-url origin
```

Estrai `owner` e `repo` dall'URL:
- HTTPS: `https://github.com/owner/repo.git` → `owner/repo`
- SSH: `git@github.com:owner/repo.git` → `owner/repo`

### 1c. Recupera diff e lista file modificati

**Se `$ARGUMENTS` è un commit hash** (stringa esadecimale, 7-40 caratteri):

```bash
git show $ARGUMENTS --stat
git show $ARGUMENTS --name-only --format=""
git show $ARGUMENTS
```

Se il commit non è presente localmente (fetch it):
```bash
git fetch origin
git show $ARGUMENTS --name-only --format=""
```

Se ancora non trovato, usa GitHub API:
```bash
gh api repos/{owner}/{repo}/commits/$ARGUMENTS \
  -H "Accept: application/vnd.github.diff"
```

**Se `$ARGUMENTS` è un numero di PR** (numero intero, con o senza `#`):

```bash
gh pr view $ARGUMENTS --json number,title,body,headRefName,commits
gh pr diff $ARGUMENTS --name-only
gh pr diff $ARGUMENTS
```

Ottieni l'elenco definitivo dei file `.java` modificati (aggiunti o cambiati, non eliminati).

---

## FASE 2 — Code review dei file modificati

> Questa è la fase principale. Per ogni file `.java` modificato nel commit/PR, esegui una **code review completa** leggendo il file per intero — non solo le righe nel diff. Il contesto del file completo è necessario per rilevare violazioni architetturali, SOLID, e dipendenze tra classi.

Per ogni file `.java` nella lista:

### 2a. Leggi il file completo

```
Read: <percorso completo del file>
```

Se il file è stato eliminato nel commit, saltalo e segnala solo: "File eliminato: `NomeFile.java`".

### 2b. Identifica il layer

Determina automaticamente il layer dalla struttura e dalle annotazioni:
- `@RestController` / `@Controller` → **Controller**
- `@Service` → **Service**
- `@Repository` → **Repository**
- `@Entity` → **Entity**
- Classe senza annotazioni Spring con suffisso `DTO` o `Request`/`Response` → **DTO**
- Classe con metodi `fromEntityToDTO` / `fromDTOToEntity` → **Mapper**

### 2c. Parte 1 — Qualità generale del codice

Analizza il file cercando:

**Principi SOLID e Clean Code**
- Violazioni del Single Responsibility Principle (classe con troppe responsabilità o > 400 righe)
- Metodi troppo lunghi (più di 20-30 righe; idealmente 10-15 righe per metodi ben focalizzati)
- Duplicazione di codice (violazione DRY)
- Magic numbers o stringhe hardcoded non costantizzate
- Naming non descrittivo o ambiguo (variabili, metodi, classi)

**Sicurezza (OWASP Top 10)**
- SQL injection: query costruite con concatenazione di stringhe
- Esposizione di dati sensibili (password, token, dati personali) in log o response
- `@CrossOrigin(origins = "*")` senza restrizioni
- Credenziali hardcoded nel codice o nei file `.properties`
- Mancanza di validazione input (`@Valid`) su endpoint pubblici

**Gestione errori e logging**
- `catch (Exception e)` generico che nasconde la causa reale
- Eccezioni inghiottite senza logging
- `e.printStackTrace()` invece di logging strutturato
- Assenza di logging in punti critici (inizio/fine operazioni importanti)
- Logging inconsistente tra metodi dello stesso layer

**Performance**
- Query N+1 con JPA (accesso a collection lazy dentro un loop)
- Operazioni pesanti in loop su liste grandi
- Mancanza di paginazione per query che possono restituire molti risultati
- `@Transactional` su blocchi troppo lunghi che includono operazioni non necessarie

**Best practice Spring Boot**
- `@Autowired` su campo invece di constructor injection
- Dipendenze iniettate ma mai utilizzate
- `@Value` per configurazioni complesse (usare `@ConfigurationProperties`)
- `new Date()` invece di `LocalDateTime` o `Instant`
- Comparazione stringhe con `==` invece di `.equals()`
- `System.out.println(` o `Thread.sleep(` nel codice business

### 2d. Parte 2 — Rispetto dell'architettura a strati

In base al layer identificato:

**Controller**
- Nessuna logica business: tutta la logica deve stare nel Service
- Input e output solo tramite DTO (mai Entity JPA direttamente)
- Ogni endpoint deve avere l'annotazione Swagger `@Operation`
- Gestione eccezioni con try-catch e risposta strutturata (`HttpResponseDTO`)
- Logger inizializzato con la classe corretta (`LogManager.getLogger(NomeClasseCorretta.class)`)
- `@CrossOrigin` non con `*` in produzione

**Service**
- `@Transactional` presente su metodi che modificano dati
- Nessun accesso a oggetti HTTP (HttpServletRequest, HttpServletResponse)
- Dipendenze iniettate via constructor
- Nessun accesso diretto al database senza Repository

**Repository**
- Solo Spring Data JPA: nessuna logica applicativa
- Query custom solo con `@Query` o metodi derivati Spring Data
- Nessuna manipolazione dati (filtraggio, trasformazione) nel Repository

**Entity**
- Solo annotazioni JPA e Lombok, nessuna logica applicativa
- Campi monetari sempre `BigDecimal` (mai `double` o `float`)
- `@Audited` e `@AuditTable` se richiesto dall'audit trail
- Timestamp con `@CreationTimestamp` / `@UpdateTimestamp`

**DTO**
- Nessuna dipendenza da classi Entity JPA
- Usare Java `record` per DTO immutabili (solo lettura)
- Nessuna logica business

**Mapper**
- Metodi chiari: `fromEntityToDTO()` e `fromDTOToEntity()`
- Gestione esplicita dei valori null
- Nessuna chiamata a Repository o Service

### 2e. Copertura test

Per ogni file `.java` non-test nel commit, cerca il test corrispondente:

```
Glob: src/test/java/**/*NomeClasse*Test.java
```

Verifica:
- Esiste un file di test per questa classe?
- Se il commit aggiunge nuovi metodi pubblici, il test esiste ed è aggiornato?
- Se il file di test è nel commit, controlla che usi `@MockitoBean` (non `@MockBean`, deprecato da Spring Boot 3.4)

---

## FASE 3 — Validazione del messaggio di commit

Leggi il messaggio di commit:
- Per **commit hash**: estratto da `git show $ARGUMENTS --format="%s%n%n%b" --no-patch`
- Per **PR**: estratto dal titolo e corpo della PR tramite `gh pr view $ARGUMENTS --json title,body`

Verifica la conformità a **Conventional Commits**:

| Controllo | Regola |
|-----------|--------|
| Formato subject | `<type>[(scope)]: <descrizione>` |
| Tipo valido | `feat` / `fix` / `refactor` / `perf` / `test` / `docs` / `style` / `chore` / `ci` / `revert` |
| Lunghezza subject | ≤ 50 caratteri |
| Modo imperativo | "add" non "added", "fix" non "fixed", "remove" non "removed" |
| Lingua coerente | Tutto italiano o tutto inglese, non misto |
| Body presente | Obbligatorio se > 5 file modificati o logica non ovvia |
| Body formattato | Righe ≤ 72 caratteri |
| Breaking change | Dichiarato con `!` e/o footer `BREAKING CHANGE:` se applicabile |
| Coerenza | Il tipo del commit corrisponde alle modifiche effettive? (es. `fix` per una nuova feature è errato) |

---

## FASE 4 — Statistiche commit/PR

Riporta:
- Numero di file Java modificati / aggiunti / eliminati
- Righe totali aggiunte e rimosse
- Layer coinvolti (controller, service, repository, entity, dto, mapper, test)
- File di configurazione sensibili toccati: `application*.properties`, `pom.xml`, `beans.xml`, `log4j2.xml`
- Se `pom.xml` è modificato: elenca le dipendenze aggiunte o cambiate

---

## FASE 5 — Report strutturato

### 📋 File esaminati

Elenca ogni file con il layer identificato:
```
✅ CalcoloService.java         [Service]
✅ CalcoloController.java      [Controller]
⚠️ PraticaDTO.java             [DTO] — dipende da Entity
🔴 PraticaController.java      [Controller] — usa Repository direttamente
```

### 🔴 Problemi rilevati

Per ogni problema trovato:
```
[LIVELLO] File: NomeFile.java — Riga: N
Categoria: (Sicurezza | SOLID | Architettura - Controller | Performance | Test | ecc.)
Problema: descrizione chiara in italiano
Impatto: perché è rilevante per il sistema
Soluzione: come correggere
```

### 🧾 Messaggio di commit

```
Subject:          "feat(service): add interest calculation"
Formato:          ✅ CONFORME / ❌ NON CONFORME
Tipo rilevato:    feat
Coerente con diff: ✅ sì / ❌ no (es. il tipo è "fix" ma è una nuova feature)
Body:             presente / assente
Breaking change:  sì / no
```

### 📊 Statistiche

```
File esaminati:   N (controller: N, service: N, entity: N, ...)
Righe aggiunte:   +N
Righe rimosse:    -N
File sensibili:   pom.xml modificato / nessuno
```

### ✅ Verdetto finale

```
CRITICI:    N
ATTENZIONI: N
INFO:       N

Verdetto: APPROVATO | APPROVATO CON RISERVE | RICHIEDE MODIFICHE
```

**Criteri:**
- **APPROVATO** → 0 critici, ≤ 2 attenzioni, messaggio commit conforme
- **APPROVATO CON RISERVE** → 0 critici, > 2 attenzioni o messaggio non conforme (da correggere prima del merge)
- **RICHIEDE MODIFICHE** → ≥ 1 critico

Se `RICHIEDE MODIFICHE`: elenca le **3 cose più urgenti** da correggere prima del merge.

---

## Regole importanti

- Leggi sempre il **file completo**, non solo le righe nel diff: il contesto serve per valutare architettura e dipendenze
- Non fare assunzioni su codice non presente nel commit o nei file letti
- Non eseguire `git checkout`, `git reset` o comandi che modificano lo stato del repository
- Se un file non è raggiungibile localmente, usa l'API GitHub per leggerlo
- Per PR con molti file (> 15), dai priorità ai file business-critical (Service, Controller, Entity) rispetto a utility e configurazioni
- Segnala sempre se `pom.xml` è modificato: potrebbe impattare l'intero team
