// lib/services/educational_content_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:komuniapp/models/content_model.dart'; // Importa el modelo
import 'package:komuniapp/models/upload_content_model.dart'; // Importa el modelo
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Método auxiliar para obtener el token, similar al de UserApiService
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

class ContentApiService {
  final String _baseUrl = kIsWeb
      ? 'http://localhost:3000/api' // Para navegadores web
      : 'http://10.0.2.2:3000/api'; // Para emuladores de Android

  /// Método para extraer el ID del usuario directamente del token JWT almacenado.
  /// Este método es el que tu controlador llamará para obtener el userId.
  Future<String?> getUserIdFromToken() async {
    try {
      final String? jwtToken =
          await _getToken(); // Usa el _getToken() existente

      // Verificamos si el token es nulo o ha expirado
      if (jwtToken == null || JwtDecoder.isExpired(jwtToken)) {
        print('ContentApiService: No JWT token found or token is expired.');
        return null;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(jwtToken);

      return decodedToken['user_id'].toString();
    } catch (e) {
      print('ContentApiService: Error decoding JWT or getting user ID: $e');
      return null;
    }
  }

  Future<List<Content>> fetchContents() async {
    try {
      final token = await _getToken();
      // Verificamos si existe un token
      if (token == null) {
        throw Exception(
          'No hay token de autenticación para obtener contenidos. Por favor, inicia sesión.',
        );
      }

      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // Añade el token JWT al encabezado
      };

      // Endpoint para obtener contenidos
      final response = await http.get(
        Uri.parse('$_baseUrl/contents'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> contentsJson = jsonDecode(response.body);
        // Utiliza Content.fromJson que ahora espera 'file_url'
        return contentsJson.map((json) => Content.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
          'Error al cargar contenidos: ${response.statusCode} - ${responseData['message']}',
        );
        throw Exception(
          responseData['message'] ?? 'Error desconocido al cargar contenidos',
        );
      }
    } catch (e) {
      print('Excepción al cargar contenidos: $e');
      throw Exception('Error de conexión al cargar contenidos: $e');
    }
  }

  // Método para subir contenido
  Future<bool> uploadContent(UploadContentModel content) async {
    try {
      final token = await _getToken();

      // Verificamos si existe un token
      if (token == null) {
        throw Exception(
          'No hay token de autenticación para obtener contenidos. Por favor, inicia sesión.',
        );
      }

      // Endpoint para subir contenidos (el mismo que para GET, pero POST)
      final response = await http.post(
        Uri.parse('$_baseUrl/contents'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Añade el token JWT al encabezado
        },

        // Utiliza content.toJson() que ahora envía 'file_url'
        body: jsonEncode(content.toJson()),
      );

      if (response.statusCode == 201) {
        print('Contenido subido exitosamente: ${response.body}');
        return true;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
          'Error al subir contenido: ${response.statusCode} - ${responseData['message']}',
        );
        throw Exception(
          responseData['message'] ?? 'Error desconocido al subir contenido',
        );
      }
    } catch (e) {
      print('Excepción al subir contenido: $e');
      throw Exception('Error de conexión al subir contenido: $e');
    }
  }

  Future<bool> inscribeUserToContent(int contentId) async {
    String? userId;
    userId = await getUserIdFromToken();

    final url = Uri.parse('$_baseUrl/inscribe_content');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'contentId': contentId,
          'consult': false,
        }),
      );

      if (response.statusCode == 201) {
        // Creado exitosamente (nueva inscripción)
        return true;
      } else if (response.statusCode == 200) {
        // Puede que tu backend devuelva 200 si el usuario ya estaba inscrito
        final responseData = json.decode(response.body);
        final message =
            responseData['message'] ?? 'Ya estás inscrito en este contenido.';
        throw Exception(
          message,
        ); // Lanza una excepción con el mensaje del backend
      } else {
        // Otros códigos de error
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['error'] ?? 'Error desconocido en la inscripción.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Error de conexión al inscribirse: $e');
    }
  }

  Future<bool> isUserRegisteredForContent(
    String contentId,
    String userId,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found. User not logged in.');
      }
      // Endpoint para subir contenidos (el mismo que para GET, pero POST)
      final response = await http.post(
        Uri.parse('$_baseUrl/inscribe_content'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Añade el token JWT al encabezado
        },

        // Utiliza content.toJson() que ahora envía 'file_url'
        body: jsonEncode({
          'userId': userId,
          'contentId': contentId,
          'consult': true,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // <<<< AJUSTA ESTA LÓGICA: Tu API debería devolver un booleano o un objeto con un estado. >>>>
        // Asumimos que la respuesta JSON es algo como `{'isRegistered': true}` o `{'isRegistered': false}`
        return data['isRegistered'] as bool? ??
            false; // Retorna true si 'isRegistered' es true, de lo contrario false
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token.');
      } else if (response.statusCode == 404) {
        // Si el servidor indica que el recurso no existe o no encuentra el estado para esa combinación
        return false; // Podemos interpretarlo como "no registrado"
      } else {
        throw Exception(
          'Failed to check registration status: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('ContentApiService: Error in isUserRegisteredForContent: $e');
      rethrow; // Re-lanza la excepción para que el controlador la capture
    }
  }

  Future<List<Content>> fetchUserRegisteredContents() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception(
          'No hay token de autenticación para obtener contenidos inscritos. Por favor, inicia sesión.',
        );
      }

      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // ¡Este es el dato clave!
      };

      // EL BACKEND DEBE FILTRAR POR EL USER_ID DEL TOKEN RECIBIDO
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/registered_contents',
        ), // Endpoint sin userId en la URL
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> contentsJson = jsonDecode(response.body);
        return contentsJson.map((json) => Content.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No autorizado: Token inválido o expirado.');
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(
          'Error al cargar contenidos inscritos: ${response.statusCode} - ${responseData['message']}',
        );
        throw Exception(
          responseData['message'] ??
              'Error desconocido al cargar contenidos inscritos',
        );
      }
    } catch (e) {
      print('Excepción al cargar contenidos inscritos: $e');
      throw Exception('Error de conexión al cargar contenidos inscritos: $e');
    }
  }
}
