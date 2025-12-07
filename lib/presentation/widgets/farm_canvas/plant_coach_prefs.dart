import 'package:shared_preferences/shared_preferences.dart';

class PlantCoachPrefs {
  static const _key = 'plant_coachmark_shown';

  static Future<bool> isShown() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_key) ?? false;
  }

  static Future<void> markShown() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, true);
  }
}
