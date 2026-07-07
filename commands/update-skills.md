---
name: update-skills
description: Force une resynchronisation du repo claude-tooling (git pull + re-copie des skills/commandes actifs) sans quitter la session
disable-model-invocation: true
allowed-tools: Bash(bash *), Bash(git *), Read
---

# /update-skills — Forcer une resync du repo claude-tooling

Équivalent en session du script `scripts/update-skills.sh` (voir README racine, étape 6) : `git pull` du repo claude-tooling puis re-copie des skills/commandes actifs dans `~/.claude/`.

## Étapes

1. **Localiser le repo claude-tooling.** Il n'est pas au même endroit sur chaque poste. Dans l'ordre :
   - Lire `~/.claude/settings.json` et chercher le hook `SessionStart` qui pointe vers `.../scripts/daily-sync.sh` — le repo est le dossier deux niveaux au-dessus de ce fichier.
   - Sinon, essayer `~/dev/claude-tooling` (emplacement suggéré par le README).
   - Sinon, demander à l'utilisateur où il a cloné le repo.

2. **Lancer le script** :
   ```
   bash [repo]/scripts/update-skills.sh
   ```
   Le script fait le `git pull --ff-only` et le refresh lui-même ; ne pas les refaire à la main.

3. **Rapporter le résultat** tel quel : commits récupérés (ou « déjà à jour »), erreurs éventuelles (pull refusé pour divergence, réseau, etc.). Ne pas masquer une erreur — c'est justement l'intérêt de cette commande par rapport au hook silencieux.

4. **Rappeler la limite** : les copies dans `~/.claude/` sont à jour, mais la session courante a chargé les skills et commandes à son démarrage. Les changements (skill modifié, nouvelle commande...) prendront effet à la **prochaine** session Claude Code.

---
*Commande créée le 2026-07-07 — pendant équivalent en session de `scripts/update-skills.sh`*
