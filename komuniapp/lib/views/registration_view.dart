// Este archivo construye la interfaz de usuario para el registro.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/controllers/registration_controller.dart';

class RegistrationView extends StatelessWidget {
  const RegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    final registrationController = Provider.of<RegistrationController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[300], // Fondo gris claro
      appBar: AppBar(
        title: const Text(
          'Registro de Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Color del icono de retroceso
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'KomuniApp',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 32.0),
              // Campo Nombre Completo
              TextField(
                onChanged: registrationController.setName,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu nombre completo',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.deepPurple,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Campo Correo Electrónico
              TextField(
                onChanged: registrationController.setEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu correo electrónico',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Campo Contraseña
              TextField(
                onChanged: registrationController.setPassword,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              // Selección de Género
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Género',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Masculino'),
                      value: 'Masculino',
                      groupValue: registrationController.gender,
                      onChanged: registrationController.setGender,
                      activeColor: Colors.deepPurple,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Femenino'),
                      value: 'Femenino',
                      groupValue: registrationController.gender,
                      onChanged: registrationController.setGender,
                      activeColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Aceptar Términos y Condiciones
              Row(
                children: <Widget>[
                  Checkbox(
                    value: registrationController.termsAccepted,
                    onChanged: registrationController.setTermsAccepted,
                    activeColor: Colors.deepPurple,
                  ),
                  const Expanded(
                    child: Text(
                      'Acepto los términos y condiciones',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              // Mensaje de error
              if (registrationController.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    registrationController.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Botón Registrar
              ElevatedButton(
                onPressed: registrationController.isLoading
                    ? null
                    : () async {
                        bool success = await registrationController
                            .registerUser();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('¡Registro exitoso!'),
                              backgroundColor: Colors.green[700],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(10),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.deepPurple, // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto del botón
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: registrationController.isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Registrar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
