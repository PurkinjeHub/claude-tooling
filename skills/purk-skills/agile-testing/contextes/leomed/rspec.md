# Référence RSpec — LeoMed API / Hub

## Conventions de base

```ruby
# Toujours utiliser la syntaxe `describe` / `context` / `it`
# Le nom du `it` décrit le comportement attendu (le QUOI)

RSpec.describe NomDeLaClasse, type: :model do
  describe '#nom_de_la_methode' do
    context 'quand [condition]' do
      it 'retourne [résultat attendu]' do
        # Arrange
        # Act
        # Assert
      end
    end
  end
end
```

## Tests de modèles (Small)

```ruby
# spec/models/patient_spec.rb
RSpec.describe Patient, type: :model do
  describe 'validations' do
    it 'est invalide sans numéro de dossier' do
      patient = build(:patient, numero_dossier: nil)
      expect(patient).not_to be_valid
      expect(patient.errors[:numero_dossier]).to include("doit être rempli(e)")
    end

    it 'est valide avec tous les champs obligatoires' do
      patient = build(:patient)
      expect(patient).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:medecin) }
    it { should have_many(:consultations) }
  end
end
```

## Tests de services (Small avec mocks)

```ruby
# spec/services/calcul_dosage_service_spec.rb
RSpec.describe CalculDosageService do
  describe '#calculer' do
    let(:patient) { instance_double(Patient, poids_kg: 70, age: 45) }

    context 'quand le poids est dans les limites normales' do
      it 'calcule la dose correcte selon le protocole standard' do
        service = described_class.new(patient: patient, medicament: 'amoxicilline')
        expect(service.calculer).to eq(500)
      end
    end

    context 'quand le poids dépasse le seuil critique' do
      let(:patient) { instance_double(Patient, poids_kg: 150, age: 45) }

      it 'plafonne la dose au maximum autorisé' do
        service = described_class.new(patient: patient, medicament: 'amoxicilline')
        expect(service.calculer).to eq(1000) # dose maximale
      end
    end
  end
end
```

## Tests de requêtes API (Medium)

```ruby
# spec/requests/api/patients_spec.rb
RSpec.describe 'API Patients', type: :request do
  describe 'GET /api/v1/patients/:id' do
    let(:patient) { create(:patient) }

    context 'quand la requête est authentifiée' do
      before { get "/api/v1/patients/#{patient.id}", headers: auth_headers }

      it 'retourne le statut 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'retourne les données du patient' do
        json = JSON.parse(response.body)
        expect(json['id']).to eq(patient.id)
        expect(json['nom']).to eq(patient.nom)
      end
    end

    context 'quand la requête n\'est pas authentifiée' do
      before { get "/api/v1/patients/#{patient.id}" }

      it 'retourne le statut 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
```

## Factories (FactoryBot)

```ruby
# spec/factories/patients.rb
FactoryBot.define do
  factory :patient do
    sequence(:numero_dossier) { |n| "DOS-#{n.to_s.rjust(6, '0')}" }
    nom { Faker::Name.last_name }
    prenom { Faker::Name.first_name }
    date_naissance { Faker::Date.birthday(min_age: 18, max_age: 90) }
    association :medecin
  end
end
```

## Mocks et stubs courants

```ruby
# Stub d'un service externe
allow(ServiceExterne).to receive(:appeler).and_return({ statut: 'ok' })

# Mock d'un objet
double_patient = instance_double(Patient, nom: 'Tremblay', poids_kg: 70)

# Vérifier qu'une méthode est appelée
expect(NotificationService).to receive(:envoyer).with(patient.id).once

# Stub de la BD pour rester en Small
allow(Patient).to receive(:find).with(42).and_return(double_patient)
```

## Helpers partagés

```ruby
# spec/support/auth_helpers.rb
module AuthHelpers
  def auth_headers(utilisateur = create(:utilisateur))
    token = JsonWebToken.encode(user_id: utilisateur.id)
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
```

## RSwag request specs — dépendance OAuth (leomed-hub)

Les specs dans `spec/requests/v1/` utilisent RSwag avec authentification OAuth.
**Leomed-hub doit être démarré** pour valider les tokens — sans lui, tous les specs
retournent `401 {"message":"invalid token"}`.

Ce n'est pas un échec de code : c'est une contrainte d'infrastructure.

```bash
# Vérifier que leomed-hub tourne sur le port 3001 avant de lancer
curl -s http://localhost:3001/health || echo "leomed-hub non démarré"

# Lancer uniquement les model specs (pas de dépendance OAuth)
bundle exec rspec spec/models/

# Lancer les request specs (nécessite leomed-hub)
bundle exec rspec spec/requests/
```

En CI, leomed-hub doit être dans le stack de services avant de lancer les request specs.

---

## Commandes utiles

```bash
# Lancer tous les tests
bundle exec rspec

# Lancer un fichier spécifique
bundle exec rspec spec/models/patient_spec.rb

# Lancer un test spécifique (ligne)
bundle exec rspec spec/models/patient_spec.rb:42

# Lancer avec format documentation
bundle exec rspec --format documentation

# Lancer uniquement les tests marqués
bundle exec rspec --tag focus
```

## Marqueurs utiles

```ruby
# Marquer un test en cours de développement
it 'fait quelque chose', :focus do ... end

# Marquer un test lent (Medium/Large)
it 'fait une intégration BD', :slow do ... end

# Test en attente
xit 'sera implémenté plus tard' do ... end
pending 'attend la fonctionnalité X'
```
