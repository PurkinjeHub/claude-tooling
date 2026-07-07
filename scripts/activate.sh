#!/bin/bash
# activate.sh — Active des skills et/ou des commandes de ce repo dans ~/.claude/
#
# Un skill actif est une copie de son dossier du repo dans ~/.claude/skills/. Une
# commande active est une copie de son fichier .md dans ~/.claude/commands/. On copie
# (plutôt que de créer des liens symboliques) parce que les vrais symlinks demandent
# des privilèges spéciaux sur Windows — Git Bash retombe alors silencieusement sur une
# copie, ce qui donnait des copies figées qui dérivaient du repo sans que personne ne
# s'en aperçoive. Ici la copie est assumée : `daily-sync.sh` re-copie les éléments
# actifs après chaque synchronisation (voir --refresh), donc un `git pull` finit
# toujours par se propager.
#
# Conséquence : ne jamais éditer un skill/une commande dans ~/.claude/ directement —
# toute modification locale y sera écrasée au prochain refresh. Éditer dans le repo.
#
# Désactiver = supprimer la copie : rm -rf ~/.claude/skills/nom-du-skill (le repo
# n'est pas affecté, et le refresh ne réactive jamais un élément supprimé).
#
# Usage :
#   ./scripts/activate.sh --list                       # voir ce qui est disponible / actif
#   ./scripts/activate.sh skill agile-testing           # activer (ou rafraîchir) un skill
#   ./scripts/activate.sh command pr-new                # activer une commande
#   ./scripts/activate.sh command --all                 # activer toutes les commandes
#   ./scripts/activate.sh skill agile-testing command pr-new pr-upd   # mélanger
#   ./scripts/activate.sh --refresh                     # re-copier tout ce qui est actif
#                                                       # (utilisé par daily-sync.sh)

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

skill_is_active() {
  [ -e "$SKILLS_DIR/$1" ]
}

command_is_active() {
  [ -e "$COMMANDS_DIR/$1.md" ]
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
      if skill_is_active "$name"; then
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
      if command_is_active "$name"; then
        echo "  ✅ $name (actif)"
      else
        echo "  ⬜ $name (inactif)"
      fi
    done
  fi
  [ "$found" -eq 0 ] && echo "  (aucune commande trouvée)"
  return 0
}

# copy_skill / copy_command : rm avant cp pour que les fichiers supprimés du repo
# disparaissent aussi de la copie active (cp -R sur un dossier existant fusionne).
copy_skill() {
  local name="$1" path="$2"
  mkdir -p "$SKILLS_DIR"
  rm -rf "${SKILLS_DIR:?}/$name"
  cp -R "$path" "$SKILLS_DIR/$name"
}

copy_command() {
  local name="$1"
  mkdir -p "$COMMANDS_DIR"
  rm -f "$COMMANDS_DIR/$name.md"
  cp "$REPO_ROOT/commands/$name.md" "$COMMANDS_DIR/$name.md"
}

activate_skill() {
  local name="$1"
  local path verb="activé"
  path="$(find_skill_path "$name" || true)"
  if [ -z "$path" ]; then
    echo "❌ Skill introuvable : $name (voir --list)"
    return
  fi
  skill_is_active "$name" && verb="rafraîchi"
  copy_skill "$name" "$path"
  echo "✅ Skill $name $verb → $SKILLS_DIR/$name"
}

activate_command() {
  local name="$1"
  local verb="activée"
  if [ ! -f "$REPO_ROOT/commands/$name.md" ]; then
    echo "❌ Commande introuvable : $name (voir --list)"
    return
  fi
  command_is_active "$name" && verb="rafraîchie"
  copy_command "$name"
  echo "✅ Commande /$name $verb → $COMMANDS_DIR/$name.md"
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

# Re-copie silencieusement tout ce qui est déjà actif (appelé par daily-sync.sh après
# le pull quotidien). Ne réactive jamais rien : un élément désactivé (rm) le reste.
refresh_active() {
  for base in "$REPO_ROOT/skills/purk-skills" "$REPO_ROOT/skills/external-skills"; do
    [ -d "$base" ] || continue
    for dir in "$base"/*/; do
      [ -f "${dir}SKILL.md" ] || continue
      local name
      name="$(basename "$dir")"
      skill_is_active "$name" && copy_skill "$name" "$dir"
    done
  done
  if [ -d "$REPO_ROOT/commands" ]; then
    for file in "$REPO_ROOT/commands"/*.md; do
      [ -f "$file" ] || continue
      local name
      name="$(basename "$file" .md)"
      [ "$name" = "README" ] && continue
      command_is_active "$name" && copy_command "$name"
    done
  fi
  return 0
}

if [ "$#" -eq 0 ] || [ "$1" = "--list" ]; then
  list_all
  exit 0
fi

if [ "$1" = "--refresh" ]; then
  refresh_active
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
