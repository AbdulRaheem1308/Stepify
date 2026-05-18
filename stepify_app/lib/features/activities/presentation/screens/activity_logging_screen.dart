import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import '../../domain/models/activity_model.dart';
import '../providers/activity_provider.dart';

class ActivityLoggingScreen extends ConsumerStatefulWidget {
  const ActivityLoggingScreen({super.key});

  @override
  ConsumerState<ActivityLoggingScreen> createState() => _ActivityLoggingScreenState();
}

class _ActivityLoggingScreenState extends ConsumerState<ActivityLoggingScreen> {
  ActivityType _selectedType = ActivityType.running;
  final _durationController = TextEditingController();
  final _distanceController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Log Activity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'What did you do today?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Activity Type Grid
            const Text('Activity Type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ActivityType.values.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(_formatActivityName(type)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                  selectedColor: AppTheme.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                  avatar: Icon(_getActivityIcon(type), size: 18, color: isSelected ? Colors.white : AppTheme.primaryGreen),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Duration Input
            const Text('Duration (minutes)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 30',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.timer_outlined),
              ),
            ),
            
            // Distance Input (Conditional)
            if (_hasDistance(_selectedType)) ...[
              const SizedBox(height: 24),
              const Text('Distance (km)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 5.2',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.map_outlined),
                ),
              ),
            ],
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _submitActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: state.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Log Workout & Earn Points', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 24),
            // Multiplier Info
            Center(
              child: Text(
                '⚡ Earn ${Activity.getPointsMultiplier(_selectedType).toStringAsFixed(1)}x points for this activity!',
                style: const TextStyle(color: AppTheme.accentYellow, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _submitActivity() async {
    if (_durationController.text.isEmpty) return;
    
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) return;
    
    double? distance;
    if (_hasDistance(_selectedType) && _distanceController.text.isNotEmpty) {
      distance = double.tryParse(_distanceController.text);
    }
    
    await ref.read(activityProvider.notifier).logActivity(
      type: _selectedType,
      duration: Duration(minutes: duration),
      distanceKm: distance,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity Logged! Points added.')),
      );
      context.pop();
    }
  }

  String _formatActivityName(ActivityType type) {
    return type.name[0].toUpperCase() + type.name.substring(1);
  }
  
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.walking: return Icons.directions_walk;
      case ActivityType.running: return Icons.directions_run;
      case ActivityType.cycling: return Icons.directions_bike;
      case ActivityType.yoga: return Icons.self_improvement;
      case ActivityType.swimming: return Icons.pool;
      case ActivityType.gym: return Icons.fitness_center;
      case ActivityType.hiking: return Icons.hiking;
    }
  }
  
  bool _hasDistance(ActivityType type) {
    return type == ActivityType.walking || 
           type == ActivityType.running || 
           type == ActivityType.cycling || 
           type == ActivityType.hiking ||
           type == ActivityType.swimming;
  }
}
