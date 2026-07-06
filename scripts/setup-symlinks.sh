#!/bin/bash
# setup-symlinks.sh — Active des skills et/ou des commandes de ce repo dans ~/.claude/
#
# Un skill actif est un lien symbolique dans ~/.claude/skills/ vers son dossier dans ce
# repo. Une commande active est un lien symbolique dans ~/.claude/commands/ vers son
# fichier .md dans ce repo. Désactiver = supprimer le lien (rm), rien à voir avec le
# repo lui-même.
#
# Usage :
#   ./scripts/setup-symlinks.sh --list                       # voir ce qui est disponible / actif
#   ./scripts/setup-symlinks.sh skill agile-testing           # activer un skill
#   ./scripts/setup-symlinks.sh command pr-new                # activer une commande
#   ./scripts/setup-symlinks.sh command --all                 # activer toutes les commandes
#   ./scripts/setup-symlinks.sh skill agile-testing command pr-new pr-upd   # mélanger

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
COMMANDS_DIR="$HOME/.claude/commands"

find_skill_path() {
  local name="$1"
  for base in "$REPO_ROOT/skills/purk-skills" "$REPO_ROOT/skills/external-skills"; do
    if [ -d "$base/$name" ] && [ -f "$base/$name/SKILL.md" ]; then
      echo "$base/$name"
      return 0
    fi
  done
  return 1
}

list_all() {
  echo "Skills disponibles :"
  local found=0
  for base in "$REPO_ROOT/skills/purk-skills" "$REPO_ROOT/skills/external-skills"; do
    [ -d "$base" ] || continue
    for dir in "$base"/*/; do
      [ -f "${dir}SKILL.md" ] || continue
      found=1
      local name origine
      name="$(basename "$dir")"
      origine="$(basename "$base")"
      if [ -L "$SKILLS_DIR/$name" ]; then
        echo "  ✅ $name ($origine, actif)"
      else
        echo "  ⬜ $name ($origine, inactif)"
      fi
    done
  done
  [ "$found" -eq 0 ] && echo "  (aucun skill trouvé)"

  echo ""
  echo "Commandes disponibles :"
  found=0
  if [ -d "$REPO_ROOT/commands" ]; then
    for file in "$REPO_ROOT/commands"/*.md; do
      [ -f "$file" ] || continue
      [ "$(basename "$file")" = "README.md" ] && continue
      found=1
      local name
      name="$(basename "$file" .md)"
      if [ -L "$COMMANDS_DIR/$name.md" ]; then
        echo "  ✅ $name (actif)"
      else
        echo "  ⬜ $name (inactif)"
      fi
    done
  fi
  [ "$found" -eq 0 ] && echo "  (aucune commande trouvée)"
  return 0
}

activate_skill() {
  local name="$1"
  local path
  path="$(find_skill_path "$name" || true)"
  if [ -z "$path" ]; then
    echo "❌ Skill introuvable : $name (voir --list)"
    return
  fi
  mkdir -p "$SKILLS_DIR"
  if [ -e "$SKILLS_DIR/$name" ] || [ -L "$SKILLS_DIR/$name" ]; then
    echo "⚠️  Skill $name déjà présent dans $SKILLS_DIR — rien fait (rm \"$SKILLS_DIR/$name\" pour relier à nouveau)"
    return
  fi
  ln -s "$path" "$SKILLS_DIR/$name"
  echo "✅ Skill $name activé → $SKILLS_DIR/$name"
}

activate_command() {
  local name="$1"
  local src="$REPO_ROOT/commands/$name.md"
  if [ ! -f "$src" ]; then
    echo "❌ Commande introuvable : $name (voir --list)"
    return
  fi
  mkdir -p "$COMMANDS_DIR"
  if [ -e "$COMMANDS_DIR/$name.md" ] || [ -L "$COMMANDS_DIR/$name.md" ]; then
    echo "⚠️  Commande $name déjà présente dans $COMMANDS_DIR — rien fait (rm \"$COMMANDS_DIR/$name.md\" pour relier à nouveau)"
    return
  fi
  ln -s "$src" "$COMMANDS_DIR/$name.md"
  echo "✅ Commande /$name activée → $COMMANDS_DIR/$name.md"
}

activate_all_commands() {
  for file in "$REPO_ROOT/commands"/*.md; do
    [ -f "$file" ] || continue
    local base
    base="$(basename "$file" .md)"
    [ "$base" = "README" ] && continue
    activate_command "$base"
  done
}

if [ "$#" -eq 0 ] || [ "$1" = "--list" ]; then
  list_all
  exit 0
fi

mode=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    skill)
      mode="skill"
      ;;
    command)
      mode="command"
      ;;
    --all)
      if [ "$mode" = "command" ]; then
        activate_all_commands
      else
        echo "❌ --all n'est supporté qu'après 'command' (ex: command --all)"
      fi
      ;;
    *)
      if [ "$mode" = "skill" ]; then
        activate_skill "$1"
      elif [ "$mode" = "command" ]; then
        activate_command "$1"
      else
        echo "❌ Précise 'skill' ou 'command' avant un nom (ex: skill agile-testing)"
      fi
      ;;
  esac
  shift
done
