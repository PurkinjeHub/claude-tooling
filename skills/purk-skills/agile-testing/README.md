# agile-testing — Skill d'équipe Claude Code

Skill de référence méthodologique pour les tests automatisés en contexte agile, inspiré de *Agile Testing* de Lisa Crispin et Janet Gregory (Addison-Wesley, 2009), complété par les deux éditions du modèle Google (*How Google Tests Software*, 2012 ; *Software Engineering at Google*, 2020) et par la technique de fragmentation/migration de Félix-Antoine Bourbonnais (ATQ18, 2026).

Ce skill sert toute l'équipe (développeurs + analyste QA) sur tous les projets. La méthodologie est commune ; les particularités par projet vivent dans `contextes/` (nommé ainsi pour éviter la confusion avec les Projets de claude.ai, une fonctionnalité sans lien avec ce skill).

## Installation

Ce skill vit dans le repo partagé `claude-tooling`, sous `skills/purk-skills/agile-testing/`. Voir le `README.md` à la racine du repo pour l'installation complète (clone, activation par lien symbolique, synchronisation automatique) — pas de clone séparé pour ce skill seul.

## Structure

```
agile-testing/
├── SKILL.md                          ← Point d'entrée, chargé automatiquement
├── README.md                         ← Ce fichier
├── CHANGELOG.md                      ← Évolution du contenu de ce skill
├── references/                       ← Méthodologie générale, applicable à tout projet
│   ├── conventions-internes.md       ← ⚠️ Toujours chargé en premier (directives d'équipe)
│   ├── principes-agiles.md           ← Les 10 principes du testeur agile
│   ├── quadrants.md                  ← Modèle des 4 quadrants (Marick)
│   ├── q1-tests-techniques.md        ← Tests unitaires/composantes/intégration
│   ├── automatisation.md             ← Pyramide (Cohn), ROI, réconciliation des 3 pyramides
│   ├── pyramide-google.md            ← Approche Google 2020 : sizes, doubles, hermeticity
│   ├── fragmentation-bourbonnais.md  ← S/M/L Google 2012 + fragmentation/migration (Bourbonnais, ATQ18)
│   ├── cycle-iteration.md            ← Quand tester quoi dans le sprint
│   ├── roles-responsabilites.md      ← Matrice RACI dev/QA, règles d'arbitrage
│   └── protocole-analyse.md          ← Protocole tableau + snapshot, applicable à tout projet
├── checklists/                       ← Pour les revues de PR
│   ├── revue-test-unitaire.md
│   ├── revue-test-integration.md
│   └── revue-test-e2e.md
└── contextes/                         ← Particularités par projet — jamais de théorie ici
    ├── leomed/
    │   ├── CONTEXTE.md                ← Gate Linear, stack, navigateurs, snapshot
    │   ├── rspec.md
    │   ├── jasmine.md
    │   └── playwright.md
    └── _template/
        └── CONTEXTE.md                ← Copier pour démarrer un nouveau projet
```

## Usage

Le skill se déclenche automatiquement dès qu'un contexte de test est détecté — générique (« écris un test unitaire pour cette méthode ») ou lié à un projet connu (mention de LeoMed, ticket `LOG-XX`, nom de repo). Dans ce dernier cas, `contextes/leomed/CONTEXTE.md` est chargé en plus de la méthodologie générale.

Exemples de prompts qui activeront le skill :

- *« Écris un test unitaire pour cette méthode »*
- *« Cette PR ajoute des tests, fais-en la revue »*
- *« LOG-42, génère les tests pour ce ticket »*
- *« Qui doit écrire ce test, moi ou l'analyste QA? »*
- *« Ce test te semble pertinent? »*

## Ajouter un nouveau projet

```bash
cp -r contextes/_template contextes/[nom_du_projet]
```

Remplir `CONTEXTE.md`, ajouter un fichier par framework si nécessaire, puis ajouter une ligne dans le tableau « Contextes connus » de `SKILL.md` (section détection du contexte actif).

## Limites assumées

- **Pas de conventions framework-spécifiques à la racine.** Elles vivent dans `contextes/[nom]/`, chargées uniquement quand ce contexte est actif.
- **Q3 (exploratoire) et Q4 (perf/sécu) ne sont pas généralisés** dans les références racine — un contexte peut avoir ses propres règles Q3/Q4 dans son `CONTEXTE.md` (ex. LeoMed a une règle d'exploratoire multi-navigateur).
- **Inspiré des sources citées, pas une copie** : le contenu est paraphrasé et réorganisé en français. Pour les passages originaux, consulter les sources (voir « Références » plus bas).

## Évolution prévue

Complété :
1. ✅ `references/roles-responsabilites.md` — matrice RACI dev/QA
2. ✅ `checklists/revue-test-e2e.md` — pendant QA des checklists dev existantes
3. ✅ `references/protocole-analyse.md` — protocole tableau + snapshot généralisé ; `contextes/leomed/CONTEXTE.md` n'en garde que le delta (colonne Navigateurs, champs `repos`/`browsers`)
4. ✅ Intégré au dépôt Git partagé `claude-tooling` (`skills/purk-skills/agile-testing/`), avec `CHANGELOG.md` propre à ce skill — voir aussi le `CHANGELOG.md` racine du repo pour l'historique structurel

À suivre :
5. Possible extension Q3/Q4 générique si la pratique l'exige

## Maintenance

Quand un débat d'équipe fait émerger une convention récurrente, l'ajouter ici plutôt que la redire à chaque PR — dans `references/` si elle s'applique à tous les projets, dans `contextes/[nom]/` si elle est propre à un projet. Garder les fichiers sous ~300 lignes ; si un fichier devient trop gros, le scinder par sous-thème. **Logger le changement dans `CHANGELOG.md`** (celui de ce skill, pas celui du repo).

**Historique de fusion :** ce skill remplace l'ancien Projet Claude.ai `qa-leomed`, qui dupliquait une partie de cette théorie sous une attribution différente (voir `contextes/leomed/CONTEXTE.md`, section « Application des grilles générales », pour le détail des corrections). ⚠️ Une fois ce skill validé et en place, retirer `qa-leomed` comme skill/Projet séparé pour éviter que les deux se déclenchent en parallèle sur les mêmes phrases.

**Note de nommage :** le dossier s'appelle `contextes/` et non `projets/` — délibérément, pour ne pas entrer en collision avec les Projets de claude.ai (une fonctionnalité distincte, sans lien technique avec ce skill, mais qui aurait pu prêter à confusion dans les conversations d'équipe puisque `qa-leomed` vivait justement dans un Projet claude.ai avant cette fusion).

## Références

Crispin, L. & Gregory, J. (2009). *Agile Testing: A Practical Guide for Testers and Agile Teams*. Addison-Wesley. ISBN 978-0-321-53446-0.

Concept des quadrants : Marick, B. (2003), https://www.exampler.com/old-blog/

Pyramide de tests : Cohn, M. (2009). *Succeeding with Agile*. Addison-Wesley.

Winters, T., Manshreck, T., & Wright, H. (Eds.) (2020). *Software Engineering at Google*. O'Reilly. https://abseil.io/resources/swe-book

Whittaker, J.A., Arbon, J., & Carollo, J. (2012). *How Google Tests Software*. Addison-Wesley.

Wacker, M. (2015). *Just Say No to More End-to-End Tests*. Google Testing Blog. https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html

Bourbonnais, F.-A. & Jean, S. (17 juin 2026). *ATQ18 — Pourquoi mes tests automatisés sont durs à maintenir* (session interne). — Enseigne le S/M/L 2012 et le ratio 70/20/10 de Google ; source directe pour la technique de fragmentation/boulonnage, propre à Bourbonnais.
