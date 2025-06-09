import 'package:flutter/material.dart';
import 'package:komuniapp/models/user_profile_model.dart';
import 'package:komuniapp/services/user_api_service.dart';

class UserProfileController extends ChangeNotifier {
  final UserApiService _apiService = UserApiService();
  UserProfile? _userProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Fetches the user profile based on the provided email.
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final profile = await _apiService.fetchUserProfile();
      _userProfile = profile;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      print('Error en UserProfileController: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
