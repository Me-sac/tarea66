import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caja de Herramientas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Herramientas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? gender;
  String? age;
  String? country;
  List<University> universities = [];
  String? weather;
  List<News> news = [];

  Future<String?> fetchGender(String name) async {
    final response = await http.get(Uri.parse('https://api.genderize.io/?name=$name'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['gender'];
    }
    return null;
  }

  Future<String?> fetchAge(String name) async {
    final response = await http.get(Uri.parse('https://api.agify.io/?name=$name'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final int age = data['age'];
      if (age < 30) {
        return 'Joven';
      } else if (age >= 30 && age < 60) {
        return 'Adulto';
      } else {
        return 'Anciano';
      }
    }
    return null;
  }

  Future<List<University>> fetchUniversities(String country) async {
    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<University> universities = [];
      for (var item in data) {
        universities.add(University(
          name: item['name'],
          domain: item['domains'][0],
          website: item['web_pages'][0],
        ));
      }
      return universities;
    }
    return [];
  }

  Future<String?> fetchWeather() async {
    final response = await http.get(Uri.parse('https://api.weather.com/search=$weather'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['weather'];
    }
    return null;
  }

  Future<List<News>> fetchNews() async {
    final response = await http.get(Uri.parse('https://listindiario.com/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<News> news = [];
      for (var item in data) {
        news.add(News(
          title: item['title'],
          summary: item['summary'],
          url: item['url'],
        ));
      }
      return news;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Image.asset('assets/caja.png'),
          const SizedBox(height: 16.0),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ingresa un nombre',
            ),
            onChanged: (value) async {
              final gender = await fetchGender(value);
              setState(() {
                this.gender = gender;
              });
            },
          ),
          if (gender != null)
            Text(
              gender == 'male' ? 'Azul' : 'Rosa',
              style: TextStyle(
                color: gender == 'male' ? Colors.blue : Colors.pink,
                fontSize: 24.0,
              ),
            ),
          const SizedBox(height: 16.0),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Edad',
              hintText: 'Ingresa un Tu edad',
            ),
            onChanged: (value) async {
              final age = await fetchAge(value);
              setState(() {
                this.age = age;
              });
            },
          ),
          if (age != null)
            Column(
              children: [
                Image.asset(
                  age == 'Joven'
                      ? 'assets/joven.webp'
                      : age == 'Adulto'
                      ? 'assets/adulto.jpg'
                      : 'assets/anciano.jpg',
                  width: 150.0,
                ),
                Text(
                  age!,
                  style: const TextStyle(fontSize: 24.0),
                ),
              ],
            ),
          const SizedBox(height: 16.0),
          TextField(
            decoration: const InputDecoration(
              labelText: 'País',
              hintText: 'Ingresa un país en inglés',
            ),
            onChanged: (value) async {
              final universities = await fetchUniversities(value);
              setState(() {
                this.universities = universities;
              });
            },
          ),
          if (universities.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: universities
                  .map(
                    (university) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nombre: ${university.name}'),
                    Text('Dominio: ${university.domain}'),
                    Text('Sitio web: ${university.website}'),
                    const SizedBox(height: 8.0),
                  ],
                ),
              )
                  .toList(),
            ),
          const SizedBox(height: 16.0),
          FutureBuilder<String?>(
            future: fetchWeather(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error al obtener el clima');
              } else {
                final weather = snapshot.data;
                return Text('Clima: $weather');
              }
            },
          ),
          const SizedBox(height: 16.0),
          Image.asset('assets/wordpress_logo.jpg'),
          const SizedBox(height: 16.0),
          FutureBuilder<List<News>>(
            future: fetchNews(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error al obtener las noticias');
              } else {
                final news = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: news!
                      .map(
                        (news) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Título: ${news.title}'),
                        Text('Resumen: ${news.summary}'),
                        Text('URL: ${news.url}'),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  )
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class University {
  final String name;
  final String domain;
  final String website;

  University({
    required this.name,
    required this.domain,
    required this.website,
  });
}

class News {
  final String title;
  final String summary;
  final String url;

  News({
    required this.title,
    required this.summary,
    required this.url,
  });
}
