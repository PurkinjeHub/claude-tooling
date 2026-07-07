#!/bin/bash
# daily-sync.sh — Appelé par un hook SessionStart de Claude Code (voir README, section
# « Installation »). Met à jour ce repo au plus une fois par jour, re-copie les skills
# et commandes actifs dans ~/.claude/ (voir activate.sh --refresh), et reste silencieux
# (et rapide) le reste du temps, comme demandé par la doc Claude Code pour les hooks
# SessionStart.
#
# Ce script ne bloque jamais une session : il se termine toujours avec exit 0, même
# si le pull échoue (pas de réseau, conflit, etc.). En cas de doute, lancer
# `scripts/update-skills.sh` à la main (voir README) pour voir l'erreur réelle.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MARKER="$HOME/.claude/.last-skills-sync"
TODAY=$(date +%F)

# Déjà synchronisé aujourd'hui → sortir tout de suite, reste rapide (exigence SessionStart)
if [ -f "$MARKER" ] && [ "$(cat "$MARKER" 2>/dev/null)" = "$TODAY" ]; then
  exit 0
fi

cd "$REPO_ROOT" 2>/dev/null || exit 0

BEFORE=$(git rev-parse HEAD 2>/dev/null)
git pull --ff-only --quiet 2>/dev/null
AFTER=$(git rev-parse HEAD 2>/dev/null)

mkdir -p "$(dirname "$MARKER")" 2>/dev/null
echo "$TODAY" > "$MARKER" 2>/dev/null

# Re-copier les skills/commandes actifs pour propager le pull dans ~/.claude/.
# Lancé même sans nouveau commit : ça ne coûte presque rien une fois par jour et ça
# rattrape aussi un pull manuel fait entre-temps.
bash "$REPO_ROOT/scripts/activate.sh" --refresh 2>/dev/null

# Ne rien afficher si rien n'a changé — un message par session serait du bruit
if [ -n "$AFTER" ] && [ "$BEFORE" != "$AFTER" ]; then
  echo "🔄 claude-tooling mis à jour ($(git log -1 --format=%s 2>/dev/null))"
fi

exit 0
