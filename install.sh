#!/usr/bin/env bash
# install.sh — Installa le skill Claude Code aziendali
# Compatibile con macOS e Linux

set -e

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"

echo "=== Installazione skill Claude Code aziendali ==="
echo ""

# Verifica che Claude Code sia installato
if ! command -v claude &>/dev/null; then
  echo "ATTENZIONE: il comando 'claude' non è stato trovato nel PATH."
  echo "Assicurati di aver installato Claude Code prima di procedere."
  echo "https://docs.anthropic.com/it/docs/claude-code/getting-started"
  echo ""
fi

# Crea la directory skills se non esiste
if [ ! -d "$SKILLS_DIR" ]; then
  echo "Creazione directory $SKILLS_DIR ..."
  mkdir -p "$SKILLS_DIR"
fi

# Installa ogni skill
INSTALLED=0
SKIPPED=0

for skill_dir in "$SOURCE_DIR"/*/; do
  skill_name=$(basename "$skill_dir")
  dest="$SKILLS_DIR/$skill_name"

  if [ -d "$dest" ]; then
    read -r -p "La skill '$skill_name' esiste già. Sovrascrivere? [s/N] " answer
    case "$answer" in
      [sS])
        cp -r "$skill_dir" "$dest"
        echo "  ✓ $skill_name (aggiornata)"
        INSTALLED=$((INSTALLED + 1))
        ;;
      *)
        echo "  - $skill_name (saltata)"
        SKIPPED=$((SKIPPED + 1))
        ;;
    esac
  else
    cp -r "$skill_dir" "$dest"
    echo "  ✓ $skill_name (installata)"
    INSTALLED=$((INSTALLED + 1))
  fi
done

echo ""
echo "Installazione completata: $INSTALLED installate, $SKIPPED saltate."
echo ""
echo "Skill disponibili in Claude Code:"
echo "  /architettura-progetto <root-progetto>"
echo "  /gestione-test <percorso-file>"
echo "  /revisione-codice <percorso-file>"
