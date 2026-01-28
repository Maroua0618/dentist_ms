import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dentist_ms/core/models/app_user.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<AppUser> updateUser(AppUser user) async {
    try {
      print('📝 AuthRepository:  Updating user ${user.id}');
      print('   Profile Image URL: ${user.profileImageUrl}');

      // Update the database
      await _supabase
          .from('users')
          .update({
            'first_name': user.firstName,
            'last_name': user.lastName,
            'phone': user.phone,
            'specialization': user.specialization,
            'profile_image_url': user.profileImageUrl, // THIS IS THE KEY LINE
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      print('✅ Database updated successfully');

      // Fetch fresh data
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      final updatedUser = AppUser.fromJson(response);
      print('✅ Fresh user fetched.  Image URL: ${updatedUser.profileImageUrl}');

      return updatedUser;
    } catch (e) {
      print('❌ Failed to update user: $e');
      throw Exception('Failed to update user:  $e');
    }
  }

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

  /// Sign in using face recognition
  Future<AppUser> signInWithFace(List<double> faceEmbedding) async {
    try {
      print('🔍 Searching for matching face embedding...');

      // Fetch all users with face encodings
      final response = await _supabase
          .from('users')
          .select('id, auth_id, face_encoding, first_name, last_name')
          .not('face_encoding', 'is', null);

      final users = response as List<dynamic>;

      if (users.isEmpty) {
        throw Exception(
          'Aucun utilisateur avec reconnaissance faciale configurée',
        );
      }

      print('Found ${users.length} users with face encodings');

      // Find best match
      String? bestMatchAuthId;
      double bestSimilarity = -1.0;
      const double threshold = 0.6; // 60% similarity threshold

      for (final user in users) {
        final storedEncodingStr = user['face_encoding'] as String?;
        if (storedEncodingStr == null || storedEncodingStr.isEmpty) continue;

        try {
          final storedEmbedding = storedEncodingStr
              .split(',')
              .map((e) => double.parse(e))
              .toList();

          // Calculate cosine similarity
          final similarity = _calculateCosineSimilarity(
            faceEmbedding,
            storedEmbedding,
          );

          print(
            'User ${user['first_name']} ${user['last_name']}: similarity = ${similarity.toStringAsFixed(3)}',
          );

          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
            bestMatchAuthId = user['auth_id'] as String;
          }
        } catch (e) {
          print('Error processing user ${user['id']}: $e');
        }
      }

      print('Best match similarity: ${bestSimilarity.toStringAsFixed(3)}');

      if (bestMatchAuthId == null || bestSimilarity < threshold) {
        throw Exception(
          'Visage non reconnu. Similarité: ${(bestSimilarity * 100).toStringAsFixed(1)}%',
        );
      }

      print(
        '✅ Face matched with similarity: ${(bestSimilarity * 100).toStringAsFixed(1)}%',
      );

      // Fetch full user profile
      return await _fetchUserProfile(bestMatchAuthId);
    } catch (e) {
      print('❌ Face login failed: $e');
      throw Exception('Échec de la connexion faciale: $e');
    }
  }

  /// Calculate cosine similarity between two embeddings
  double _calculateCosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
    }

    return dotProduct; // Assuming normalized embeddings
  }
}
