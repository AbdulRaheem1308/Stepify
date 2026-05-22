import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stepify_app/core/theme/app_theme.dart';
import 'package:stepify_app/l10n/app_localizations.dart';
import '../providers/company_provider.dart';

class JoinCompanyScreen extends ConsumerStatefulWidget {
  const JoinCompanyScreen({super.key});

  @override
  ConsumerState<JoinCompanyScreen> createState() => _JoinCompanyScreenState();
}

class _JoinCompanyScreenState extends ConsumerState<JoinCompanyScreen> {
  final _codeController = TextEditingController();
  
  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (_codeController.text.isEmpty) return;
    
    final success = await ref.read(companyProvider.notifier).joinCompany(_codeController.text);
    if (success && mounted) {
      context.replace('/company/dashboard');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(companyProvider).error ?? AppLocalizations.of(context)?.failedToJoin ?? 'Failed to join')),
        );
      }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)?.joinCompanyTitle ?? 'Join Company')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.business, size: 80, color: AppTheme.primaryGreen),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)?.enterCompanyCode ?? 'Enter Company Code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)?.companyCodeSubtitle ?? 'Get your unique code from your HR or wellness administrator to join your colleagues.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.neutral600),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)?.inviteCodeLabel ?? 'Invite Code',
                hintText: AppLocalizations.of(context)?.inviteCodeHint ?? 'e.g. CORP2024',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _join,
                child: state.isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context)?.joinCompanyTitle ?? 'Join Company'),
              ),
            ),
            if (state.error != null)
               Padding(
                 padding: const EdgeInsets.only(top: 20),
                 child: Text(state.error!, style: const TextStyle(color: Colors.red)),
               ),
          ],
        ),
      ),
    );
  }
}
