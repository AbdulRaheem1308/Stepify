import 'package:flutter_test/flutter_test.dart';
import 'package:wellnex_app/core/utils/platform_utils.dart';

void main() {
  group('Platform Utils', () {
    test('isAndroid returns a boolean', () {
      // We can't guarantee what platform the test runner is on,
      // but we can ensure the getter doesn't throw and returns a bool.
      expect(isAndroid.runtimeType, bool);
    });

    test('isIOS returns a boolean', () {
      expect(isIOS.runtimeType, bool);
    });
  });
}
