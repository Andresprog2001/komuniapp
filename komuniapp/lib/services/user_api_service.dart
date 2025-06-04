import 'dart:convert'; // Para codificar y decodificar JSON
import 'package:http/http.dart' as http; // Importa el paquete http
import 'package:komuniapp/models/registration_model.dart';

class UserApiService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';

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
      throw Exception('Error de conexión: $e');
    }
  }
}
