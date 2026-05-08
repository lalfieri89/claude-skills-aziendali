---
name: commit-push-pr
description: Gestisce commit, push e creazione PR opzionale per qualsiasi progetto. Genera il messaggio in formato Conventional Commits, chiede conferma prima di ogni operazione git distruttiva, e al termine chiede se creare la PR. Usare dopo /code-reviewer (per Java) o direttamente per qualsiasi branch.
disable-model-invocation: true
argument-hint: "[branch-destinazione] [--no-push] [--draft-pr] [--squash]"
allowed-tools: Bash
---

**Branch di destinazione**: $ARGUMENTS (default: `main` se non specificato)

**Flag supportati**:
- `--no-push`: Esegui commit ma non fare push
- `--draft-pr`: Crea la PR come bozza
- `--squash`: Proponi squash dei commit prima del push

---

## FASE 1 — Generazione messaggio di commit

Analizza le modifiche:
```bash
git diff --staged   # se c'è qualcosa in staging
# oppure
git diff HEAD       # se nulla è staged
```

Genera un messaggio di commit in formato **Conventional Commits**:

```
<type>(<scope>): <descrizione imperativa ≤50 caratteri>

<body: cosa e perché, righe ≤72 caratteri — solo se logica non ovvia o > 5 file>

<footer: BREAKING CHANGE: ... — solo se applicabile>
```

Tipi validi: `feat` / `fix` / `refactor` / `perf` / `test` / `docs` / `style` / `chore` / `ci` / `revert`

Regole:
- Imperativo: "add" non "added", "fix" non "fixed"
- Lingua coerente con la storia del repository (`git log --oneline -5`)
- Body obbligatorio se > 5 file modificati
- Scope = modulo/package principale toccato

---

## ⏸ Pausa 1 — Conferma commit

**STOP. Presenta all'utente:**

```
File da includere: [lista file modificati]
Messaggio proposto:

  <type>(<scope>): <descrizione>

  <body se presente>
```

**Non eseguire `git add` o `git commit` senza conferma esplicita.**

---

## FASE 2 — Commit

Dopo conferma utente:

```bash
git add <file modificati — NO git add -A>
git commit -m "<messaggio approvato>"
git status
git log --oneline -5
```

Controlla conflitti con branch di destinazione:
```bash
git fetch origin
git log HEAD..origin/<target-branch> --oneline
```

---

## ⏸ Pausa 2 — Conferma push

**STOP. Presenta all'utente:**

```
Branch corrente:      <nome>
Branch destinazione:  <target>
Commit da pushare:    N
Conflitti rilevati:   sì / no

[lista commit che verranno pushati]
```

Se `--no-push` è attivo: comunica che il push è stato saltato e termina qui.

**Non eseguire `git push` senza conferma esplicita.**

---

## FASE 3 — Push

Dopo conferma utente:

```bash
git push origin <branch-corrente>
```

Se `--squash` è attivo, proponi squash prima del push e attendi conferma.

---

## ⏸ Pausa 3 — PR opzionale

Dopo il push, chiedi all'utente:

```
Push completato.

Vuoi creare una Pull Request? (sì/no)
Branch destinazione (default: main): 
```

Se l'utente dice no → termina.

---

## FASE 4 — Creazione PR (solo se richiesta)

Raccogli le informazioni per la descrizione:
```bash
git log origin/<target>..HEAD --oneline
```

Genera la descrizione PR:
- Riepilogo delle modifiche (cosa e perché)
- Breaking change se presenti
- Checklist revisori

```bash
gh pr create \
  --title "<type>(<scope>): <descrizione>" \
  --body "<descrizione generata>" \
  --base <target-branch> \
  [--draft se --draft-pr]
```

---

## Regole importanti

- `git add` sempre su file specifici — mai `git add -A` o `git add .`
- Non eseguire operazioni git distruttive (reset --hard, force push) senza conferma esplicita
- Se `pom.xml` è tra i file modificati, segnalarlo nel messaggio di commit e nella PR
