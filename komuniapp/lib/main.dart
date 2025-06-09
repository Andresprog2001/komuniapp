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

void main() {
  runApp(const MyApp());
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
        fontFamily: 'Inter', // Usando la fuente Inter
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => ChangeNotifierProvider(
          create: (context) => LoginController(),
          child: const LoginView(),
        ),
        '/register': (context) => ChangeNotifierProvider(
          create: (context) => RegistrationController(),
          child: const RegistrationView(),
        ),
        '/contents': (context) => ChangeNotifierProvider(
          create: (context) => ContentController(),
          child: const ContentView(),
        ),
        '/upload_contents': (context) => ChangeNotifierProvider(
          create: (context) => UploadContentController(),
          child: UploadContentView(),
        ),
        '/user_profile': (context) => ChangeNotifierProvider(
          create: (context) => UserProfileController(),
          child: UserProfileView(),
        ),
      },
    );
  }
}
