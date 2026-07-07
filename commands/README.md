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

## Setup requis par repo

Les 4 commandes du cycle ticket → PR sont génériques (pas propres à un repo précis), mais chaque repo cible où elles s'exécutent doit fournir localement deux choses : un fichier de config pour les reviewers, et des permissions pour éviter les confirmations répétées sur `git`/`gh`/Linear.

### 1. `.claude/pr-config.json`

À créer à la racine du repo cible (pas ici, dans `claude-tooling`). Gabarit complet :

```json
{
  "reviewers": ["github-username-1", "github-username-2"],
  "base_branch": "main",
  "assignee": "@me",
  "confirm_before_push": true
}
```

Seul `reviewers` est **actif** — `/pr-new` le lit pour préremplir les reviewers du PR. `base_branch`, `assignee` et `confirm_before_push` sont **ignorés** : les valeurs correspondantes (`main`, `@me`, confirmation systématique) sont hardcodées dans les commandes. Les inclure dans le fichier ne change rien tant que les commandes ne sont pas modifiées pour les lire — voir la section « Configuration par repo » de `SKILL.md` du skill `workflow-dev-pur`.

Si tu n'as pas besoin de documenter les champs ignorés, le format minimal suffit :

```json
{ "reviewers": ["github-username-1", "github-username-2"] }
```

### 2. Permissions dans `.claude/settings.json`

À ajouter (fusionner, pas remplacer) dans `.claude/settings.json` du repo cible, pour que Claude Code n'interrompe pas le flux avec une confirmation à chaque appel `git`, `gh` ou Linear :

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(gh *)",
      "PowerShell(git *)",
      "PowerShell(gh *)",
      "mcp__claude_ai_Linear__get_issue",
      "mcp__claude_ai_Linear__get_issue_status",
      "mcp__claude_ai_Linear__list_issue_statuses",
      "mcp__claude_ai_Linear__list_issues",
      "mcp__claude_ai_Linear__list_projects",
      "mcp__claude_ai_Linear__list_teams",
      "mcp__claude_ai_Linear__list_users",
      "mcp__claude_ai_Linear__list_comments",
      "mcp__claude_ai_Linear__get_project",
      "mcp__claude_ai_Linear__get_team",
      "mcp__claude_ai_Linear__get_user",
      "mcp__claude_ai_Linear__save_issue"
    ]
  }
}
```

Seuls `get_issue` et `save_issue` sont appelés explicitement dans le texte des 4 commandes ; le reste de la liste Linear couvre les résolutions de noms/statuts/personnes que le modèle peut faire en cours de route sans que ce soit écrit littéralement dans une commande.

### Pourquoi ce fichier n'est jamais activé comme commande

`scripts/activate.sh` exclut explicitement `README.md` de `commands/` — dans `list_all`, `activate_all_commands` et `refresh_active`, chacun a un `[ "$name" = "README" ] && continue` (ou équivalent). Ce fichier ne sera donc jamais copié dans `~/.claude/commands/` ni proposé comme fausse commande `/README`.

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

Les 4 commandes existantes restreignent leur propre frontmatter à `Bash(git *)` et `Bash(gh *)`. Les outils MCP Linear qu'elles appellent (`get_issue`, `save_issue`) n'y sont pas listés — c'est le `permissions.allow` du `.claude/settings.json` **du repo cible** (section « Setup requis par repo » ci-dessus) qui les autorise réellement. À vérifier contre la doc Claude Code au moment d'écrire de nouvelles commandes si tu veux restreindre leur `allowed-tools` aussi précisément.
