import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepify_app/l10n/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../services/api_service.dart';
import '../../../../services/storage_service.dart';
import '../providers/auth_provider.dart';

/// Complete Profile Screen (Single step form)
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _weightController = TextEditingController(text: '70');
  final _heightController = TextEditingController(text: '170');
  
  bool _isEmailReadOnly = false;
  bool _isPhoneReadOnly = false;
  
  double _stepGoal = 5000;
  int _selectedAvatarIndex = 0;
  
  // Avatars
  List<dynamic> _avatars = [];
  bool _isLoadingAvatars = false;
  
  // No longer needed
  // final List<Color> _avatarColors = ...
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchAvatars();
  }

  Future<void> _fetchAvatars() async {
    setState(() => _isLoadingAvatars = true);
    try {
      final response = await ref.read(apiServiceProvider).get('/users/avatars');
      setState(() {
        _avatars = response.data;
        // Default to first if available and none selected yet
        if (_avatars.isNotEmpty && _selectedAvatarIndex >= _avatars.length) {
          _selectedAvatarIndex = 0;
        }
      });
    } catch (e) {
      // Fallback
    } finally {
      setState(() => _isLoadingAvatars = false);
    }
  }

  void _loadUser() {
    final user = StorageService.getUser();
    if (user != null) {
      _nameController.text = user['name'] ?? '';
      
      if (user['email'] != null && (user['email'] as String).isNotEmpty) {
        _emailController.text = user['email'];
        _isEmailReadOnly = true;
      }
      
      if (user['phone'] != null && (user['phone'] as String).isNotEmpty) {
        _phoneController.text = user['phone'];
        _isPhoneReadOnly = true;
      }
      
      if (user['dailyStepGoal'] != null) {
        _stepGoal = (user['dailyStepGoal'] as num).toDouble();
      }
      if (user['age'] != null) _ageController.text = user['age'].toString();
      if (user['weightKg'] != null) _weightController.text = user['weightKg'].toString();
      if (user['heightCm'] != null) _heightController.text = user['heightCm'].toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final user = StorageService.getUser() ?? {};
      
      final age = int.tryParse(_ageController.text) ?? 25;
      final weight = int.tryParse(_weightController.text) ?? 70;
      final height = int.tryParse(_heightController.text) ?? 170;

      final data = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'heightCm': height,
        'weightKg': weight,
        'age': age,
        'dailyStepGoal': _stepGoal.toInt(),
        'dailyStepGoal': _stepGoal.toInt(),
        'avatarUrl': _avatars.isNotEmpty ? _avatars[_selectedAvatarIndex]['url'] : 'default',
      };
      
      // Call API
      await ref.read(apiServiceProvider).put('/users/me', data: data);
      
      // Update local
      final currentUser = StorageService.getUser();
      if (currentUser != null) {
        currentUser.addAll(data);
        await StorageService.saveUser(currentUser);
      }
      
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Complete Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Tell us about yourself to personalize your experience.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.neutral500,
                        ),
                      ).animate().fadeIn(),
                      
                      const SizedBox(height: 32),
                      
                      // 1. Name Input
                      _buildLabel('Your Name'),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: _buildInputDecoration('e.g. Alex Step', Icons.person_outline),
                        validator: (v) => v == null || v.length < 2 ? 'Name must be at least 2 chars' : null,
                      ).animate(delay: 100.ms).fadeIn(),
                      
                      const SizedBox(height: 24),
                      
                      // 1.1 Contact Info
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Email'),
                                TextFormField(
                                  controller: _emailController,
                                  readOnly: _isEmailReadOnly,
                                  style: TextStyle(color: _isEmailReadOnly ? AppTheme.neutral500 : AppTheme.neutral900),
                                  decoration: _buildInputDecoration('email@example.com', Icons.email_outlined, isReadOnly: _isEmailReadOnly),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Required';
                                    if (!v.contains('@')) return 'Invalid email';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate(delay: 150.ms).fadeIn(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Phone'),
                                TextFormField(
                                  controller: _phoneController,
                                  readOnly: _isPhoneReadOnly,
                                  style: TextStyle(color: _isPhoneReadOnly ? AppTheme.neutral500 : AppTheme.neutral900),
                                  decoration: _buildInputDecoration('+1234567890', Icons.phone_outlined, isReadOnly: _isPhoneReadOnly),
                                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate(delay: 150.ms).fadeIn(),

                      const SizedBox(height: 24),

                      // 2. Physical Stats (Row)
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Age'),
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration('25', null),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Weight (kg)'),
                                TextFormField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration('70', null),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Height (cm)'),
                                TextFormField(
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration('170', null),
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate(delay: 200.ms).fadeIn(),

                      const SizedBox(height: 24),
                      
                      // 3. Avatar Carousel
                      _buildLabel('Choose Avatar'),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _avatars.isEmpty ? 5 : _avatars.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            if (_isLoadingAvatars) {
                              return Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                              ).animate(onPlay: (c) => c.repeat()).shimmer();
                            }
                            
                            if (_avatars.isEmpty) {
                              // Fallback placeholders
                              return Container(
                                width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: Colors.grey),
                              );
                            }
                            
                            final isSelected = _selectedAvatarIndex == index;
                            final avatarUrl = _avatars[index]['url'];
                            
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatarIndex = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.elasticOut,
                                width: isSelected ? 70 : 50,
                                height: isSelected ? 70 : 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                                    width: 3,
                                  ),
                                  color: Colors.white,
                                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.4), blurRadius: 8)] : null,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    avatarUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.person),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ).animate(delay: 300.ms).fadeIn(),
                      
                      const SizedBox(height: 24),
                      
                      // 4. Goal Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('Daily Step Goal'),
                          Text(
                            '${_stepGoal.toInt()} steps',
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primaryGreen,
                          inactiveTrackColor: AppTheme.neutral200,
                          thumbColor: AppTheme.primaryGreen,
                          overlayColor: AppTheme.primaryGreen.withOpacity(0.2),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _stepGoal,
                          min: 2000,
                          max: 20000,
                          divisions: 18,
                          onChanged: (value) => setState(() => _stepGoal = value),
                        ),
                      ).animate(delay: 400.ms).fadeIn(),
                    ],
                  ),
                ),
              ),
              
              // Bottom Section
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Complete Setup",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.neutral700)),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData? icon, {bool isReadOnly = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.neutral200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.neutral200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
      ),
      filled: true,
      fillColor: isReadOnly ? AppTheme.neutral100 : AppTheme.neutral50,
    );
  }
}
