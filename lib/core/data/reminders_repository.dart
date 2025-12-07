// lib/core/data/reminders_repository.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CropReminder {
  final String id; // uuid-ish string (we’ll use notificationId as string)
  final String cropName;
  final String? note;
  final DateTime whenLocal;
  final int notificationId; // ties to flutter_local_notifications

  CropReminder({
    required this.id,
    required this.cropName,
    required this.whenLocal,
    required this.notificationId,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'cropName': cropName,
    'note': note,
    'whenLocal': whenLocal.toIso8601String(),
    'notificationId': notificationId,
  };

  factory CropReminder.fromJson(Map<String, dynamic> json) => CropReminder(
    id: json['id'] as String,
    cropName: json['cropName'] as String,
    note: json['note'] as String?,
    whenLocal: DateTime.parse(json['whenLocal'] as String),
    notificationId: json['notificationId'] as int,
  );
}

class RemindersRepository {
  RemindersRepository._();
  static final RemindersRepository instance = RemindersRepository._();

  static const _prefsKey = 'cropwise.crop_reminders';

  Future<List<CropReminder>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List)
        .cast<Map<String, dynamic>>()
        .map(CropReminder.fromJson)
        .toList();
    // Optional: sort by upcoming
    list.sort((a, b) => a.whenLocal.compareTo(b.whenLocal));
    return list;
  }

  Future<void> upsert(CropReminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();
    final idx = current.indexWhere((r) => r.id == reminder.id);
    if (idx >= 0) {
      current[idx] = reminder;
    } else {
      current.add(reminder);
    }
    await prefs.setString(
      _prefsKey,
      jsonEncode(current.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> removeById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();
    current.removeWhere((r) => r.id == id);
    await prefs.setString(
      _prefsKey,
      jsonEncode(current.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
