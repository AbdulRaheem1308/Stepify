import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/devices/presentation/screens/device_sync_screen.dart';
import 'package:stepify_app/features/devices/presentation/providers/device_provider.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  Widget createTestWidget(DeviceState initialState) {
    return ProviderScope(
      overrides: [
        deviceProvider.overrideWith((ref) => MockDeviceNotifier(initialState)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const DeviceSyncScreen(),
      ),
    );
  }

  testWidgets('DeviceSyncScreen shows empty state correctly', (tester) async {
    await tester.pumpWidget(createTestWidget(DeviceState(devices: [])));
    await tester.pumpAndSettle();

    expect(find.text('No devices connected'), findsOneWidget);
    expect(find.text('Connect Health App'), findsOneWidget);
  });

  testWidgets('DeviceSyncScreen shows connected devices', (tester) async {
    final devices = [
      ConnectedDevice(
        id: 'd1',
        name: 'Apple Watch',
        type: 'WATCH_APPLE',
        status: SyncStatus.connected,
        lastSyncTime: DateTime.now(),
        syncedSteps: 5000,
      ),
    ];

    await tester.pumpWidget(createTestWidget(DeviceState(devices: devices)));
    await tester.pumpAndSettle();

    expect(find.text('Apple Watch'), findsOneWidget);
    expect(find.text('5000'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
  });

  testWidgets('DeviceSyncScreen shows error snackbar on error state', (tester) async {
    final notifier = MockDeviceNotifier(DeviceState(devices: []));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DeviceSyncScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Trigger state change
    notifier.state = notifier.state.copyWith(error: 'Test Error Message');
    await tester.pumpAndSettle();

    expect(find.text('Test Error Message'), findsOneWidget);
  });

  testWidgets('DeviceSyncScreen sync button and disconnect button call methods', (tester) async {
    final devices = [
      ConnectedDevice(
        id: 'd1',
        name: 'Apple Watch',
        type: 'WATCH_APPLE',
        status: SyncStatus.connected,
        lastSyncTime: DateTime.now(),
        syncedSteps: 5000,
      ),
    ];
    final notifier = MockDeviceNotifier(DeviceState(devices: devices));
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          deviceProvider.overrideWith((ref) => notifier),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeviceSyncScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap sync button
    await tester.tap(find.byIcon(Icons.sync));
    await tester.pumpAndSettle();

    // Tap disconnect button
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    
    // Tap confirm in dialog
    expect(find.text('Disconnect'), findsOneWidget);
    await tester.tap(find.text('Disconnect'));
    await tester.pumpAndSettle();
  });
}

class MockDeviceNotifier extends StateNotifier<DeviceState> implements DeviceNotifier {
  MockDeviceNotifier(super.state);

  @override
  Future<void> addDevice(String name, String type) async {}

  @override
  Future<void> connectHealthDevice() async {}

  @override
  Future<void> loadDevices() async {}

  @override
  Future<void> removeDevice(String id) async {}

  @override
  Future<void> syncDevice(String id) async {}
}
