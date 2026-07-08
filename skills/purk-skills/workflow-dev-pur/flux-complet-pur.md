# Flux complet de développement PUR-

## Vue d'ensemble

Le flux de bout en bout s'articule autour d'un ticket Linear (préfixe `LOG-`) et de quatre slash commands Claude Code qui automatisent les transitions entre les étapes. Chaque commande gère explicitement les transitions de statut Linear via le MCP Linear, ce qui rend le suivi serré sans dépendre de magic keywords dans les descriptions de PR.

```
Ticket Linear (LOG-XXXX)
        │
        ▼
   /start-ticket   ──►  branche <user gitHub>/LOG-XXXX créée, billet → In Progress
        │
        ▼
   Développement local, stage et commit fait par le développeur
        │
        ▼
   /pr-new         ──►  PR ouverte [LOG-XXXX] <summary>, billet → In Code Review
        │
        ▼
   Itération (révision par un pair, ajustements par le développeur)
        │
        ▼
   /pr-upd         ──►  description de la PR enrichie avec les nouveaux commits
        │
        ▼
   /pr-complete    ──►  squash merge, branche supprimée, billet → In QA
```

## Phase 1 — Démarrage : `/start-ticket`

**Point de départ** : un ticket Linear existant à l'état *Backlog* ou *Todo*, prêt à être pris en charge.

**Argument requis** : l'identifiant du billet (ex. `LOG-40`).

**Ce que la commande fait** :

- Vérifie qu'il n'y a pas de changements non commités ; sinon elle arrête.
- Checkout `main` et pull pour partir d'une base à jour.
- Récupère le nom d'utilisateur GitHub (`gh api user --jq .login`) et crée la branche `<gh_user>/<id>` (ex. `CathyCcot/LOG-1234`).
- Lit le billet Linear via le MCP Linear pour obtenir titre, objectif, critères d'acceptation et contexte ; affiche un résumé et garde le titre en mémoire pour `/pr-new`.
- Passe le billet Linear à **In Progress**.
- Vérifie que la transition a bien eu lieu ; si ce n'est pas le cas, affiche un avertissement et demande de faire le changement manuellement dans Linear.

**Vigilance** :

- Le billet doit être assigné au développeur avant de démarrer pour éviter une collision avec un autre dev.
- La commande utilise toujours `main` comme branche de base ; un repo qui s'attendrait à autre chose nécessiterait une adaptation de la commande.

## Phase 2 — Développement local

Phase manuelle, sans slash command dédiée. Le développeur travaille avec Claude Code dans VS Code, en s'appuyant sur GitLens pour la navigation Git et sur l'extension GitHub Pull Requests pour la visibilité.

**Conventions de commit** :

- Messages en anglais, au format conventionnel : préfixe `feat:`, `fix:`, `test:`, `docs:` ou `refactor:` suivi d'une description claire et de la référence du ticket (ex. `feat: add transmission polling (LOG-1234)`).
- Commit distinct pour les tests unitaires, séparé du commit de code de l'issue.
- Si le changement a un impact API ou sur les statuts : mettre à jour la documentation dans un commit de la même branche.
- Déplacements et renommages de fichiers avec `git mv` — jamais copier/supprimer — pour préserver l'historique (`git log --follow`).
- Pas de réécriture forcée de l'historique pendant le développement actif.
- Les messages de commit restent intacts dans l'historique. Le polish des descriptions destinées à la PR a lieu plus tard, dans `/pr-new`, qui reformule les commits en bullets clairs pour le corps de la PR sans toucher aux messages d'origine.

## Phase 3 — Ouverture de la PR : `/pr-new`

**Ce que la commande fait** :

- Identifie la branche courante et en extrait l'ID du billet (dernier segment après `/`).
- Identifie les commits depuis `main` (excluant les merges).
- Merge `origin/main` dans la branche courante pour intégrer les changements récents ; en cas de conflits, les affiche et aide à les résoudre avant de continuer.
- Lit le billet Linear pour récupérer le titre. Si le MCP est indisponible, utilise le titre mémorisé par `/start-ticket` ou demande au développeur.
- Reformule chaque commit en un bullet clair pour le corps de la PR (une ligne par commit, langage non technique si possible).
- Lit `.claude/pr-config.json` à la racine du repo pour obtenir la liste des reviewers.
- Construit un aperçu (titre `[<id>] <titre>`, branche, assignee, reviewers, description) et **demande confirmation** avant de procéder.
- Une fois confirmé : pousse la branche (`git push -u origin HEAD`) et crée la PR via `gh pr create` avec `--title`, `--body`, `--assignee @me`, `--reviewer <liste>`, `--base main`.
- Affiche l'URL de la PR.
- Passe le billet Linear à **In Code Review**.

**Vigilance** :

- Aucun magic keyword n'est inséré dans la description. Le lien Linear ↔ PR repose sur le nom de branche et le titre `[LOG-XXXX]`, et la transition de statut est faite explicitement par la commande via le MCP Linear.
- Si `.claude/pr-config.json` est absent ou mal formé, le comportement actuel n'est pas spécifié ; à confirmer au moment de l'utiliser sur un repo qui n'a pas encore le fichier.
- La checklist des critères d'acceptation du billet dans la description est une pratique recommandée, mais `/pr-new` ne l'ajoute pas automatiquement — l'ajouter manuellement après la création de la PR (interface GitHub ou `gh pr edit`).

## Phase 4 — Itération sur la PR : `/pr-upd`

**Quand l'utiliser** : après des commits additionnels suite à une revue ou un ajustement de portée.

**Ce que la commande fait** :

- Vérifie qu'un PR existe sur la branche courante ; sinon, arrête.
- Identifie les commits entre `origin/<branche>` et `HEAD` (commits non encore poussés, excluant les merges). Si aucun nouveau commit, le signale et demande s'il faut tout de même mettre à jour.
- Merge `origin/main` dans la branche courante ; en cas de conflits, les affiche et aide à les résoudre avant de continuer.
- Reformule les **nouveaux commits seulement** en bullets clairs.
- Récupère la description actuelle de la PR.
- Construit un aperçu (description actuelle + nouveaux bullets) et **demande confirmation**.
- Une fois confirmé : `git push` puis `gh pr edit --body "<description actuelle + nouveaux bullets>"`.
- Affiche l'URL de la PR mise à jour.

**Vigilance** :

- La commande ne touche pas au titre de la PR ni à la liste des reviewers. Si le titre du billet a changé ou si les reviewers doivent être ajustés, c'est à faire manuellement (`gh pr edit --title`, interface GitHub, etc.).
- Les ajouts manuels dans la description sont préservés : la commande ajoute en suffixe sans réécrire le bloc existant.
- La commande ne touche pas non plus au statut Linear : le billet reste à **In Code Review** pendant toutes les itérations.

## Phase 5 — Finalisation : `/pr-complete`

**Point de départ** : la PR est approuvée et les checks CI sont verts.

**Ce que la commande fait** :

- Identifie la branche courante et en extrait l'ID du billet.
- Vérifie qu'un PR existe et lit son état d'approbation (`gh pr view --json number,url,reviewDecision,state`).
  - Si aucun PR : arrête.
  - Si le PR n'est pas approuvé : affiche l'état et demande si on veut tout de même continuer.
- Affiche un résumé (numéro de PR, titre, état, action prévue) et **demande confirmation**.
- Une fois confirmé : `gh pr merge --squash --delete-branch`.
- Retourne sur `main` et pull.
- Supprime la branche locale (avec `-d`, ou `-D` en avertissant si nécessaire).
- Passe le billet Linear à **In QA**.

**Vigilance** :

- Le merge est toujours un **squash** ; la politique n'est pas configurable par repo.
- Le ticket Linear n'est pas fermé : il continue son cycle de vie vers **In QA**, où la suite (test, validation, etc.) est prise en charge par un autre acteur.
- Si le merge échoue (conflits tardifs, check qui devient rouge), la commande devrait s'arrêter proprement et indiquer l'étape à reprendre manuellement.

## Annexes

### Configuration par repo (`.claude/pr-config.json`)

Le fichier est lu par `/pr-new` pour obtenir la liste des reviewers à ajouter à la PR. Les exemples de configuration contiennent également les champs `base_branch`, `assignee` et `confirm_before_push`, mais ces valeurs sont actuellement codées en dur dans les commandes (`main`, `@me`, confirmation systématiquement demandée). Si ces champs doivent réellement devenir configurables, il faudra étendre les commandes en conséquence.

Exemple minimal :
```json
{
  "reviewers": ["slemire-purkinje"]
}
```

Exemple complet :
```json
{
  "reviewers": [
    "slemire-purkinje",
    "cathyCcot",
    "anguyenduc",
    "KimmyPurkinje"
  ]
}
```

### Lien Linear ↔ PR

Le lien entre un billet Linear et sa PR repose sur deux conventions :

- Le nom de branche (`<user gitHub>/LOG-XXXX`), créé par `/start-ticket`.
- Le titre de la PR (`[LOG-XXXX] <résumé>`), construit par `/pr-new`.

Les magic keywords Linear (`Fixes`, `Closes`, `Resolves`) ne sont **pas** utilisés par ce flux. Les transitions de statut Linear sont déclenchées explicitement par chaque commande via le MCP Linear (`mcp__claude_ai_Linear__save_issue`).

### Cycle de statut Linear pour un billet typique

| Étape          | Statut Linear      | Déclenché par     |
|----------------|--------------------|-------------------|
| Avant le dev   | *Backlog* / *Todo* | manuel            |
| Démarrage      | *In Progress*      | `/start-ticket`   |
| PR ouverte     | *In Code Review*   | `/pr-new`         |
| Itérations PR  | *In Code Review*   | (inchangé)        |
| PR mergée      | *In QA*            | `/pr-complete`    |
| Plus tard      | *Done* (ou autre)  | hors flux dev     |

### Outils impliqués dans le flux

- **Claude Code** : exécution des slash commands.
- **GitHub CLI (`gh`)** : opérations PR (création, mise à jour, merge, suppression de branche).
- **VS Code** : édition, navigation Git via GitLens, visualisation des PRs via l'extension GitHub Pull Requests.
- **MCP Linear** : récupération du contexte des tickets et transitions de statut.
- **MCP GitHub** *(prévu)* : pourrait remplacer certains appels CLI à terme.
