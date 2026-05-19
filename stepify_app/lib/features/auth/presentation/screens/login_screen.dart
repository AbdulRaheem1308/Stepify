import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'dart:io';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';
import '../../services/social_auth_service.dart';

/// Login Screen with Social Auth
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final SocialAuthService _socialAuth = SocialAuthService();
  bool _isLoading = false;

  Future<void> _handleSocialLogin(Future<String?> Function() signInMethod, String providerName) async {
    setState(() => _isLoading = true);
    try {
      // 1. Get Firebase ID Token
      final idToken = await signInMethod();
      
      if (idToken != null && mounted) {
        // 2. Login to Backend
        final isNewUser = await ref.read(authProvider.notifier).loginWithSocial(idToken);
        
        if (mounted) {
           // 3. Navigate
           if (isNewUser) {
             context.go(AppRoutes.onboarding);
           } else {
             context.go(AppRoutes.home);
           }
        }
      } else {
        // User canceled
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in with $providerName: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                
                // Logo
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_walk_rounded,
                      size: 60,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                const Text(
                  'Stepify',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  'Walk more. Earn more.\nJoin the movement safely.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                
                const Spacer(flex: 2),
                
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white))
                else ...[
                  // Google Button
                  _SocialButton(
                    icon: FontAwesomeIcons.google.data,
                    label: 'Continue with Google',
                    onTap: () => _handleSocialLogin(_socialAuth.signInWithGoogle, 'Google'),
                    color: Colors.white,
                    textColor: Colors.black87,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Apple Button (Only on iOS usually, but can be on Android too service-wise)
                  if (Platform.isIOS) 
                    _SocialButton(
                      icon: FontAwesomeIcons.apple.data,
                      label: 'Continue with Apple',
                      onTap: () => _handleSocialLogin(_socialAuth.signInWithGoogle, 'Apple'), // Using Google placeholder for now as Apple setup is complex locally without certs
                      // TODO: Switch to _socialAuth.signInWithApple when provisioned
                      color: Colors.black,
                      textColor: Colors.white,
                    ),
                ],
                
                const Spacer(),
                
                Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon; // Using IconData instead of Widget for simplicity with FontAwesome
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
