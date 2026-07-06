# Référence Playwright — LeoMed WebApp (E2E)

## Quand utiliser Playwright (Large)

Playwright est réservé aux tests **Large** — utiliser seulement pour valider des flux
utilisateurs complets qui ne peuvent pas être testés autrement. Rappel pyramide :
~10% des tests seulement.

**Flux typiques pour LeoMed :**
- Connexion / déconnexion
- Création complète d'un dossier patient
- Navigation entre modules critiques
- Impression / export de documents médicaux

## Structure des fichiers

```
playwright/
  tests/                    ← specs E2E (ex: additional-text.spec.ts)
  helpers/                  ← fonctions utilitaires partagées
  global-setup.ts           ← auth unique avant tous les tests
  .auth/user.json           ← session réutilisée (ne pas committer)
playwright.config.ts        ← à la racine de leomed-webapp
```

> ⚠️ Le dossier s'appelle `playwright/`, pas `e2e/`.

## Configuration (playwright.config.ts)

```typescript
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  
  reporter: [
    ['html', { open: 'never' }],
    ['list']
  ],

  use: {
    baseURL: 'http://localhost:4200',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    locale: 'fr-CA',
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
```

## Test de connexion (flux critique)

```typescript
// e2e/auth/connexion.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentification', () => {
  test('connexion réussie avec des identifiants valides', async ({ page }) => {
    // Arrange
    await page.goto('/connexion');

    // Act
    await page.getByLabel('Nom d\'utilisateur').fill('medecin@leomed.ca');
    await page.getByLabel('Mot de passe').fill('MotDePasseTest123!');
    await page.getByRole('button', { name: 'Se connecter' }).click();

    // Assert — vérifier la présence d'un élément, pas les détails (évite la fragilité)
    await expect(page).toHaveURL('/tableau-de-bord');
    await expect(page.getByRole('navigation')).toBeVisible();
  });

  test('affiche un message d\'erreur avec des identifiants invalides', async ({ page }) => {
    // Arrange
    await page.goto('/connexion');

    // Act
    await page.getByLabel('Nom d\'utilisateur').fill('inconnu@leomed.ca');
    await page.getByLabel('Mot de passe').fill('mauvais_mot_de_passe');
    await page.getByRole('button', { name: 'Se connecter' }).click();

    // Assert — vérifier le message d'erreur, pas la valeur des champs
    await expect(page.getByRole('alert')).toContainText('Identifiants invalides');
  });
});
```

## Helpers d'authentification (réutilisation)

```typescript
// e2e/helpers/auth.helper.ts
import { Page } from '@playwright/test';

/**
 * Connecte un utilisateur et attend la redirection vers le tableau de bord.
 * À utiliser dans beforeEach pour éviter la duplication.
 */
export async function seConnecter(page: Page, role: 'medecin' | 'infirmiere' | 'admin' = 'medecin') {
  const identifiants = {
    medecin: { email: 'medecin@leomed.ca', mdp: 'MotDePasseTest123!' },
    infirmiere: { email: 'infirmiere@leomed.ca', mdp: 'MotDePasseTest123!' },
    admin: { email: 'admin@leomed.ca', mdp: 'MotDePasseTest123!' },
  };

  await page.goto('/connexion');
  await page.getByLabel('Nom d\'utilisateur').fill(identifiants[role].email);
  await page.getByLabel('Mot de passe').fill(identifiants[role].mdp);
  await page.getByRole('button', { name: 'Se connecter' }).click();
  await page.waitForURL('/tableau-de-bord');
}
```

## Test de flux patient (Medium/Large)

```typescript
// e2e/patients/creation-dossier.spec.ts
import { test, expect } from '@playwright/test';
import { seConnecter } from '../helpers/auth.helper';

test.describe('Création de dossier patient', () => {
  test.beforeEach(async ({ page }) => {
    await seConnecter(page, 'medecin');
  });

  test('crée un dossier patient avec les informations minimales', async ({ page }) => {
    // Arrange
    await page.goto('/patients/nouveau');

    // Act
    await page.getByLabel('Nom').fill('Tremblay');
    await page.getByLabel('Prénom').fill('Jean');
    await page.getByLabel('Date de naissance').fill('1975-03-15');
    await page.getByRole('button', { name: 'Créer le dossier' }).click();

    // Assert — vérifier que le dossier a été créé (présence d'un identifiant)
    await expect(page.getByText('Dossier créé avec succès')).toBeVisible();
    // Vérifier qu'un numéro de dossier a été généré (sans vérifier la valeur exacte)
    await expect(page.getByTestId('numero-dossier')).not.toBeEmpty();
  });
});
```

## Bonnes pratiques anti-fragilité

```typescript
// ✅ BON : sélecteur sémantique (stable)
await page.getByRole('button', { name: 'Sauvegarder' }).click();
await page.getByLabel('Nom du patient').fill('Tremblay');
await page.getByTestId('numero-dossier');

// ❌ MAUVAIS : sélecteur CSS fragile (change avec le design)
await page.locator('.btn-primary.submit-form').click();
await page.locator('#input-12345').fill('Tremblay');

// ✅ BON : vérifier la présence, pas la valeur exacte quand non critique
await expect(page.getByRole('alert')).toBeVisible();
await expect(page.getByTestId('liste-patients')).not.toBeEmpty();

// ❌ MAUVAIS : vérifier un texte exact qui peut changer
await expect(page.locator('h1')).toHaveText('Liste des patients - 42 résultats');
```

## Attributs data-testid

Pour les composantes Angular, ajouter des attributs `data-testid` pour les sélecteurs stables :

```html
<!-- Dans le template Angular -->
<button data-testid="btn-sauvegarder" type="submit">Sauvegarder</button>
<span data-testid="numero-dossier">{{ patient.numeroDossier }}</span>
<div data-testid="liste-patients">...</div>
```

## Tests E2E sur supportqa — prérequis avant d'exécuter

Les tests Playwright ciblent `supportqa.leomed.co`. Deux conditions doivent être réunies :

1. **La fonctionnalité doit être déployée sur supportqa** — si la branche n'est pas déployée, les tests échoueront même si le code local est correct. Vérifier la version dans le footer de l'app (`x.y.z (date)`).
2. **Les données de test doivent exister** — formulaires, patients, et autres entités référencées dans le spec doivent être créés manuellement sur supportqa avant la première exécution.

---

## Mode sériel — suites avec état partagé

Utiliser le mode sériel quand les tests d'une suite partagent un état (même formulaire, même patient, même run) sur un environnement distant.

```typescript
test.describe('Ma suite', () => {
  test.describe.configure({ mode: 'serial' });
  // Un seul échec arrête toute la suite.
  // Diagnostiquer toujours le test #1 en premier.
});
```

En mode sériel, les tests suivant un échec apparaissent comme `-` (skipped) dans le rapport — ce n'est pas un résultat, c'est une conséquence du premier échec.

---

## Commandes utiles

```bash
# Lancer tous les tests E2E
npx playwright test

# Lancer un seul projet (Chrome uniquement)
npx playwright test --project=chrome

# Mode interface graphique (débogage)
npx playwright test --ui

# Lancer un fichier spécifique
npx playwright test playwright/tests/mon-spec.spec.ts

# Générer le rapport HTML
npx playwright show-report

# Enregistrer un nouveau test (codegen)
npx playwright codegen https://supportqa.leomed.co
```

## Quand proposer Cucumber à la place

Proposer Cucumber + Playwright si Alice mentionne :
- Des scénarios à valider avec des non-développeurs (analystes, médecins)
- Des tests de recette formels
- Une documentation vivante des cas métier

```gherkin
# Exemple Cucumber (si adopté)
Fonctionnalité: Création de dossier patient

  Scénario: Création réussie avec les champs obligatoires
    Étant donné que je suis connecté en tant que médecin
    Quand je crée un dossier pour "Jean Tremblay" né le "15/03/1975"
    Alors un numéro de dossier est généré
    Et un message de confirmation s'affiche
```
