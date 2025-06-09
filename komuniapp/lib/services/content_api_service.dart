// lib/services/educational_content_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:komuniapp/models/content_model.dart'; // Importa el modelo
import 'package:komuniapp/models/upload_content_model.dart'; // Importa el modelo
import 'package:shared_preferences/shared_preferences.dart';

// Método auxiliar para obtener el token, similar al de UserApiService
Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

class ContentApiService {
  final String _baseUrl = kIsWeb
      ? 'http://localhost:3000/api' // Para navegadores web
      : 'http://10.0.2.2:3000/api'; // Para emuladores de Android

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
}
