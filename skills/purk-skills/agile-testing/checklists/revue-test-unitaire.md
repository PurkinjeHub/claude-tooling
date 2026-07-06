# Checklist de revue d'un test unitaire

Liste à parcourir lors d'une revue de PR contenant des tests unitaires.
Chaque point coché renforce la confiance ; chaque point décoché est une discussion à avoir.

## Intention et lisibilité

- [ ] **Le nom du test décrit le comportement attendu**, pas la méthode appelée.
  *Exemple : `test_calcul_taxe_avec_client_exempte_retourne_zero` plutôt que `test_calcul_taxe`.*

- [ ] **Le test est compréhensible en lisant juste son nom et son corps**, sans devoir naviguer dans le code de production.

- [ ] **Les données de test ont du sens humain** (`client_exempte`, `commande_avec_3_articles`) plutôt que des identifiants opaques (`user_1`, `data_42`).

## Structure

- [ ] **Le test suit clairement la structure AAA** (Arrange, Act, Assert) ou équivalent — les trois blocs sont visibles.

- [ ] **Une seule action testée** dans le bloc Act. Si plusieurs appels métier différents s'enchaînent, c'est probablement plusieurs tests.

- [ ] **Pas de logique conditionnelle** (`if`, `for`, `try/catch`, `switch`) dans le test, sauf cas exceptionnel justifié.

- [ ] **Une ou deux assertions ciblées** sur le résultat. Si dix `expect` vérifient des aspects sans rapport, c'est plusieurs tests à scinder.

## Isolation

- [ ] **Aucune I/O réelle** : pas d'accès à la vraie DB, au réseau, au système de fichiers — sauf si c'est un test d'intégration assumé (auquel cas voir l'autre checklist).

- [ ] **Les dépendances externes sont mockées ou stubbées proprement** (pas de mock dans le mock dans le mock).

- [ ] **Le test ne dépend pas de l'ordre d'exécution** : il passe seul, il passe en groupe, il passe dans un ordre aléatoire.

- [ ] **Le test ne dépend pas de l'heure courante** ou utilise une horloge injectable (`Time.now` figé, `freeze_time`, etc.).

- [ ] **Pas d'état partagé non maîtrisé** : variables globales, singletons mutés, fichiers temporaires.

## Pertinence du test

- [ ] **Le test couvre un comportement réel**, pas un détail d'implémentation.
  *Anti-pattern : vérifier qu'une méthode privée a été appelée.*

- [ ] **Le test ne teste pas le mock** : si on stub un retour puis on vérifie ce retour, le test est tautologique.

- [ ] **Le test attrape un bug si le code de production est modifié pour devenir incorrect** : passer mentalement le code en revue et imaginer un bug qui devrait être détecté.

- [ ] **Si le test échoue, le message d'erreur indique clairement le problème** sans avoir besoin de lire le code du test.

## Couverture qualitative (pas quantitative)

- [ ] **Le happy path est couvert.**

- [ ] **Au moins un cas limite ou cas d'erreur significatif est couvert** (entrée invalide, frontière, exception attendue).

- [ ] **Les branches conditionnelles non triviales du code testé sont exercées** (si une méthode a 3 chemins distincts, au moins 3 tests devraient exister).

- [ ] **Pas de test purement décoratif** qui couvre du code trivial (getters/setters simples sans logique).

## Maintenabilité

- [ ] **Pas de duplication excessive entre tests** qui rendrait douloureux le changement d'une fixture commune — mais pas non plus d'abstraction prématurée qui rend les tests cryptiques.

- [ ] **Pas de `skip`, `pending`, `xit`, `TODO`** sans justification claire et un ticket ouvert.

- [ ] **Le test ne contient pas de constantes magiques** non expliquées (`expect(result).to eq(0.84321)` sans contexte).

## Signaux d'alerte

Si l'un de ces signaux apparaît, soulever le point en revue :

- 🚩 **Test trop long** (> 30 lignes pour un test unitaire) → probablement à scinder ou monte au niveau intégration.
- 🚩 **Mocking de plus de 3-4 dépendances** → le code de production a probablement trop de responsabilités.
- 🚩 **Préparation de fixtures > 10 lignes** → suggère un couplage fort, à challenger.
- 🚩 **Commentaires dans le test expliquant ce qu'il fait** → le test n'est pas assez explicite par lui-même.
- 🚩 **Le test casse à chaque petit refactor de la classe testée** → trop couplé à l'implémentation.

## Rappel sur les principes

Pour invoquer un point en revue, référer au principe sous-jacent (voir `../references/principes-agiles.md`) :
- Lisibilité → principe 3 (communication) et 9 (focus on people)
- Simplicité → principe 5 (keep it simple)
- Robustesse au refactor → principe 7 (respond to change)
- Suppression d'un test obsolète → principe 4 (courage)
