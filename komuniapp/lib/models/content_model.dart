// Este archivo define el modelo de datos para el contenido educativo.

class Content {
  final String id;
  final String title;
  final String description;
  final String author;
  final String category;
  final String fileUrl;
  final String? userId;

  Content({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.category,
    required this.fileUrl,
    this.userId,
  });

  // Constructor para crear una instancia de Content desde un mapa JSON
  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'].toString(), // Asegura que el ID sea string
      title: json['title'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      fileUrl: json['file_url'] as String,
      userId: json['user_id'].toString(),
    );
  }

  // Método para convertir una instancia de Content a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'category': category,
      'file_url': fileUrl,
      'user_id': userId,
    };
  }
}
