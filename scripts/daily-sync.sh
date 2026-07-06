#!/bin/bash
# daily-sync.sh — Appelé par un hook SessionStart de Claude Code (voir README, section
# « Installation », étape 3). Met à jour ce repo au plus une fois par jour, et reste
# silencieux (et rapide) le reste du temps, comme demandé par la doc Claude Code pour
# les hooks SessionStart.
#
# Ce script ne bloque jamais une session : il se termine toujours avec exit 0, même
# si le pull échoue (pas de réseau, conflit, etc.). En cas de doute, lancer
# `update-skills` à la main (voir README) pour voir l'erreur réelle.

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

# Ne rien afficher si rien n'a changé — un message par session serait du bruit
if [ -n "$AFTER" ] && [ "$BEFORE" != "$AFTER" ]; then
  echo "🔄 claude-tooling mis à jour ($(git log -1 --format=%s 2>/dev/null))"
fi

exit 0
