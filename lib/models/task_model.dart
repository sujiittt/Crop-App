// lib/models/task_model.dart
import 'dart:convert';

enum TaskStatus {
  pending,
  completed,
  cancelled,
}

class TaskModel {
  final String id;
  final String title; // short human-friendly title
  final String type; // e.g. "Irrigation", "Fertilizer", "Pesticide"
  final String? fieldId; // optional id of the field/plot
  final String? cropLabel; // optional crop description or emoji
  final DateTime dateTime; // scheduled date/time
  final String? notes;
  final TaskStatus status;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    this.fieldId,
    this.cropLabel,
    this.notes,
    this.status = TaskStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? type,
    String? fieldId,
    String? cropLabel,
    DateTime? dateTime,
    String? notes,
    TaskStatus? status,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      fieldId: fieldId ?? this.fieldId,
      cropLabel: cropLabel ?? this.cropLabel,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'fieldId': fieldId,
      'cropLabel': cropLabel,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      fieldId: json['fieldId'] as String?,
      cropLabel: json['cropLabel'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      notes: json['notes'] as String?,
      status: _statusFromString(json['status'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  static TaskStatus _statusFromString(String? s) {
    if (s == null) return TaskStatus.pending;
    switch (s) {
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      case 'pending':
      default:
        return TaskStatus.pending;
    }
  }

  static List<TaskModel> listFromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return <TaskModel>[];
    final List<dynamic> arr = json.decode(jsonString) as List<dynamic>;
    return arr.map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  static String listToJsonString(List<TaskModel> tasks) {
    final arr = tasks.map((t) => t.toJson()).toList();
    return json.encode(arr);
  }
}
