# Claude Code — Skill Aziendali Java Spring Boot

Pacchetto di skill personalizzate per Claude Code, ottimizzate per progetti **Java 17 + Spring Boot** sviluppati in azienda.

---

## Skill incluse

| Skill | Comando | Ruolo | Descrizione |
|-------|---------|-------|-------------|
| Architettura progetto | `/architettura-progetto` | Tutti | Analisi architetturale completa del progetto |
| Revisione codice | `/revisione-codice` | Tutti | Code review qualità, sicurezza e architettura |
| Gestione test | `/gestione-test` | Sviluppatore | Genera, revisiona e analizza i gap di test |
| Gestione commit | `/gestione-commit` | Sviluppatore | Pre-commit check, fix, messaggio Conventional Commits e push |
| Revisione commit | `/revisione-commit` | Team Leader | Review di un commit/PR su GitHub con report strutturato |

---

## Requisiti

- [Claude Code](https://docs.anthropic.com/it/docs/claude-code/getting-started) installato
- macOS/Linux (per `install.sh`) oppure Windows (per `install.bat`)
- [GitHub CLI (`gh`)](https://cli.github.com/) installato e autenticato — richiesto da `/gestione-commit` e `/revisione-commit`
  ```bash
  gh auth login   # da eseguire una sola volta per sviluppatore
  ```

---

## Installazione

### macOS / Linux

```bash
# 1. Clona il repository
git clone <url-repo-aziendale> claude-skills-aziendali
cd claude-skills-aziendali

# 2. Rendi eseguibile lo script e lancia l'installazione
chmod +x install.sh
./install.sh
```

### Windows

```cmd
# 1. Clona il repository
git clone <url-repo-aziendale> claude-skills-aziendali
cd claude-skills-aziendali

# 2. Lancia lo script di installazione
install.bat
```

Le skill vengono copiate in `~/.claude/skills/` (macOS/Linux) o `%USERPROFILE%\.claude\skills\` (Windows).

---

## Utilizzo

Dopo l'installazione, le skill sono disponibili in qualsiasi sessione Claude Code con il prefisso `/`.

### `/architettura-progetto`
Analizza l'intera architettura di un progetto. Passa la root del progetto come argomento.

```
/architettura-progetto src/main/java/it/csea/mioprogetto
```

Cosa controlla: separazione dei layer, dipendenze tra package, coerenza strutturale, gestione transazioni, boundary API, pattern sistemici.

---

### `/revisione-codice`
Esegue una code review completa su una singola classe Java.

```
/revisione-codice src/main/java/it/csea/mioprogetto/service/CalcoloService.java
```

Cosa controlla: SOLID, sicurezza OWASP Top 10, performance, best practice Spring Boot, rispetto delle regole per layer (Controller/Service/Repository/Entity/DTO/Mapper).

Output: lista di problemi con livello CRITICO / ATTENZIONE / INFO, numero riga e soluzione. Giudizio finale: APPROVATO / APPROVATO CON RISERVE / DA RIVEDERE.

---

### `/gestione-test`
Gestisce il ciclo di vita dei test per una classe. Analizza, genera e revisiona i test.

```
/gestione-test src/main/java/it/csea/mioprogetto/service/CalcoloService.java
```

Cosa fa:
1. Analizza la classe sorgente e individua i metodi pubblici
2. Se i test coprono meno del 70% dei metodi, li genera (file scritto in `src/test/java/`)
3. Se i test esistono, ne analizza la qualità
4. Produce una gap analysis con priorità e stima effort

---

### `/gestione-commit` — per lo Sviluppatore

Workflow completo pre-commit. Lancia senza argomenti, opera sulle modifiche già staged.

```bash
git add src/main/java/it/csea/mioprogetto/service/CalcoloService.java
/gestione-commit
```

Cosa fa in sequenza:
1. Verifica cosa è staged e segnala file dimenticati
2. Scansiona il diff per segreti/credenziali, debug code, TODO, problemi architetturali
3. Se trova problemi CRITICI → si ferma (nessun commit)
4. Se trova ATTENZIONI → propone fix e chiede conferma
5. Genera il messaggio di commit secondo **Conventional Commits** (50/72 rule)
6. Chiede conferma del messaggio, poi esegue `git commit`
7. Chiede se fare `git push origin <branch>`

---

### `/revisione-commit` — per il Team Leader

Review di un commit specifico o di una PR. Richiede `gh auth login` eseguito in precedenza.

```bash
# Review di un commit
/revisione-commit a1b2c3d

# Review di una PR
/revisione-commit 42
```

Cosa analizza:
- Formato messaggio di commit (Conventional Commits)
- Sicurezza: credenziali hardcoded, SQL injection, CORS
- Qualità Java: field injection, catch generici, debug prints
- Architettura: violazioni layer, Entity nei Controller, logica nel Controller
- Test: nuovi metodi senza test, `@MockBean` deprecato
- Performance: N+1, query senza paginazione

Output: report con livelli CRITICO / ATTENZIONE / INFO + verdetto APPROVATO / APPROVATO CON RISERVE / RICHIEDE MODIFICHE.

---

## Aggiornare le skill

Quando viene rilasciata una nuova versione del pacchetto:

```bash
git pull
./install.sh   # rispondere 's' quando chiede di sovrascrivere
```

---

## Template CLAUDE.md

Nella cartella `templates/` trovi `CLAUDE.md.template`: copialo nella root di ogni nuovo progetto Spring Boot e personalizzalo con le informazioni specifiche del progetto.

```bash
cp templates/CLAUDE.md.template /path/al/tuo/progetto/CLAUDE.md
```

---

## Struttura del pacchetto

```
claude-skills-aziendali/
├── skills/
│   ├── architettura-progetto/SKILL.md   ← analisi architetturale
│   ├── gestione-commit/SKILL.md         ← workflow pre-commit (sviluppatore)
│   ├── gestione-test/SKILL.md           ← ciclo di vita test
│   ├── revisione-codice/SKILL.md        ← code review classe
│   └── revisione-commit/SKILL.md        ← review commit/PR (team leader)
├── templates/
│   └── CLAUDE.md.template               ← template per nuovi progetti
├── install.sh
├── install.bat
└── README.md
```
