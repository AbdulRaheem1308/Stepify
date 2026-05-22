import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'dart:async';

class ConsentService {
  static const String _consentKey = 'consent_status';

  /// Request consent info update and show form if required.
  Future<void> requestConsentInfoUpdate() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();
    
    // For testing:
    // ConsentDebugSettings debugSettings = ConsentDebugSettings(
    //   debugGeography: DebugGeography.debugGeographyEea,
    //   testIdentifiers: ['TEST-DEVICE-HASHED-ID'],
    // );
    // params = ConsentRequestParameters(consentDebugSettings: debugSettings);

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          final isConsentFormAvailable = await ConsentInformation.instance.isConsentFormAvailable();
          if (isConsentFormAvailable) {
            await _loadAndShowConsentFormIfRequired();
          }
           if (!completer.isCompleted) completer.complete();
        },
        (FormError error) {
          debugPrint('Consent Info Error: ${error.message}');
           if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (e) {
      debugPrint('Consent Service Error: $e');
      if (!completer.isCompleted) completer.complete();
    }
    
    return completer.future;
  }

  Future<void> _loadAndShowConsentFormIfRequired() async {
    try {
      ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) {
          debugPrint('Consent Form Error: ${error.message}');
        } else {
          // Consent gathered or not required
        }
      });
    } catch (e) {
      debugPrint('Consent Load Error: $e');
    }
  }
  
  /// Check if we can initialize ads (Personalized or Non-Personalized)
  Future<bool> canInitializeAds() async {
    final status = await ConsentInformation.instance.getConsentStatus();
    return status == ConsentStatus.obtained || status == ConsentStatus.notRequired;
  }
}

final consentServiceProvider = ConsentService();
