import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/ad_service.dart';

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
    
    // Fallback simulation for Web or missing AdMob config
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
    if (_hasError) {
      // Premium placeholder/fallback when ads fail to load
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neutral200.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.star, color: AppTheme.accentOrange),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stepify Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Ad Free Experience', style: TextStyle(color: AppTheme.neutral500, fontSize: 14)),
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
              child: const Text('Upgrade'),
            ),
          ],
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
      height: 300, // Typical height for native ads
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
