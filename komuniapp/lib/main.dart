// Este archivo configura la aplicación principal y el punto de entrada.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/controllers/login_controller.dart';
import 'package:komuniapp/views/login_view.dart';
import 'package:komuniapp/controllers/registration_controller.dart';
import 'package:komuniapp/views/registration_view.dart';
import 'package:komuniapp/controllers/content_controller.dart';
import 'package:komuniapp/views/content_view.dart';
import 'package:komuniapp/controllers/upload_content_controller.dart';
import 'package:komuniapp/views/upload_content_view.dart';
import 'package:komuniapp/controllers/user_profile_controller.dart';
import 'package:komuniapp/views/user_profile_view.dart';
import 'package:komuniapp/views/content_detail_view.dart';
import 'package:komuniapp/models/content_model.dart';
import 'package:komuniapp/views/registered_content_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Listar todos los controladores que necesitan ser accesibles globalmente o en múltiples vistas
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => RegistrationController()),
        ChangeNotifierProvider(create: (_) => ContentController()),
        ChangeNotifierProvider(create: (_) => UploadContentController()),
        ChangeNotifierProvider(create: (_) => UserProfileController()),
      ],
      child: const MyApp(), // MyApp ahora es el hijo de MultiProvider
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KomuniApp Login',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Usando la fuente Inters
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: '/login',
      routes: {
        // Los controladores ya están disponibles globalmente desde el MultiProvider en main()
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegistrationView(),
        '/contents': (context) => const ContentView(),
        '/upload_contents': (context) => const UploadContentView(),
        '/user_profile': (context) => const UserProfileView(),
        '/registered_contents': (context) => const RegisteredContentView(),
        // No necesitamos registrar ContentDetailView aquí si se navega con MaterialPageRoute
      },
      // Puedes usar onGenerateRoute si pasas argumentos complejos (como ContentModel)
      onGenerateRoute: (settings) {
        if (settings.name == '/content_detail') {
          // Asume que el argumento es tu ContentModel
          final args = settings.arguments;
          if (args is Content) {
            // Asegúrate de que 'Content' sea tu ContentModel
            return MaterialPageRoute(
              builder: (context) => ContentDetailView(content: args),
            );
          }
          // Manejar caso de argumento incorrecto o nulo si es necesarioss
          return MaterialPageRoute(
            builder: (context) => const Text('Error: Contenido no encontrados'),
          );
        }
        // Dejar que el sistema de rutas estándar maneje otras rutas con nombre
        return null;
      },
    );
  }
}
