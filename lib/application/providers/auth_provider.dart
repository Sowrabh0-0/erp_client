import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ Use NotifierProvider in Riverpod 3
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthState {
  final bool loading;
  final ProfileModel? profile;
  final String? error;

  const AuthState({
    this.loading = false,
    this.profile,
    this.error,
  });

  AuthState copyWith({
    bool? loading,
    ProfileModel? profile,
    String? error,
  }) {
    return AuthState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      error: error ?? this.error,
    );
  }
}

// ✅ Now extend Notifier<AuthState>, not StateNotifier<AuthState>
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repo;
  SupabaseClient get client => _repo.supabase;


  @override
  AuthState build() {
    _repo = AuthRepository();
    _init();
    return const AuthState();
  }

  Future<void> _init() async {
    final session = _repo.supabase.auth.currentSession;
    if (session?.user != null) {
      await fetchProfile();
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final session = await _repo.signIn(email, password);
      if (session != null) {
        await fetchProfile();
      } else {
        state = state.copyWith(error: 'Invalid credentials');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> fetchProfile() async {
    final userId = _repo.supabase.auth.currentUser?.id;
    if (userId == null) return;
    final profile = await _repo.getProfile(userId);
    state = state.copyWith(profile: profile);
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }
}
