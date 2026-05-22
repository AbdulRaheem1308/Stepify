// Unit tests for StorageService using in-memory Hive.
//
// StorageService uses a static Hive box, so we must initialise Hive with an
// in-memory adapter for each test group and reset state between tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stepify_app/services/storage_service.dart';

void main() {
  // Hive in-memory setup
  setUpAll(() async {
    // Register in-memory Hive for tests (no file I/O)
    Hive.init('');
  });

  setUp(() async {
    // Open a fresh in-memory box before each test.
    // We call init() which opens 'stepify_storage'.
    if (Hive.isBoxOpen('stepify_storage')) {
      await Hive.box('stepify_storage').clear();
    } else {
      await StorageService.init();
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });

  group('StorageService — guard', () {
    test('throws StateError before init is called', () async {
      // Close the box to simulate pre-init state.
      if (Hive.isBoxOpen('stepify_storage')) {
        await Hive.box('stepify_storage').close();
      }
      expect(
        () => StorageService.get<String>('any_key'),
        throwsA(isA<StateError>()),
      );
      // Re-open for subsequent tests.
      await StorageService.init();
    });
  });

  group('StorageService — generic get/put/delete', () {
    test('put and get string value', () async {
      await StorageService.put('str_key', 'hello');
      expect(StorageService.get<String>('str_key'), 'hello');
    });

    test('put and get int value', () async {
      await StorageService.put('int_key', 42);
      expect(StorageService.get<int>('int_key'), 42);
    });

    test('get returns defaultValue when key is absent', () async {
      expect(StorageService.get<String>('missing', defaultValue: 'def'), 'def');
    });

    test('get returns null when key is absent and no default', () async {
      expect(StorageService.get<String>('missing'), isNull);
    });

    test('get returns defaultValue on type mismatch without throwing', () async {
      await StorageService.put('bad_type', 'not_an_int');
      // Should return defaultValue instead of throwing.
      expect(StorageService.get<int>('bad_type', defaultValue: 0), 0);
    });

    test('delete removes the key', () async {
      await StorageService.put('del_key', 'val');
      await StorageService.delete('del_key');
      expect(StorageService.get<String>('del_key'), isNull);
    });
  });

  group('StorageService — user data', () {
    const user = <String, dynamic>{'id': '1', 'name': 'Alice'};

    test('saveUser and getUser round-trip', () async {
      await StorageService.saveUser(user);
      final retrieved = StorageService.getUser();
      expect(retrieved, isNotNull);
      expect(retrieved!['name'], 'Alice');
    });

    test('getUser returns null when not set', () async {
      expect(StorageService.getUser(), isNull);
    });

    test('clearUser removes the user', () async {
      await StorageService.saveUser(user);
      await StorageService.clearUser();
      expect(StorageService.getUser(), isNull);
    });
  });

  group('StorageService — onboarding', () {
    test('isOnboardingComplete returns false by default', () {
      expect(StorageService.isOnboardingComplete(), isFalse);
    });

    test('setOnboardingComplete persists the flag', () async {
      await StorageService.setOnboardingComplete();
      expect(StorageService.isOnboardingComplete(), isTrue);
    });
  });

  group('StorageService — theme', () {
    test('getThemeMode returns system by default', () {
      expect(StorageService.getThemeMode(), 'system');
    });

    test('setThemeMode and getThemeMode round-trip', () async {
      await StorageService.setThemeMode('dark');
      expect(StorageService.getThemeMode(), 'dark');
    });
  });
}
