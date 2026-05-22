import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'dart:io';
import 'package:stepify_app/l10n/app_localizations.dart';

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
        final l10n = AppLocalizations.of(context);
        final errorMessage = l10n?.signInFailed(providerName, e.toString()) ?? 'Failed to sign in with $providerName: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: AppTheme.error),
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
    final socialAuth = ref.watch(socialAuthServiceProvider);
    
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
                  child: ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26),
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
                ),
                
                const SizedBox(height: 32),
                
                Semantics(
                  header: true,
                  child: const Text(
                    'Stepify',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  AppLocalizations.of(context)?.loginSubtitle ?? 'Walk more. Earn more.\nJoin the movement safely.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                    label: AppLocalizations.of(context)?.continueWithGoogle ?? 'Continue with Google',
                    onTap: () => _handleSocialLogin(socialAuth.signInWithGoogle, 'Google'),
                    color: Theme.of(context).colorScheme.surface,
                    textColor: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Apple Button (Only on iOS usually, but can be on Android too service-wise)
                  if (Platform.isIOS) 
                    _SocialButton(
                      icon: FontAwesomeIcons.apple.data,
                      label: AppLocalizations.of(context)?.continueWithApple ?? 'Continue with Apple',
                      onTap: () => _handleSocialLogin(socialAuth.signInWithApple, 'Apple'),
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      textColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    ),
                ],
                
                const Spacer(),
                
                Text(
                  AppLocalizations.of(context)?.termsAndPrivacy ?? 'By continuing, you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withAlpha(153), fontSize: 12),
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
    return Semantics(
      button: true,
      label: label,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 56), // Touch target size
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(child: Icon(icon, size: 20)),
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
      ),
    );
  }
}
