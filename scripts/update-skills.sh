#!/bin/bash
# update-skills.sh — Force une resynchronisation immédiate : git pull + re-copie des
# skills/commandes actifs dans ~/.claude/ (via activate.sh --refresh).
#
# Contrairement au hook quotidien (daily-sync.sh), ce script est fait pour être lancé
# à la main : il ne se limite pas à une fois par jour et affiche les erreurs en clair
# au lieu de les avaler. C'est l'outil de dépannage quand une mise à jour ne semble
# pas se propager (voir README, section « Dépannage »).
#
# Usage (depuis Git Bash sur Windows) :
#   ./scripts/update-skills.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$REPO_ROOT"
echo "📦 git pull dans $REPO_ROOT..."
git pull --ff-only

echo "🔄 Re-copie des skills/commandes actifs dans ~/.claude/..."
bash "$REPO_ROOT/scripts/activate.sh" --refresh

echo "✅ Synchronisation terminée. Redémarre ta session Claude Code pour charger les changements."
