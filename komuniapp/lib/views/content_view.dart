import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:komuniapp/controllers/content_controller.dart';
import 'package:komuniapp/controllers/login_controller.dart';
import 'package:komuniapp/models/content_model.dart';
import 'package:komuniapp/views/upload_content_view.dart';
import 'package:komuniapp/views/content_detail_view.dart';
import 'package:komuniapp/views/login_view.dart';

class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  _ContentViewState createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  final TextEditingController _searchController = TextEditingController();
  late LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = Provider.of<LoginController>(context, listen: false);

    _searchController.addListener(() {
      Provider.of<ContentController>(
        context,
        listen: false,
      ).filterContents(_searchController.text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Llama a fetchContents después de que la vista se haya construido
      Provider.of<ContentController>(context, listen: false).fetchContents();
    });
  }

  void _filterContent(String query) {
    Provider.of<ContentController>(
      context,
      listen: false,
    ).filterContents(query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentController = Provider.of<ContentController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[300],

      appBar: AppBar(
        title: const Text(
          'KomuniApp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white), //
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () async {
        //       await _loginController.logout(context);
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Busque contenido educativo',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _filterContent(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Buscar"),
                ),
              ],
            ),
          ),
          contentController.isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : contentController.errorMessage != null
              ? Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'VIEW: ${contentController.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: contentController.filteredContents.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron contenidos.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: contentController.filteredContents.length,
                          itemBuilder: (context, index) {
                            final content =
                                contentController.filteredContents[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    // <<-- ¡AQUÍ ESTÁ EL CAMBIO CLAVE! Usa un Row para el layout horizontal
                                    children: [
                                      Expanded(
                                        // <<-- Permite que la columna de texto ocupe el espacio disponible
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              content.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              content.category,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ), // Mantenemos este SizedBox para el espacio vertical
                                            Text(
                                              'Autor: ${content.author}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ), // Espacio horizontal entre el texto y el botón
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ContentDetailView(
                                                    content: content,
                                                  ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Ver Detalles'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.list_alt,
                color: Colors.white,
              ), // Nuevo icono: lista con verificación
              onPressed: () {
                Navigator.pushNamed(context, '/registered_contents');
              },
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, "/user_profile");
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/upload_contents");
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
