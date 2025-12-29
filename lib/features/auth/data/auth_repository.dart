import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/core/models/app_user.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<AppUser> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    return await _fetchUserProfile(response.user!.id);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<AppUser?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    try {
      return await _fetchUserProfile(authUser.id);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Stream<AppUser?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      try {
        return await _fetchUserProfile(user.id);
      } catch (e) {
        print('Error in auth state change: $e');
        return null;
      }
    });
  }

  Future<AppUser> _fetchUserProfile(String authId) async {
    final response = await _supabase
        .from('users')
        .select()
        .eq('auth_id', authId)
        .single();

    return AppUser.fromJson(response);
  }
}
