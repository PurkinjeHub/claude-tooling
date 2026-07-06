# Changelog — skill agile-testing

Suit l'évolution du **contenu** de ce skill (méthodologie, structure interne, attributions). Pour les changements au niveau du repo (ajout d'autres skills, scripts), voir `../../CHANGELOG.md` à la racine.

## [Non publié]

## 2026-07-06 — Intégration au repo partagé

- Le skill rejoint le repo `claude-tooling` sous `skills/purk-skills/agile-testing/`, activable par lien symbolique plutôt que copié directement dans `~/.claude/skills/`.
- Aucun changement de contenu méthodologique dans cette entrée — uniquement l'emplacement.

## Fusion et maturation (résumé des étapes précédentes)

- **Fusion initiale** — le skill personnel `agile-testing` (méthodologie générale) et l'ancien Projet claude.ai `qa-leomed` (spécifique à LeoMed) sont unifiés en un seul skill. `qa-leomed` devient `contextes/leomed/CONTEXTE.md`, dégraissé de la théorie déjà couverte à la racine. Ajout de `contextes/_template/` pour les futurs projets.
- **Correction d'attribution** — le S/M/L et le ratio 70/20/10 documentés dans `fragmentation-bourbonnais.md` sont en réalité ceux de Google (*How Google Tests Software*, Whittaker et al., 2012 ; ratio popularisé par Mike Wacker, Google Testing Blog, 2015), que Félix-Antoine Bourbonnais enseigne sans en être l'auteur. Sa contribution propre, la technique de fragmentation et de boulonnage, reste distincte et correctement attribuée. `automatisation.md` et le contexte LeoMed mis à jour en conséquence.
- **Répartition des rôles** — ajout de `references/roles-responsabilites.md` : matrice RACI développeur/analyste QA, règle de la couche unique de vérité, règle du tableau obligatoire. Ajout de `checklists/revue-test-e2e.md`, pendant QA des checklists dev existantes.
- **Généralisation du protocole d'analyse** — ajout de `references/protocole-analyse.md` (tableau d'analyse + snapshot JSON, applicable à tout projet). `contextes/leomed/CONTEXTE.md` n'en garde que son delta propre (colonne Navigateurs, champs `repos`/`browsers`).
- **Renommage `projets/` → `contextes/`** — pour éviter la confusion avec les Projets de claude.ai. `PROJET.md` renommé `CONTEXTE.md` par cohérence.
