# claude-tooling

Dépôt partagé de tout ce que l'équipe utilise avec Claude Code : skills, commandes, et serveurs MCP. Un `git pull` synchronise tout ; chacun choisit ensuite quoi activer sur son propre poste.

## Structure

```
claude-tooling/
├── skills/
│   ├── purk-skills/        ← Skills qu'on développe et maintient nous-mêmes
│   │   └── agile-testing/  ← Méthodologie de test agile + spécificités par projet
│   └── external-skills/    ← Skills provenant d'ailleurs (marketplace, autres équipes...)
├── commands/                ← Commandes /nom-commande à effets de bord (Git, GitHub, Linear)
├── mcp/                     ← Serveurs MCP globaux (disponibles peu importe le projet ouvert)
│   └── leomed-mcp/          ← Pilote les 3 apps LeoMed en local (hub, api, webapp)
├── scripts/
│   ├── activate.sh          ← Active un skill ou une commande localement (copie gérée)
│   ├── daily-sync.sh        ← Utilisé par le hook de synchronisation automatique
│   └── update-skills.sh     ← Force une resync immédiate à la main (pull + refresh)
└── CHANGELOG.md             ← Changements structurels du repo
```

Chaque skill et chaque serveur MCP garde son propre `README.md` (et `CHANGELOG.md` s'il y a lieu) dans son dossier — ce fichier-ci ne documente que le repo dans son ensemble.

**Pourquoi `purk-skills/` et `external-skills/` séparés :** un skill externe ne devrait jamais être édité en place, sinon on perd la capacité de le mettre à jour proprement depuis sa source.

**Ce qui ne vit jamais ici :** un skill ou une commande **spécifique à un seul projet**. Ce repo-ci est réservé à ce qui doit être disponible **globalement**, peu importe le projet ouvert.

## Installation (une fois, par poste)

> **Windows :** lance les commandes de ce README depuis **Git Bash**, pas PowerShell/cmd.exe. Les scripts (`.sh`) sont écrits en bash ; depuis PowerShell, Windows essaie de les « ouvrir » via l'association de fichier au lieu de les exécuter (dialogue « Choisir une application »).

### 1. Cloner le repo

```bash
git clone [url-du-repo] ~/dev/claude-tooling
```

Peut être cloné n'importe où — les scripts se repèrent par rapport à leur propre emplacement, pas à un chemin fixe. Le reste de ce README utilise `[chemin]/claude-tooling` : remplace `[chemin]` par le dossier où tu as réellement cloné (dans l'exemple ci-dessus, ce serait `~` pour home, mais ce sera probablement différent chez toi).

### 2. Activer les skills voulus

```bash
cd [chemin]/claude-tooling
./scripts/activate.sh --list                # voir ce qui est disponible / actif
./scripts/activate.sh skill agile-testing    # activer ce skill
```

Chacun choisit ses skills actifs. Activer = copier dans `~/.claude/skills/` ; le hook de synchronisation (étape 5) rafraîchit automatiquement les copies actives, donc un `git pull` finit toujours par se propager. **Ne jamais éditer un skill directement dans `~/.claude/`** — les modifications y seraient écrasées au prochain rafraîchissement ; éditer dans le repo.

Pour désactiver un skill plus tard : `rm -rf ~/.claude/skills/agile-testing` (le repo n'est pas affecté, et la synchronisation ne réactive jamais un élément désactivé).

### 3. Activer les commandes voulues

```bash
./scripts/activate.sh command pr-new         # activer une commande précise
./scripts/activate.sh command --all          # ou toutes les activer d'un coup
```

Les 4 commandes du cycle ticket → PR (`start-ticket`, `pr-new`, `pr-upd`, `pr-complete`) n'ont d'effet que sur demande explicite (`disable-model-invocation: true`), donc les activer toutes ne présente pas le même risque qu'activer tous les skills sans discernement — `command --all` est un bon défaut pour celles-là.

### 4. Enregistrer les serveurs MCP voulus

```bash
cd [chemin]/claude-tooling/mcp/leomed-mcp
uv sync
claude mcp add leomed -s user -- uv --directory [chemin]/claude-tooling/mcp/leomed-mcp run server.py
```

⚠️ **Si `leomed-wsl` existe déjà** (ancien enregistrement, avant ce repo) : `claude mcp remove leomed-wsl` d'abord — voir `mcp/leomed-mcp/README.md` pour le détail complet, y compris la config personnelle (`~/.leomed-mcp/config.toml`) qui n'est pas affectée par ce changement.

### 5. Synchronisation automatique (optionnel mais recommandé)

Ajouter dans `~/.claude/settings.json` :

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "[chemin]/claude-tooling/scripts/daily-sync.sh" }] }
    ]
  }
}
```

Remplace `[chemin]` par le dossier où tu as cloné le repo. Ce hook vérifie une fois par session s'il a déjà synchronisé aujourd'hui ; si non, il fait un `git pull` silencieux, **re-copie les skills et commandes actifs** dans `~/.claude/` (c'est ce qui propage les mises à jour du repo sur ton poste), et affiche un message seulement s'il y avait du nouveau. Il ne bloque jamais une session, même si le pull échoue.

### 6. Forcer une resync à tout moment (`update-skills.sh`)

Le hook de l'étape 5 est automatique mais limité : une fois par jour, en silence, et seulement au démarrage d'une session Claude Code. Pour forcer une mise à jour immédiate — par exemple après avoir pushé un changement dans ce repo, ou pour voir les erreurs en clair quand quelque chose ne se propage pas — lancer depuis Git Bash :

```bash
cd [chemin]/claude-tooling
./scripts/update-skills.sh
```

Le script fait le `git pull` puis re-copie les skills/commandes actifs dans `~/.claude/`, en affichant ce qu'il fait et les erreurs éventuelles. Redémarre ensuite ta session Claude Code pour charger les changements.

Si tu es déjà dans une session Claude Code, la commande `/update-skills` (à activer comme les autres, étape 3) fait la même chose sans quitter la session — mais les changements ne seront chargés qu'à la session suivante, Claude Code lit les skills/commandes au démarrage.

## Ajouter un skill qu'on développe (`skills/purk-skills/`)

```bash
mkdir skills/purk-skills/nom-du-skill
# construire SKILL.md, references/, etc. — voir agile-testing/ comme exemple de structure
```

Documenter dans `CHANGELOG.md` (racine) et, si le skill le justifie, créer son propre `CHANGELOG.md` interne dès le départ.

## Ajouter un skill externe (`skills/external-skills/`)

**Copie figée (recommandé à notre échelle) :**
```bash
cp -r /chemin/vers/le/skill-telecharge skills/external-skills/nom-du-skill
```

**Git submodule (si tu veux suivre les mises à jour de la source) :**
```bash
git submodule add [url-du-skill-externe] skills/external-skills/nom-du-skill
```
Permet `git submodule update --remote`, mais ajoute de la complexité — à réserver aux cas où le suivi actif vaut le coût.

**Ne jamais éditer un skill externe en place** — voir `skills/external-skills/README.md`.

## Ajouter une commande (`commands/`)

Voir `commands/README.md`, section « Ajouter une commande ».

## Ajouter un serveur MCP (`mcp/`)

Voir `mcp/README.md` — sous-dossier avec code propre si c'est un vrai petit projet, simple `.mcp.json` avec `${VAR}` pour les secrets si c'est juste une définition de serveur distant.

## Dépannage

- **Un `git pull` ne semble pas pris en compte** — les skills/commandes actifs sont des copies dans `~/.claude/`, rafraîchies par le hook quotidien ou `./scripts/update-skills.sh`. Après un pull manuel, lancer `./scripts/activate.sh --refresh` (ou simplement `update-skills.sh`, qui refait le pull sans coûter plus cher). Et dans tous les cas : nouvelle session requise, Claude Code charge les skills au démarrage, pas en cours de session.
- **Une modification faite dans `~/.claude/skills/` a disparu** — comportement attendu : les copies actives sont écrasées à chaque rafraîchissement. Toujours éditer dans le repo (`[chemin]/claude-tooling`), jamais dans `~/.claude/`.
- **Le hook `daily-sync.sh` ne semble rien faire** — vérifie `~/.claude/.last-skills-sync`, il contient la date de la dernière synchronisation. Supprime-le pour forcer une resync au prochain démarrage, ou lance `./scripts/update-skills.sh` directement.
- **`git pull` échoue avec un message de divergence** — `--ff-only` a volontairement refusé de créer un merge commit automatique. Résoudre à la main (`git log`, `git status`) plutôt que de forcer.
- **Un serveur MCP ne se connecte pas après un changement de chemin** — vérifier `claude mcp get [nom]` pour voir le chemin actuellement enregistré ; un `claude mcp remove` + `claude mcp add` est parfois plus fiable qu'une édition manuelle de `~/.claude.json`.
