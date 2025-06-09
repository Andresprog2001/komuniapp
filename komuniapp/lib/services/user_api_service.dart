import 'package:flutter/foundation.dart'
    show kIsWeb; // Importa kIsWeb para detectar la plataforma web
import 'dart:convert'; // Para codificar y decodificar JSON
import 'package:http/http.dart' as http; // Importa el paquete http
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komuniapp/models/registration_model.dart';
import 'package:komuniapp/models/user_profile_model.dart';

class UserApiService {
  // kIsWeb se usa para determinar si la aplicación se está ejecutando en un navegador web o en un dispositivo móvil.
  final String _baseUrl = kIsWeb
      ? 'http://localhost:3000/api' // Para navegadores web
      : 'http://10.0.2.2:3000/api';

  // <<-- MÉTODOS PARA GESTIONAR EL TOKEN -->>
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<bool> registerUser(RegistrationModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'), // Endpoint de registro en el backend
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()), // Convierte el modelo a JSON string
      );

      if (response.statusCode == 201) {
        // 201 Created o 200 OK
        print('Registro exitoso: ${response.body}');
        return true;
      } else {
        // Fallo en el registro.
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
          'Error de registro: ${response.statusCode} - ${responseData['message']}',
        );
        throw Exception(
          responseData['message'] ?? 'Error desconocido al registrar usuario',
        );
      }
    } catch (e) {
      // Manejo de errores de red o cualquier otra excepción
      print('Excepción al registrar usuario: $e');
      throw Exception(e);
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email, // Enviamos el email en el cuerpo JSON
          'password': password, // Enviamos la contraseña en el cuerpo JSON
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String? token = responseData['token'];

        print("aqui esta el token: $token");
        if (token != null) {
          await _saveToken(token); // <<-- GUARDA EL TOKEN RECIBIDO -->>
          print('Inicio de sesión exitoso. Token guardado.');
          return {'token': token}; // Devuelve el token
        } else {
          throw Exception('Token no recibido del servidor.');
        }
      } else {
        // Si el estado no es 200, significa que hubo un error (ej. 401 Unauthorized, 400 Bad Request)
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
          'Error de inicio de sesión: ${response.statusCode} - ${responseData['message']}',
        );
        throw Exception(responseData['message'] ?? 'Credenciales incorrectas');
      }
    } catch (e) {
      // Capturamos cualquier excepción de red o de otro tipo
      print('Excepción al iniciar sesión: $e');
      throw Exception('Error de conexión al iniciar sesión : $e');
    }
  }

  Future<UserProfile> fetchUserProfile() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No hay token de autenticación. Inicia sesión.');
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Este es el codigo response ${jsonResponse}");

        return UserProfile.fromJson(jsonResponse);
      } else {
        print(
          'Error al obtener perfil: ${response.statusCode} - ${response.body}',
        );
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        throw Exception(
          responseData['message'] ?? 'Error al cargar el perfil del usuario',
        );
      }
    } catch (e) {
      print('Excepción al obtener perfil: $e');
      throw Exception('Error de conexión al obtener perfil: $e');
    }
  }
}
