import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Modelo de Noticia
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Noticia>> noticiasFuture;

  @override
  void initState() {
    super.initState();
    noticiasFuture = getNoticias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noticias"),
        actions: const [
          IconButton(onPressed: null, icon: Icon(Icons.search)),
          IconButton(onPressed: null, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder(
              future: noticiasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  final noticias = snapshot.data!;
                  return buildNoticias(noticias);
                } else {
                  return const Text("No hay noticias disponibles");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Noticia>> getNoticias() async {
    const apiKey = 'TU_API_KEY_AQUI'; // ← Cambia esto por tu propia API Key
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=82f2d844a5a44e41aa93e1edd547ecb9');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok') {
        List articles = jsonData['articles'];
        return articles.map((e) => Noticia.fromJson(e)).toList();
      }
    }

    throw Exception("No se pudieron cargar las noticias");
  }

  Widget buildNoticias(List<Noticia> noticias) {
    return Expanded(
      child: ListView.separated(
        itemCount: noticias.length,
        itemBuilder: (BuildContext context, int index) {
          final noticia = noticias[index];

          return ListTile(
            title: Text(noticia.title),
            subtitle: Text(noticia.description),
            leading: noticia.urlToImage.isNotEmpty
                ? Image.network(
                    noticia.urlToImage,
                    width: 100,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image_not_supported),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final uri = Uri.parse(noticia.url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(thickness: 2),
      ),
    );
  }
}
