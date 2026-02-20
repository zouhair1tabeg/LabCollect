import 'package:flutter_test/flutter_test.dart';
import 'package:labocollect/shared/models/collection_data_model.dart';

void main() {
  group('CollectionDataModel', () {
    test('default constructor creates empty model', () {
      const model = CollectionDataModel();

      expect(model.category, isNull);
      expect(model.location, isNull);
      expect(model.clientInfo, isNull);
      expect(model.productInfo, isNull);
      expect(model.sampleDetails, isNull);
      expect(model.analysisRequirements, isNull);
      expect(model.documentation, isNull);
      expect(model.exportInfo, isNull);
    });

    test('toJson/fromJson round-trip preserves all sub-models', () {
      final original = CollectionDataModel(
        category: 'Eau',
        location: LocationData(
          lat: 48.8566,
          lng: 2.3522,
          accuracy: 5.0,
          timestamp: DateTime(2024, 1, 1),
        ),
        clientInfo: const ClientInfo(
          nom: 'Client A',
          contact: '0123456789',
          adresse: '10 Rue de Paris',
          reference: 'REF-001',
        ),
        productInfo: const ProductInfo(
          nom: 'Produit X',
          code: 'PX-001',
          lot: 'LOT-A',
          fabricant: 'FabriCo',
        ),
        sampleDetails: const SampleDetails(
          quantite: 500.0,
          unite: 'mL',
          conditionnement: 'Bouteille stérile',
          temperature: 4.0,
          observations: 'RAS',
        ),
        analysisRequirements: const AnalysisRequirements(
          tests: ['pH', 'Turbidité', 'Conductivité'],
          priorite: 'Haute',
          delai: '48h',
          labDestination: 'Labo Central',
        ),
        documentation: const Documentation(
          photos: ['/path/photo1.jpg'],
          documents: ['/path/doc.pdf'],
          notes: 'Notes de terrain',
        ),
        exportInfo: ExportInfo(
          format: 'PDF',
          destination: 'Serveur',
          timestamp: DateTime(2024, 1, 1, 12, 0),
        ),
      );

      final json = original.toJson();
      final roundTripped = CollectionDataModel.fromJson(json);

      expect(roundTripped.category, 'Eau');
      expect(roundTripped.location?.lat, 48.8566);
      expect(roundTripped.location?.lng, 2.3522);
      expect(roundTripped.location?.accuracy, 5.0);
      expect(roundTripped.clientInfo?.nom, 'Client A');
      expect(roundTripped.clientInfo?.contact, '0123456789');
      expect(roundTripped.productInfo?.nom, 'Produit X');
      expect(roundTripped.productInfo?.code, 'PX-001');
      expect(roundTripped.sampleDetails?.quantite, 500.0);
      expect(roundTripped.sampleDetails?.unite, 'mL');
      expect(roundTripped.analysisRequirements?.tests, hasLength(3));
      expect(roundTripped.analysisRequirements?.priorite, 'Haute');
      expect(roundTripped.documentation?.photos, hasLength(1));
      expect(roundTripped.documentation?.notes, 'Notes de terrain');
      expect(roundTripped.exportInfo?.format, 'PDF');
    });

    test('copyWith preserves other fields', () {
      const model = CollectionDataModel(category: 'Sol');
      final updated = model.copyWith(
        clientInfo: const ClientInfo(nom: 'Nouveau Client'),
      );

      expect(updated.category, 'Sol'); // preserved
      expect(updated.clientInfo?.nom, 'Nouveau Client');
    });
  });

  group('LocationData', () {
    test('fromJson handles null accuracy', () {
      final json = {'lat': 48.85, 'lng': 2.35};
      final loc = LocationData.fromJson(json);

      expect(loc.lat, 48.85);
      expect(loc.lng, 2.35);
      expect(loc.accuracy, isNull);
    });
  });

  group('AnalysisRequirements', () {
    test('default tests list is empty', () {
      const ar = AnalysisRequirements();
      expect(ar.tests, isEmpty);
    });
  });

  group('Documentation', () {
    test('default lists are empty', () {
      const doc = Documentation();
      expect(doc.photos, isEmpty);
      expect(doc.documents, isEmpty);
      expect(doc.notes, isNull);
    });
  });
}
