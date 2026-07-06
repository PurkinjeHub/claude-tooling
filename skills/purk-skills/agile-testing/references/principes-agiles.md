# Les 10 principes du testeur agile

> Source : Crispin & Gregory, *Agile Testing*, chapitre 2. Paraphrasé et adapté en français.

Ces principes définissent la posture du testeur (et de tout membre d'équipe qui touche aux tests) dans un contexte agile. Ils sont à invoquer dans les revues de PR ou les rétrospectives quand un débat porte sur le *pourquoi* d'une pratique de test, pas seulement le *comment*.

## 1. Fournir du feedback en continu

Le rôle premier des tests est d'informer, pas de juger. Une suite de tests qui ne tourne qu'une fois par semaine ne donne pas de feedback ; elle constate des dommages.

**En pratique :**
- Les tests doivent être exécutables localement par n'importe quel développeur sans setup laborieux.
- L'intégration continue exécute la suite à chaque commit ou PR.
- Un test rouge est une *information précieuse*, pas une faute morale.

**Signal d'alerte :** quand un test échoue en CI et que la première réaction de l'équipe est « relance le job », on a perdu le feedback.

## 2. Livrer de la valeur au client

On ne teste pas pour tester. Chaque test a un coût (écriture, maintenance, temps d'exécution). La question est : « qu'est-ce que ce test protège côté valeur livrée? ».

**En pratique :**
- Couvrir d'abord le happy path d'une fonctionnalité critique avant les cas limites d'une fonctionnalité marginale.
- Si une fonctionnalité disparaît du produit, les tests associés doivent disparaître aussi.
- Un test sans cas d'usage business identifiable est suspect.

## 3. Faciliter la communication directe

Les tests sont un *langage commun* entre développeurs, testeurs et business. Un bon test se lit comme une spécification d'intention.

**En pratique :**
- Les noms de tests doivent décrire le comportement attendu, pas l'implémentation. *« calcule la TPS sur un montant exempté retourne zéro »* plutôt que *« test_method_42 »*.
- Quand un test devient incompréhensible pour un non-développeur, c'est souvent un signe qu'il teste l'implémentation, pas le comportement.

## 4. Avoir du courage

Du courage pour :
- Dire qu'une feature n'est pas prête, même si le sprint se termine.
- Proposer de supprimer des tests obsolètes ou redondants.
- Refactorer une suite de tests dégradée plutôt que d'y ajouter une énième rustine.
- Soulever un débat sur la stratégie de test même quand l'équipe préfère « avancer ».

## 5. Garder simple

Un test simple, court, qui teste *une seule chose*, vaut mieux qu'un test exhaustif qu'on ne comprend plus six mois plus tard.

**En pratique :**
- Structure AAA : *Arrange, Act, Assert*. Une seule action testée, une ou deux assertions ciblées.
- Pas de logique conditionnelle dans un test (`if`, `for`, `try`) sauf cas exceptionnel — sinon on teste le test.
- Préférer la duplication explicite à l'abstraction prématurée dans les tests.

## 6. Pratiquer l'amélioration continue

La suite de tests évolue avec le code. Ce qui était une bonne pratique l'an dernier peut être un anti-pattern aujourd'hui.

**En pratique :**
- Inclure les tests dans les rétrospectives : « quels tests nous ont coûté du temps inutilement ce sprint? ».
- Mesurer le temps d'exécution de la suite. S'il dépasse quelques minutes en local, c'est un problème à traiter, pas une fatalité.
- Tracker les *flaky tests* (tests intermittents) — un flaky test est pire qu'un test absent.

## 7. Répondre au changement

Un code qui change est un code vivant. Une suite de tests qui rend chaque refactor douloureux est mal conçue.

**En pratique :**
- Tester le *comportement public* d'un module, pas ses détails internes.
- Si renommer une variable privée casse 30 tests, les tests sont trop couplés à l'implémentation.
- Privilégier les tests qui parlent au niveau du *contrat* (entrées/sorties, effets observables).

## 8. S'auto-organiser

L'équipe est responsable collectivement de la qualité des tests. Le testeur n'est pas seul à porter cette charge.

**En pratique :**
- Whole-team approach : développeurs, testeurs, product owner contribuent tous à la stratégie de test.
- Pas de « jet par-dessus le mur » : un développeur ne complète pas un ticket sans avoir lui-même écrit ou révisé les tests pertinents.

## 9. Se concentrer sur les personnes

Les tests sont écrits, lus, maintenus par des humains. Un test optimisé pour la machine mais illisible pour l'équipe est un mauvais test.

**En pratique :**
- Messages d'erreur explicites en cas d'assertion échouée.
- Fixtures et données de test qui ont du sens pour un humain (`utilisateur_sans_permission` plutôt que `user_42`).
- Documentation des conventions de test au même titre que les conventions de code.

## 10. Prendre du plaisir (Enjoy)

Le dixième principe est curieusement le plus important : si écrire des tests est vécu comme une corvée, ils seront mal faits ou pas faits du tout. Une bonne suite de tests procure une *forme de tranquillité* quand on refactore. C'est cette tranquillité qui doit motiver l'effort.

---

## Comment invoquer ces principes dans une revue de PR

Plutôt que dire *« ce test est mauvais »*, pointer le(s) principe(s) en jeu :

- *« Ce test mélange trois assertions sur des comportements différents — voir principe 5 (keep it simple), je suggère de le scinder. »*
- *« Le nom du test décrit l'implémentation, pas le comportement attendu — voir principe 3 (langage commun). »*
- *« Ce test casse à chaque refactor mineur — voir principe 7 (répondre au changement), il est trop couplé aux détails internes. »*

Ça transforme une critique personnelle en discussion technique référencée.
