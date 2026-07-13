# Projet LeoMed — Spécificités

> Ce fichier est chargé par `SKILL.md` (racine) quand la conversation porte sur LeoMed
> (mention explicite, ticket Linear `LOG-XX`, ou repos `leomed-api` / `leomed-webapp` / `leomed-hub`).
> Il ne contient **que** ce qui est propre à LeoMed. La méthodologie générale (quadrants,
> pyramides, principes, fragmentation, rôles) vit dans `../../references/` et s'applique
> ici sans être répétée.

## Contexte projet

**Stack technique :**
- `leomed-api` → Rails (RSpec) — API backend
- `leomed-webapp` → Angular (Jasmine/Karma + Playwright E2E)
- `leomed-hub` → Rails (RSpec) — Hub central

**Chemins des tests :**
| Framework | Repo | Chemin |
|-----------|------|--------|
| RSpec (unitaires + intégration) | leomed-api | `spec/` |
| RSpec (unitaires + intégration) | leomed-hub | `spec/` |
| Jasmine/Karma (composantes Angular) | leomed-webapp | `src/**/*.spec.ts` |
| Playwright (E2E) | leomed-webapp | `e2e/` |

**Navigateurs supportés (Playwright) :** Chrome, Edge, Firefox — **tous les 3 par défaut** pour tout test E2E.

**Langue :** tous les tests et commentaires générés sont en **français**.

**Conventions techniques par framework :** voir `rspec.md`, `jasmine.md`, `playwright.md` dans ce même dossier.

---

## Application des grilles générales à LeoMed

Pour LeoMed, on applique les grilles décrites à la racine du skill sans les redéfinir :

- **Quadrants** (`../../references/quadrants.md`) : le modèle Q1-Q4 s'applique tel quel.
- **Pyramide Google, édition 2020** (`../../references/pyramide-google.md`) : grille par défaut pour les décisions techniques (taille, doubles de test, hermeticité).
- **S/M/L Google édition 2012, enseigné par Bourbonnais** (`../../references/fragmentation-bourbonnais.md`) : grille par portée/frontière de composante, et technique de fragmentation/dégradage (celle-ci, propre à Bourbonnais).

> ⚠️ **Correction historique (mise à jour)** — l'ancienne version de ce fichier (skill `qa-leomed`) attribuait sa pyramide Small/Medium/Large à *« Google (Whittaker, Arbon & Carollo) »*, avec le ratio 70/20/10 et un critère de « frontière de composante franchie ». **Cette attribution était en fait correcte.** Whittaker, Arbon & Carollo sont bien les auteurs de *How Google Tests Software* (2012), qui définit le S/M/L avec ce critère de portée/frontière ; et le ratio 70/20/10 vient de Google également (Mike Wacker, Google Testing Blog, 2015). La vraie nuance à connaître : Google a **fait évoluer** cette grille dans un livre plus récent (*Software Engineering at Google*, Winters et al., 2020), qui sépare plus proprement *size* (contraintes techniques pures) et *scope* (portée du code) — c'est cette édition 2020 que documente `../../references/pyramide-google.md`, avec le ratio cible 80/15/5. Les deux éditions viennent de Google ; ce ne sont pas deux sources concurrentes.

**Ratio cible pour LeoMed :** 70/20/10 (Google 2015 / Wacker, enseigné par Bourbonnais) comme jalon pragmatique actuel ; 80/15/5 (Google 2020) comme cible à moyen terme une fois l'infrastructure de test mature (voir `../../references/automatisation.md`, section réconciliation).

**Répartition des rôles :** voir `../../references/roles-responsabilites.md` pour la matrice complète (RACI) et les règles d'arbitrage. Rappel pour LeoMed :
- Small / Medium (Q1, incluant les règles d'affaires vérifiables sans navigateur) → **Développeur**
- Large / E2E automatisé (Q2) + exploratoire (Q3) → **Analyste QA**
- Le Product Owner fournit les critères d'acceptation mais ne possède aucun niveau de test.

---

## Étape 0 — Validation du ticket Linear ⛔ GATE OBLIGATOIRE

**Avant toute analyse, récupérer le ticket Linear et valider la présence des champs suivants.**

### Champs minimaux requis

| Champ | Description | Où chercher dans Linear |
|-------|-------------|------------------------|
| **Titre** | Nom clair de la fonctionnalité ou du bug | Champ `title` |
| **Description** | Explication du besoin ou du problème | Champ `description` |
| **Critères d'acceptation** | Conditions précises pour que le ticket soit considéré terminé | Section dédiée dans la description, ou labels/custom fields |
| **Repo(s) concerné(s)** | leomed-api / leomed-webapp / leomed-hub | Labels ou mention explicite dans la description |
| **Type de ticket** | Feature, Bug, Chore, etc. | Labels Linear |

### Règle de blocage — STRICT

**Si UN SEUL champ minimal est absent ou vide :**

1. ❌ **Arrêter immédiatement** — ne pas commencer l'analyse
2. Afficher le message suivant :

```
⛔ Analyse bloquée — informations manquantes dans le ticket [LOG-XX]

Les champs suivants sont requis pour démarrer l'analyse QA :
- [liste des champs manquants]

Veuillez compléter le ticket dans Linear avant de relancer l'analyse.
Je ne ferai aucune hypothèse sur le contenu manquant.
```

3. Ne pas proposer d'alternatives, ne pas faire d'hypothèses, ne pas continuer.

### Si tous les champs sont présents → continuer à l'Étape 1

---

## Étape 1 — Récupérer et lire le ticket Linear

Quand quelqu'un donne un numéro de ticket (ex: `LOG-42`) :

1. Utiliser l'outil MCP Linear pour récupérer le contenu complet du ticket :
   - Titre, description, critères d'acceptation
   - Labels, priorité, statut
2. Appliquer l'Étape 0 (validation) avant toute autre action
3. Lire attentivement les **critères d'acceptation** — ce sont les raisons d'échec potentielles
4. Identifier le(s) repo(s) concerné(s) (api / webapp / hub)

---

## Étape 2 — Analyse, classification et décision auto/manuel

Pour chaque critère d'acceptation du ticket, classer selon les grilles générales et attribuer un propriétaire — voir `../../references/roles-responsabilites.md`. Puis décider auto vs manuel selon les critères suivants, propres au contexte LeoMed :

**Automatiser si :**
- Répétable et déterministe (même input → même output)
- Règle d'affaires clairement définie dans les critères d'acceptation
- Régression probable (logique modifiable dans le futur)
- Validation technique (SQL, API, validateurs)
- Flux critique utilisateur (login, sauvegarde patient, etc.)

**Tester manuellement si :**
- Exploratoire (découvrir des comportements non anticipés)
- UX/ergonomie subjective (est-ce que c'est agréable à utiliser ?)
- Workflows métier complexes impliquant un jugement humain
- Dépend de données patients réelles ou de contexte médical spécifique
- Test de convivialité (usability testing)
- Nouveaux flux jamais encore automatisés (tester manuellement en premier)

**Tests exploratoires multi-navigateur (Q3) :**
Quand un test manuel exploratoire touche l'interface web, noter explicitement dans l'analyse qu'il devrait être exécuté sur **Chrome, Edge et Firefox**. Les différences de rendu et de comportement entre navigateurs sont une source de défauts non-reproductibles en automatisation.

### Q4 pour LeoMed (sécurité et performance)

Le root du skill (`../../references/quadrants.md`) laisse Q4 hors scope généralisé, avec une note d'évolution explicite (« éventuellement Q3/Q4 générisés si la pratique l'exige »). Pour LeoMed spécifiquement, l'expérience d'une analyse réelle (LOG-124, portail patient — application manipulant des données de santé) justifie une politique Q4 propre au projet, sans attendre une généralisation à la racine :

- **Sécurité — ne jamais différer, même en V1 ou en pilote.** LeoMed est une application médicale ; l'isolement des données patient et les protections de base (brute-force sur les facteurs d'authentification à espace de recherche restreint comme un code OTP, injection/XSS sur les champs de saisie libre, CSRF sur les actions sensibles) doivent être couverts dès la première version d'une feature, pas reportés à une itération de durcissement ultérieure.
- **Performance/charge — peut être différée, mais pas ignorée.** Un vrai test de charge (simulation d'utilisateurs concurrents) n'a de sens qu'une fois qu'on dispose de données réelles de trafic — inutile de l'anticiper sur une feature en phase pilote. Par contre, des **mesures de référence à usage unique** (temps de chargement observé avec un volume de données réaliste, sans seuil strict imposé) restent peu coûteuses à capturer dès l'analyse initiale, pour détecter une dégradation future.
- **Propriété (RACI) pour LeoMed** : sécurité Small/Medium (règles de validation, rate-limiting, policies d'autorisation) → développeur, comme le reste de Q1 ; sécurité E2E/exploratoire et mesures de performance de référence → analyste QA, en Q3/Q4 manuel. Pas de generalisation à la ligne Q4 du RACI racine (`../../references/roles-responsabilites.md`) — ceci est un ajustement explicite propre à LeoMed, documenté ici conformément à la règle « Ajuster pour un projet » de ce même fichier.

### Bilinguisme FR/EN

LeoMed est un produit bilingue (français et anglais) — à ne pas confondre avec la règle ci-dessus sur la langue du **code des tests** (toujours en français, voir plus haut). Le bilinguisme concerne l'interface elle-même et doit apparaître comme sa propre catégorie de critères d'acceptation, pas seulement comme un aspect secondaire d'un autre test :

- Vérifier que chaque libellé, bouton, message d'état, en-tête et élément de menu visible existe et s'affiche correctement dans **les deux langues** — pas seulement que le changement de langue met à jour l'interface (ça, c'est un seul critère parmi d'autres).
- Vérifier la complétude des clés de traduction (chaque clé FR a un équivalent EN et vice versa) : un test Small rapide et exhaustif, à faire avant tout balayage écran par écran.
- Le contenu des courriels transactionnels (notifications, invitations, réinitialisation de mot de passe) doit suivre la langue préférée du destinataire, pas une langue fixe.
- Prévoir une revue manuelle de non-troncature : le texte anglais est fréquemment plus long que son équivalent français (et parfois l'inverse) — un test de présence de texte ne détecte pas un débordement visuel, seul un jugement humain le peut.
- Sur une analyse réelle (LOG-124), ce point n'était mentionné nulle part dans la documentation produit et a généré 14 scénarios distincts une fois soulevé explicitement — à intégrer systématiquement dans le tableau d'analyse dès qu'une feature touche l'interface, pas seulement quand quelqu'un y pense en cours de route.

---

## Étape 3 — Tableau d'analyse et snapshot

Appliquer le **protocole général** décrit dans `../../references/protocole-analyse.md` (structure du tableau, règle « aucune ligne orpheline », format de base du snapshot). LeoMed étend ce socle avec deux ajouts, propres à l'exigence multi-navigateur du projet :

### Colonne additionnelle : Navigateurs

Le tableau d'analyse LeoMed ajoute une colonne au socle commun :

```
| # | Scénario de test | AC lié | Catégorie | Niveau | Propriétaire | Auto/Manuel | Framework | Navigateurs |
|---|-----------------|--------|-----------|--------|--------------|-------------|-----------|-------------|
| 1 | ... | AC-1 | Unitaire/Composante/E2E | Small/Medium/Large | Développeur/QA | Auto | RSpec/Jasmine/Playwright | — / Chrome+Edge+Firefox |
| 2 | ... | AC-1 | | | | Manuel | — | Chrome+Edge+Firefox |
```

**Colonne Navigateurs :**
- Tests non-UI (RSpec, Jasmine unitaire) → `—`
- Tests Playwright E2E → `Chrome + Edge + Firefox`
- Tests manuels exploratoires web → `Chrome + Edge + Firefox`

**Catégories :**
- **Unitaire** : teste une classe ou méthode isolée (Small)
- **Composante** : teste l'interaction entre quelques composantes (Medium)
- **E2E (bout en bout)** : teste un flux complet dans le navigateur (Large)

### Champs additionnels du snapshot : `repos` et `browsers`

Le snapshot LeoMed étend le schéma de base (`../../references/protocole-analyse.md`) avec `repos` au niveau racine et `browsers` par ligne de `test_analysis` :

```json
{
  "ticket_id": "LOG-XX",
  "snapshot_date": "YYYY-MM-DD",
  "snapshot_status": "todo",
  "title": "...",
  "description": "...",
  "acceptance_criteria": ["critère 1", "critère 2"],
  "repos": ["leomed-api", "leomed-webapp"],
  "test_analysis": [
    {
      "id": 1,
      "scenario": "...",
      "acceptance_criteria_ref": "AC-1",
      "category": "Unitaire|Composante|E2E",
      "level": "Small|Medium|Large",
      "owner": "Développeur|Analyste QA",
      "automation": "Auto|Manuel",
      "framework": "RSpec|Jasmine|Playwright|—",
      "browsers": "—|Chrome+Edge+Firefox"
    }
  ]
}
```

**Chemin :** `.claude/qa-snapshots/[LOG-XX]-todo-snapshot.json` — confirmer après sauvegarde : `✅ Snapshot sauvegardé : .claude/qa-snapshots/LOG-XX-todo-snapshot.json`

---

## Étape 4 — Générer les tests

Pour chaque test à automatiser, lire la référence correspondante **dans ce dossier** :

- Tests RSpec (Rails) → voir `rspec.md`
- Tests Jasmine/Karma (Angular) → voir `jasmine.md`
- Tests Playwright (E2E) → voir `playwright.md`

Et appliquer les principes de rédaction généraux : voir `../../references/q1-tests-techniques.md` (nommage, AAA, une seule raison d'échouer, mocks) et `../../references/pyramide-google.md` (choix du bon type de double : fake > stub > mock).

### Configuration Playwright multi-navigateur

Tous les tests Playwright doivent être configurés pour tourner sur les 3 navigateurs. Dans `playwright.config.ts` :

```typescript
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox',  use: { ...devices['Desktop Firefox'] } },
  { name: 'edge',     use: { ...devices['Desktop Edge'], channel: 'msedge' } },
],
```

Si ce bloc n'est pas présent dans le projet, le signaler avant de générer les tests E2E.

### Structure de nommage des fichiers

**RSpec :**
```
spec/
  models/          → tests de modèles (Small)
  services/        → tests de services (Small/Medium)
  requests/        → tests d'API (Medium)
  features/        → tests de flux complets (Large - rare)
```

**Jasmine/Karma :**
```
src/app/[composante]/
  [composante].component.spec.ts   → test du composant Angular
  [service].service.spec.ts        → test du service Angular
```

**Playwright :**
```
e2e/
  [flux]/
    [flux].spec.ts    → test E2E du flux
  fixtures/           → données de test partagées
  helpers/            → fonctions utilitaires
```

---

## Étape 5 — Recommandation sur l'outil E2E

Playwright est le choix par défaut. Proposer une alternative seulement si :

| Situation | Recommandation |
|-----------|---------------|
| Tests E2E standard (navigation, formulaires, flux Angular) | **Playwright** ✅ (Chrome + Edge + Firefox) |
| Tests nécessitant du BDD / Gherkin lisible par les non-devs | **Cucumber + Playwright** |
| Tests nécessitant une compatibilité multi-navigateur ancienne | **Selenium** (à éviter si possible) |
| Tests d'API purs sans UI | **RSpec request specs** ou **Postman/Newman** |

---

## Avertissements importants

⚠️ **Anti-pattern : Ice Cream Cone** — Avoir trop de tests Large et peu de Small/Medium. Si la distribution s'éloigne trop de 70/20/10, le signaler. Pour la stratégie de correction (dégradage opportuniste lié aux stories, sans sprint dédié), voir `../../references/fragmentation-bourbonnais.md`.

⚠️ **Fragilité des tests** — Un test qui échoue pour plusieurs raisons différentes est un test fragile. Refuser de générer des tests qui violent la règle "une seule raison d'échec". Voir la technique de fragmentation et boulonnage dans `../../references/fragmentation-bourbonnais.md` pour scinder un scénario trop large.

⚠️ **Silos à éviter** — Les tests unitaires ne sont pas "seulement pour les devs". En QA, il faut comprendre et co-construire tous les niveaux — la matrice de rôles répartit la responsabilité d'écriture, pas la compréhension.

⚠️ **Médical** — LeoMed est une application médicale. Les flux impliquant des données patients réelles ou des décisions cliniques doivent **toujours** inclure une validation manuelle en complément de l'automatisation.
