# Protocole d'analyse — Tableau et snapshot

> Applicable à tout projet. Ce protocole prend le relais une fois qu'un contexte actif a été identifié (voir `../SKILL.md`, section « Détection du contexte actif ») et que ses éventuelles étapes préalables sont passées (ex. un gate de validation de ticket, si le `CONTEXTE.md` du projet en définit un — voir `../contextes/leomed/CONTEXTE.md` pour un exemple avec Linear).

## Principe

**Avant d'écrire le moindre test, produire un tableau d'analyse qui couvre tous les critères d'acceptation, avec un propriétaire assigné à chacun — développeur ou analyste QA.** Personne ne commence à coder avant que ce tableau soit validé. C'est le mécanisme qui rend concrètes les deux règles de `roles-responsabilites.md` (couche unique de vérité, tableau obligatoire).

Ce protocole s'applique **peu importe qui lance la conversation** — développeur ou analyste QA — pour que les deux rôles voient la même répartition avant de commencer.

## Étape 1 — Identifier tous les critères d'acceptation

Extraire du besoin (ticket, story, description de feature) la liste complète des critères d'acceptation. Chaque critère devra apparaître dans le tableau — aucun ne peut rester en dehors.

## Étape 2 — Construire le tableau

### Colonnes obligatoires (tout projet)

| # | Scénario de test | AC lié | Catégorie | Niveau | Propriétaire | Auto/Manuel | Framework |
|---|---|---|---|---|---|---|---|
| 1 | ... | AC-1 | Unitaire/Composante/E2E | Small/Medium/Large | Développeur/Analyste QA | Auto | (nom du framework) |

- **AC lié** — chaque critère d'acceptation du besoin doit apparaître dans au moins une ligne. Aucune ligne orpheline (sans AC), aucun AC sans ligne.
- **Catégorie / Niveau** — voir `quadrants.md`, `pyramide-google.md`, `fragmentation-bourbonnais.md`.
- **Propriétaire** — développeur ou analyste QA, selon `roles-responsabilites.md`. En cas de doute, appliquer la règle de la couche unique de vérité.
- **Auto/Manuel** — voir `automatisation.md` pour les critères généraux ; un projet peut préciser ses propres critères dans son `CONTEXTE.md`.

### Colonnes optionnelles (ajoutées par le projet si pertinent)

Un `CONTEXTE.md` peut étendre ce tableau avec des colonnes propres à son contexte — par exemple une colonne **Navigateurs** pour un projet avec exigence multi-navigateur (voir `contextes/leomed/CONTEXTE.md`), ou une colonne **Environnement** pour un projet avec plusieurs cibles de déploiement. Ces colonnes s'ajoutent au socle commun, elles ne le remplacent pas.

### Format de présentation

```
## Analyse des tests — [Identifiant] : [Titre]

### Critères d'acceptation identifiés
[Liste des critères d'acceptation]

### Tableau d'analyse

| # | Scénario de test | AC lié | Catégorie | Niveau | Propriétaire | Auto/Manuel | Framework |
|---|-----------------|--------|-----------|--------|--------------|-------------|-----------|
| 1 | ... | AC-1 | ... | ... | ... | Auto | ... |
| 2 | ... | AC-1 | ... | ... | ... | Manuel | — |
```

**Attendre la validation avant de générer le code.**

## Étape 3 — Sauvegarder le snapshot

Une fois le tableau validé et **avant de générer les tests**, sauvegarder automatiquement un fichier snapshot.

**Chemin :** `.claude/qa-snapshots/[identifiant]-todo-snapshot.json`

L'identifiant est le numéro de ticket si le projet en utilise un (ex. `LOG-42`), ou un nom de feature court sinon.

**Schéma de base (tout projet) :**

```json
{
  "identifiant": "...",
  "snapshot_date": "YYYY-MM-DD",
  "snapshot_status": "todo",
  "title": "...",
  "description": "...",
  "acceptance_criteria": ["critère 1", "critère 2"],
  "test_analysis": [
    {
      "id": 1,
      "scenario": "...",
      "acceptance_criteria_ref": "AC-1",
      "category": "...",
      "level": "Small|Medium|Large",
      "owner": "Développeur|Analyste QA",
      "automation": "Auto|Manuel",
      "framework": "..."
    }
  ]
}
```

Un projet peut étendre ce schéma avec des champs propres (ex. `repos`, `browsers` pour LeoMed — voir `contextes/leomed/CONTEXTE.md` pour l'exemple complet).

Confirmer après sauvegarde : `✅ Snapshot sauvegardé : .claude/qa-snapshots/[identifiant]-todo-snapshot.json`

## Pourquoi un fichier plutôt qu'une simple réponse en conversation

Le snapshot survit à la conversation. Si le développeur écrit sa partie aujourd'hui et que l'analyste QA reprend le même ticket trois jours plus tard dans une conversation différente, elle peut lire le snapshot et voir immédiatement ce qui est pris, par qui, et à quel niveau — sans redemander ou re-analyser depuis zéro.

## Lien avec le reste du skill

- Qui possède quel niveau : `roles-responsabilites.md`
- Grilles de classification : `quadrants.md`, `pyramide-google.md`, `fragmentation-bourbonnais.md`
- Décision auto/manuel : `automatisation.md`
- Étapes préalables propres à un projet (ex. gate de ticket) : `../contextes/[nom]/CONTEXTE.md`
