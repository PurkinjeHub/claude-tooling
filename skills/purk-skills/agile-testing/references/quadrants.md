# Les quadrants des tests agiles (modèle Marick)

> Source : Crispin & Gregory, *Agile Testing*, chapitres 6 et 12, qui développent le modèle original de Brian Marick (2003). Paraphrasé et adapté en français.

## Le modèle en une image

Deux axes orthogonaux, quatre quadrants :

- **Axe horizontal** : qui le test sert-il? *Supporte l'équipe* (à gauche) vs *critique le produit* (à droite).
- **Axe vertical** : sur quoi le test porte-t-il? *Business-facing* (en haut) vs *technology-facing* (en bas).

```
                  │ SUPPORTE L'ÉQUIPE  │  CRITIQUE LE PRODUIT
                  │  (guider le dev)   │  (challenger l'output)
──────────────────┼────────────────────┼──────────────────────
 BUSINESS-FACING  │                    │
 (langage métier) │       Q2           │         Q3
                  │  Tests             │  Tests exploratoires
                  │  fonctionnels      │  Scénarios utilisateurs
                  │  Story tests       │  Tests d'utilisabilité
                  │  Exemples ATDD/BDD │  UAT, alpha/beta
                  │  Wireframes        │
                  │                    │
                  │  Auto + manuels    │  Manuels (humain requis)
──────────────────┼────────────────────┼──────────────────────
 TECHNOLOGY-      │                    │
 FACING           │       Q1           │         Q4
 (langage tech)   │  Tests unitaires   │  Performance
                  │  Tests composantes │  Charge / Stress
                  │  Tests d'intégr.   │  Sécurité
                  │  bas niveau (API,  │  « ilités »
                  │  contrats internes)│  (scalabilité,
                  │                    │   maintenabilité...)
                  │  Automatisés       │  Outils + experts
```

## Lecture des quatre quadrants

### Q1 — Technology-facing, supporte l'équipe

**Ce qu'on y met :** tests unitaires, tests de composantes, tests d'intégration de bas niveau (services, API internes, accès aux données).

**Public :** développeurs. Le langage est technique : noms de méthodes, contrats d'interface, structures de données.

**Quand ça tourne :** à chaque sauvegarde de fichier, à chaque commit, à chaque PR. Doit être *rapide* (idéalement secondes, pas minutes).

**Qui écrit :** principalement les développeurs (souvent en TDD). Les testeurs peuvent contribuer par revue ou pairage.

**C'est le focus principal de ce skill.** Voir `q1-tests-techniques.md` pour les détails.

### Q2 — Business-facing, supporte l'équipe

**Ce qu'on y met :** tests fonctionnels, *story tests*, exemples ATDD/BDD, wireframes validés avec le client, simulations de scénarios métier.

**Public :** toute l'équipe — développeurs, testeurs, product owner. Le langage est métier : *« quand un médecin signe une ordonnance électronique, alors... »*.

**Quand ça tourne :** souvent en CI, parfois manuellement pour les démos. Plus lents que Q1 (secondes à minutes par test).

**Qui écrit :** collaboration testeur + dev + product owner. Le PO valide les exemples avant qu'ils deviennent du code.

**Distinction subtile avec Q1 :** un test Q2 décrit *ce que le système fait pour le métier*, un test Q1 décrit *comment un composant fonctionne techniquement*. Le même bout de code peut être couvert par les deux à des niveaux différents.

### Q3 — Business-facing, critique le produit

**Ce qu'on y met :** tests exploratoires, scénarios utilisateurs end-to-end, tests d'utilisabilité, UAT, alpha/beta avec vrais utilisateurs.

**Public :** testeurs experts, parfois utilisateurs réels.

**Quand ça tourne :** manuellement, en fin d'itération ou avant release. *L'automatisation tue ce quadrant* — c'est précisément le jugement humain qu'on cherche.

**Qui fait :** testeurs avec une vraie expertise du domaine, parfois utilisateurs ou clients pilotes.

*Hors scope de ce skill pour l'instant.*

### Q4 — Technology-facing, critique le produit

**Ce qu'on y met :** tests de performance, charge, stress, sécurité, et toutes les *« ilités »* (scalabilité, fiabilité, maintenabilité...).

**Public :** experts techniques, parfois équipes dédiées.

**Quand ça tourne :** typiquement avant release, ou en continu sur environnements dédiés. Lent et coûteux.

**Qui fait :** souvent des spécialistes (ingénieurs perf, équipe sécurité). Mais les développeurs peuvent participer — un test unitaire avec un harness multi-thread devient un mini-test de stress.

*Hors scope de ce skill pour l'instant.*

## Comment utiliser le modèle dans une discussion

Le modèle n'est **pas** un ordre d'exécution (« d'abord Q1, puis Q2... »). C'est une *grille de couverture* qui aide à diagnostiquer les trous :

- *« Notre couverture Q1 est solide mais on n'a aucun Q2 — comment valide-t-on qu'une story est faite? »*
- *« On a 200 tests Q3 manuels, c'est insoutenable, il faut en faire descendre vers Q1/Q2. »*
- *« On lance les Q4 perf juste avant release et on découvre toujours des problèmes trop tard. »*

Une équipe saine a une présence dans les **quatre** quadrants, avec un poids variable selon le contexte (un site critique sécurité aura plus de Q4 qu'une app interne de gestion).

## Lien avec la pyramide de tests

La pyramide de Mike Cohn est **orthogonale** au modèle des quadrants — elle décrit la *forme de la suite automatisée*, pas la stratégie globale :

- Beaucoup de tests Q1 unitaires rapides (base de la pyramide)
- Moins de tests Q1/Q2 d'intégration (milieu)
- Très peu de tests E2E lents (sommet)

Voir `automatisation.md` pour le détail.

## Mise en garde sur les frontières

La frontière Q1/Q2 et Q2/Q3 est **floue** dans la littérature et la pratique. Ne pas s'enliser dans des débats taxonomiques : ce qui compte, c'est de couvrir les quatre intentions (support tech, support business, critique business, critique tech). Le découpage exact entre « unitaire » et « intégration » dépend autant des conventions d'équipe que de définitions théoriques.

**Règle pragmatique :** si un test échoue, sait-on *en lisant juste son nom et son output* quelle partie du système est en cause? Si oui, peu importe son étiquette.
