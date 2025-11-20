import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../../core/config/supabase_client.dart';

class AuthRepository {
  final supabase = SupabaseConfig.client;

  Future<Session?> signIn(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.session;
  }

  Future<void> signOut() async => await supabase.auth.signOut();

  Future<ProfileModel?> getProfile(String userId) async {
    final data = await supabase.from('profiles').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }
}
