# Projet [NOM_PROJET] — Spécificités

> Gabarit de départ. Copier ce dossier vers `contextes/[nom_projet]/`, remplir les sections,
> supprimer celles qui ne s'appliquent pas. Ce fichier est chargé par `SKILL.md` (racine)
> quand la conversation porte sur ce projet. Il ne doit contenir **que** ce qui est propre
> au projet — la méthodologie générale vit dans `../../references/` et s'applique ici sans
> être répétée ni redéfinie.

## Contexte projet

**Stack technique :**
- `[repo-1]` → [langage/framework]
- `[repo-2]` → [langage/framework]

**Chemins des tests :**
| Framework | Repo | Chemin |
|-----------|------|--------|
| [ex: RSpec] | [repo] | [chemin] |

**Contraintes d'environnement particulières** (ex : dépendance à un service pour l'auth, navigateurs supportés, langue des tests) :
- [...]

**Conventions techniques par framework :** créer un fichier par framework dans ce dossier (ex. `rspec.md`, `jasmine.md`) si les conventions du projet diffèrent de l'usage par défaut du framework.

---

## Application des grilles générales

Ce projet applique les grilles définies à la racine sans les redéfinir :
- **Quadrants** (`../../references/quadrants.md`)
- **Pyramide Google** (`../../references/pyramide-google.md`) — grille par défaut pour les décisions techniques
- **S/M/L Google édition 2012 + fragmentation** (`../../references/fragmentation-bourbonnais.md`) — grille par portée/frontière de composante (Google 2012, enseignée par Bourbonnais), et technique de fragmentation/dégradage (propre à Bourbonnais)

**Ratio cible pour ce projet :** [80/15/5 par défaut, ou 70/20/10 si l'infrastructure de test n'est pas encore mature — voir `../../references/automatisation.md`]

**Répartition des rôles :** voir `../../references/roles-responsabilites.md`. Ajuster ici uniquement les écarts propres à ce projet par rapport à la matrice générale (ex. si un rôle n'existe pas sur ce projet, ou si un niveau est réparti différemment).

---

## Étape 0 — Validation du ticket/de la demande ⛔ GATE (si applicable)

Si ce projet utilise un système de tickets (Linear, Jira, GitHub Issues...), définir ici :
- Les champs minimaux requis avant de démarrer une analyse
- Le message de blocage si un champ manque
- L'outil MCP ou la méthode pour récupérer le ticket

Si aucun système de ticket formel n'est utilisé, supprimer cette étape.

## Étape 1 — Analyse, classification et attribution des tests

Pour chaque critère d'acceptation / comportement à couvrir :
1. Classer selon les grilles générales (quadrant, niveau de pyramide)
2. Attribuer un propriétaire selon la matrice de rôles
3. Décider auto vs manuel selon les critères généraux (`../../references/automatisation.md`) et les particularités de ce projet

**Particularités de ce projet pour la décision auto/manuel :** [...]

## Étape 2 — Tableau d'analyse et snapshot

Appliquer le protocole général du skill : `../../references/protocole-analyse.md` (structure du tableau, règle « aucune ligne orpheline », schéma de base du snapshot). Ajouter ici uniquement les colonnes/champs propres à ce projet, s'il y en a — voir `contextes/leomed/CONTEXTE.md` pour un exemple (colonne Navigateurs, champs `repos`/`browsers`).

**Colonnes additionnelles pour ce projet (si nécessaire) :** [...]

## Étape 3 — Générer les tests

Lire les références techniques de ce dossier (framework par framework), puis appliquer les principes généraux de `../../references/q1-tests-techniques.md` et `../../references/pyramide-google.md`.

## Étape 4 — Recommandation d'outils (si pertinent)

Si ce projet a plusieurs outils possibles pour un même type de test (ex. plusieurs frameworks E2E), documenter ici la recommandation par défaut et les cas où proposer une alternative.

---

## Avertissements spécifiques à ce projet

[Ex. : contraintes réglementaires, domaines sensibles, données à ne jamais utiliser en test, etc. — supprimer si aucun.]
