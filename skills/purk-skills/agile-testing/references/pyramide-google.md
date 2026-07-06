# La pyramide de tests de Google

> Approche complémentaire à celle de Crispin & Gregory, formalisée dans *Software Engineering at Google* (O'Reilly, 2020), chapitres 11-14. Le livre est co-écrit par plusieurs ingénieurs Google et documente leurs pratiques à grande échelle (millions de tests, dizaines de milliers d'ingénieurs). Une édition en ligne libre est disponible : https://abseil.io/resources/swe-book

## Idée centrale et complémentarité avec Cohn

Là où la pyramide de Cohn (voir `automatisation.md`) classe les tests par **ce qu'ils testent** (unité, intégration, E2E), Google les classe par **contraintes techniques d'exécution** — quel temps ils peuvent prendre, quelles ressources ils peuvent utiliser, quelles I/O sont autorisées.

Avantage pratique : la classification devient **binaire et vérifiable**. Un test qui fait un appel réseau ne peut pas être Small, point. Ça coupe court aux débats sémantiques.

Les deux pyramides se combinent : Cohn convainc, Google outille.

---

## Les tailles de tests (Test Sizes)

### Small

**Contraintes techniques :**
- Un seul processus, un seul thread
- Aucun accès réseau (même localhost)
- Aucun accès disque (fichiers, DB)
- Aucun `sleep`, aucune attente sur horloge
- Temps d'exécution : de l'ordre de la seconde ou moins

**Ce que ça donne en pratique :**
- Le test tourne entièrement en mémoire
- Le résultat est 100 % déterministe par construction
- Idéal pour : logique métier pure, transformations, calculs, validations

**Correspondance approximative avec Cohn :** tests unitaires bien isolés.

### Medium

**Contraintes techniques :**
- Peuvent utiliser plusieurs threads/processus
- Peuvent accéder à `localhost` (DB locale, serveur web local en test)
- **Interdit :** accès réseau externe
- Temps d'exécution : jusqu'à ~1 minute

**Ce que ça donne en pratique :**
- Un test qui monte une DB in-memory (SQLite, H2) ou une vraie DB locale : Medium
- Un test qui monte un serveur HTTP local et fait un vrai appel HTTP : Medium
- Un test qui appelle Stripe, Google Maps, ou toute API externe : **pas Medium**

**Correspondance approximative avec Cohn :** tests d'intégration.

### Large

**Contraintes techniques :**
- Peuvent utiliser plusieurs machines
- Peuvent accéder au réseau externe
- Peuvent utiliser des systèmes distribués complets
- Temps d'exécution : plusieurs minutes acceptable

**Ce que ça donne en pratique :**
- Tests E2E complets (browser-based, chaîne complète)
- Tests contre un environnement staging
- Tests d'intégration avec de vrais services externes

**Correspondance approximative avec Cohn :** tests E2E / système.

## Ratios cibles

Ordre de grandeur recommandé par Google :

- **~80 %** de Small tests
- **~15 %** de Medium tests
- **~5 %** de Large tests

Ces ratios se mesurent en **nombre de tests**, pas en lignes couvertes. Une équipe avec 60 % de Large tests a un problème d'infrastructure de test, pas un manque de tests.

---

## Distinction clé : Test Size ≠ Test Scope

**La partie la plus subtile — et la plus utile — de l'approche Google.**

Le *size* d'un test décrit **comment il s'exécute** (contraintes techniques).
Le *scope* décrit **combien de code il exerce** (une fonction, un module, l'app entière).

Les deux sont **orthogonaux** :

|  | Unit scope | Integration scope | System scope |
|---|---|---|---|
| **Small size** | ✅ le cas normal | ⚠️ rare mais possible avec bons fakes | ❌ impossible en pratique |
| **Medium size** | ⚠️ souvent un anti-pattern* | ✅ le cas normal | ⚠️ possible mais coûteux |
| **Large size** | ❌ presque toujours un anti-pattern | ⚠️ possible | ✅ le cas normal |

\* Un test avec un *unit scope* qui est *Medium* size (autorise DB locale, threads...) est souvent signe qu'on n'a pas pris le temps d'isoler correctement — un fake ou un stub ferait mieux.

**Question à se poser en revue de PR :**
> *« Ce test a-t-il vraiment besoin du size qu'il occupe, ou pourrait-il être plus petit à scope équivalent? »*

Chaque descente d'un tier vers Small améliore la vitesse, le déterminisme, et la scalabilité de la suite. C'est un investissement qui rapporte à chaque exécution ultérieure.

---

## Hermeticité

Un test est **hermétique** s'il donne toujours le même résultat pour le même code, indépendamment de l'environnement d'exécution. C'est le graal chez Google.

- **Small tests sont hermétiques par construction** — les contraintes techniques les y forcent.
- **Medium tests peuvent l'être** avec effort : DB in-memory, ports dynamiques, nettoyage explicite d'état.
- **Large tests sont rarement pleinement hermétiques** — c'est le prix à payer pour couvrir la chaîne complète.

**Règle pratique :** un test non-hermétique est une bombe à retardement. Il finira par devenir flaky. Investir dans l'hermeticité en amont coûte moins cher que débugger les flakes en aval.

---

## Taxonomie des test doubles

Terminologie originellement formalisée par Gerard Meszaros (*xUnit Test Patterns*, 2007), reprise et affinée par Google (chapitre 13). Utile en revue de PR pour dire précisément *quel* type de double est utilisé, plutôt que le terme fourre-tout « mock ».

| Type | Comportement | Utilisation typique |
|---|---|---|
| **Dummy** | Objet passé pour satisfaire une signature, jamais utilisé | Compléter un constructeur qu'on ne veut pas exercer |
| **Stub** | Retourne des valeurs pré-programmées, aucune logique | Fournir des réponses fixes à un appel de service externe |
| **Fake** | Implémentation légère mais **fonctionnelle** | `InMemoryUserRepository` qui remplace une vraie DB |
| **Spy** | Enveloppe un vrai objet et enregistre les interactions | Vérifier qu'une méthode a été appelée sans changer son comportement |
| **Mock** | Comme spy, mais **avec des attentes pré-programmées** qui font échouer le test si non satisfaites | Vérifier une séquence d'appels précise (à utiliser avec parcimonie) |

**Ordre de préférence Google : Fakes > Stubs > Mocks.**

Pourquoi cet ordre :
- **Fakes** offrent un comportement réaliste. Un test avec un fake ressemble au code de production.
- **Stubs** sont simples et lisibles, mais peuvent devenir tautologiques (« je stub que la méthode retourne X, je vérifie qu'elle retourne X »).
- **Mocks** couplent le test à la *séquence d'appels internes* — antinomique avec le principe *« tester le comportement, pas l'implémentation »*.

**Signal en revue de PR :** une PR avec 6 mocks pour tester une méthode devrait déclencher la question *« ne pourrait-on pas remplacer par un fake unique? »*.

**Corollaire pour ton équipe :** quand un service externe est utilisé fréquemment en test (repository, client HTTP, service de cache), envisager d'écrire un *fake* réutilisable dans le codebase de test. L'investissement initial est vite rentabilisé.

---

## Flaky tests — le poison silencieux

Chiffres publiés par Google :

- **~1,5 %** des exécutions de tests produisent un résultat non-déterministe (flaky)
- **~16 %** des tests ont flaké au moins une fois sur une fenêtre de 30 jours
- **~3,7 heures** d'ingénierie en moyenne pour réparer un flaky test

À échelle Google c'est massif, mais même sur une suite de 500 tests, un taux de flakes de 5 % suffit à empoisonner le CI.

**Pourquoi c'est catastrophique — au-delà du coût direct :**
- Érosion de la confiance dans **toute** la suite
- Les devs ignorent les échecs (« c'est probablement le flake ») → les vrais bugs passent
- Le CI devient un jeu de dés
- Le temps perdu à relancer, débugger, se demander si c'est réel se compte en semaines-ingénieur

**Approche Google :**
1. **Détecter automatiquement** : relancer les tests plusieurs fois, mesurer la variance de résultat
2. **Quarantaine** : sortir les tests flakes de la suite bloquante rapidement, avec un ticket obligatoire
3. **SLA de réparation** : un test en quarantaine plus de X jours est supprimé — un test ignoré n'apporte plus rien
4. **Politique zéro tolérance** : la CI qui casse pour cause de flake est traitée en priorité, comme un vrai bug

**Corollaire :** vaut mieux moins de tests fiables que plus de tests instables. Une suite de 200 tests solides bat une suite de 2000 tests dont 100 flakent.

---

## Comment appliquer tout ça en pratique

Chaque fois qu'un nouveau test est écrit :

1. **Écrire aussi petit que possible** — tenter Small d'abord ; ne monter en size que si nécessaire
2. **Nommer le size dans le fichier** (annotation, tag, dossier séparé) pour que la CI puisse trier — une suite Small doit pouvoir tourner en pré-commit ; les Large tournent la nuit
3. **Vérifier l'hermeticité** — le test passe-t-il en isolation, sans autre test, dans n'importe quel ordre?
4. **Choisir le bon double** — préférer un fake si disponible ; sinon stub ; mock en dernier recours
5. **Suivi flakes** — noter tout test devenu intermittent dans un canal dédié, traiter dans la semaine

## En revue de PR — questions rapides

Pour toute PR contenant de nouveaux tests :

- 🔍 **Quel size?** (Small / Medium / Large — vérifier les contraintes)
- 🔍 **Quel scope?** (Unit / Integration / System — indépendant du size)
- 🔍 **La combinaison size×scope est-elle optimale?** (Small × Unit est la valeur par défaut à préserver)
- 🔍 **Le test est-il hermétique?** (passe-t-il seul, en groupe, dans un ordre aléatoire?)
- 🔍 **Les test doubles utilisés sont-ils du bon type?** (fake plutôt que mock quand possible)

## Lien avec le reste du skill

- Pyramide de Cohn (`automatisation.md`) → vision stratégique, forme globale de la suite
- Pyramide de Google (ce fichier) → vision opérationnelle, critères concrets par test
- Principes de Crispin/Gregory (`principes-agiles.md`) → posture et culture d'équipe
- Q1 techniques (`q1-tests-techniques.md`) → écriture concrète d'un test bien fait

Les quatre se complètent — aucune ne remplace les autres.

## Références

Winters, T., Manshreck, T., & Wright, H. (Eds.) (2020). *Software Engineering at Google*. O'Reilly. Édition libre : https://abseil.io/resources/swe-book

- Chapitre 11 : Testing Overview (test sizes, test scope)
- Chapitre 12 : Unit Testing
- Chapitre 13 : Test Doubles
- Chapitre 14 : Larger Testing

Meszaros, G. (2007). *xUnit Test Patterns: Refactoring Test Code*. Addison-Wesley. (Taxonomie originale des test doubles.)

Micco, J. (2016). *Flaky Tests at Google and How We Mitigate Them*. Google Testing Blog. https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html
