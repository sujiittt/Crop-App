import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class FarmStorage {
  static const _key = 'farm_fields_v1';

  static Future<List<FarmField>?> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => FarmField.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> save(List<FarmField> fields) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(fields.map((f) => f.toJson()).toList());
    await sp.setString(_key, raw);
  }
}
