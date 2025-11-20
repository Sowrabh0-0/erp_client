// lib/data/repositories/company_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_client.dart';

class CompanyRepository {
  final SupabaseClient supabase = SupabaseConfig.client;

  Future<List<Map<String,dynamic>>> fetchCompanies() async {
    final res = await supabase.from('companies').select().order('name');
    return List<Map<String,dynamic>>.from(res as List);
  }

  Future<List<Map<String,dynamic>>> fetchTimePeriodsForCompany(String companyId) async {
    final res = await supabase
        .from('time_periods')
        .select()
        .eq('company_id', companyId)
        .order('start_date', ascending: true);
    return List<Map<String,dynamic>>.from(res as List);
  }
}
