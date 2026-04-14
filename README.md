# Claude Code — Skill Aziendali Java Spring Boot

Pacchetto di skill personalizzate per Claude Code, ottimizzate per progetti **Java 17 + Spring Boot** sviluppati in azienda.

---

## Skill incluse

| Skill | Comando | Descrizione |
|-------|---------|-------------|
| Architettura progetto | `/architettura-progetto` | Analisi architetturale completa del progetto |
| Revisione codice | `/revisione-codice` | Code review qualità, sicurezza e architettura |
| Gestione test | `/gestione-test` | Genera, revisiona e analizza i gap di test |

---

## Requisiti

- [Claude Code](https://docs.anthropic.com/it/docs/claude-code/getting-started) installato
- macOS/Linux (per `install.sh`) oppure Windows (per `install.bat`)

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
│   ├── architettura-progetto/SKILL.md
│   ├── gestione-test/SKILL.md
│   └── revisione-codice/SKILL.md
├── templates/
│   └── CLAUDE.md.template
├── install.sh
├── install.bat
└── README.md
```
