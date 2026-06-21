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
      country: json["country"],
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

  final TextEditingController _controller = TextEditingController();

  String locationText = "";
  String errorMessage = "";

  List<City> cities = [];

  Map<String, dynamic>? currentWeather;
  Map<String, dynamic>? hourlyWeather;
  Map<String, dynamic>? dailyWeather;

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

  String weatherDescription(int code) {
    if (code == 0) return "Clear sky";
    if (code == 1 || code == 2 || code == 3) return "Cloudy";
    if (code == 45 || code == 48) return "Fog";
    if (code >= 51 && code <= 67) return "Rain";
    if (code >= 71 && code <= 77) return "Snow";
    if (code >= 80 && code <= 82) return "Rain showers";
    if (code >= 95) return "Thunderstorm";
    return "Unknown";
  }

  Future<void> useSearch() async {
    if (_controller.text.isEmpty) {
      setState(() {
        cities = [];
      });
      return;
    }

    String city = _controller.text;

    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=5",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    List results = data["results"] ?? [];

    List<City> cityList = [];

    for (var item in results) {
      cityList.add(City.fromJson(item));
    }

    setState(() {
      cities = cityList;
    });
  }

  void selectCity(City city) {
    setState(() {
      _controller.text = city.name;
      cities = [];
      locationText = "${city.name}, ${city.region}, ${city.country}";
    });

    fetchWeather(city.latitude, city.longitude);
  }

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
        errorMessage = "Location permissions are permanently denied";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      locationText = "${position.latitude}, ${position.longitude}";
      errorMessage = "";
    });

    fetchWeather(position.latitude, position.longitude);
  }

  Future<void> fetchWeather(double latitude, double longitude) async {
    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=$latitude"
      "&longitude=$longitude"
      "&current=temperature_2m,weather_code,wind_speed_10m"
      "&hourly=temperature_2m,weather_code,wind_speed_10m"
      "&daily=weather_code,temperature_2m_max,temperature_2m_min"
      "&timezone=auto",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    setState(() {
      currentWeather = data["current"];
      hourlyWeather = data["hourly"];
      dailyWeather = data["daily"];
    });
  }

  Widget currentView() {
    if (currentWeather == null) {
      return const Center(child: Text("Loading..."));
    }

    return Center(
      child: Text(
        "Currently\n\n"
        "$locationText\n\n"
        "Temperature: ${currentWeather!["temperature_2m"]} °C\n"
        "Weather: ${weatherDescription(currentWeather!["weather_code"])}\n"
        "Wind: ${currentWeather!["wind_speed_10m"]} km/h",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }

  Widget todayView() {
    if (hourlyWeather == null) {
      return const Center(child: Text("Loading..."));
    }

    return ListView.builder(
      itemCount: 24,
      itemBuilder: (context, index) {
        String time = hourlyWeather!["time"][index];
        double temp = hourlyWeather!["temperature_2m"][index];
        int code = hourlyWeather!["weather_code"][index];
        double wind = hourlyWeather!["wind_speed_10m"][index];

        return ListTile(
          title: Text(time),
          subtitle: Text(
            "$temp °C - ${weatherDescription(code)} - $wind km/h",
          ),
        );
      },
    );
  }

  Widget weeklyView() {
    if (dailyWeather == null) {
      return const Center(child: Text("Loading..."));
    }

    return ListView.builder(
      itemCount: dailyWeather!["time"].length,
      itemBuilder: (context, index) {
        String date = dailyWeather!["time"][index];
        double minTemp = dailyWeather!["temperature_2m_min"][index];
        double maxTemp = dailyWeather!["temperature_2m_max"][index];
        int code = dailyWeather!["weather_code"][index];

        return ListTile(
          title: Text(date),
          subtitle: Text(
            "Min: $minTemp °C - Max: $maxTemp °C - ${weatherDescription(code)}",
          ),
        );
      },
    );
  }

  Widget pageContent(Widget view) {
    return Column(
      children: [
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        Expanded(child: view),
        if (cities.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: cities.length,
              itemBuilder: (context, index) {
                City city = cities[index];

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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: (text) {
                  useSearch();
                },
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
      body: TabBarView(
        controller: _tabController,
        children: [
          pageContent(currentView()),
          pageContent(todayView()),
          pageContent(weeklyView()),
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