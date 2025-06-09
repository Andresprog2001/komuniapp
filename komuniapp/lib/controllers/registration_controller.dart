import 'package:flutter/material.dart';
import 'package:komuniapp/models/registration_model.dart';
import 'package:komuniapp/services/user_api_service.dart'; // IMPORTAR EL NUEVO SERVICIO

class RegistrationController extends ChangeNotifier {
  final RegistrationModel _model = RegistrationModel();
  final UserApiService _apiService = UserApiService(); // INSTANCIAR EL SERVICIO
  bool _isLoading = false;

  String get name => _model.name;
  String get email => _model.email;
  String get password => _model.password;
  String get gender => _model.gender;
  bool get termsAccepted => _model.termsAccepted;
  String get errorMessage => _model.errorMessage;
  bool get isLoading => _isLoading;

  void setName(String value) {
    _model.setName(value);
  }

  void setEmail(String value) {
    _model.setEmail(value);
  }

  void setPassword(String value) {
    _model.setPassword(value);
  }

  void setGender(String? value) {
    if (value != null) {
      _model.setGender(value);
    }
    notifyListeners();
  }

  void setTermsAccepted(bool? value) {
    _model.setTermsAccepted(value ?? false);
    notifyListeners();
  }

  /// Realiza el proceso de registro de usuario usando el servicio API.
  Future<bool> registerUser() async {
    _isLoading = true;
    _model.errorMessage = ''; // Limpiar errores previos antes de intentar
    notifyListeners();

    if (!_model.validateRegistration()) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      // LLAMAMOS AL SERVICIO API REAL
      final success = await _apiService.registerUser(_model);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      // Manejar el error reportado por el servicio
      _model.errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Limpiar "Exception: "
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
