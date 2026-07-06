# Conventions internes — directives d'équipe

> Ce fichier rassemble les conventions et directives **propres à l'équipe**, distinctes du contenu issu du livre *Agile Testing* de Crispin & Gregory. Il est à **charger systématiquement** au début de toute activité de test, avant les références issues du livre. En cas de conflit, ces conventions priment sur les principes généraux.

## C-1 — Aligner l'organisation des tests sur l'architecture du code de production

Si le code est organisé par feature (`src/features/facturation/`), les tests le sont aussi (`tests/features/facturation/`). Si l'architecture est en couches (`controllers/`, `services/`, `models/`), les tests suivent la même décomposition. Ne pas inventer une taxonomie de tests qui contredit celle du code — ça crée une charge cognitive double et fait dériver les deux structures avec le temps.

**Implications pratiques :**

- Avant d'écrire un test, **observer la structure du projet** où il va vivre. Le test doit pouvoir se trouver par déduction logique depuis l'emplacement du code testé.
- Si l'architecture du code évolue (refactor, réorganisation par feature, migration de couches), **les tests suivent le même mouvement** dans la même PR — pas dans une PR ultérieure.
- Si on découvre que les tests ne reflètent plus l'architecture du code, c'est une dette à signaler, pas à ignorer.
- Ne pas introduire une convention de test qui suppose une architecture différente de celle du repo (ex. organisation par type de test alors que le code est par feature).

**En revue de PR :**

Demander *« où vit le code testé, et est-ce que ce test est rangé en miroir? »*. Si la réponse est non, c'est à discuter avant merge.

---

## Comment ajouter une nouvelle convention ici

Format suggéré :
- Identifiant court (`C-2`, `C-3`...) pour pouvoir la citer en revue de PR
- Titre directif
- Paragraphe d'explication du *pourquoi*
- Section « Implications pratiques » avec exemples concrets
- Section « En revue de PR » pour le mode opératoire

Garder chaque convention courte et actionnable. Si une convention demande plus de 50 lignes, c'est probablement deux conventions à scinder.
