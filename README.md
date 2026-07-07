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
│   ├── setup-symlinks.sh    ← Active un skill localement (lien symbolique)
│   └── daily-sync.sh        ← Utilisé par le hook de synchronisation automatique
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

Peut être cloné ailleurs si tu préfères — les scripts se repèrent par rapport à leur propre emplacement. Le reste de ce README suppose `~/dev/claude-tooling`.

### 2. Activer les skills voulus

```bash
cd ~/dev/claude-tooling
./scripts/setup-symlinks.sh --list                # voir ce qui est disponible / actif
./scripts/setup-symlinks.sh skill agile-testing    # activer ce skill
```

Chacun choisit ses skills actifs. Pour désactiver un skill plus tard : `rm ~/.claude/skills/agile-testing` (le repo n'est pas affecté).

### 3. Activer les commandes voulues

```bash
./scripts/setup-symlinks.sh command pr-new         # activer une commande précise
./scripts/setup-symlinks.sh command --all          # ou toutes les activer d'un coup
```

Les 4 commandes du cycle ticket → PR (`start-ticket`, `pr-new`, `pr-upd`, `pr-complete`) n'ont d'effet que sur demande explicite (`disable-model-invocation: true`), donc les activer toutes ne présente pas le même risque qu'activer tous les skills sans discernement — `command --all` est un bon défaut pour celles-là.

### 4. Enregistrer les serveurs MCP voulus

```bash
cd ~/dev/claude-tooling/mcp/leomed-mcp
uv sync
claude mcp add leomed -s user -- uv --directory ~/dev/claude-tooling/mcp/leomed-mcp run server.py
```

⚠️ **Si `leomed-wsl` existe déjà** (ancien enregistrement, avant ce repo) : `claude mcp remove leomed-wsl` d'abord — voir `mcp/leomed-mcp/README.md` pour le détail complet, y compris la config personnelle (`~/.leomed-mcp/config.toml`) qui n'est pas affectée par ce changement.

### 5. Synchronisation automatique (optionnel mais recommandé)

Ajouter dans `~/.claude/settings.json` :

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "~/dev/claude-tooling/scripts/daily-sync.sh" }] }
    ]
  }
}
```

Ajuste le chemin si tu as cloné ailleurs. Ce hook vérifie une fois par session s'il a déjà synchronisé aujourd'hui ; si non, il fait un `git pull` silencieux et affiche un message seulement s'il y avait du nouveau. Il ne bloque jamais une session, même si le pull échoue.

### 6. Alias manuel (pour forcer une resync à tout moment)

Ajouter dans `.bashrc` / `.zshrc` :

```bash
update-skills() {
  cd ~/dev/claude-tooling && git pull --ff-only
}
```

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

- **Un skill ne se déclenche plus après un `git pull`** — nouvelle session requise ; Claude Code charge les skills au démarrage, pas en cours de session.
- **Le hook `daily-sync.sh` ne semble rien faire** — vérifie `~/.claude/.last-skills-sync`, il contient la date de la dernière synchronisation. Supprime-le pour forcer une resync au prochain démarrage, ou lance `update-skills` directement.
- **`git pull` échoue avec un message de divergence** — `--ff-only` a volontairement refusé de créer un merge commit automatique. Résoudre à la main (`git log`, `git status`) plutôt que de forcer.
- **Un serveur MCP ne se connecte pas après un changement de chemin** — vérifier `claude mcp get [nom]` pour voir le chemin actuellement enregistré ; un `claude mcp remove` + `claude mcp add` est parfois plus fiable qu'une édition manuelle de `~/.claude.json`.
