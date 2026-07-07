---
name: workflow-dev-pur
description: Conventions de développement pour les projets PurkinjeHub (tickets Linear préfixés LOG-). Utilise ce skill dès que l'utilisateur mentionne un ticket LOG-XXXX, une branche commençant par le username de gitHub de l'utilisateur, un des slash commands /start-ticket, /pr-new, /pr-upd, /pr-complete, un fichier .claude/pr-config.json, ou toute action sur les pull requests, le flux Linear ↔ GitHub, le format de titre de PR, ou la configuration de reviewers par repo. Utilise aussi ce skill si l'utilisateur demande de l'aide pour démarrer un ticket, ouvrir une PR, mettre à jour une PR, ou la finaliser dans un repo PurkinjeHub.
---

# Workflow dev PurkinjeHub (tickets LOG-)

Tu assistes le développeur à PurkinjeHub. Ce skill encode ses conventions de développement et son outillage Linear ↔ GitHub. Le détail complet du flux est dans `flux-complet-pur.md` ; consulte ce fichier dès que tu as besoin de comprendre l'enchaînement précis ou le comportement détaillé d'une commande.

## Identités et préfixes

- **Utilisateur GitHub** : par exemple `CathyCcot`.
- **Préfixe de branche** : `<user gitHub>/<id-ticket>`, par exemple `CathyCcot/LOG-1234`.
- **Préfixe des tickets Linear** : `LOG-` (ex. `LOG-1234`).

## Slash commands de référence

Quatre slash commands automatisent le flux de bout en bout. Chacune gère explicitement les transitions de statut Linear via le MCP Linear — il n'y a pas de magic keywords dans les PRs.

- `/start-ticket <id>` — démarre le travail. Checkout `main`, pull, création de la branche `<user gitHub>/<id>`, lecture du billet via MCP Linear. Ticket Linear passe à **In Progress**.
- `/pr-new` — ouvre la PR initiale. Merge `origin/main` dans la branche, reformule les commits en bullets clairs, lit `.claude/pr-config.json` pour les reviewers, demande confirmation, puis push + `gh pr create`. Ticket passe à **In code Review**.
- `/pr-upd` — ajoute les nouveaux commits (depuis `origin/<branche>`) à la description de la PR existante. **Ne touche pas** au titre, aux reviewers, ni au statut Linear. Les ajouts manuels dans la description sont préservés.
- `/pr-complete` — squash merge, suppression de branche distante et locale, retour sur `main` et pull. Ticket passe à **In QA** (pas Done — la suite est faite par un autre acteur).

Quand le développeur invoque l'une de ces commandes ou discute de leur comportement, présume qu'elles existent et fonctionnent comme documenté. Ne lui propose pas d'équivalents manuels sauf si il le demande explicitement.

## Conventions de pull request

- **Format de titre obligatoire** : `[<id>] <résumé>` avec l'ID Linear entre crochets droits, en majuscules (ex. `[LOG-1234] Refactor patient lookup`).
- **Pas de magic keywords** (`Fixes`, `Closes`, `Resolves`) dans la description. Le lien Linear ↔ PR repose sur le nom de branche et le titre.
- **Corps de la PR** : construit par `/pr-new` en reformulant chaque commit en bullet clair (une ligne par commit, langage non technique quand possible). Pas de `--fill-verbose`.
- **Base** : toujours `main` (hardcodé dans les commandes).
- **Assignee** : toujours `@me` (hardcodé).
- **Merge** : toujours un squash via `gh pr merge --squash --delete-branch`. Non configurable par repo actuellement.

## Configuration par repo

Chaque repo contient `.claude/pr-config.json` à sa racine, lu par `/pr-new` pour la liste des reviewers. Format minimal :

```json
{ "reviewers": ["github-username-1", "github-username-2"] }
```

D'autres champs peuvent apparaître dans des exemples (`base_branch`, `assignee`, `confirm_before_push`) mais sont **actuellement ignorés** — les valeurs correspondantes sont hardcodées dans les commandes. Rendre ces champs effectifs demanderait une évolution des commandes, pas une simple édition de config.

Si `.claude/pr-config.json` est absent ou mal formé, signale-le explicitement plutôt que d'inventer une configuration silencieuse.

## Cycle de statut Linear

| Étape          | Statut          | Déclenché par    |
|----------------|-----------------|------------------|
| Avant le dev   | Backlog / Todo  | manuel           |
| Démarrage      | In Progress     | `/start-ticket`  |
| PR ouverte     | In code Review  | `/pr-new`        |
| Itérations PR  | In code Review  | (inchangé)       |
| PR mergée      | In QA           | `/pr-complete`   |
| Plus tard      | Done / autre    | hors flux dev    |

Important : `/pr-complete` **ne ferme pas** le ticket. Il passe à *In QA* pour qu'un autre acteur (QA, test, validation) prenne la suite.

## Conventions de commit

- Messages clairs et concis, en français.
- Les messages de commit d'origine **ne sont jamais réécrits**. Le polish a lieu uniquement dans la reformulation pour le corps de la PR (`/pr-new`).
- Pas de réécriture forcée de l'historique (rebase interactif, amend sur des commits poussés, etc.) sans confirmation explicite.

## Communication

- Réponds en français.
- Style professionnel mesuré et structuré ; évite le familier et le colloquial.
- Sois direct et précis ; pas de flatterie ni de remplissage.
- Privilégie la prose structurée aux listes à puces, sauf si la nature du contenu les exige.

## Comportements attendus

- **Actions destructives ou irréversibles** (force-push, suppression de branche, merge, reset, `git clean -fd`) : demande confirmation explicite en montrant la commande exacte avant d'exécuter.
- **Confirmation systématique** : chaque slash command affiche un aperçu et demande confirmation avant d'agir. Respecte ce pattern si tu proposes une action équivalente en dehors d'une commande.
- **Conventions ou détails non clairs** : demande plutôt que de présumer.
- **Hors périmètre** : si la question sort du flux dev LOG- (RoboHelp, communication interne, autres projets), réponds normalement mais n'applique pas ces conventions à des contextes où elles ne valent pas.
