#!/usr/bin/env bash
# install.sh — Installa le skill e gli agenti Claude Code aziendali
# Compatibile con macOS e Linux

set -e

SKILLS_DIR="$HOME/.claude/skills"
AGENTS_DIR="$HOME/.claude/agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS="$SCRIPT_DIR/skills"
SOURCE_AGENTS="$SCRIPT_DIR/agents"

echo "=== Installazione skill Claude Code aziendali ==="
echo ""

# Verifica che Claude Code sia installato
if ! command -v claude &>/dev/null; then
  echo "ATTENZIONE: il comando 'claude' non è stato trovato nel PATH."
  echo "Assicurati di aver installato Claude Code prima di procedere."
  echo "https://docs.anthropic.com/it/docs/claude-code/getting-started"
  echo ""
fi

# Crea le directory se non esistono
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"

INSTALLED=0
SKIPPED=0

# Installa le skill (directory)
echo "Installazione skill..."
for skill_dir in "$SOURCE_SKILLS"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  dest="$SKILLS_DIR/$skill_name"

  if [ -d "$dest" ]; then
    read -r -p "  La skill '$skill_name' esiste già. Sovrascrivere? [s/N] " answer
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

# Installa le skill file singoli (es. init-project.md)
for skill_file in "$SOURCE_SKILLS"/*.md; do
  [ -f "$skill_file" ] || continue
  skill_name=$(basename "$skill_file")
  dest="$SKILLS_DIR/$skill_name"

  if [ -f "$dest" ]; then
    read -r -p "  La skill '$skill_name' esiste già. Sovrascrivere? [s/N] " answer
    case "$answer" in
      [sS])
        cp "$skill_file" "$dest"
        echo "  ✓ $skill_name (aggiornata)"
        INSTALLED=$((INSTALLED + 1))
        ;;
      *)
        echo "  - $skill_name (saltata)"
        SKIPPED=$((SKIPPED + 1))
        ;;
    esac
  else
    cp "$skill_file" "$dest"
    echo "  ✓ $skill_name (installata)"
    INSTALLED=$((INSTALLED + 1))
  fi
done

# Installa gli agenti
echo ""
echo "Installazione agenti..."
for agent_file in "$SOURCE_AGENTS"/*.md; do
  [ -f "$agent_file" ] || continue
  agent_name=$(basename "$agent_file")
  dest="$AGENTS_DIR/$agent_name"

  if [ -f "$dest" ]; then
    read -r -p "  L'agente '$agent_name' esiste già. Sovrascrivere? [s/N] " answer
    case "$answer" in
      [sS])
        cp "$agent_file" "$dest"
        echo "  ✓ $agent_name (aggiornato)"
        INSTALLED=$((INSTALLED + 1))
        ;;
      *)
        echo "  - $agent_name (saltato)"
        SKIPPED=$((SKIPPED + 1))
        ;;
    esac
  else
    cp "$agent_file" "$dest"
    echo "  ✓ $agent_name (installato)"
    INSTALLED=$((INSTALLED + 1))
  fi
done

echo ""
echo "Installazione completata: $INSTALLED installati, $SKIPPED saltati."
echo ""
echo "Skill disponibili in Claude Code:"
echo "  /commit-push-pr [--no-push] [--draft-pr] [--squash]"
echo "  /java-spring-reviewer <percorso-file>"
echo "  /test-reviewer <percorso-file>"
echo "  /init-project"
