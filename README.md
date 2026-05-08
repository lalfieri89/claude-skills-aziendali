# Claude Code — Skill Aziendali Java Spring Boot

Pacchetto di skill personalizzate per Claude Code, ottimizzate per progetti **Java 17 + Spring Boot** sviluppati in azienda.

---

## Skill incluse

| Skill | Comando | Ruolo | Descrizione |
|-------|---------|-------|-------------|
| Code reviewer | `/code-reviewer` | Sviluppatore | Orchestratore pre-commit: lancia in parallelo `java-spring-reviewer` e `test-reviewer` su ogni `.java` modificato |
| Commit & Push | `/commit-push-pr` | Sviluppatore | Commit Conventional Commits, push e PR opzionale |
| Java Spring reviewer | `/java-spring-reviewer` | Tutti | Code review qualità, sicurezza e architettura su una singola classe |
| Test reviewer | `/test-reviewer` | Tutti | Genera, revisiona e analizza i gap di test su una singola classe |
| Architettura progetto | `/architettura-progetto` | Tutti | Analisi architetturale completa del progetto |
| Revisione commit | `/revisione-commit` | Team Leader | Review di un commit o PR su GitHub con report strutturato |
| Init project | `/init-project` | Tutti | Inizializza `.claude/CLAUDE.md` con le configurazioni del progetto |

---

## Flusso tipico sviluppatore

```
1. /code-reviewer [--skip-tests]
   → analisi parallela su tutti i .java modificati → report

2. (eventuale fix dei problemi trovati)

3. /commit-push-pr [--no-push] [--draft-pr] [--squash]
   → commit → push → PR opzionale
```

`/java-spring-reviewer` e `/test-reviewer` possono essere usati anche individualmente su una singola classe, senza passare dall'orchestratore.

---

## Requisiti

- [Claude Code](https://docs.anthropic.com/it/docs/claude-code/getting-started) installato
- macOS/Linux (per `install.sh`) oppure Windows (per `install.bat`)
- [GitHub CLI (`gh`)](https://cli.github.com/) installato e autenticato — richiesto da `/commit-push-pr` e `/revisione-commit`
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
REM 1. Clona il repository
git clone <url-repo-aziendale> claude-skills-aziendali
cd claude-skills-aziendali

REM 2. Lancia lo script di installazione
install.bat
```

Lo script copia:
- `skills/` → `~/.claude/skills/` (macOS/Linux) o `%USERPROFILE%\.claude\skills\` (Windows)
- `agents/` → `~/.claude/agents/` (macOS/Linux) o `%USERPROFILE%\.claude\agents\` (Windows)

---

## Utilizzo

### `/code-reviewer [--skip-tests]`

Orchestratore di analisi pre-commit per tutti i file `.java` modificati nel branch corrente.

```
/code-reviewer
/code-reviewer --skip-tests
```

Come funziona:
1. Legge `.claude/CLAUDE.md` del progetto per stack e convenzioni
2. Legge le skill `java-spring-reviewer` e `test-reviewer` e ne inietta il contenuto nel prompt di ciascun subagent (approccio cross-platform: nessun path hardcodato negli agenti)
3. Lancia un agente per ogni `.java` modificato, tutti in parallelo
4. Produce un report consolidato con critici, attenzioni e info

Si ferma dopo il report — il commit va fatto separatamente con `/commit-push-pr`.

---

### `/commit-push-pr [--no-push] [--draft-pr] [--squash]`

Workflow git completo dal commit alla PR opzionale.

```
/commit-push-pr
/commit-push-pr --no-push
/commit-push-pr --draft-pr
```

Cosa fa in sequenza:
1. Analizza il diff e genera un messaggio secondo **Conventional Commits** (≤ 50 caratteri)
2. ⏸ Chiede conferma del messaggio e dei file da committare
3. Esegue `git add <file specifici>` + `git commit`
4. ⏸ Chiede conferma del push
5. Esegue `git push origin <branch>`
6. ⏸ Chiede se creare la PR (interattivo, non automatico)
7. Se confermato: genera descrizione da diff e lancia `gh pr create`

---

### `/java-spring-reviewer <percorso-file>`

Code review completa su una singola classe Java.

```
/java-spring-reviewer src/main/java/it/mioprogetto/service/OrdineService.java
```

Cosa controlla: SOLID e Clean Code, sicurezza OWASP Top 10, gestione errori e logging, performance (N+1, paginazione), best practice Spring Boot, rispetto delle regole per layer (Controller / Service / Repository / Entity / DTO / Mapper).

Output: lista problemi con livello CRITICO / ATTENZIONE / INFO, numero riga e soluzione proposta. Giudizio finale: APPROVATO / APPROVATO CON RISERVE / DA RIVEDERE.

---

### `/test-reviewer <percorso-file>`

Gestisce il ciclo di vita dei test per una classe.

```
/test-reviewer src/main/java/it/mioprogetto/service/OrdineService.java
```

Cosa fa:
1. Analizza la classe e individua i metodi pubblici
2. Se i test coprono meno del 70% dei metodi, li genera (file scritto in `src/test/java/`)
3. Se i test esistono, ne analizza la qualità (assertion, mock, isolamento, naming, struttura AAA)
4. Esegue i test con Maven, ciclo fix/rilancio fino a 5 iterazioni
5. Produce una gap analysis con priorità (ALTA / MEDIA / BASSA) e stima effort (S / M / L)

---

### `/architettura-progetto <root-progetto>`

Analizza l'intera architettura di un progetto. Passa la root del progetto come argomento.

```
/architettura-progetto src/main/java/it/mioprogetto
```

Cosa controlla: separazione dei layer, dipendenze tra package, coerenza strutturale, gestione transazioni, boundary API, pattern sistemici.

---

### `/revisione-commit <hash|PR>` — per il Team Leader

Review di un commit specifico o di una PR. Richiede `gh auth login` eseguito in precedenza.

```bash
/revisione-commit a1b2c3d   # review di un commit
/revisione-commit 42        # review di una PR
```

Cosa analizza: formato Conventional Commits, sicurezza, qualità Java, architettura a strati, copertura test, performance.

Output: report con livelli CRITICO / ATTENZIONE / INFO + verdetto APPROVATO / APPROVATO CON RISERVE / RICHIEDE MODIFICHE.

---

### `/init-project`

Inizializza la configurazione Claude Code per il progetto corrente. Da eseguire una sola volta per ogni nuovo progetto.

```
/init-project
```

Guida lo sviluppatore con domande su stack, convenzioni e vincoli, poi genera `.claude/CLAUDE.md` nella root del progetto. Tutti gli agenti leggeranno questo file automaticamente ad ogni sessione.

---

## Aggiornare le skill

Quando viene rilasciata una nuova versione del pacchetto:

```bash
git pull
./install.sh   # rispondere 's' quando chiede di sovrascrivere
```

---

## Struttura del pacchetto

```
claude-skills-aziendali/
├── agents/                              ← subagent definitions (system prompt)
│   ├── architettura-progetto.md
│   ├── code-reviewer.md                 ← orchestratore
│   ├── java-spring-reviewer.md          ← riceve i criteri via prompt dall'orchestratore
│   ├── revisione-commit.md
│   └── test-reviewer.md                 ← riceve i criteri via prompt dall'orchestratore
├── skills/                              ← slash commands + fonte criteri
│   ├── code-reviewer/SKILL.md
│   ├── commit-push-pr/SKILL.md
│   ├── java-spring-reviewer/SKILL.md    ← criteri di code review (letti dall'orchestratore)
│   ├── test-reviewer/SKILL.md           ← criteri di test (letti dall'orchestratore)
│   └── init-project.md
├── install.sh
├── install.bat
└── README.md
```
