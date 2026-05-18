import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

/// Coin Counter with bounce animation on value change
class CoinCounter extends StatefulWidget {
  final int coinBalance;
  final VoidCallback? onTap;

  const CoinCounter({
    super.key,
    required this.coinBalance,
    this.onTap,
  });

  @override
  State<CoinCounter> createState() => _CoinCounterState();
}

class _CoinCounterState extends State<CoinCounter> {
  int _previousValue = 0;
  bool _shouldBounce = false;

  @override
  void didUpdateWidget(CoinCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coinBalance != widget.coinBalance) {
      _previousValue = oldWidget.coinBalance;
      _shouldBounce = widget.coinBalance > _previousValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget counter = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentYellow.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              _formatNumber(widget.coinBalance),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );

    // Apply bounce animation
    if (_shouldBounce) {
      counter = counter.animate(onComplete: (_) {
        setState(() => _shouldBounce = false);
      }).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.15, 1.15),
        duration: 150.ms,
      ).then().scale(
        begin: const Offset(1.15, 1.15),
        end: const Offset(1, 1),
        duration: 150.ms,
        curve: Curves.bounceOut,
      );
    }

    return counter;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
