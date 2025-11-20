// lib/application/providers/company_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/company_repository.dart';

class CompanyState {
  final bool loading;
  final List<Map<String,dynamic>> companies;
  final String? selectedCompanyId;
  final String? selectedCompanyName;
  final List<Map<String,dynamic>> timePeriods;
  final String? selectedTimePeriodId;

  const CompanyState({
    this.loading = false,
    this.companies = const [],
    this.selectedCompanyId,
    this.selectedCompanyName,
    this.timePeriods = const [],
    this.selectedTimePeriodId,
  });

  CompanyState copyWith({
    bool? loading,
    List<Map<String,dynamic>>? companies,
    String? selectedCompanyId,
    String? selectedCompanyName,
    List<Map<String,dynamic>>? timePeriods,
    String? selectedTimePeriodId,
  }) => CompanyState(
        loading: loading ?? this.loading,
        companies: companies ?? this.companies,
        selectedCompanyId: selectedCompanyId ?? this.selectedCompanyId,
        selectedCompanyName: selectedCompanyName ?? this.selectedCompanyName,
        timePeriods: timePeriods ?? this.timePeriods,
        selectedTimePeriodId: selectedTimePeriodId ?? this.selectedTimePeriodId,
      );
}

final companyProvider = NotifierProvider<CompanyNotifier, CompanyState>(CompanyNotifier.new);

class CompanyNotifier extends Notifier<CompanyState> {
  final CompanyRepository _repo = CompanyRepository();

  @override
  CompanyState build() {
    return const CompanyState();
  }

  Future<void> loadCompanies() async {
    state = state.copyWith(loading: true);
    try {
      final companies = await _repo.fetchCompanies();
      state = state.copyWith(loading: false, companies: companies);
    } catch (e) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  Future<void> selectCompany(String id, String name) async {
    state = state.copyWith(loading: true);
    try {
      final periods = await _repo.fetchTimePeriodsForCompany(id);
      // default pick the latest (last) period if exists
      String? defaultPeriodId;
      if (periods.isNotEmpty) defaultPeriodId = periods.last['id'] as String;
      state = state.copyWith(
        loading: false,
        selectedCompanyId: id,
        selectedCompanyName: name,
        timePeriods: periods,
        selectedTimePeriodId: defaultPeriodId,
      );
    } catch (e) {
      state = state.copyWith(loading: false);
      rethrow;
    }
  }

  void selectTimePeriod(String periodId) {
    state = state.copyWith(selectedTimePeriodId: periodId);
  }

  void clearSelection() {
    state = const CompanyState(companies: []);
  }
}
