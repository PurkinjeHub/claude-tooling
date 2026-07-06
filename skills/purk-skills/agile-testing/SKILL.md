---
name: agile-testing
description: Cadre de référence pour les tests en contexte agile (tests unitaires, d'intégration, de composantes), basé sur le livre *Agile Testing* de Lisa Crispin et Janet Gregory (2009) et le modèle des quadrants de Brian Marick. Active ce skill chaque fois que la conversation porte sur l'écriture, la revue, la stratégie ou la critique de tests automatisés — y compris pour des demandes implicites comme « écris un test pour cette méthode », « est-ce qu'il manque des cas de test ici? », « comment couvrir cette feature », « pyramide de tests », « ratio unitaires/intégration », « TDD », « BDD », « quoi tester en premier », « ce test est-il pertinent », « qui doit écrire ce test, dev ou QA », ou toute discussion sur la qualité, la couverture, le mocking, les fixtures, ou l'organisation des suites de tests. Déclencher aussi pour tout ticket ou projet connu (ex. LOG-XX pour LeoMed) même sans vocabulaire de test explicite. Le skill fournit le vocabulaire commun, les principes méthodologiques, la répartition des rôles et des checklists de revue ; les conventions spécifiques à un framework (RSpec, Jasmine, Playwright...) vivent dans `contextes/[nom]/`, chargées seulement quand ce contexte est actif.
---

# Agile Testing — Cadre méthodologique

Skill d'équipe de référence pour orienter l'écriture et la revue de tests automatisés dans un contexte agile — développeurs et analyste QA. Inspiré du livre *Agile Testing: A Practical Guide for Testers and Agile Teams* (Crispin & Gregory, 2009, Pearson) et adapté en français.

## Quand utiliser ce skill

Activer dès qu'une tâche implique :

- **Écrire** un test (unitaire, intégration, composante)
- **Réviser** des tests existants (revue de PR, refactor de suite)
- **Décider** quoi tester, à quel niveau, avec quelle priorité
- **Évaluer** une couverture ou une stratégie d'automatisation
- **Discuter** vocabulaire ou philosophie de tests dans un débat d'équipe

Ne pas activer pour des questions purement syntaxiques (« comment mocker un service en Jasmine »), qui relèvent de la doc du framework ou d'un skill technique par projet.

## Principe directeur

> **Les tests servent à deux choses : guider le développement (supporter l'équipe) et critiquer le produit (challenger ce qui a été construit).** Une suite de tests qui ne fait que l'un des deux est incomplète.

Ce skill se concentre sur la moitié *supporter l'équipe* — c'est là que vivent les tests unitaires, de composantes et d'intégration, et la répartition claire entre développeurs et analyste QA.

## ⚠️ Conventions internes — à charger en premier

**Avant** toute autre référence, charger `references/conventions-internes.md`. Ce fichier contient les directives propres à l'équipe (distinctes du livre), et en cas de conflit avec les principes généraux, **les conventions internes priment**. Elles s'appliquent à toute activité de test, peu importe le quadrant ou le niveau de la pyramide.

## 🗂️ Détection du contexte actif — à faire juste après les conventions internes

Ce skill est unique pour toute l'équipe, mais certains projets (LeoMed, et les suivants) ont des conventions techniques et des process propres (frameworks, chemins, gate de ticket, navigateurs supportés...). Ces particularités vivent dans `contextes/[nom]/`, **jamais** dans les fichiers de méthodologie générale (`references/`).

> Le dossier s'appelle `contextes/`, pas `projets/` — pour éviter la confusion avec les Projets de claude.ai, qui sont une fonctionnalité complètement différente et sans lien avec ce skill.

**Comment détecter le contexte actif :**
- Mention explicite du nom du projet (ex. « LeoMed »)
- Un numéro de ticket dont le préfixe est associé à un contexte connu (ex. `LOG-XX` → LeoMed)
- Le nom d'un repo connu (ex. `leomed-api`, `leomed-webapp`, `leomed-hub` → LeoMed)

**Contextes connus :**

| Projet | Dossier | Déclencheurs |
|---|---|---|
| LeoMed | `contextes/leomed/CONTEXTE.md` | « LeoMed », tickets `LOG-XX`, repos `leomed-api`/`leomed-webapp`/`leomed-hub` |

Si le contexte actif est identifié, **charger son `CONTEXTE.md` avant de continuer** — il peut ajouter des étapes (ex. un gate de ticket obligatoire), préciser la répartition des rôles pour ce contexte, et pointer vers ses propres fichiers de conventions par framework (ex. `contextes/leomed/rspec.md`).

Si aucun contexte connu n'est détecté mais que la conversation en révèle un nouveau, ou si le contexte n'existe pas encore comme dossier : proposer de créer `contextes/[nom]/` à partir de `contextes/_template/CONTEXTE.md` plutôt que d'improviser des conventions dans la conversation.

Si aucun contexte spécifique n'est identifiable, continuer avec la méthodologie générale seule (`references/`) — elle s'applique par défaut, peu importe le contexte.

## Vocabulaire commun (à utiliser dans les PR et revues)

| Terme | Définition courte |
|---|---|
| **Q1** | Tests *technology-facing* qui supportent l'équipe — unitaires, composantes, intégration de bas niveau |
| **Q2** | Tests *business-facing* qui supportent l'équipe — fonctionnels, story tests, exemples ATDD/BDD |
| **Q3** | Tests *business-facing* qui critiquent le produit — exploratoire, UAT, scénarios utilisateurs |
| **Q4** | Tests *technology-facing* qui critiquent le produit — performance, charge, sécurité, « ilités » |
| **Pyramide** | Beaucoup de tests unitaires rapides, moins de tests d'intégration, encore moins d'E2E (Mike Cohn) |
| **Cornet de glace** | Anti-pattern : peu de tests unitaires, beaucoup d'E2E lents — à éviter |
| **TDD** | Test-Driven Development — écrire le test avant le code de production |
| **ATDD/BDD** | Acceptance-/Behavior-Driven Development — exemples côté business pilotent l'implémentation |
| **Happy path** | Cas d'usage nominal, sans erreur ni cas limite |
| **Whole-team approach** | La qualité est l'affaire de toute l'équipe, pas seulement du testeur/QA |

## Méthode de travail

Quand on me demande d'écrire ou de réviser un test :

1. **Charger les conventions internes** (`references/conventions-internes.md`) — ces directives priment sur tout le reste.
2. **Détecter le contexte actif** et charger son `contextes/[nom]/CONTEXTE.md` s'il existe (voir section ci-dessus).
3. **Identifier le quadrant cible** : la tâche relève-t-elle de Q1 (technique support) ou Q2 (fonctionnel support)? Si Q3/Q4, signaler que ce n'est pas le focus du skill et orienter autrement.
4. **Vérifier la place dans la pyramide** : faut-il un test unitaire, d'intégration, ou de composante? Le niveau le plus bas qui suffit est généralement le meilleur.
5. **Attribuer un propriétaire** (développeur ou analyste QA) selon `references/roles-responsabilites.md`.
6. **Produire le tableau d'analyse et le snapshot** avant d'écrire le moindre test — voir `references/protocole-analyse.md`. Aucun code avant que le tableau soit validé.
7. **Appliquer les principes** : continuous feedback, keep it simple, deliver value (voir `references/principes-agiles.md`).
8. **Utiliser une checklist de revue** : voir `checklists/revue-test-unitaire.md`, `checklists/revue-test-integration.md`, ou `checklists/revue-test-e2e.md` selon le niveau.
9. **Signaler les trous** : si un quadrant entier est absent de la stratégie de couverture, le mentionner — c'est souvent là que le bât blesse.

## Références à charger selon le besoin

Charger uniquement la(les) référence(s) pertinente(s) — pas toutes d'un coup. **Exception : `conventions-internes.md` se charge systématiquement.**

| Fichier | Charger quand... |
|---|---|
| `references/conventions-internes.md` | **Toujours**, en premier — directives d'équipe qui priment |
| `references/principes-agiles.md` | Discussion sur le rôle du testeur, le « pourquoi » des tests, retours de PR sur la philosophie |
| `references/quadrants.md` | Décision sur quel type de test écrire, débat sur la couverture globale, planification de release |
| `references/q1-tests-techniques.md` | **Cœur du skill** : écriture/revue de tests unitaires, composantes, intégration de bas niveau |
| `references/automatisation.md` | Discussion sur la pyramide (Cohn), le ROI d'automatiser, quoi garder dans la suite de régression |
| `references/pyramide-google.md` | Discussion technique sur *test sizes* (Small/Medium/Large), *test doubles* (fake/stub/mock), hermeticité, flaky tests, ou ratios précis. Complémentaire à `automatisation.md` |
| `references/fragmentation-bourbonnais.md` | Un test vérifie plusieurs choses à la fois, on veut le scinder ; on hérite d'une suite dominée par des tests Large fragiles et on cherche une stratégie de migration ; on veut appliquer la règle « une seule raison d'échouer » |
| `references/cycle-iteration.md` | Planification de sprint, estimation, « quand tester quoi » dans une itération |
| `references/roles-responsabilites.md` | Décider qui (développeur ou analyste QA) doit écrire un test donné ; arbitrer un cas ambigu |
| `references/protocole-analyse.md` | Avant d'écrire un test : produire le tableau d'analyse et le snapshot, quel que soit le projet |
| `contextes/[nom]/CONTEXTE.md` | Dès que le contexte actif est identifié (voir section « Détection du contexte actif ») — toujours avant les fichiers ci-dessus si un contexte est détecté |

## Checklists (à appliquer dans les revues de PR)

| Fichier | Usage |
|---|---|
| `checklists/revue-test-unitaire.md` | Évaluer un test unitaire avant d'approuver une PR |
| `checklists/revue-test-integration.md` | Évaluer un test d'intégration avant d'approuver une PR |
| `checklists/revue-test-e2e.md` | Évaluer un test E2E avant d'approuver une PR |

## Limites volontaires du skill

- **Pas de conventions framework-spécifiques à la racine** (RSpec, Minitest, Jasmine, Jest, Cypress...). Ces conventions vivent dans `contextes/[nom]/` (ex. `contextes/leomed/rspec.md`), chargées uniquement quand ce contexte est actif.
- **Pas de focus sur Q3 (exploratoire) ni Q4 (perf/sécu)** dans les références générales — un contexte donné peut avoir ses propres règles Q3/Q4 dans son `CONTEXTE.md` (ex. exploratoire multi-navigateur pour LeoMed), mais ce n'est pas généralisé à la racine pour l'instant.
- **Inspiré du livre, pas une copie** : le contenu est paraphrasé en français. Pour les passages originaux, voir le PDF source (Crispin & Gregory, *Agile Testing*, Addison-Wesley, 2009, ISBN 978-0-321-53446-0).

## Historique de fusion

Ce skill résulte de la fusion d'un skill personnel (agile-testing, méthodologie générale) et d'un ancien Projet Claude.ai propre à LeoMed (`qa-leomed`), qui vivait séparément et dupliquait une partie de la théorie. Au passage, une attribution erronée a été corrigée dans `references/fragmentation-bourbonnais.md` et `references/automatisation.md` : le S/M/L qu'on y présentait comme une grille propre à Bourbonnais est en réalité celui de Google (édition 2012, *How Google Tests Software*), que Bourbonnais enseigne sans en être l'auteur — voir le détail dans `contextes/leomed/CONTEXTE.md` (section « Application des grilles générales ») et dans `fragmentation-bourbonnais.md` lui-même.

## Évolution

Complété :
- ✅ `references/roles-responsabilites.md` — matrice RACI dev/QA + règles de la couche unique de vérité et du tableau obligatoire
- ✅ `checklists/revue-test-e2e.md` — pendant QA des deux checklists dev existantes
- ✅ `references/protocole-analyse.md` — protocole tableau + snapshot généralisé à tout projet ; `contextes/leomed/CONTEXTE.md` n'en garde que le delta (colonne Navigateurs, champs `repos`/`browsers`)

En cours :
- Dépôt Git partagé + `CHANGELOG.md` pour la synchronisation entre les postes de l'équipe
- Éventuellement Q3/Q4 générisés si la pratique l'exige
