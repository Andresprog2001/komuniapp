// Este archivo maneja la lógica de negocio y la interacción entre el modelo y la vista.
import 'package:flutter/material.dart';
import 'package:komuniapp/models/login_model.dart';

class LoginController extends ChangeNotifier {
  final LoginModel _model = LoginModel();
  bool _isLoading = false;

  String get username => _model.username;
  String get password => _model.password;
  String get errorMessage => _model.errorMessage;
  bool get isLoading => _isLoading;

  void setUsername(String value) {
    _model.setUsername(value);
  }

  void setPassword(String value) {
    _model.setPassword(value);
  }

  /// Simula el proceso de inicio de sesión.
  Future<bool> login() async {
    _isLoading = true;

    // Simular una llamada a la API
    await Future.delayed(const Duration(seconds: 2));

    if (_model.validateCredentials()) {
      _isLoading = false;
      return true;
    } else {
      _isLoading = false;
      return false;
    }
  }
}
