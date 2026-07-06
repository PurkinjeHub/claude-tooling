# Q1 — Tests techniques qui supportent l'équipe

> Source : Crispin & Gregory, *Agile Testing*, chapitre 7. Paraphrasé et adapté en français, avec ajouts pratiques.

**C'est le cœur du skill.** Ce fichier couvre ce que la littérature appelle Q1 : tests unitaires, tests de composantes, et tests d'intégration de bas niveau.

## Trois types de tests dans Q1

### 1. Tests unitaires

**Définition :** isolent une *unité* de code (méthode, classe, fonction pure) et vérifient son comportement sans dépendre du reste du système.

**Caractéristiques :**
- Ultra-rapides (millisecondes)
- Aucune I/O réelle (pas de DB, pas de réseau, pas de système de fichiers)
- Toutes les dépendances externes sont mockées, stubbées ou injectées
- Déterministes : même entrée → même sortie, toujours

**Quand en écrire :**
- Logique métier dans un service, un model, un helper
- Calculs, transformations de données, validations
- Branches conditionnelles non triviales
- Cas limites et erreurs

**Quand *ne pas* en écrire :**
- Getters/setters triviaux (sauf s'ils contiennent de la logique)
- Code purement déclaratif (configuration, routes, schémas) — sauf si la config a un comportement testable

### 2. Tests de composantes

**Définition :** testent une *composante* en tant qu'unité un peu plus large — typiquement une classe avec ses collaborateurs proches, ou un composant UI avec son template.

**Caractéristiques :**
- Rapides (dizaines à centaines de ms)
- Peuvent monter une partie du framework (ex. compiler un composant Angular avec son template) sans monter toute l'app
- Dépendances externes lointaines (DB, API) restent mockées
- Test le *contrat de la composante*, pas chaque méthode individuellement

**Quand en écrire :**
- Composants Angular avec liaison template/logique
- Composants React/Vue avec hooks/lifecycle
- Classes Rails qui combinent plusieurs concerns
- Pipes, directives, présentateurs, view models

### 3. Tests d'intégration bas niveau

**Définition :** vérifient l'*intégration* entre deux ou trois composantes ou couches, sans monter toute l'app.

**Caractéristiques :**
- Plus lents (centaines de ms à quelques secondes)
- Peuvent toucher une vraie DB locale (ex. SQLite in-memory, MySQL/Postgres test)
- Touchent du vrai code dans plusieurs couches : service ↔ repository ↔ DB, ou controller ↔ service ↔ model
- Ne touchent *pas* l'UI complète ni les vrais services externes

**Quand en écrire :**
- Validation que les requêtes ORM/SQL produisent les bons résultats
- Vérification que les transactions DB se comportent correctement
- Tests de contrats d'API internes (un controller appelé directement par requête HTTP, sans browser)
- Intégration entre deux modules importants du système

**Distinction clé avec un test E2E :** un test d'intégration bas niveau coupe à un point précis et mock le reste. Un test E2E pilote toute la pile, navigateur compris.

## La structure AAA (Arrange, Act, Assert)

Tout test Q1 devrait visiblement se découper en trois blocs :

```
def test_calcule_taxe_avec_exemption()
  # Arrange — préparer l'état et les entrées
  client = Client.new(province: "QC", exempte: true)
  produit = Produit.new(prix: 100.00)
  
  # Act — une seule action testée
  taxe = CalculTaxe.new.pour(client, produit)
  
  # Assert — vérifier le résultat attendu
  expect(taxe).to eq(0.00)
end
```

Si le bloc Act fait plus d'une action, c'est probablement deux tests.

## Nommage des tests

**Règle :** le nom du test doit décrire le *comportement attendu*, pas la *méthode appelée*.

| ❌ Mauvais | ✅ Bon |
|---|---|
| `test_calculer_taxe` | `test_calculer_taxe_avec_client_exempte_retourne_zero` |
| `test_validation` | `test_validation_rejette_courriel_sans_arobase` |
| `test_save_user` | `test_sauvegarde_utilisateur_genere_un_id_unique` |

Trois conventions courantes (choisir une et s'y tenir) :
1. `test_[contexte]_[action]_[résultat_attendu]`
2. *Given-When-Then* : `given_client_exempte_when_calcul_taxe_then_retourne_zero`
3. Phrase descriptive : `« retourne zéro quand le client est exempté »` (BDD-style)

## Ce qu'un bon test Q1 doit avoir

1. **Un nom qui se lit comme une spécification** (voir ci-dessus)
2. **Une seule raison de casser** : si plusieurs assertions vérifient des aspects différents du résultat, ça peut rester ensemble ; si elles vérifient plusieurs *comportements*, c'est plusieurs tests
3. **Aucune logique conditionnelle** (`if`, `for`, `try`) — sinon le test lui-même devient du code à tester
4. **Données de test explicites** : préférer `client_exempte` ou `commande_avec_3_articles` à `client_1` ou `data_42`
5. **Un message d'erreur clair** quand l'assertion échoue : on doit comprendre le problème *sans* lire le code du test
6. **Indépendance** : l'ordre d'exécution ne doit pas affecter le résultat ; les tests ne partagent pas d'état

## Anti-patterns courants

### Test qui teste le mock

```ruby
service = double("Service")
allow(service).to receive(:calcul).and_return(42)
expect(service.calcul).to eq(42)  # On teste le mock, pas le code
```

Si tu mockes ce que tu veux tester, tu ne testes plus rien. Un mock doit représenter une *dépendance externe* du sujet sous test.

### Test couplé à l'implémentation

```ruby
expect(service).to have_received(:_methode_privee_etape_2)
```

Vérifier qu'une méthode privée a été appelée couple le test à l'implémentation. Au prochain refactor, le test casse alors que le comportement n'a pas changé. Tester le *résultat observable*, pas la *séquence interne*.

### Test trop large

Un test « unitaire » qui prépare 30 lignes de fixtures, démarre 4 services et fait 12 assertions n'est pas unitaire. Il est probablement à découper, soit en plusieurs tests, soit en remontant au niveau intégration assumé.

### Test fragile (flaky)

Un test qui passe parfois, échoue parfois. Causes fréquentes :
- Dépendance à l'heure courante (utiliser une horloge injectable)
- Dépendance à l'ordre d'exécution (état partagé entre tests)
- Concurrence non maîtrisée (threads, async)
- Dépendance à une ressource externe (réseau, DB partagée)

**Règle absolue :** un test flaky est pire qu'un test absent. Il faut le réparer ou le supprimer immédiatement — un test qu'on ignore érode la confiance dans toute la suite.

### Excès de DRY dans les tests

Le code de production gagne à être DRY. Les tests gagnent souvent à être *plus duplicatifs* mais *plus explicites*. Une fixture partagée par 50 tests crée un couplage caché qui fait dérailler la suite à chaque modification.

## La règle de la pyramide appliquée à Q1

Dans Q1, on cherche à pousser un maximum de couverture vers les tests *unitaires* (rapides, isolés), et à minimiser le besoin de tests *d'intégration* (plus lents, plus fragiles).

**Heuristique :** si tu hésites entre écrire un test unitaire et un test d'intégration pour vérifier la même chose, prends d'abord l'unitaire. Ajoute un test d'intégration uniquement si l'unitaire ne peut pas couvrir un risque réel (ex. requête SQL spécifique, comportement transactionnel).

## Quand le code rend Q1 difficile à écrire

Un Q1 difficile à écrire est presque toujours un signal de design :

- *« Je dois mocker 8 dépendances »* → trop de responsabilités, scinder la classe.
- *« Je dois préparer 50 lignes de fixtures »* → la méthode dépend de trop d'état, simplifier le contrat.
- *« Le test échoue de façon non déterministe »* → effet de bord caché (état global, horloge, ordre).
- *« Je ne sais pas quoi tester »* → la responsabilité de l'unité n'est pas claire ; clarifier le contrat d'abord.

**Réflexe :** ne pas se battre contre le test. Si le test résiste, c'est le code de production qui doit changer.

## Lien avec les checklists

Pour appliquer ces principes concrètement dans une revue de PR, voir :
- `../checklists/revue-test-unitaire.md`
- `../checklists/revue-test-integration.md`
