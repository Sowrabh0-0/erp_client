import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/company_provider.dart';
import '../../../core/config/supabase_client.dart';

class CompanySelectionScreen extends ConsumerStatefulWidget {
  const CompanySelectionScreen({super.key});

  @override
  ConsumerState<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends ConsumerState<CompanySelectionScreen> {
  @override
  void initState() {
    final s = SupabaseConfig.client;
s.from('companies').select().then((data) {
  debugPrint('COMPANIES TEST FROM SCREEN: $data');
}).catchError((e) {
  debugPrint('❌ ERROR FROM SCREEN: $e');
});

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(companyProvider.notifier).loadCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyProvider);
    final notifier = ref.read(companyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Company'),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
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
                              : () {
                                  final companyId = state.selectedCompanyId!;
                                  final nameEncoded = Uri.encodeComponent(
                                      state.selectedCompanyName ?? '');
                                  final timePeriodId = state.selectedTimePeriodId!;

                                  // 🔥 GoRouter navigation
                                  context.go(
                                    '/home'
                                    '?companyId=$companyId'
                                    '&companyName=$nameEncoded'
                                    '&timePeriodId=$timePeriodId',
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
