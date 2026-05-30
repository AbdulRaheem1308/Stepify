import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wellnex_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/ad_service.dart';

/// Main Shell with Bottom Navigation
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const MainShell({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  List<_NavItem> _getNavItems(AppLocalizations l10n) => [
    _NavItem(icon: Icons.home_rounded, label: l10n.home, route: '/home'),
    _NavItem(icon: Icons.analytics_rounded, label: l10n.analytics, route: '/analytics'),
    _NavItem(icon: Icons.people_rounded, label: l10n.friends, route: '/friends'),
    _NavItem(icon: Icons.card_giftcard_rounded, label: l10n.rewards, route: '/rewards'),
    _NavItem(icon: Icons.person_rounded, label: l10n.profile, route: '/profile'),
  ];

  int _getSelectedIndex(List<_NavItem> navItems, String location) {
    for (int i = 0; i < navItems.length; i++) {
      if (location.startsWith(navItems[i].route)) {
        return i;
      }
    }
    return 0; // Default to home
  }

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  DateTime? _currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }
  
  void _loadBannerAd() {
    final adService = ref.read(adServiceProvider);
    _bannerAd = adService.createBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) {
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _bannerAd = null;
          });
        }
      },
    );
    
    // Only load if ad was successfully created (supported platform)
    if (_bannerAd != null) {
      _bannerAd!.load().catchError((e) {
        debugPrint('Failed to load banner ad: $e');
      });
    }
  }
  
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final navItems = _getNavItems(l10n);
    final location = widget.location;
    final selectedIndex = _getSelectedIndex(navItems, location);
    final isHome = location == '/home';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        
        if (!isHome) {
          context.go('/home');
        } else {
          final now = DateTime.now();
          if (_currentBackPressTime == null || 
              now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
            _currentBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pressBackToExit),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            // Double pressed within 2 seconds
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isAdLoaded && _bannerAd != null)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    final isSelected = selectedIndex == index;
                    
                    return _buildNavItem(
                      icon: item.icon,
                      label: item.label,
                      isSelected: isSelected,
                      onTap: () {
                        context.go(item.route);
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryGreen.withValues(alpha: 0.08) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.neutral400,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.neutral400,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
