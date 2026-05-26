import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/main.dart';
import 'package:stepify_app/core/router/app_router.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';

class MockApiService extends ApiService {
  MockApiService() : super();

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {
        'themeMode': 'system',
        'language': 'en',
        'pushNotifications': true,
        'dailyReminders': true,
        'dataSyncOverCellular': true,
        'soundEnabled': true,
        'isPublic': true,
        'showOnLeaderboard': true,
        'showMilestones': true,
        'distanceUnit': 'km',
      },
      statusCode: 200,
    );
  }

  @override
  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {},
      statusCode: 200,
    );
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('be.tramckrijte.workmanager/workmanager'),
            (MethodCall methodCall) async {
      return null;
    });

    final temp = await Directory.systemTemp.createTemp();
    Hive.init(temp.path);
    if (!Hive.isBoxOpen('stepify_storage')) {
      await StorageService.init();
    }
  });

  testWidgets('StepifyApp creates successfully', (WidgetTester tester) async {
    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SizedBox()),
      ],
    );

    // Basic test to ensure the root widget can be constructed
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(mockRouter),
          apiServiceProvider.overrideWithValue(MockApiService()),
        ],
        child: const StepifyApp(),
      ),
    );
    
    // We just verify it pumps without throwing a critical widget error
    expect(find.byType(StepifyApp), findsOneWidget);
  });
}
