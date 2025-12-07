import 'package:flutter_test/flutter_test.dart';
import 'package:cropwise/main.dart';

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const CropWiseApp());
    expect(find.text('CropWise'), findsOneWidget); // appbar title exists
  });
}
