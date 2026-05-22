import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/community/presentation/screens/community_screen.dart';
import 'package:stepify_app/features/community/presentation/providers/community_provider.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('CommunityScreen renders correctly with empty state', (tester) async {
    final mockState = CommunityState(
      isLoading: false,
      posts: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(
      const CommunityScreen(),
      overrides: [
        communityProvider.overrideWith((ref) => MockCommunityNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Community'), findsWidgets);
    expect(find.text('No posts yet'), findsOneWidget);
    expect(find.text('Be the first to share!'), findsOneWidget);
  });

  testWidgets('CommunityScreen renders posts', (tester) async {
    final mockState = CommunityState(
      isLoading: false,
      posts: [
        FeedPost(
          id: 'p1',
          userName: 'Alice',
          type: FeedItemType.milestone,
          content: 'Just ran 5 miles!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          likes: 10,
          comments: 2,
        ),
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest(
      const CommunityScreen(),
      overrides: [
        communityProvider.overrideWith((ref) => MockCommunityNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Just ran 5 miles!'), findsOneWidget);
    expect(find.text('10'), findsOneWidget); // likes
    expect(find.text('2'), findsOneWidget); // comments
  });

  testWidgets('CommunityScreen shows create post dialog', (tester) async {
    final mockState = CommunityState(
      isLoading: false,
      posts: [],
    );

    await tester.pumpWidget(createWidgetUnderTest(
      const CommunityScreen(),
      overrides: [
        communityProvider.overrideWith((ref) => MockCommunityNotifier(mockState)),
      ],
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Share Milestone'));
    await tester.pumpAndSettle();

    expect(find.text('Share with Community'), findsOneWidget);
    expect(find.text('What would you like to share?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
  });
}

class MockCommunityNotifier extends StateNotifier<CommunityState> implements CommunityNotifier {
  MockCommunityNotifier(super.state);

  @override
  Future<void> loadFeed() async {}

  @override
  Future<void> reactToPost(String postId) async {}

  @override
  Future<void> createPost(String content) async {}
}
