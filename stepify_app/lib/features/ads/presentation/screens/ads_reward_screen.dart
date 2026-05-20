import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../services/api_service.dart';
import '../../../../services/ad_service.dart';

/// Ads Reward Screen
class AdsRewardScreen extends ConsumerStatefulWidget {
  const AdsRewardScreen({super.key});

  @override
  ConsumerState<AdsRewardScreen> createState() => _AdsRewardScreenState();
}

class _AdsRewardScreenState extends ConsumerState<AdsRewardScreen> {
  bool _isLoading = true;
  bool _canWatch = true;
  int _cooldownRemaining = 0;
  int _todayViews = 0;
  final int _maxDailyAds = 10;
  final int _pointsPerAd = 10;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _checkAdAvailability();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAdAvailability() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/ads/can-watch');
      setState(() {
        _canWatch = response.data['canWatch'] ?? true;
        _cooldownRemaining = response.data['cooldownRemaining'] ?? 0;
        _todayViews = response.data['todayViews'] ?? 0;
        _isLoading = false;
      });
      if (_cooldownRemaining > 0) _startCooldownTimer();
    } catch (e) {
      setState(() {
        _canWatch = true;
        _todayViews = 3;
        _isLoading = false;
      });
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownRemaining > 0) {
        setState(() => _cooldownRemaining--);
      } else {
        timer.cancel();
        setState(() => _canWatch = true);
      }
    });
  }

  Future<void> _claimRewardOnBackend() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final adService = ref.read(adServiceProvider);
      
      final response = await api.post(
        '/ads/claim',
        data: {
          'adType': 'REWARDED',
          'adUnitId': adService.rewardedAdUnitId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showRewardDialog();
        await _checkAdAvailability();
      } else {
        throw Exception('Failed to claim reward');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to claim reward: $e')),
        );
      }
    }
  }

  Future<void> _watchAd() async {
    final adService = ref.read(adServiceProvider);
    
    adService.showRewardedAd(
      onUserEarnedReward: (reward) async {
        await _claimRewardOnBackend();
      },
      onAdFailedToShow: () async {
        // Fall back to simulation dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _AdSimulationDialog(onComplete: () async {
            if (ctx.mounted) {
              Navigator.pop(ctx);
            }
            await _claimRewardOnBackend();
          }),
        );
      },
    );
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.rewardGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, size: 64, color: Colors.white),
              const SizedBox(height: 16),
              const Text('Reward Earned!',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('+$_pointsPerAd points',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.accentOrange),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch & Earn'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      children: [
                        const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                        const SizedBox(height: 16),
                        const Text('Watch ads to earn points!',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Earn $_pointsPerAd points per ad', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(child: _buildStat('Today', '$_todayViews/$_maxDailyAds', Icons.today, AppTheme.secondaryBlue)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStat('Remaining', '${_maxDailyAds - _todayViews}', Icons.hourglass_empty, AppTheme.accentPurple)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (_canWatch && _todayViews < _maxDailyAds)
                    ElevatedButton.icon(
                      onPressed: _watchAd,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Watch Ad Now'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange, padding: const EdgeInsets.symmetric(vertical: 16)),
                    )
                  else if (_cooldownRemaining > 0)
                    _buildCooldown()
                  else
                    _buildLimitReached(),
                ],
              ),
            ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.neutral200)),
      child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 8), Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(color: AppTheme.neutral500, fontSize: 12))]),
    );
  }

  Widget _buildCooldown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.neutral100, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [const Icon(Icons.timer, size: 48, color: AppTheme.neutral400), const SizedBox(height: 12), Text('Next ad available in', style: TextStyle(color: AppTheme.neutral500)), Text(_formatTime(_cooldownRemaining), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))]),
    );
  }

  Widget _buildLimitReached() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Column(children: [const Icon(Icons.check_circle, size: 48, color: AppTheme.warning), const Text('Daily limit reached!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text('Come back tomorrow', style: TextStyle(color: AppTheme.neutral500))]),
    );
  }
}

class _AdSimulationDialog extends StatefulWidget {
  final VoidCallback onComplete;
  const _AdSimulationDialog({required this.onComplete});

  @override
  State<_AdSimulationDialog> createState() => _AdSimulationDialogState();
}

class _AdSimulationDialogState extends State<_AdSimulationDialog> {
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() => _progress += 0.02);
      if (_progress >= 1) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 300), widget.onComplete);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.play_circle_filled, size: 80, color: AppTheme.primaryGreen),
          const SizedBox(height: 16),
          const Text('Watching Ad...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text('${(5 - _progress * 5).ceil()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
          const SizedBox(height: 16),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _progress, backgroundColor: AppTheme.neutral200, valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen), minHeight: 10)),
        ]),
      ),
    );
  }
}
