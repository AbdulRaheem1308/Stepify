import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepify_app/features/auth/services/social_auth_service.dart';

void main() {
  test('socialAuthServiceProvider provides a SocialAuthService instance', () {
    final container = ProviderContainer();
    final service = container.read(socialAuthServiceProvider);
    
    expect(service, isA<SocialAuthService>());
  });
}
