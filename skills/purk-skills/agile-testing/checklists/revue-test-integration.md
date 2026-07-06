# Checklist de revue d'un test d'intégration

Liste à parcourir lors d'une revue de PR contenant des tests d'intégration de bas niveau (pas E2E).

Beaucoup de points sont communs avec les tests unitaires — voir `revue-test-unitaire.md`. Cette checklist se concentre sur ce qui est *spécifique* à l'intégration.

## Justification du niveau

- [ ] **Le test est au bon niveau de la pyramide** : il vérifie quelque chose qui ne *peut pas* être validé par un test unitaire isolé.
  *Exemples valides : requête ORM complexe, transaction DB, contrat HTTP d'un endpoint interne, intégration entre deux modules importants.*
  *Exemple invalide : test qui pourrait être unitaire mais qu'on a écrit en intégration par habitude.*

- [ ] **Le périmètre du test est explicite** : on sait précisément quelles couches sont impliquées et lesquelles sont mockées.
  *« Ce test exerce le controller → service → repository → DB. L'authentification est stubbée. »*

- [ ] **Le test ne déborde pas en E2E** : pas de pilotage de navigateur, pas d'appel à des services externes réels.

## Données et isolation

- [ ] **Les données de test sont préparées de façon explicite et minimale** dans le test ou via une factory claire. Pas de dépendance à un état laissé par un autre test.

- [ ] **La DB est dans un état connu au début du test** (transaction qui rollback, base nettoyée, seeds explicites).

- [ ] **Le test nettoie après lui** (ou compte sur la transaction de rollback du framework) — l'ordre d'exécution ne doit pas affecter le résultat.

- [ ] **Pas de partage caché d'état** entre tests via fichiers, caches, variables d'environnement modifiées.

- [ ] **Les données de test sont représentatives** : pas juste un cas avec des valeurs `null` partout, mais des données qui ressemblent à de la vraie donnée métier.

## Performance

- [ ] **Le test reste raisonnablement rapide** (idéalement < 1 seconde, max quelques secondes).
  *Si plusieurs tests dépassent 10s chacun, la suite va devenir injouable en CI.*

- [ ] **Pas de `sleep`, `wait`, ou délai arbitraire** pour synchroniser. Utiliser des hooks d'attente déterministes (ex. `wait_until` sur condition observable).

- [ ] **Setup partagé judicieux** : si plusieurs tests utilisent la même fixture coûteuse, envisager `before(:all)` plutôt que `before(:each)` — mais en mesurant le risque de couplage.

## Stabilité (anti-flakiness)

- [ ] **Le test passe 10 fois de suite sans modification.** (Ne pas se contenter d'un seul passage en CI.)

- [ ] **Aucune dépendance à un service externe** non maîtrisé (API tierce, DNS, NTP...).

- [ ] **Aucune dépendance à l'ordre alphabétique des résultats** ou à un ordre d'insertion en DB qui n'est pas explicitement trié.

- [ ] **Pas de race condition** dans les tests asynchrones : les attentes sont sur des conditions observables, pas sur le temps écoulé.

- [ ] **Dates et UUIDs maîtrisés** : pas d'`uuid()` ou de `now()` dans les assertions sans capture explicite.

## Pertinence

- [ ] **Le test vérifie un comportement observable** côté client/appelant du système (réponse HTTP, état persisté, événement émis), pas le détail interne d'une étape intermédiaire.

- [ ] **Le test attrape une vraie classe de bugs** : poser la question *« quelle modification incorrecte du code ferait échouer ce test? »*. Si la réponse est *« rien de plausible »*, le test n'apporte pas grand-chose.

- [ ] **Le test ne duplique pas la couverture d'un test unitaire existant** sans raison.

## Quand le test d'intégration est-il vraiment nécessaire?

Cocher au moins un de ces cas :

- [ ] Vérification d'une **requête ORM/SQL** complexe qu'un test unitaire avec mock ne pourrait pas valider correctement.
- [ ] Vérification du comportement **transactionnel** (rollback, isolation, contraintes DB).
- [ ] Test d'un **contrat HTTP/API** côté serveur sans piloter le navigateur (request specs en Rails, supertest en Node, etc.).
- [ ] Vérification de l'**intégration entre deux modules** dont les contrats sont complexes ou évolutifs.
- [ ] Test d'une **migration de données** ou d'un script de batch.

Si aucun de ces cas ne s'applique, demander : *est-ce qu'un test unitaire ne suffirait pas?*

## Signaux d'alerte

- 🚩 **Le test prend plus de 5 secondes** sans raison technique claire → probablement trop large ou mal isolé.
- 🚩 **Le test crée des dizaines d'enregistrements en DB** pour vérifier un comportement → trop large, à découper.
- 🚩 **Le test échoue de façon non déterministe** → flaky, à réparer ou supprimer immédiatement.
- 🚩 **Le test reproduit la même logique que le code de production** dans son setup → couplage à l'implémentation.
- 🚩 **Le test passe « en CI » mais pas en local** (ou inversement) → environnement non reproductible, problème à résoudre avant merge.

## Rappels

- Un test d'intégration vaut **plus cher** qu'un test unitaire en maintenance. Investir avec parcimonie.
- Un test d'intégration qui n'apporte rien de plus qu'un unitaire est **du gaspillage** déguisé en rigueur.
- Voir `../references/automatisation.md` pour la stratégie globale et `../references/q1-tests-techniques.md` pour les principes communs avec les unitaires.
