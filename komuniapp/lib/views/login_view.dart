// Este archivo construye la interfaz de usuario.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/controllers/login_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el LoginController
    final loginController = Provider.of<LoginController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[300], // Fondo gris claro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo de KomuniApp
              Container(
                width: 150,
                height: 150,
                child: Center(
                  child: Image.asset(
                    'assets/komuniapp_logo.png',
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.people, // Icono de fallback si la imagen no carga
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              // Título KomuniApp
              const Text(
                'KOMUNIAPP',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 48.0),
              // Campo de Usuario
              TextField(
                onChanged: loginController.setUsername,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu usuario',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Esquinas redondeadas
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
              // Campo de Contraseña
              TextField(
                onChanged: loginController.setPassword,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Esquinas redondeadas
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
              // Mensaje de error
              if (loginController.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    loginController.errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Botón Ingresar
              ElevatedButton(
                onPressed: loginController.isLoading
                    ? null // Deshabilitar el botón mientras carga
                    : () async {
                        bool success = await loginController.login();
                        if (success) {
                          // Navegar a la siguiente pantalla si el login es exitoso
                          // Por ejemplo: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('¡Inicio de sesión exitoso!'),
                              backgroundColor: Colors.green[700],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.all(10),
                            ),
                          );
                        } else {
                          // El mensaje de error ya se muestra en el UI a través del Provider
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Color de fondo del botón
                  foregroundColor: Colors.white, // Color del texto del botón
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      30.0,
                    ), // Botón más redondeado
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // Ancho completo
                ),
                child: loginController.isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(
                height: 20.0,
              ), // Espacio entre el botón de login y el de registro
              // Opción de Registro
              TextButton(
                onPressed: () {
                  // Navegar a la pantalla de registro
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  '¿No estás registrado? Regístrate aquí',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Barra de navegación inferior (como en la imagen)
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.deepPurple),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.deepPurple),
              onPressed: () {},
            ),
            const SizedBox(width: 48), // Espacio para el botón flotante
            IconButton(
              icon: const Icon(Icons.person, color: Colors.deepPurple),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.deepPurple),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción del botón flotante
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            30.0,
          ), // Botón flotante redondeado
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
