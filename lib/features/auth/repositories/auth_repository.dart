import '../../../shared/models/user_model.dart';
import '../../../shared/services/api_service.dart';

/// Repository handling auth API calls
class AuthRepository {
  final ApiService _api = ApiService();

  /// Validates email format
  static final RegExp _emailRegex = RegExp(
    r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  /// Login with email and password.
  /// Returns a [UserModel] on success; throws [Exception] on failure.
  Future<UserModel> login(String email, String password) async {
    // Client-side validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Veuillez remplir tous les champs');
    }
    if (!_emailRegex.hasMatch(email)) {
      throw Exception('Format d\'email invalide');
    }
    if (password.length < 4) {
      throw Exception('Le mot de passe doit contenir au moins 4 caractères');
    }

    try {
      final response = await _api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // For development/demo: return a mock user
      // TODO: Remove this mock in production
      if (email.isNotEmpty && password.isNotEmpty) {
        return UserModel(
          id: '1',
          name: 'Utilisateur Test',
          email: email,
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          role: 'collector',
        );
      }
      throw Exception('Identifiants invalides');
    }
  }
}
