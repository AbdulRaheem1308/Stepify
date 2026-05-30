import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/ad_service.dart';
import '../../../../l10n/app_localizations.dart';

/// A widget that renders a native ad, with a polished fallback/placeholder
/// shown when the ad fails to load (e.g., on Web or without AdMob config).
class NativeAdContainer extends ConsumerStatefulWidget {
  final String factoryId;

  const NativeAdContainer({super.key, this.factoryId = 'adFactoryExample'});

  @override
  ConsumerState<NativeAdContainer> createState() => _NativeAdContainerState();
}

class _NativeAdContainerState extends ConsumerState<NativeAdContainer> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final adService = ref.read(adServiceProvider);

    try {
      final ad = await adService.loadNativeAd(factoryId: widget.factoryId);
      if (ad != null && mounted) {
        setState(() {
          _nativeAd = ad;
          _isLoaded = true;
        });
      } else {
        if (mounted) setState(() => _hasError = true);
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_hasError) {
      // Premium placeholder/fallback when ads fail to load
      return Semantics(
        label: '${l10n.wellnexPremium} - ${l10n.adFreeExperience}',
        button: true,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.neutral200.withAlpha(128)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: AppTheme.accentOrange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.wellnexPremium,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      l10n.adFreeExperience,
                      style: const TextStyle(color: AppTheme.neutral500, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(l10n.upgradeBtn),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isLoaded) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.neutral100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
