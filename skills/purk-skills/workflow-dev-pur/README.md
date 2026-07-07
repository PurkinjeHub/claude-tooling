# workflow-dev-pur — Skill d'équipe Claude Code

Skill de référence pour le flux de développement chez PurkinjeHub : conventions Git/GitHub, cycle de statut Linear (tickets préfixés `LOG-`), et comportement attendu des quatre slash commands qui automatisent le cycle ticket → PR (`/start-ticket`, `/pr-new`, `/pr-upd`, `/pr-complete`).

Ce skill documente le **comportement** attendu de ces commandes (conventions, statuts, communication) ; leur **implémentation** vit dans `commands/` à la racine du repo.

## Installation

Ce skill vit dans le repo partagé `claude-tooling`, sous `skills/purk-skills/workflow-dev-pur/`. Voir le [`README.md`](../../../README.md) à la racine du repo pour l'installation complète (clone, activation, synchronisation automatique) — pas de clone séparé pour ce skill seul.

Les quatre slash commands du cycle ticket → PR sont un complément indissociable de ce skill ; voir [`commands/README.md`](../../../commands/README.md) à la racine, section « Setup requis par repo », pour la configuration à faire dans chaque repo cible (`.claude/pr-config.json` et permissions).

## Structure

```
workflow-dev-pur/
├── SKILL.md              ← Point d'entrée, chargé automatiquement
├── README.md             ← Ce fichier
└── flux-complet-pur.md   ← Détail phase par phase du flux (chargé à la demande)
```

Pas de `references/` ni de `contextes/` ici : contrairement à `agile-testing`, ce skill n'a qu'un seul contexte (PurkinjeHub) et pas de variation par projet à isoler.

## Usage

Le skill se déclenche dès qu'un contexte de développement PurkinjeHub est détecté : mention d'un ticket `LOG-XXXX`, d'une branche `<user gitHub>/LOG-XXXX`, d'un des quatre slash commands, ou toute question sur le flux Linear ↔ GitHub.

Exemples de prompts qui activeront le skill :

- *« /start-ticket LOG-1234 »*
- *« Pourquoi mon `/pr-new` n'a pas mis à jour les reviewers? »*
- *« Le titre de PR doit-il avoir l'ID Linear? »*
- *« /pr-complete ferme-t-il le ticket? »*

## Maintenance

Quand une convention d'équipe évolue (format de PR, statuts Linear, comportement d'une commande), la mettre à jour ici en premier — `SKILL.md` pour les règles générales, `flux-complet-pur.md` pour le détail phase par phase. Si le comportement réel d'une commande change, mettre à jour ce skill et `commands/README.md` ensemble : le premier documente l'intention, le second l'implémentation.

Pas de `CHANGELOG.md` propre à ce skill pour l'instant ; consulter le `CHANGELOG.md` racine du repo pour l'historique structurel.
