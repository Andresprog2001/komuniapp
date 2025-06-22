import 'package:flutter/material.dart';
import 'package:komuniapp/models/login_model.dart';
import 'package:komuniapp/views/login_view.dart';
import 'package:komuniapp/services/user_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ChangeNotifier {
  final LoginModel _model = LoginModel();
  final UserApiService _apiService = UserApiService();
  bool _isLoading = false;
  String? _jwtToken; // Para almacenar el token JWT
  String? _loggedInUserId;

  String get email => _model.email;
  String get password => _model.password;
  String get errorMessage => _model.errorMessage;
  bool get isLoading => _isLoading;
  String? get jwtToken => _jwtToken;
  String? get loggedInUserId => _loggedInUserId;

  LoginController() {}

  void setEmail(String value) {
    _model.setEmail(value);
  }

  void setPassword(String value) {
    _model.setPassword(value);
  }

  ///proceso de inicio de sesión.
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

  // Future<void> logout(BuildContext context) async {
  //   _isLoading = true;
  //   _model.errorMessage = '';
  //   notifyListeners(); // Notificar a la vista que el estado de carga ha cambiado

  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.remove('jwt_token'); // Eliminar el token de SharedPreferences
  //     _jwtToken = null; // Limpiar el token en memoria

  //     // Navegación: empuja LoginView y remueve todas las rutas anteriores
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) => const LoginView()),
  //         (Route<dynamic> route) =>
  //             false, // Predicado para remover todas las rutas
  //       );
  //     });
  //   } catch (e) {
  //     _model.errorMessage = 'Error al cerrar sesión: ${e.toString()}';
  //     print("Error during logout and navigation: $e");
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners(); // Notificar a la vista que el usuario ha cerrado sesión (y _isLoading cambió)
  //   }
  // }

  // // Este método isLoggedIn() es crucial para verificar el token si decides usarlo en el futuro
  // // para un Splash Screen o un FutureBuilder en el home de MaterialApp.
  // Future<bool> isLoggedIn() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('jwt_token');
  //     if (token != null && token.isNotEmpty) {
  //       _jwtToken = token;
  //       return true;
  //     }
  //     _jwtToken = null;
  //     return false;
  //   } catch (e) {
  //     print('Error al verificar el estado de login2: $e');
  //     _jwtToken = null;
  //     return false;
  //   }
  // }
}
