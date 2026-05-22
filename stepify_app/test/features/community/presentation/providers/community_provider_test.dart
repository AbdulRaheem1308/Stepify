import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:stepify_app/services/api_service.dart';
import 'package:stepify_app/features/community/presentation/providers/community_provider.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late CommunityNotifier notifier;

  setUp(() {
    mockApiService = MockApiService();
    
    // We need to mock the initial loadFeed call inside constructor
    when(() => mockApiService.get('/community/feed')).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/community/feed'),
      data: [],
    ));

    notifier = CommunityNotifier(mockApiService);
  });

  group('CommunityNotifier', () {
    test('initial loadFeed fetches data', () async {
      // Allow async init to finish
      await Future.delayed(Duration.zero);
      
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.posts, isEmpty);
      verify(() => mockApiService.get('/community/feed')).called(1);
    });

    test('loadFeed updates state with posts', () async {
      // Arrange
      final postData = [
        {
          'id': 'p1',
          'user': {'name': 'Alice'},
          'type': 'MILESTONE',
          'content': 'Reached 10k steps!',
          'createdAt': DateTime.now().toIso8601String(),
          'likesCount': 5,
          'commentsCount': 2,
        }
      ];

      when(() => mockApiService.get('/community/feed')).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/community/feed'),
        data: postData,
      ));

      // Act
      await notifier.loadFeed();

      // Assert
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.posts.length, 1);
      expect(notifier.state.posts.first.userName, 'Alice');
      expect(notifier.state.posts.first.type, FeedItemType.milestone);
    });

    test('reactToPost applies optimistic update when failing', () async {
      // Arrange
      notifier.state = notifier.state.copyWith(
        posts: [
          FeedPost(
            id: 'p1',
            userName: 'Alice',
            type: FeedItemType.manual,
            content: 'Hello',
            timestamp: DateTime.now(),
            likes: 0,
            comments: 0,
          )
        ],
      );

      when(() => mockApiService.post('/community/posts/p1/react', data: any(named: 'data')))
          .thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // Act
      await notifier.reactToPost('p1');

      // Assert
      expect(notifier.state.posts.first.likes, 1);
    });

    test('createPost calls api and reloads feed', () async {
      // Arrange
      when(() => mockApiService.post('/community/posts', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: '/community/posts'),
            data: {'success': true},
          ));
          
      when(() => mockApiService.get('/community/feed')).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/community/feed'),
        data: [],
      ));

      // Act
      await notifier.createPost('New post');

      // Assert
      verify(() => mockApiService.post('/community/posts', data: {'content': 'New post', 'type': 'MANUAL'})).called(1);
    });
  });
}
