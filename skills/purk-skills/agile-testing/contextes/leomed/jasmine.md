# Référence Jasmine/Karma — LeoMed WebApp (Angular)

## Conventions de base

```typescript
// Structure standard d'un test de composante Angular
describe('NomComposante', () => {
  // Arrange global
  let composante: NomComposante;
  let fixture: ComponentFixture<NomComposante>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [NomComposante],
      providers: [...],
      imports: [...]
    }).compileComponents();

    fixture = TestBed.createComponent(NomComposante);
    composante = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('devrait être créé', () => {
    expect(composante).toBeTruthy();
  });
});
```

## Tests de composantes (Small)

```typescript
// src/app/patient/patient-detail/patient-detail.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PatientDetailComponent } from './patient-detail.component';
import { PatientService } from '../patient.service';

describe('PatientDetailComponent', () => {
  let composante: PatientDetailComponent;
  let fixture: ComponentFixture<PatientDetailComponent>;
  let patientServiceSpy: jasmine.SpyObj<PatientService>;

  beforeEach(async () => {
    // Créer un spy pour isoler le composant du service réel (reste Small)
    const spy = jasmine.createSpyObj('PatientService', ['obtenirPatient']);

    await TestBed.configureTestingModule({
      declarations: [PatientDetailComponent],
      providers: [
        { provide: PatientService, useValue: spy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(PatientDetailComponent);
    composante = fixture.componentInstance;
    patientServiceSpy = TestBed.inject(PatientService) as jasmine.SpyObj<PatientService>;
  });

  it('devrait afficher le nom du patient', () => {
    // Arrange
    const patient = { id: 1, nom: 'Tremblay', prenom: 'Jean' };
    patientServiceSpy.obtenirPatient.and.returnValue(of(patient));
    
    // Act
    fixture.detectChanges();
    
    // Assert
    const element = fixture.nativeElement.querySelector('.nom-patient');
    expect(element.textContent).toContain('Tremblay');
  });

  it('devrait afficher un message d\'erreur quand le patient est introuvable', () => {
    // Arrange
    patientServiceSpy.obtenirPatient.and.returnValue(
      throwError(() => new Error('Patient introuvable'))
    );
    
    // Act
    fixture.detectChanges();
    
    // Assert
    const erreur = fixture.nativeElement.querySelector('.message-erreur');
    expect(erreur).toBeTruthy();
  });
});
```

## Tests de services Angular (Small)

```typescript
// src/app/patient/patient.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { PatientService } from './patient.service';

describe('PatientService', () => {
  let service: PatientService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [PatientService]
    });

    service = TestBed.inject(PatientService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify(); // Vérifier qu'aucune requête non traitée ne reste
  });

  it('devrait récupérer un patient par son identifiant', () => {
    // Arrange
    const patientAttendu = { id: 42, nom: 'Lavoie', prenom: 'Marie' };

    // Act
    service.obtenirPatient(42).subscribe(patient => {
      // Assert
      expect(patient).toEqual(patientAttendu);
    });

    // Simuler la réponse HTTP (Medium → Small grâce au mock HTTP)
    const req = httpMock.expectOne('/api/v1/patients/42');
    expect(req.request.method).toBe('GET');
    req.flush(patientAttendu);
  });

  it('devrait gérer une erreur 404', () => {
    // Act
    service.obtenirPatient(999).subscribe({
      error: (erreur) => {
        // Assert
        expect(erreur.status).toBe(404);
      }
    });

    const req = httpMock.expectOne('/api/v1/patients/999');
    req.flush('Patient introuvable', { status: 404, statusText: 'Not Found' });
  });
});
```

## Tests de formulaires réactifs (Small)

```typescript
describe('FormulairePatientComponent', () => {
  it('devrait être invalide quand le nom est vide', () => {
    // Arrange
    composante.formulaire.controls['nom'].setValue('');
    
    // Assert
    expect(composante.formulaire.controls['nom'].valid).toBeFalse();
    expect(composante.formulaire.controls['nom'].errors?.['required']).toBeTrue();
  });

  it('devrait activer le bouton de soumission quand le formulaire est valide', () => {
    // Arrange
    composante.formulaire.setValue({
      nom: 'Gagnon',
      prenom: 'Pierre',
      dateNaissance: '1980-05-15'
    });
    fixture.detectChanges();
    
    // Assert
    const bouton = fixture.nativeElement.querySelector('button[type="submit"]');
    expect(bouton.disabled).toBeFalse();
  });
});
```

## Spies Jasmine courants

```typescript
// Spy sur une méthode existante
spyOn(composante, 'sauvegarder').and.callThrough();

// Spy qui retourne une valeur fixe
spyOn(service, 'obtenirDonnees').and.returnValue(of(donneesMock));

// Spy qui simule une erreur
spyOn(service, 'supprimer').and.returnValue(throwError(() => new Error('Erreur serveur')));

// Vérifier si une méthode a été appelée
expect(composante.sauvegarder).toHaveBeenCalledTimes(1);
expect(service.obtenirDonnees).toHaveBeenCalledWith(42);
```

## Prérequis WSL2 — Chrome manquant par défaut

WSL2 n'a pas de binaire Chrome Linux installé par défaut. Karma échoue avec
`No binary for ChromeHeadless browser on your platform`.

**Solution — installer Chromium une fois :**
```bash
sudo apt-get install -y chromium-browser
```

**Lancer les tests avec le bon binaire :**
```bash
CHROME_BIN=$(which chromium-browser) npx ng test --watch=false --browsers=ChromeHeadless
CHROME_BIN=$(which chromium-browser) npx ng test --include="**/mon-spec.spec.ts" --watch=false --browsers=ChromeHeadless
```

---

## `NO_ERRORS_SCHEMA` — ne supprime pas les pipes

`NO_ERRORS_SCHEMA` ignore les **éléments HTML et composantes inconnus** (ex: `nz-switch`, `leomed-*`),
mais **ne supprime pas les erreurs sur les pipes**. Tout pipe custom utilisé dans le
template doit être déclaré ou mocké explicitement dans `declarations`.

**Pattern — mock d'un pipe custom :**
```typescript
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'translateObj', standalone: false })
class MockTranslateObjPipe implements PipeTransform {
  transform(value: any): any { return value; }
}

// Dans TestBed :
declarations: [MonComposant, MockTranslateObjPipe],
schemas: [NO_ERRORS_SCHEMA],
```

Pipes LeoMed à mocker fréquemment : `translateObj` (dans `pipes/translate-obj/`).

---

## Mock NgRx Store

Les composantes qui injectent `Store` dans leur constructeur échouent à la création
si le store n'est pas fourni. Mock minimal :

```typescript
import { NEVER } from 'rxjs';
import { Store } from '@ngrx/store';

const mockStore = { select: () => NEVER, dispatch: () => {} };

// Dans TestBed :
providers: [{ provide: Store, useValue: mockStore }],
```

---

## Commandes utiles

```bash
# Lancer tous les tests une fois
ng test --watch=false

# Lancer avec couverture de code
ng test --code-coverage --watch=false

# Lancer un fichier spécifique
ng test --include="**/patient.service.spec.ts" --watch=false

# Mode watch (développement)
ng test
```
