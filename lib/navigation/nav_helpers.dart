import 'package:flutter/foundation.dart';

/// Current main-tab index for the global BottomNavigationBar.
/// 0: Home (Dashboard), 1: Weather, 2: Soil, 3: Schemes, 4: Mandi
final ValueNotifier<int> mainTabIndex = ValueNotifier<int>(0);

/// Call this from any screen to switch tabs (no route push).
void goToMainTab(int index) {
  mainTabIndex.value = index;
}
