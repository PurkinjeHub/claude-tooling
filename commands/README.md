# commands/

Commandes Claude Code invocables via `/nom-commande`. Contrairement aux skills dans `../skills/`, ce sont des actions ponctuelles à effets de bord (Git, GitHub, Linear) — jamais déclenchées automatiquement par Claude (`disable-model-invocation: true` sur chacune), toujours sur demande explicite.

Rangées à plat ici, sans sous-dossier — voir « Ajouter une commande » plus bas pour savoir quand ça changerait.

## Séquences documentées

### Cycle ticket → PR

```
/start-ticket [id]  →  /pr-new  →  /pr-upd (au besoin, répétable)  →  /pr-complete
```

- **`/start-ticket`** crée la branche, passe le billet Linear en *In Progress*, garde le titre en mémoire pour `/pr-new`.
- **`/pr-new`** ouvre le PR, passe le billet en *In code Review*.
- **`/pr-upd`** ajoute les nouveaux commits à un PR déjà ouvert — répétable autant de fois que nécessaire pendant la révision.
- **`/pr-complete`** merge (squash), nettoie les branches, passe le billet en *In QA*.

Chaque commande vérifie ses propres préconditions (branche parente encore sur le remote, PR existant, PR approuvé) et demande confirmation avant toute action destructive — elles n'assument jamais l'état laissé par la précédente.

## Catalogue

| Commande | Description | Effets de bord | Fait partie de |
|---|---|---|---|
| `/start-ticket` | Démarre le travail sur un billet Linear | Crée une branche, modifie le statut Linear | Cycle ticket → PR |
| `/pr-new` | Crée et envoie un PR en révision | Push, crée un PR, modifie le statut Linear | Cycle ticket → PR |
| `/pr-upd` | Met à jour un PR existant | Push, modifie la description du PR | Cycle ticket → PR |
| `/pr-complete` | Finalise un PR approuvé | Squash merge, supprime des branches, modifie le statut Linear | Cycle ticket → PR |
| `/update-skills` | Force une resync du repo claude-tooling (pull + refresh) | Pull du repo, écrase les copies actives dans `~/.claude/` | — |

## Dépendance commune

Les 4 commandes du cycle ticket → PR attendent un `.claude/pr-config.json` à la racine du repo où elles s'exécutent (reviewers par défaut). Ce fichier vit dans chaque repo de projet (LeoMed ou futur), pas ici — ces commandes sont génériques, pas propres à LeoMed.

## Ajouter une commande

1. Créer le fichier `nom-commande.md` ici, à plat, avec un frontmatter minimal :
   ```yaml
   ---
   name: nom-commande
   description: Une phrase claire de ce que ça fait
   disable-model-invocation: true   # si la commande a un effet de bord
   allowed-tools: Bash(git *)        # restreindre aux outils réellement utilisés
   ---
   ```
2. Ajouter une ligne au tableau catalogue ci-dessus (« Fait partie de » = `—` si elle est indépendante).
3. Si elle rejoint ou crée une séquence, documenter cette séquence dans sa propre sous-section, comme « Cycle ticket → PR » ci-dessus.
4. Logger l'ajout dans `../CHANGELOG.md` (racine du repo).
5. L'activer sur ton poste : `../scripts/activate.sh command nom-commande` (voir le README racine, étape d'installation).

**Quand passer d'un fichier à un sous-dossier :** si une commande a besoin de fichiers de support (gabarit, script séparé), ou si plusieurs commandes non reliées au cycle ticket → PR commencent à former leur propre groupe cohérent — pas avant.

## Note sur `allowed-tools`

Les 4 commandes existantes restreignent `Bash(git *)` et `Bash(gh *)`. Elles utilisent aussi des outils MCP Linear (`mcp__..._Linear__get_issue`, `save_issue`) qui ne sont pas explicitement listés dans `allowed-tools` — à vérifier contre la doc Claude Code au moment d'écrire de nouvelles commandes si tu veux les restreindre aussi précisément.
