import '../../core/constants/app_constants.dart';

/// Model representing an item in the offline sync queue
class SyncQueueModel {
  final String id;
  final String missionId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int attempts;
  final SyncStatus status;

  const SyncQueueModel({
    required this.id,
    required this.missionId,
    required this.data,
    required this.createdAt,
    this.attempts = 0,
    this.status = SyncStatus.pending,
  });

  factory SyncQueueModel.fromJson(Map<String, dynamic> json) {
    return SyncQueueModel(
      id: json['id'] as String,
      missionId: json['missionId'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      attempts: json['attempts'] as int? ?? 0,
      status: SyncStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SyncStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'missionId': missionId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'attempts': attempts,
      'status': status.name,
    };
  }

  SyncQueueModel copyWith({
    String? id,
    String? missionId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? attempts,
    SyncStatus? status,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      missionId: missionId ?? this.missionId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
    );
  }
}
