# Checklist de revue d'un test E2E

Liste à parcourir lors d'une revue de PR contenant des tests E2E (Large — Playwright, Cypress, Selenium...).

Beaucoup de principes sont communs avec les checklists unitaire/intégration — voir `revue-test-unitaire.md` et `revue-test-integration.md`. Celle-ci se concentre sur ce qui est *spécifique* au E2E et à son propriétaire par défaut, l'analyste QA (voir `../references/roles-responsabilites.md`).

## Justification du niveau

- [ ] **Ce test a vraiment besoin d'être E2E** : il vérifie un parcours utilisateur réel qu'aucun test Medium ne pourrait couvrir (navigation, rendu, interaction UI complète).
- [ ] **Le test ne re-vérifie pas une règle métier déjà couverte en Small/Medium** (règle de la couche unique de vérité — voir `../references/roles-responsabilites.md`). S'il contient des assertions détaillées sur un calcul ou une validation, poser la question : *est-ce déjà testé par le développeur à un niveau inférieur?*
- [ ] **Le test vérifie le branchement, pas la logique** : affichage du bon résultat, navigation correcte, intégration entre écrans — pas le détail du calcul sous-jacent.

## Une seule raison d'échouer, même en E2E

- [ ] **Le scénario ne mélange pas plusieurs intentions distinctes.** Un parcours métier complexe (ex. « signer une ordonnance persiste, log l'audit, et notifie le pharmacien ») devrait être fragmenté en plusieurs tests E2E ciblés plutôt qu'un seul test monolithique — voir la technique de fragmentation dans `../references/fragmentation-bourbonnais.md`.
- [ ] **Si le test échoue, on sait en lisant son nom et la première assertion cassée quelle partie du parcours est en cause**, sans devoir dérouler tout le scénario pour comprendre.

## Sélecteurs et stabilité

- [ ] **Sélecteurs sémantiques** (rôle, label, `data-testid`) plutôt que sélecteurs CSS ou structurels fragiles qui changent avec le design.
- [ ] **Vérifications sur la présence/le contenu significatif**, pas sur des détails susceptibles de changer sans rapport avec le comportement testé (ex. un texte exact qui inclut un compteur variable).
- [ ] **Pas de `sleep` ou délai arbitraire** — attentes sur des conditions observables (élément visible, navigation terminée, réponse réseau reçue).

## Prérequis d'environnement

- [ ] **Les prérequis de déploiement et de données sont vérifiés avant l'exécution** (voir les prérequis spécifiques du projet, ex. `contextes/[nom]/playwright.md`). Un échec parce que la fonctionnalité n'est pas encore déployée sur l'environnement de test n'est pas un signal sur le code.
- [ ] **Les navigateurs requis par le projet sont couverts** (voir `CONTEXTE.md` du projet — le nombre et le choix de navigateurs varient d'un projet à l'autre).
- [ ] **Le mode sériel est utilisé si — et seulement si — les tests de la suite partagent un état** sur un environnement distant ; sinon, préférer des tests indépendants.

## Hermeticité (avec les attentes réalistes du niveau Large)

- [ ] **Le test nettoie après lui ou repart d'un état connu** — pas de dépendance à ce qu'un test précédent aurait laissé, sauf mode sériel assumé et documenté.
- [ ] **Le test est reproductible** : il donne le même résultat à plusieurs exécutions consécutives sans intervention manuelle.
- [ ] Un test E2E n'est jamais pleinement hermétique par nature (voir `../references/pyramide-google.md`) — l'objectif n'est pas la perfection mais l'absence de flakiness évitable (sélecteurs fragiles, attentes arbitraires, état partagé non maîtrisé).

## Pertinence

- [ ] **Le test couvre un flux critique** (voir les critères auto vs manuel du projet) — pas un cas marginal qui coûterait plus cher à automatiser et maintenir qu'à vérifier manuellement une fois.
- [ ] **Le test attrape une vraie régression possible** : si le branchement entre deux écrans casse, ce test le détecte-t-il vraiment?
- [ ] **Les flux nécessitant un jugement humain (UX, ergonomie, contexte métier sensible) ne sont pas forcés en E2E automatisé** — ils restent en exploratoire manuel (Q3), voir `../references/roles-responsabilites.md`.

## Maintenabilité

- [ ] **Pas de `skip`, `TODO`, ou test commenté** sans ticket associé.
- [ ] **Les helpers partagés (ex. connexion) sont réutilisés**, pas dupliqués dans chaque spec.
- [ ] **Le test reste lisible pour quelqu'un qui ne connaît pas le détail de l'implémentation** — un scénario E2E documente un comportement utilisateur, il devrait se lire comme tel.

## Signaux d'alerte

- 🚩 **Un test E2E vérifie un calcul ou une validation en détail** → probablement une duplication d'un test Medium existant ou manquant.
- 🚩 **La suite E2E domine la suite de tests globale** (anti-pattern Ice Cream Cone) → voir la stratégie de dégradage opportuniste dans `../references/fragmentation-bourbonnais.md`.
- 🚩 **Le test échoue de façon intermittente sans changement de code** → flaky, à corriger ou retirer immédiatement (voir la politique de quarantaine dans `../references/pyramide-google.md`).
- 🚩 **Un développeur a écrit ce test E2E « parce que c'était plus simple »** → vérifier si un Medium aurait suffi (voir `../references/roles-responsabilites.md`).

## Rappels

- Un test E2E est le plus cher à écrire, exécuter et maintenir — chaque scénario doit justifier sa place.
- La propriété par défaut du E2E automatisé est l'analyste QA ; en cas de doute sur qui devrait écrire un scénario donné, consulter `../references/roles-responsabilites.md`.
