class Noticia {
  final String title;
  final String description;
  final String urlToImage;
  final String url;

  Noticia({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.url,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      urlToImage: json['urlToImage'] ?? '',
      url: json['url'] ?? '',
    );
  }
}