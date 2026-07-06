# Répartition des rôles — Développeur vs Analyste QA

> Applicable à tout projet. Un `CONTEXTE.md` peut ajuster ponctuellement cette matrice si la composition d'équipe ou le contexte d'un projet diffère (voir section « Ajuster pour un projet » en bas de ce fichier) — mais l'ajustement doit être explicite et justifié, pas une dérive implicite.

## Pourquoi ce fichier existe

Sans règle explicite, trois frictions reviennent systématiquement dans une équipe qui mélange développeurs et analyste QA :

1. **Tests dupliqués** — la même règle vérifiée deux fois, à deux niveaux différents, par deux personnes qui ignoraient que l'autre l'avait déjà couverte.
2. **Zones non couvertes** — chacun suppose que l'autre s'en occupe.
3. **Tests au mauvais niveau** — ex. un test E2E complet pour vérifier une règle de calcul qui aurait pu être vérifiée par un test Medium sans navigateur.

Ce fichier règle les trois avec une matrice de propriété par défaut et deux règles d'arbitrage.

## Les rôles

- **Développeur** — écrit le code de production et les tests qui vérifient sa logique interne.
- **Analyste QA** — possède la stratégie de test de bout en bout et l'exploratoire ; ne réécrit pas ce que le développeur a déjà vérifié à un niveau inférieur.
- **Product Owner** — fournit les critères d'acceptation (AC). **Ne possède aucun niveau de test.** Son rôle s'arrête à la définition du besoin ; ni le développeur ni l'analyste QA n'attendent de lui qu'il choisisse un niveau de pyramide ou écrive un scénario technique.

## Matrice de propriété (RACI)

R = Responsible (exécute) · A = Accountable (imputable du résultat) · C = Consulted (consulté avant/pendant) · I = Informed (informé après)

| Niveau | Quadrant | Développeur | Analyste QA | Product Owner |
|---|---|---|---|---|
| **Small** — logique pure, mocks | Q1 | **R, A** | I | — |
| **Medium** — contrats internes, ORM, API interne, y compris une règle d'affaires vérifiable sans navigateur | Q1 | **R, A** | C | I (fournit l'AC) |
| **Large / E2E automatisé** — parcours utilisateur complet | Q2 auto | C | **R, A** | I (fournit l'AC) |
| **Exploratoire** — UX, jugement métier, cas non anticipés | Q3 | I | **R, A** | C (priorise les scénarios à explorer) |
| Perf / sécurité | Q4 | — | — | — *(hors scope actuel du skill)* |

**Lecture rapide :** si un critère d'acceptation peut être vérifié par un appel direct au code ou à l'API (sans passer par l'interface), il est **Medium, propriété développeur**, même si le PO l'a formulé dans un langage métier. S'il ne peut être vérifié qu'en pilotant réellement l'interface, il est **Large, propriété analyste QA**.

## Règle 1 — La couche unique de vérité

> Chaque critère d'acceptation est vérifié en détail à **un seul niveau : le plus bas où il peut l'être complètement.** Les niveaux supérieurs qui traversent ce même critère ne le réaffirment pas en détail — ils vérifient seulement le branchement (navigation, affichage, intégration), pas la règle métier elle-même.

**Exemple concret :**

Critère d'acceptation : *« Un patient exempté de taxe ne doit jamais se voir facturer la TPS. »*

- Le calcul d'exemption est vérifié **une fois**, en Medium, par le développeur (`CalculTaxeService`, mocks sur le statut du patient).
- Le scénario E2E qui couvre le parcours de facturation complet **ne re-vérifie pas le calcul** — il vérifie que l'écran affiche le bon total et que le bouton de facturation fonctionne. Si le calcul est déjà bon en Medium, l'E2E n'a pas besoin de tester dix cas de patients exemptés différents ; un seul passage suffit pour prouver le branchement.

**Ce que ça élimine :** la duplication (le E2E ne refait pas le travail du Medium) et le mauvais niveau (le calcul n'est jamais vérifié uniquement en E2E).

## Règle 2 — Le tableau obligatoire, sans ligne orpheline

> Chaque critère d'acceptation doit apparaître dans le tableau d'analyse **avec un propriétaire assigné**, avant que quiconque commence à écrire du code — développeur ou analyste QA.

Le mécanisme concret (tableau + snapshot JSON) est généralisé pour tout projet dans `protocole-analyse.md`. `../contextes/leomed/CONTEXTE.md` en documente le delta propre à LeoMed (hérité de l'ancien skill qa-leomed).

**Ce que ça élimine :** les zones non couvertes. Si un AC n'a pas de ligne, il ne peut pas être considéré comme couvert par supposition.

## Comment trancher un cas ambigu

Dans l'ordre :

1. **Est-ce vérifiable sans navigateur ?** Oui → développeur (Small/Medium). Non → analyste QA (Large).
2. **Est-ce déjà couvert à un niveau inférieur ?** Si oui, le niveau supérieur ne vérifie que le branchement (règle 1).
3. **Est-ce du jugement humain, pas une règle déterministe ?** (ergonomie, cohérence clinique, cas non anticipé) → toujours analyste QA, en exploratoire (Q3), jamais automatisé.
4. **Toujours incertain après ces trois questions ?** Trancher en synchro rapide développeur + analyste QA au moment du remplissage du tableau (étape 3 de l'analyse) — pas après coup en revue de PR.

## Signes qu'un déséquilibre s'installe

- 🚩 Un développeur écrit un test Playwright « parce que c'est plus simple à visualiser » — vérifier si un Medium suffirait.
- 🚩 L'analyste QA écrit un test unitaire « pour être sûre » d'une règle déjà couverte par le développeur — signe que le tableau n'a pas été consulté avant d'écrire.
- 🚩 Un scénario E2E contient des assertions détaillées sur un calcul métier — signe que la règle 1 n'a pas été appliquée ; ce calcul devrait déjà être couvert en Medium, et l'E2E ne devrait vérifier que le résultat affiché.
- 🚩 Un critère d'acceptation n'apparaît dans aucune ligne du tableau au moment où le code commence.

## Ajuster pour un projet

Un `contextes/[nom]/CONTEXTE.md` peut préciser ou ajuster cette matrice si, par exemple :
- L'équipe du projet n'a pas d'analyste QA dédié (le développeur hérite alors de la colonne QA).
- Il y a plusieurs analystes QA ou plusieurs développeurs avec des spécialisations différentes.
- Un rôle supplémentaire existe (ex. un architecte qui possède Q4).

Tout ajustement doit être documenté explicitement dans le `CONTEXTE.md` du projet concerné — jamais improvisé dans une conversation.

## Lien avec le reste du skill

- Grilles de classification (quadrant, pyramide) : `quadrants.md`, `pyramide-google.md`, `fragmentation-bourbonnais.md`
- Comment écrire un bon test au niveau qui vous revient : `q1-tests-techniques.md` (développeur), `../checklists/revue-test-e2e.md` (analyste QA)
- Cadence dans le sprint : `cycle-iteration.md`
