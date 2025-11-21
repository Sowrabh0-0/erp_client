// lib/presentation/screens/home/company_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/company_provider.dart';
import '../../../application/providers/auth_provider.dart';

class CompanySelectionScreen extends ConsumerStatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  ConsumerState<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends ConsumerState<CompanySelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider.notifier).loadCompanies();
    });
  }

  Future<bool> _setActiveCompany(String companyId) async {
    // cache notifier before awaits
    final authNotifier = ref.read(authProvider.notifier);
    final supabase = authNotifier.client;
    try {
      // call RPC to set session variable for this connection
      final res = await supabase.rpc('set_active_company', params: {
        'company_id': companyId,
      });
      // res is usually null for void functions; log for debug
      debugPrint('set_active_company RPC result: $res');
      return true;
    } catch (e, st) {
      debugPrint('Failed to set active company: $e\n$st');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyProvider);
    final notifier = ref.read(companyProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Company')),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: state.companies.isEmpty
                      ? const Center(child: Text('No companies found'))
                      : ListView.builder(
                          itemCount: state.companies.length,
                          itemBuilder: (context, index) {
                            final company = state.companies[index];
                            return ListTile(
                              title: Text(company['name'] ?? ''),
                              onTap: () async {
                                await notifier.selectCompany(
                                  company['id'] as String,
                                  company['name'] as String,
                                );
                              },
                            );
                          },
                        ),
                ),

                if (state.selectedCompanyId != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Selected: ${state.selectedCompanyName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          value: state.selectedTimePeriodId,
                          items: state.timePeriods.map((tp) {
                            final label = tp['label'] ??
                                '${tp['start_date']} → ${tp['end_date']}';
                            return DropdownMenuItem(
                              value: tp['id'] as String,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              notifier.selectTimePeriod(val);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Time Period',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: state.selectedTimePeriodId == null
                              ? null
                              : () async {
                                  final companyId = state.selectedCompanyId!;
                                  final timePeriodId = state.selectedTimePeriodId!;
                                  // 1) set active company RPC
                                  final ok = await _setActiveCompany(companyId);
                                  if (!ok) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to set active company')));
                                    return;
                                  }

                                  // 2) Navigate to home (we keep companyId/timePeriodId in URL for clarity)
                                  final nameEncoded = Uri.encodeComponent(state.selectedCompanyName ?? '');
                                  context.go(
                                    '/home?companyId=$companyId&companyName=$nameEncoded&timePeriodId=$timePeriodId',
                                  );
                                },
                          child: const Text('Continue'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
