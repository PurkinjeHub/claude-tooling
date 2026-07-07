# Changelog — claude-tooling (repo)

Ce fichier suit les changements **structurels** du repo (ajout/retrait de skills, commandes, serveurs MCP, changements à l'organisation des dossiers ou aux scripts). Pour l'évolution du contenu d'un skill ou serveur donné, voir son propre `CHANGELOG.md`.

## [Non publié]

- Ajout de `skills/purk-skills/workflow-dev-pur/` : conventions de développement PurkinjeHub (tickets Linear `LOG-`, cycle ticket → PR via les 4 slash commands, format de PR, statuts Linear). Documente le comportement attendu de ces commandes ; leur implémentation reste dans `commands/`. `commands/README.md` mis à jour en parallèle (section « Setup requis par repo » : `.claude/pr-config.json` et permissions à ajouter dans chaque repo cible).
- Ajout de `scripts/update-skills.sh` : resync manuelle immédiate (pull + refresh), remplace l'alias shell `update-skills` que le README demandait d'ajouter dans `.bashrc`/`.zshrc` — trop de friction pour qui ne connaît pas la config de son shell, alors qu'un script dans le repo se lance directement depuis Git Bash. README (étape 6, Dépannage) et commentaire de `daily-sync.sh` mis à jour en conséquence.
- Ajout de la commande `/update-skills` : équivalent en session du script ci-dessus, pour resynchroniser sans quitter Claude Code. Retrouve le repo via le hook `SessionStart` de `~/.claude/settings.json`. Les changements synchronisés ne sont chargés qu'à la session suivante (limite documentée dans la commande et le README).

## 2026-07-07 — Activation par copies gérées (fin des symlinks)

- `scripts/setup-symlinks.sh` remplacé par `scripts/activate.sh` : l'activation copie maintenant les skills/commandes dans `~/.claude/` au lieu de créer des liens symboliques. Motif : sur Windows, les vrais symlinks exigent le Mode développeur, et Git Bash retombe silencieusement sur une copie quand il ne peut pas les créer — résultat, des copies figées qui dérivaient du repo sans avertissement (constaté sur poste : skill et commandes actifs datant d'avant la migration, sans le frontmatter `disable-model-invocation`). Même interface (`--list`, `skill <nom>`, `command <nom>`, `command --all`), plus un mode `--refresh` qui re-copie tout ce qui est actif.
- `scripts/daily-sync.sh` appelle `activate.sh --refresh` après son pull quotidien : c'est maintenant lui qui propage les mises à jour du repo vers `~/.claude/`. Un élément désactivé (`rm`) n'est jamais réactivé par le refresh.
- README : note « lancer depuis Git Bash » pour Windows (PowerShell ouvre les `.sh` via l'association de fichier au lieu de les exécuter), alias `update-skills` enrichi du `--refresh`, avertissement de ne jamais éditer dans `~/.claude/` directement.

## 2026-07-06 (2) — Renommage et élargissement : skills-claude → claude-tooling

- Renommage du repo `skills-claude` → `claude-tooling` : il couvre maintenant plus que des skills.
- `purk-skills/` et `external-skills/` déplacés sous `skills/` (`skills/purk-skills/`, `skills/external-skills/`) pour laisser la racine du repo parallèle entre `skills/`, `commands/`, `mcp/`.
- Ajout de `commands/` : 4 commandes existantes migrées (`start-ticket`, `pr-new`, `pr-upd`, `pr-complete`), avec ajout du frontmatter manquant (`disable-model-invocation: true`, `allowed-tools`) — elles n'avaient aucune protection contre un déclenchement automatique par Claude avant cette migration. Ajout d'un `commands/README.md` documentant le cycle ticket → PR et le catalogue complet.
- Ajout de `mcp/` : migration de `leomed-mcp` (serveur MCP local pilotant les 3 apps LeoMed — hub, api, webapp), auparavant enregistré au scope utilisateur sous le nom `leomed-wsl` avec un chemin propre à un seul poste. Ajout d'un `mcp/README.md` documentant la distinction sous-dossier (code propre) vs `.mcp.json` (définition seule, secrets en `${VAR}`).
- `scripts/setup-symlinks.sh` étendu pour activer aussi bien des skills (dossier → `~/.claude/skills/`) que des commandes (fichier → `~/.claude/commands/`), avec un mode `command --all` pour activer toutes les commandes d'un coup.
- Correctifs de robustesse sur les scripts : code de sortie de `setup-symlinks.sh --list` (un `[ ] && echo` en fin de fonction faisait sortir le script en erreur même quand tout fonctionnait) ; `daily-sync.sh` créait le dossier parent du marqueur avant d'y écrire (échouait silencieusement si `~/.claude/` n'existait pas encore).

## 2026-07-06 (1) — Création du repo

- Création du repo `skills-claude`, structure `purk-skills/` / `external-skills/`
- Ajout de `purk-skills/agile-testing/` (issu de la fusion du skill personnel agile-testing et de l'ancien Projet claude.ai `qa-leomed` — voir son propre CHANGELOG pour le détail)
- Ajout de `scripts/setup-symlinks.sh` — activation sélective des skills par lien symbolique dans `~/.claude/skills/`
- Ajout de `scripts/daily-sync.sh` — synchronisation quotidienne automatique via hook `SessionStart`
