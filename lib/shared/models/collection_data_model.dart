// ─────────────────────────────────────────────────────────
// Sub-models for CollectionDataModel
// ─────────────────────────────────────────────────────────

/// GPS / location data captured during collection
class LocationData {
  final double? lat;
  final double? lng;
  final double? accuracy;
  final DateTime? timestamp;

  const LocationData({this.lat, this.lng, this.accuracy, this.timestamp});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'accuracy': accuracy,
    'timestamp': timestamp?.toIso8601String(),
  };

  LocationData copyWith({
    double? lat,
    double? lng,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationData(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Client / customer information
class ClientInfo {
  final String? nom;
  final String? contact;
  final String? adresse;
  final String? reference;

  const ClientInfo({this.nom, this.contact, this.adresse, this.reference});

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      nom: json['nom'] as String?,
      contact: json['contact'] as String?,
      adresse: json['adresse'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'contact': contact,
    'adresse': adresse,
    'reference': reference,
  };

  ClientInfo copyWith({
    String? nom,
    String? contact,
    String? adresse,
    String? reference,
  }) {
    return ClientInfo(
      nom: nom ?? this.nom,
      contact: contact ?? this.contact,
      adresse: adresse ?? this.adresse,
      reference: reference ?? this.reference,
    );
  }
}

/// Product being sampled
class ProductInfo {
  final String? nom;
  final String? code;
  final String? lot;
  final DateTime? dateExpiration;
  final String? fabricant;

  const ProductInfo({
    this.nom,
    this.code,
    this.lot,
    this.dateExpiration,
    this.fabricant,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      nom: json['nom'] as String?,
      code: json['code'] as String?,
      lot: json['lot'] as String?,
      dateExpiration: json['dateExpiration'] != null
          ? DateTime.parse(json['dateExpiration'] as String)
          : null,
      fabricant: json['fabricant'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'code': code,
    'lot': lot,
    'dateExpiration': dateExpiration?.toIso8601String(),
    'fabricant': fabricant,
  };

  ProductInfo copyWith({
    String? nom,
    String? code,
    String? lot,
    DateTime? dateExpiration,
    String? fabricant,
  }) {
    return ProductInfo(
      nom: nom ?? this.nom,
      code: code ?? this.code,
      lot: lot ?? this.lot,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      fabricant: fabricant ?? this.fabricant,
    );
  }
}

/// Sample collection details
class SampleDetails {
  final double? quantite;
  final String? unite;
  final String? conditionnement;
  final double? temperature;
  final String? observations;

  const SampleDetails({
    this.quantite,
    this.unite,
    this.conditionnement,
    this.temperature,
    this.observations,
  });

  factory SampleDetails.fromJson(Map<String, dynamic> json) {
    return SampleDetails(
      quantite: (json['quantite'] as num?)?.toDouble(),
      unite: json['unite'] as String?,
      conditionnement: json['conditionnement'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      observations: json['observations'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'quantite': quantite,
    'unite': unite,
    'conditionnement': conditionnement,
    'temperature': temperature,
    'observations': observations,
  };

  SampleDetails copyWith({
    double? quantite,
    String? unite,
    String? conditionnement,
    double? temperature,
    String? observations,
  }) {
    return SampleDetails(
      quantite: quantite ?? this.quantite,
      unite: unite ?? this.unite,
      conditionnement: conditionnement ?? this.conditionnement,
      temperature: temperature ?? this.temperature,
      observations: observations ?? this.observations,
    );
  }
}

/// Laboratory analysis requirements
class AnalysisRequirements {
  final List<String> tests;
  final String? priorite;
  final String? delai;
  final String? labDestination;

  const AnalysisRequirements({
    this.tests = const [],
    this.priorite,
    this.delai,
    this.labDestination,
  });

  factory AnalysisRequirements.fromJson(Map<String, dynamic> json) {
    return AnalysisRequirements(
      tests:
          (json['tests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      priorite: json['priorite'] as String?,
      delai: json['delai'] as String?,
      labDestination: json['labDestination'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'tests': tests,
    'priorite': priorite,
    'delai': delai,
    'labDestination': labDestination,
  };

  AnalysisRequirements copyWith({
    List<String>? tests,
    String? priorite,
    String? delai,
    String? labDestination,
  }) {
    return AnalysisRequirements(
      tests: tests ?? this.tests,
      priorite: priorite ?? this.priorite,
      delai: delai ?? this.delai,
      labDestination: labDestination ?? this.labDestination,
    );
  }
}

/// Photos, documents, and notes attached to a collection
class Documentation {
  final List<String> photos;
  final List<String> documents;
  final String? notes;

  const Documentation({
    this.photos = const [],
    this.documents = const [],
    this.notes,
  });

  factory Documentation.fromJson(Map<String, dynamic> json) {
    return Documentation(
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'photos': photos,
    'documents': documents,
    'notes': notes,
  };

  Documentation copyWith({
    List<String>? photos,
    List<String>? documents,
    String? notes,
  }) {
    return Documentation(
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      notes: notes ?? this.notes,
    );
  }
}

/// Export configuration
class ExportInfo {
  final String? format;
  final String? destination;
  final DateTime? timestamp;

  const ExportInfo({this.format, this.destination, this.timestamp});

  factory ExportInfo.fromJson(Map<String, dynamic> json) {
    return ExportInfo(
      format: json['format'] as String?,
      destination: json['destination'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'format': format,
    'destination': destination,
    'timestamp': timestamp?.toIso8601String(),
  };

  ExportInfo copyWith({
    String? format,
    String? destination,
    DateTime? timestamp,
  }) {
    return ExportInfo(
      format: format ?? this.format,
      destination: destination ?? this.destination,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// ─────────────────────────────────────────────────────────
// Main collection data model
// ─────────────────────────────────────────────────────────

/// Aggregated model holding all collection data across the data-entry steps
class CollectionDataModel {
  final String? category;
  final LocationData? location;
  final ClientInfo? clientInfo;
  final ProductInfo? productInfo;
  final SampleDetails? sampleDetails;
  final AnalysisRequirements? analysisRequirements;
  final Documentation? documentation;
  final ExportInfo? exportInfo;

  const CollectionDataModel({
    this.category,
    this.location,
    this.clientInfo,
    this.productInfo,
    this.sampleDetails,
    this.analysisRequirements,
    this.documentation,
    this.exportInfo,
  });

  factory CollectionDataModel.fromJson(Map<String, dynamic> json) {
    return CollectionDataModel(
      category: json['category'] as String?,
      location: json['location'] != null
          ? LocationData.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      clientInfo: json['clientInfo'] != null
          ? ClientInfo.fromJson(json['clientInfo'] as Map<String, dynamic>)
          : null,
      productInfo: json['productInfo'] != null
          ? ProductInfo.fromJson(json['productInfo'] as Map<String, dynamic>)
          : null,
      sampleDetails: json['sampleDetails'] != null
          ? SampleDetails.fromJson(
              json['sampleDetails'] as Map<String, dynamic>,
            )
          : null,
      analysisRequirements: json['analysisRequirements'] != null
          ? AnalysisRequirements.fromJson(
              json['analysisRequirements'] as Map<String, dynamic>,
            )
          : null,
      documentation: json['documentation'] != null
          ? Documentation.fromJson(
              json['documentation'] as Map<String, dynamic>,
            )
          : null,
      exportInfo: json['exportInfo'] != null
          ? ExportInfo.fromJson(json['exportInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'location': location?.toJson(),
      'clientInfo': clientInfo?.toJson(),
      'productInfo': productInfo?.toJson(),
      'sampleDetails': sampleDetails?.toJson(),
      'analysisRequirements': analysisRequirements?.toJson(),
      'documentation': documentation?.toJson(),
      'exportInfo': exportInfo?.toJson(),
    };
  }

  CollectionDataModel copyWith({
    String? category,
    LocationData? location,
    ClientInfo? clientInfo,
    ProductInfo? productInfo,
    SampleDetails? sampleDetails,
    AnalysisRequirements? analysisRequirements,
    Documentation? documentation,
    ExportInfo? exportInfo,
  }) {
    return CollectionDataModel(
      category: category ?? this.category,
      location: location ?? this.location,
      clientInfo: clientInfo ?? this.clientInfo,
      productInfo: productInfo ?? this.productInfo,
      sampleDetails: sampleDetails ?? this.sampleDetails,
      analysisRequirements: analysisRequirements ?? this.analysisRequirements,
      documentation: documentation ?? this.documentation,
      exportInfo: exportInfo ?? this.exportInfo,
    );
  }
}
