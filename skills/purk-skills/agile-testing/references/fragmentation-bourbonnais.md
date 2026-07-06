# Fragmentation et migration progressive (technique Bourbonnais)

> Source : session ATQ18 (17 juin 2026), *Pourquoi mes tests automatisés sont durs à maintenir*, présentée par Félix-Antoine Bourbonnais et Sylvain Jean.
>
> ⚠️ **Attribution corrigée** — cette session n'introduit pas une grille S/M/L concurrente de celle de Google. La page de références publique de cette présentation (donnée par Bourbonnais depuis au moins 2018, notamment à l'Agile Tour Québec) cite explicitement *How Google Tests Software* (Whittaker, Arbon & Carollo, 2012) et l'article du Google Testing Blog *« Just Say No to More End-to-End Tests »* (Mike Wacker, 2015) — la source la plus citée pour le ratio 70/20/10. Bourbonnais **enseigne** le modèle Google (édition 2012) et son ratio associé ; il ne les a pas inventés. Ce qui lui est propre — et documenté ci-dessous — c'est la **technique de fragmentation et de boulonnage** et la **stratégie de migration progressive**.

Ce fichier documente :

1. Le S/M/L de Google **édition 2012** (Whittaker et al.), tel qu'enseigné par Bourbonnais — à distinguer de l'édition 2020 (Winters et al., voir `pyramide-google.md`)
2. La technique de **fragmentation et de boulonnage** (l'apport distinctif de Bourbonnais)
3. L'approche de **migration progressive** des tests Large fragiles
4. Les signes concrets de fragilité

## Le S/M/L de Google, édition 2012 — deux générations du même modèle

`pyramide-google.md` documente l'édition 2020 (*Software Engineering at Google*, Winters et al.), qui sépare proprement **size** (contraintes d'exécution : threads, I/O, réseau, temps) et **scope** (portée du code) comme deux axes orthogonaux.

L'édition 2012 (*How Google Tests Software*, Whittaker et al.), celle que Bourbonnais enseigne, est antérieure et **ne fait pas cette séparation aussi nettement** : son critère mélange la portée (combien de fonctionnalités/composantes interagissent) et quelques contraintes techniques légères (temps d'exécution, machine unique). C'est le même modèle que la 2020, à un stade plus ancien de son évolution chez Google — pas un modèle concurrent d'un autre auteur.

### Small (édition 2012)

- Cible une fonction ou un module isolé. Tout ce qui est externe est mocké.
- Aucune dépendance à une base de données, une interface, un fichier externe.
- Utilisé pour valider rapidement une logique isolée.

### Medium (édition 2012)

- Répond à la question : *« est-ce qu'un ensemble de fonctions/composantes voisines interagissent correctement? »*
- Peut toucher un sous-système externe (DB locale), mais reste sur une seule machine.
- Utile pour fragmenter des scénarios larges en morceaux ciblés et maintenables.

### Large (édition 2012)

- Trois fonctionnalités ou plus, scénario utilisateur réel, données réelles.
- À garder **minoritaire** — les plus coûteux, les plus fragiles.

**Pourquoi les deux éditions peuvent classer différemment le même test :** un test sans I/O qui monte trois composantes et vérifie leur interaction peut être *Small* selon l'édition 2020 (aucune contrainte technique dépassée) mais *Medium* selon l'édition 2012 (plusieurs fonctionnalités impliquées). Ce n'est pas une contradiction entre deux auteurs — c'est la même entreprise qui a affiné son propre critère avec le temps. Voir la section « Réconciliation » dans `automatisation.md`.

## Ratio 70/20/10 — origine Google, pas Bourbonnais

**Ce ratio est celui cité par Google** (popularisé par Mike Wacker, Google Testing Blog, 2015 — l'article que Bourbonnais lui-même cite en référence). Bourbonnais le relaie ; ce n'est pas une cible qu'il aurait établie lui-même.

Comparaison avec le ratio 80/15/5 de l'édition 2020 (`pyramide-google.md`) :
- **80/15/5** est la cible plus récente et plus ambitieuse
- **70/20/10** est le ratio le plus largement cité et le plus accessible comme point de départ

**Recommandation pour ce skill** : viser 80/15/5 par défaut (voir `pyramide-google.md`) tout en acceptant 70/20/10 comme jalon intermédiaire réaliste — les deux viennent de Google, à des moments différents.

---

## Technique de fragmentation et de boulonnage

**C'est l'apport distinctif de Bourbonnais** — rien dans les sources Google consultées ne documente cette technique sous cette forme ; elle semble être sa synthèse pédagogique propre, construite par-dessus le modèle Google. À utiliser chaque fois qu'un test devient trop gros ou qu'un scénario métier complexe demande à être couvert.

### Le principe

Un test qui vérifie *un long scénario en un seul bloc* échoue pour trop de raisons possibles. Quand il devient rouge, il faut faire une enquête pour comprendre *quelle* étape a cassé. Au lieu de ça :

> **Découper le scénario en plusieurs tests indépendants, chacun avec une seule raison d'échouer.**
> Les tests se « boulonnent » conceptuellement les uns aux autres : ensemble ils couvrent le scénario complet, mais chacun teste un point précis.

### Les quatre règles opérationnelles

Pour chaque test issu de la fragmentation :

1. **Une seule raison d'échouer.** Si on peut imaginer *deux* causes distinctes de l'échec d'un même test, il est probablement à scinder.
2. **Données d'entrée contrôlées.** Chaque test prépare explicitement l'état dont il a besoin — pas de dépendance à ce qu'un autre test aurait laissé.
3. **Un seul point de sortie vérifié.** Une ou deux assertions sur *un seul aspect* du résultat. Pas de test qui vérifie à la fois le calcul, la persistance, et l'événement émis.
4. **Chaînage conceptuel, pas technique.** Les tests fragmentés ne s'appellent pas entre eux et ne partagent pas d'état à l'exécution — mais dans leur lecture, ils composent le scénario global.

### Exemple d'application

Scénario métier : *« Quand un médecin signe une ordonnance, elle est persistée, un audit log est écrit, et une notification est envoyée au pharmacien. »*

❌ **Anti-pattern : un test monolithique**
```
test « signature d'ordonnance complète »
  → prépare médecin, patient, produits, pharmacien
  → appelle signer_ordonnance
  → vérifie DB : ordonnance présente
  → vérifie DB : audit log présent avec bon timestamp
  → vérifie que notification a été envoyée au bon pharmacien
```
Trois raisons d'échouer, débug coûteux, fragile.

✅ **Fragmentation**
```
test « signer_ordonnance persiste l'ordonnance »
  → focus sur la persistance uniquement, reste mocké
  
test « signer_ordonnance écrit un audit log avec le bon timestamp »
  → focus sur l'audit, persistance mockée
  
test « signer_ordonnance notifie le pharmacien assigné »
  → focus sur la notification, autres effets mockés
```
Trois raisons d'échouer, mais **chaque test n'en a qu'une**. Quand un test casse, on sait immédiatement où creuser.

### Quand *ne pas* fragmenter

- Si le comportement testé est intrinsèquement transactionnel (l'ensemble ou rien), un test qui couvre la transaction complète a du sens — au niveau d'intégration approprié.
- Si la fragmentation multiplie les fixtures et rend chaque test plus long à écrire que le monolithique, ré-évaluer : le problème est peut-être dans le design du code de production (trop couplé), pas dans la stratégie de test.

---

## Migration progressive des tests Large fragiles

Si une équipe hérite d'une suite de tests dominée par des tests Large fragiles, l'instinct est de tout réécrire. **Mauvaise idée** — coût énorme, résistance de l'équipe, perte de couverture pendant la transition.

### La règle du dégradage opportuniste

> **Quand une story modifie une zone couverte par un test Large fragile, profiter de l'occasion pour dégrader ce test vers plusieurs tests plus petits.**

Autrement dit :
- **Pas de sprint dédié « refactor des tests »** — ça ne se vend pas au product owner, et ça déconnecte le refactor des vraies contraintes métier
- **Chaque story qui touche un test Large fragile inclut son dégradage** dans la definition of done — même partiel
- Les nouveaux tests ajoutés dans une story visent directement le ratio cible (80/15/5 ou 70/20/10)
- Le PO comprend que la story « coûte un peu plus » à cause de la dette technique de test — et c'est visible, pas caché

### Ce qui compte dans le dégradage

1. **Identifier la ou les raisons d'échouer du test Large** existant — souvent multiples et enchevêtrées.
2. **Écrire les tests Small/Medium équivalents** qui couvrent les mêmes intentions, séparément.
3. **Une fois la couverture équivalente vérifiée, supprimer le test Large.** Le laisser en plus des nouveaux crée de la duplication et alourdit la CI.
4. **Documenter dans la PR** ce qui a été dégradé et pourquoi — l'équipe voit le progrès.

### Rôle des personnes

- **Développeurs et QA collaborent** sur le dégradage — pas de silo. Le développeur connaît le code, le QA connaît les intentions de test. Le dégradage se fait ensemble.
- **Le PO est informé du travail** mais n'a pas à trancher techniquement. On lui vend l'amélioration de la vélocité future, pas le refactor pour le refactor.

---

## Signes concrets d'une suite fragile

Symptômes à surveiller, tirés de l'expérience terrain :

- 🚩 **Les tests échouent constamment sans signal clair** — l'équipe ne sait plus si c'est un vrai bug ou du bruit.
- 🚩 **Une routine matinale est nécessaire** pour trier les échecs et identifier les tests vraiment problématiques.
- 🚩 **Des centaines ou milliers de tests finissent abandonnés** — commentés, skippés, marqués « broken TODO » depuis des mois.
- 🚩 **Le coût de maintenance dépasse le coût de réécriture** — signal que la dette a atteint un point critique.
- 🚩 **Les tests Large dominent la suite** — pyramide inversée (cornet de glace), typique des suites qui ont grandi sans stratégie explicite.

**Règle d'or :** un test qu'on ignore n'apporte plus rien. Vaut mieux supprimer un test skippé depuis 3 mois que le laisser polluer la suite. La qualité d'une suite se mesure au **nombre de tests auxquels l'équipe fait confiance**, pas au total brut.

---

## Application dans le skill

Pour toute activité de test, Claude devrait :

1. **Classer les tests proposés selon les deux éditions du modèle Google** — 2020 (`pyramide-google.md`, contraintes techniques pures) et 2012 (ce fichier, portée/frontière de composante). Ce sont deux angles du même modèle, pas une contradiction entre deux auteurs différents.
2. **Chaque test proposé doit expliciter sa raison d'échouer unique.** Si Claude ne peut pas la formuler en une phrase, le test est probablement à fragmenter.
3. **Devant un test qui vérifie plusieurs aspects, proposer une version fragmentée** avec les 3-4 tests boulonnés équivalents (technique de fragmentation, propre à Bourbonnais).
4. **Devant une suite dominée par des tests Large**, ne pas suggérer une réécriture en bloc — proposer une stratégie de dégradage opportuniste liée aux prochaines stories.

## Lien avec le reste du skill

- Vue stratégique de la pyramide (Cohn) : `automatisation.md` — inclut la section de **réconciliation des trois pyramides**.
- Grille opérationnelle Google, édition 2020 (S/M/L par contraintes techniques pures) : `pyramide-google.md`
- Principes fondamentaux (un test = une intention) : `principes-agiles.md`
- Comment écrire concrètement un bon test : `q1-tests-techniques.md`
- Checklists de revue : `../checklists/`

## Références

Whittaker, J.A., Arbon, J., & Carollo, J. (2012). *How Google Tests Software*. Addison-Wesley. — Source du S/M/L édition 2012.

Wacker, M. (2015). *Just Say No to More End-to-End Tests*. Google Testing Blog. https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html — Source la plus citée du ratio 70/20/10.

Bourbonnais, F.-A. & Jean, S. (17 juin 2026). *ATQ18 — Pourquoi mes tests automatisés sont durs à maintenir* (session interne). Sommaire d'équipe. — Source directe pour la technique de fragmentation/boulonnage et la stratégie de migration progressive ; enseigne (sans les avoir créés) le S/M/L 2012 et le ratio 70/20/10 de Google.
