import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/supabase_auth_service.dart';
import '../../data/repos/profile_repo.dart';

class AuthController extends ChangeNotifier {
  final SupabaseAuthService _authService;
  final ProfileRepository _profileRepo;
  final SupabaseClient _client;

  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;

  AuthController({
    SupabaseAuthService? authService,
    ProfileRepository? profileRepo,
    SupabaseClient? client,
  })  : _authService = authService ?? SupabaseAuthService(),
        _profileRepo = profileRepo ?? ProfileRepository(),
        _client = client ?? Supabase.instance.client;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Checks and caches the role ('owner', 'member', or null) for the given or current user.
  Future<String?> checkUserRole({String? userId}) async {
    final uid = userId ?? currentUser?.id;
    if (uid == null) {
      _userRole = null;
      return null;
    }

    try {
      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .maybeSingle();

      if (profile != null && profile['role'] != null) {
        _userRole = profile['role'].toString().trim().toLowerCase();
      } else {
        _userRole = null;
      }
      notifyListeners();
      return _userRole;
    } catch (_) {
      _userRole = null;
      return null;
    }
  }

  /// Signs in with email and password, then resolves and returns the user's role.
  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signInWithEmailPassword(
        email.trim(),
        password,
      );

      final uid = response.user?.id;
      final role = await checkUserRole(userId: uid);
      return role;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs up with email and password.
  Future<AuthResponse> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signUpWithEmailPassword(
        email.trim(),
        password,
      );
      return response;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Assigns a role ('owner' or 'member') to the currently authenticated user.
  Future<void> setUserRole(String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _profileRepo.createUserProfile(role: role);
      _userRole = role.toLowerCase();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs out the user and clears state.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _userRole = null;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
