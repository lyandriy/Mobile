import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AppWeather());
}

class AppWeather extends StatelessWidget {
  const AppWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherPage(),
    );
  }
}

class City {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;

  City({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json["name"],
      country: json["country"] ?? "",
      region: json["admin1"] ?? "",
      latitude: json["latitude"].toDouble(),
      longitude: json["longitude"].toDouble(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> pages = [
    "Currently",
    "Today",
    "Weekly",
  ];

  final TextEditingController _controller = TextEditingController();

  String displayText = "";

  Position? position;
  String errorMessage = "";
  List<City> cities = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    useGeo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // BUSCADOR DE CIUDADES (Ejercicio 01)
  // ---------------------------------------------------------------

  // Se llama cada vez que el usuario escribe una letra en el campo.
  // Actualiza la lista `cities`, lo que hace aparecer el overlay
  // con las sugerencias.
  void onTypingChanged(String text) {
    searchCity();
  }

  // Busca ciudades en la API de Geocoding de Open-Meteo
  // y guarda el resultado en `cities`.
  Future<void> searchCity() async {
    String city = _controller.text;

    if (city.isEmpty) {
      setState(() {
        cities = [];
      });
      return;
    }

    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=5",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("API error");
      }

      final data = jsonDecode(response.body);

      if (data["results"] == null) {
        setState(() {
          cities = [];
          errorMessage = "City not found";
        });
        return;
      }

      // Convertimos cada elemento del JSON en un objeto City
      List<City> foundCities = (data["results"] as List)
          .map((item) => City.fromJson(item))
          .toList();

      setState(() {
        cities = foundCities;
        errorMessage = "";
      });
    } catch (e) {
      setState(() {
        cities = [];
        errorMessage = "Connection error, please try again later";
      });
    }
  }

  // Se llama cuando el usuario toca una ciudad en la lista de sugerencias.
  void selectCity(City city) {
    setState(() {
      cities = [];
      _controller.text = city.name;
      displayText = "${city.name}, ${city.region}, ${city.country}";
      errorMessage = "";
    });
    // Próximamente (Ejercicio 02): aquí llamaremos a la API del clima
    // usando city.latitude y city.longitude
  }

  // Se llama al presionar el botón de buscar (icono de lupa).
  // Si hay resultados, usa directamente el primero sin mostrar la lista.
  void useSearch() async {
    setState(() {
      errorMessage = "";
    });

    await searchCity();

    if (cities.isNotEmpty) {
      selectCity(cities.first);
    }
  }

  // ---------------------------------------------------------------
  // GEOLOCALIZACIÓN (Ejercicio 00, ya lo tenías)
  // ---------------------------------------------------------------

  Future<void> useGeo() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        errorMessage = "GPS disabled";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage = "Location permissions are denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage =
            "Location permissions are permanently denied, we cannot request permissions.";
      });
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition();

    setState(() {
      position = currentPosition;
      displayText =
          "${currentPosition.latitude}, ${currentPosition.longitude}";
      errorMessage = "";
    });
  }

  // ---------------------------------------------------------------
  // INTERFAZ (UI)
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: onTypingChanged,
                decoration: const InputDecoration(
                  hintText: "Search city...",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: useSearch,
            ),
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: useGeo,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Capa de abajo: las 3 tabs de siempre
          TabBarView(
            controller: _tabController,
            children: pages.map((tab) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        displayText.isEmpty ? tab : "$tab\n$displayText",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),

          // Capa de arriba: lista de sugerencias.
          // Solo se muestra si `cities` tiene elementos.
          if (cities.isNotEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return ListTile(
                      title: Text(city.name),
                      subtitle: Text("${city.region}, ${city.country}"),
                      onTap: () {
                        selectCity(city);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.cloud), text: "Currently"),
            Tab(icon: Icon(Icons.today), text: "Today"),
            Tab(icon: Icon(Icons.calendar_view_week), text: "Weekly"),
          ],
        ),
      ),
    );
  }
}