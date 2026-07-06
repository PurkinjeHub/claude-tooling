# Le testing dans le cycle d'itération

> Source : Crispin & Gregory, *Agile Testing*, partie V (chapitres 15 à 20). Paraphrasé et adapté.

Ce fichier répond à la question : *« à quel moment du sprint fait-on quoi en matière de test? »*

## Vue d'ensemble du flux

```
Avant le sprint    │  Pendant le sprint   │  Fin du sprint
────────────────── │ ──────────────────── │ ──────────────────
Theme planning     │  Iteration kickoff   │  Wrap up
Release planning   │  Coding & testing    │  Delivery
                   │  (simultanés)        │  Retrospective
```

## Avant le sprint : planification

### Theme/Release planning

Quand on planifie un thème ou une release (plusieurs sprints d'avance) :

- **Identifier les risques de qualité** : où la complexité technique est-elle la plus haute? Où les enjeux métier sont-ils critiques?
- **Estimer l'effort de test global**, pas juste l'effort de dev. Une feature « 5 jours dev » est rarement « 5 jours dev + 0 jour test ».
- **Prévoir l'infrastructure** : faut-il un nouvel environnement de test? Des données de test particulières? Des outils?
- **Anticiper Q4** : si la feature touche la perf ou la sécurité, le prévoir tôt, pas en panique avant release.

### Iteration planning (avant le sprint)

Pour chaque story candidate au sprint :

- **Définir les critères d'acceptation sous forme d'exemples concrets**. Pas *« le calcul doit être correct »* mais *« pour un client en Ontario commandant 100$, la taxe doit être 13$ »*.
- **Pour chaque exemple, identifier le quadrant** : Q1 (test unitaire à écrire), Q2 (test fonctionnel), Q3 (exploratoire à planifier), Q4 (impact perf/sécu?).
- **Estimer en incluant l'écriture des tests**, pas séparément. Une story sans son effort de test est sous-estimée.

**Outil mental : la Power of Three** (Janet Gregory). Toute clarification d'une story devrait impliquer trois rôles : un développeur, un testeur, et le product owner (ou son représentant). Si une discussion technique se passe sans le PO, le risque est de dévier de l'intention métier. Si une discussion métier se passe sans dev/testeur, le risque est de promettre l'impossible.

## Pendant le sprint : coder et tester simultanément

L'idée centrale : *le test n'arrive pas après le code, il l'accompagne ou le précède*.

### Approche TDD/BDD

Le cycle classique :

1. **Écrire un test qui échoue** (Red) — il décrit le comportement souhaité, qui n'existe pas encore.
2. **Écrire le minimum de code pour le faire passer** (Green).
3. **Refactorer** sans casser le test (Refactor).
4. Recommencer.

Ce n'est pas obligatoire pour chaque ligne de code, mais c'est la *référence* à connaître. Particulièrement utile pour la logique métier complexe et les algorithmes.

### Les tests Q1 pendant le coding

À chaque tâche de dev :

1. **Avant le code** : lister les comportements à vérifier et au moins un cas par branche.
2. **Pendant le code** : écrire les tests unitaires en parallèle (ou avant si TDD).
3. **Avant le commit** : la suite passe localement.
4. **Avant la PR** : la suite passe en CI.

### Les tests Q2 pendant le coding

Pour chaque story :

- **Avant** ou **au début** du dev : formaliser les exemples d'acceptation en tests automatisables (Cucumber/Gherkin si BDD, ou simplement des tests d'intégration nommés business).
- **Pendant** : les tests Q2 valident progressivement que la story prend forme.
- **À la fin** : si tous les tests Q2 passent, la story est *fonctionnellement* terminée — mais pas forcément *prête à livrer* (voir Q3 et Q4).

### Exploratoire pendant le sprint (Q3)

L'exploratoire ne se fait pas seulement en fin de sprint. Dès qu'un bout de feature est testable, un testeur (ou n'importe qui de l'équipe) peut l'explorer pour :

- Découvrir des cas non couverts par les tests automatisés.
- Vérifier l'ergonomie réelle.
- Identifier des défauts dans les zones grises.

Ce qui est trouvé en exploratoire et qui est *récurrent* doit être ajouté à la suite automatisée (Q1 ou Q2 selon le niveau).

## Fin du sprint : wrap-up

À la fin de chaque itération :

- **Tous les tests automatisés (Q1 + Q2 automatisés) passent.** Ce n'est pas négociable. Une story qui « marche presque » avec 3 tests rouges n'est pas done.
- **Exploratoire de bouclage** : passe sur toute nouvelle feature pour ce qu'on n'a pas pensé à automatiser.
- **Si applicable** : tests Q4 (perf, sécu) sur les composants modifiés.
- **Démo** : le PO valide visuellement (souvent c'est là que naissent les premières observations Q3 informelles).
- **Rétro** sur les tests : qu'est-ce qui a coûté du temps inutilement? Qu'est-ce qui nous a sauvés? Quelle dette de test on accumule?

## Definition of Done — critères incluant les tests

Une definition of done bien construite inclut explicitement le volet test :

- ☐ Code écrit et revu (PR mergée)
- ☐ Tests unitaires (Q1) écrits, qui couvrent les comportements clés
- ☐ Tests d'intégration ou de composantes (Q1/Q2) écrits si pertinents
- ☐ Tous les tests existants passent (pas seulement les nouveaux)
- ☐ Tests fonctionnels d'acceptation (Q2) passent
- ☐ Exploratoire passé (Q3) si applicable à la story
- ☐ Pas de régression de performance détectée (Q4) si applicable
- ☐ Documentation à jour

Une story qui décoche tout sauf les tests n'est *pas* done — c'est de la dette qu'on porte au sprint suivant.

## Erreurs fréquentes dans le rythme

### « On automatisera plus tard »

Variante : *« on a pas le temps cette itération, on le fera quand on aura du slack »*. Le slack n'arrive jamais. Les tests faits après coup couvrent moins bien, coûtent plus cher à écrire, et sont rarement les bons.

### « Le testeur teste quand le dev a fini »

Modèle séquentiel hérité du waterfall. Crée un goulot d'étranglement en fin de sprint, force le testeur à découvrir tardivement des problèmes que le dev aurait pu éviter, et casse la collaboration. Préférer le travail en parallèle, le pairage dev/testeur sur les exemples d'acceptation.

### « Les tests passent, donc c'est done »

Les tests automatisés couvrent ce qu'on a *pensé à* tester. Une fonctionnalité où tous les tests passent peut encore être inutilisable pour de vrai. Q3 (exploratoire) reste nécessaire, même léger.

### « On verra les tests de perf en QA »

Trop tard. Les problèmes de perf découverts à ce moment-là demandent souvent des refactorings majeurs. Les Q4 doivent être anticipés au theme planning et exécutés au plus tôt sur les composants à risque.

## Lien avec les autres références

- Principes sous-jacents : `principes-agiles.md`
- Modèle des quadrants : `quadrants.md`
- Comment écrire un bon test Q1 : `q1-tests-techniques.md`
- Quand et quoi automatiser : `automatisation.md`
