# Stratégie d'automatisation

> Source : Crispin & Gregory, *Agile Testing*, chapitres 13 et 14. Concept de pyramide attribué à Mike Cohn (*Succeeding with Agile*, 2009). Paraphrasé et adapté.

## La pyramide de tests

```
                  ▲
                 ╱ ╲
                ╱   ╲           ← E2E (très peu)
               ╱     ╲              lents, fragiles
              ╱───────╲             feedback tardif
             ╱         ╲
            ╱           ╲      ← Intégration (quelques)
           ╱             ╲         moyens, ciblés
          ╱               ╲        feedback intermédiaire
         ╱─────────────────╲
        ╱                   ╲
       ╱                     ╲  ← Unitaires (beaucoup)
      ╱                       ╲    rapides, isolés
     ╱                         ╲   feedback immédiat
    ╱___________________________╲
```

**Lecture :**
- **Base large** : beaucoup de tests unitaires. Ils sont rapides, déterministes, ciblés. C'est la fondation.
- **Milieu fin** : tests d'intégration. Moins nombreux, plus lents, plus précieux par unité mais aussi plus chers à maintenir.
- **Sommet pointu** : tests E2E. Indispensables mais coûteux ; à réserver aux parcours critiques.

## Pourquoi cette forme

Chaque niveau a un coût et une valeur différents :

| Niveau | Vitesse | Coût d'écriture | Coût de maintenance | Confiance procurée |
|---|---|---|---|---|
| Unitaire | ms | Bas | Bas | Sur l'unité testée seulement |
| Intégration | s | Moyen | Moyen-Haut | Sur l'interaction de plusieurs unités |
| E2E | min | Haut | **Très haut** | Sur la chaîne complète |

Multiplier les tests à un niveau, c'est multiplier les coûts du niveau. Une suite de 500 tests unitaires tourne en quelques secondes. Une suite de 500 tests E2E tourne en plusieurs heures et casse pour toutes sortes de raisons sans rapport avec le code.

## Les anti-patterns à connaître

### Le cornet de glace (ice cream cone) 🍦

Pyramide inversée : beaucoup d'E2E, peu d'intégration, presque pas d'unitaires.

**Symptômes :**
- La suite prend 45 minutes à tourner.
- Les développeurs ne lancent jamais les tests en local.
- Un changement mineur casse une douzaine de tests pour des raisons obscures.
- L'équipe a peur de refactorer.

**Causes typiques :**
- Code legacy non testable au niveau unitaire (couplé, sans injection).
- Équipe QA séparée qui n'a accès qu'au niveau UI.
- Outils E2E « faciles » à mettre en place ont attiré trop d'investissement.

### Le sablier (hourglass) ⌛

Beaucoup d'unitaires + beaucoup d'E2E, mais quasi rien au milieu.

**Symptômes :**
- Les tests unitaires passent, les E2E passent, mais des bugs d'intégration surviennent en production.
- Refactorer une interface entre deux services casse plein d'E2E (au lieu de quelques tests d'intégration ciblés).

**Cause typique :** confusion sur ce qu'est un test d'intégration. L'équipe saute directement de « petite unité » à « toute l'app dans un navigateur ».

### Le mur de tests sans valeur

Suite de 5000 tests unitaires qui vérifient surtout des getters, des constructeurs, et la présence d'attributs. Couverture de 95% mais aucun bug attrapé.

**Symptôme :** la métrique de couverture est bonne, mais quand un vrai bug survient, aucun test n'avait été conçu pour le détecter.

**Cause typique :** culte de la métrique de couverture sans réflexion sur la *valeur* de chaque test.

## Que faut-il automatiser?

Le livre propose une grille simple. **Automatiser** quand :

- Le test sera exécuté fréquemment (régression).
- Le coût d'exécution manuelle dépasse rapidement le coût d'automatisation.
- La précision est critique (ex. calculs financiers, conformité réglementaire).
- Le résultat est déterministe et clairement vérifiable.

**Ne pas automatiser** quand :

- Le test ne sera exécuté qu'une fois ou deux (smoke test ponctuel).
- Le jugement humain est requis (utilisabilité, esthétique, ergonomie — c'est Q3).
- L'environnement est trop instable pour produire un résultat fiable.
- Le coût d'automatisation dépasse manifestement la valeur (ex. tester un assistant d'installation Windows complet).

## Le ROI de l'automatisation

Un test automatisé a deux courbes de coûts :

1. **Coût initial** : écriture du test + mise en place de l'infrastructure (fixtures, mocks, runners).
2. **Coût récurrent** : maintenance à chaque évolution du code, debug des flakiness.

Sa valeur, elle, dépend du nombre d'exécutions × la probabilité d'attraper un défaut × le coût d'un défaut non attrapé.

**Heuristique :** un test automatisé devient rentable typiquement après quelques dizaines d'exécutions. Un test qu'on lance une fois en CI puis qu'on archive a coûté plus qu'il n'a rapporté.

## Quoi garder dans la suite de régression

Critères pour qu'un test mérite sa place dans la suite qui tourne à chaque commit :

1. **Rapide à exécuter** (au niveau de son tier de pyramide)
2. **Fiable** (pas flaky)
3. **Maintenu** (pas commenté, pas skipé, pas en TODO depuis 6 mois)
4. **Avec un nom qui dit ce qu'il vérifie** (pas de `test_42`)
5. **Échouant pour la bonne raison** (quand il casse, on comprend pourquoi)

Un test qui ne satisfait pas ces critères mérite d'être réparé ou retiré, pas conservé « au cas où ».

## Continuous integration : la condition

L'automatisation sans intégration continue est une perte. Le bénéfice principal des tests automatisés vient de leur exécution *fréquente, automatique, sur du code récent*. Si la suite ne tourne qu'à la veille de la release, on retombe dans le modèle traditionnel et on perd 90% de la valeur.

**Critères minimaux pour une CI saine :**
- La suite tourne automatiquement sur chaque PR/MR.
- Le build est cassé visible par toute l'équipe.
- Un build cassé est traité dans la journée, pas la semaine d'après.
- Le résultat est consultable en quelques secondes par n'importe qui.

## Au-delà de la pyramide : la stratégie globale

La pyramide est une heuristique, pas un dogme. Selon le contexte, la forme idéale varie :

- **Système critique sécurité** : plus de tests Q4 (pénétration, fuzzing).
- **Application UI très complexe** : un peu plus de tests de composantes UI au milieu.
- **API publique** : forte couche de tests de contrat (vers le haut du milieu).
- **Système distribué** : tests de contrat entre services (consumer-driven contracts) en plus.

Le bon dosage se trouve par observation : *où nos bugs en production proviennent-ils typiquement?* Si on en trouve souvent au niveau intégration, renforcer cette couche, même si la pyramide « théorique » dit autre chose.

## Lien avec les quadrants

La pyramide concerne surtout **Q1 et le bas de Q2** (les tests automatisés qui supportent l'équipe). Q3 (exploratoire) et Q4 (perf/sécu) suivent leurs propres logiques de coût et de fréquence.

Voir `quadrants.md` pour le modèle complet.

## Approche complémentaire : la pyramide de Google (édition 2020)

La pyramide de Cohn présentée ici décrit la **forme de la suite** (beaucoup de tests rapides à la base). L'approche de Google (*Software Engineering at Google*, Winters et al., 2020) va plus loin en donnant des **critères techniques binaires** pour classer chaque test (contraintes de threads, I/O, réseau, temps d'exécution). Elle introduit aussi la distinction cruciale entre **test size** (contraintes d'exécution) et **test scope** (portée du code testé), qui sont orthogonaux.

Charger `pyramide-google.md` quand :
- La discussion glisse vers *« combien de temps ce test devrait prendre »*
- On débat de la place d'un test dans la CI (pré-commit, PR, nightly)
- Un test devient flaky ou lent
- On choisit entre différents types de test doubles (fake, stub, mock)

## Réconciliation des trois pyramides

Le skill contient trois grilles de classification des tests. **Elles ne se contredisent pas — elles éclairent trois dimensions différentes du même objet**, et deux d'entre elles viennent en réalité de la même source à des époques différentes. Cette section explicite comment les lire ensemble.

> ⚠️ **Attribution corrigée** — la grille documentée dans `fragmentation-bourbonnais.md` n'est pas une invention de Bourbonnais. C'est le S/M/L de Google **édition 2012** (*How Google Tests Software*, Whittaker et al.) et le ratio 70/20/10 qui l'accompagne (Mike Wacker, Google Testing Blog, 2015) — que Bourbonnais enseigne fidèlement, sans en être l'auteur. Ce qui est propre à Bourbonnais, c'est la technique de fragmentation/boulonnage documentée dans ce même fichier, pas la grille S/M/L elle-même.

### Ce que chaque grille apporte

| Grille | Angle | Critère | Utilité principale |
|---|---|---|---|
| **Cohn** (Unit / Integration / E2E) | Conceptuel / niveau d'abstraction | Ce que le test vérifie | Vision stratégique, forme globale de la suite, communication d'équipe |
| **Google, édition 2020** (Small / Medium / Large) | Opérationnel / contraintes d'exécution | Threads, I/O, réseau, temps | Décisions techniques concrètes : place en CI, budget de performance, flakiness |
| **Google, édition 2012** (Small / Medium / Large), enseignée par Bourbonnais | Conceptuel / portée et frontières de composante | Nombre de fonctionnalités / « peaux » de composantes franchies | Fragmentation, raison d'échouer unique, dégradage progressif |

### Un même test lu par les trois grilles

Prenons un test qui vérifie qu'un service `CalculTaxe` interroge un `TaxRepository` (mocké) et retourne le bon montant :

- **Cohn** : test unitaire ou test d'intégration, selon l'école (frontière floue).
- **Google, édition 2020** : *Small* (pas d'I/O, un seul thread, ms).
- **Google, édition 2012** : probablement *Medium* si le test exerce vraiment l'interaction entre les deux composantes ; *Small* si le repository est un simple stub qu'on ne cherche pas à valider.

Le même test peut donc être *Small* selon l'édition 2020 et *Medium* selon l'édition 2012 — sans contradiction, parce que les critères ont évolué chez Google avec le temps. L'important n'est pas d'être puriste sur l'étiquette, mais d'utiliser la grille pertinente selon la question posée.

### Comment choisir la grille selon la conversation

- **« Où placer ce test dans la CI, combien de temps peut-il prendre? »** → grille Google édition 2020 (Small = pré-commit, Medium = PR, Large = nightly).
- **« Ce test a-t-il vraiment besoin d'être aussi gros? »** → grille Google édition 2012 / Bourbonnais (combien de fonctionnalités ou de « peaux » franchit-il?).
- **« Quelle est la forme globale de notre suite? Est-ce qu'on a assez de tests unitaires vs E2E? »** → grille Cohn.
- **« Quels ratios viser? »** → 80/15/5 (Google 2020, ambitieux) comme cible par défaut, 70/20/10 (Google 2015 / Wacker, enseigné par Bourbonnais) comme jalon pragmatique.

### Ce qu'il faut retenir

Les trois grilles se **superposent** sur chaque test. Pas besoin de choisir laquelle est « la vraie » — chacune répond à une question différente. Le skill utilise l'édition 2020 de Google comme grille par défaut pour les décisions techniques, l'édition 2012 (via Bourbonnais) pour la fragmentation, et Cohn comme cadre pédagogique de haut niveau. La technique de fragmentation et de boulonnage, elle, reste la contribution propre de Bourbonnais — voir `fragmentation-bourbonnais.md`.
