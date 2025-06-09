import 'package:flutter/material.dart';
import 'package:komuniapp/models/login_model.dart';
import 'package:komuniapp/services/user_api_service.dart';

class LoginController extends ChangeNotifier {
  final LoginModel _model = LoginModel();
  final UserApiService _apiService = UserApiService();
  bool _isLoading = false;

  String get email => _model.email;
  String get password => _model.password;
  String get errorMessage => _model.errorMessage;
  bool get isLoading => _isLoading;

  void setEmail(String value) {
    _model.setEmail(value);
  }

  void setPassword(String value) {
    _model.setPassword(value);
  }

  /// Simula el proceso de inicio de sesión.
  /// Actualiza el estado de carga y el mensaje de error.
  Future<bool> login() async {
    _isLoading = true;
    _model.errorMessage = ''; // Limpiar errores previos
    notifyListeners(); // Notificar a la vista que el estado de carga ha cambiado

    if (!_model.validateCredentials()) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final Map<String, dynamic>? loginResult = await _apiService.loginUser(
        email,
        password,
      );
      _isLoading = false;

      if (loginResult != null && loginResult.containsKey('token')) {
        // _loggedInUserId = loginResult['user_id'].toString(); // Línea de userId eliminada
        notifyListeners();
        return true;
      } else {
        _model.errorMessage = 'Credenciales incorrectas o token no recibido.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _model.errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Limpiar "Exception: "
      _isLoading = false;
      notifyListeners(); // Notificar error
      return false;
    }
  }
}
