import '../../core/constants/app_constants.dart';
import 'collection_data_model.dart';

/// Mission model representing a laboratory field mission
class MissionModel {
  final String id;
  final String title;
  final String description;
  final MissionStatus status;
  final int lastCompletedStep;
  final String? categoryId;
  final String assignedTo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final CollectionDataModel? collectionData;
  final int currentStepIndex;

  const MissionModel({
    required this.id,
    required this.title,
    this.description = '',
    this.status = MissionStatus.pending,
    this.lastCompletedStep = -1,
    this.categoryId,
    required this.assignedTo,
    required this.createdAt,
    this.updatedAt,
    this.collectionData,
    this.currentStepIndex = 0,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: MissionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MissionStatus.pending,
      ),
      lastCompletedStep: json['lastCompletedStep'] as int? ?? -1,
      categoryId: json['categoryId'] as String?,
      assignedTo: json['assignedTo'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      collectionData: json['collectionData'] != null
          ? CollectionDataModel.fromJson(
              json['collectionData'] as Map<String, dynamic>,
            )
          : null,
      currentStepIndex: json['currentStepIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'lastCompletedStep': lastCompletedStep,
      'categoryId': categoryId,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'collectionData': collectionData?.toJson(),
      'currentStepIndex': currentStepIndex,
    };
  }

  MissionModel copyWith({
    String? id,
    String? title,
    String? description,
    MissionStatus? status,
    int? lastCompletedStep,
    String? categoryId,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    CollectionDataModel? collectionData,
    int? currentStepIndex,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      lastCompletedStep: lastCompletedStep ?? this.lastCompletedStep,
      categoryId: categoryId ?? this.categoryId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      collectionData: collectionData ?? this.collectionData,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}
