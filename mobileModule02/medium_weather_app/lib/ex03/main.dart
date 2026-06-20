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

  factory City.fromJson(Map<String,dynamic> json) {
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
  Map<String, dynamic>? weatherData;

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

  Future<void> useSearch() async{
    setState(() {
      errorMessage = "";
    });

    if (_controller.text.isEmpty) {
      setState(() {
        cities = [];
      });
      return;
    }

    await searchCity();
    
  }

  Future<void> searchCity() async {
    try 
      String city = _controller.text;

      final url = Uri.parse(
        "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=5",
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = "Unable to search city";
        });
        return;
      }

      final data = jsonDecode(response.body);

      List results = data["results"] ?? [];

      if (results.isEmpty) {
        setState(() {
          errorMessage = "City not found";
          cities = [];
        });
        return;
      }

      List<City> cityList = [];

      for (var city in results) {
        cityList.add(City.fromJson(city));
      }

      setState(() {
        cities = cityList;
        errorMessage = "";
      });
    } catch (e) {
      setState(() {
        errorMessage = "Connection error";
      });
    }
  }

  void selectCity(City city) async {
    _controller.text = city.name;

    cities = [];

    displayText =
        "${city.name}, ${city.region}, ${city.country}";

    await getWeather(
      city.latitude,
      city.longitude,
    );

    setState(() {});
}

  Future<void> useGeo() async {

    //ver si esta disponible GPS
    if (!await Geolocator.isLocationServiceEnabled()) {
      setState(() {
        errorMessage = "GPS disabled";
      });
      return;
    }

    //revisar si tenemos permisos para usarlo y tipo de denegacion
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
        errorMessage = "Location permissions are permanently denied, we cannot request permissions.";
      });
      return;
    } 

    //pedir posicion si nos dan permisos
    Position currentPosition =  await Geolocator.getCurrentPosition();

    setState(() {
      position = currentPosition;
      displayText = "${currentPosition.latitude}, ${currentPosition.longitude}";
      errorMessage = "";
    });
  }

  Future<void> getWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
        "https://api.open-meteo.com/v1/forecast"
        "?latitude=$lat"
        "&longitude=$lon"
        "&current=temperature_2m,wind_speed_10m,weather_code"
        "&hourly=temperature_2m,wind_speed_10m,weather_code"
        "&daily=temperature_2m_max,temperature_2m_min,weather_code"
        "&forecast_days=7",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
        });
      }
    } catch (e) {
      setState(() {
        errorMessage= "Connection error";
      });
    }
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
        children: pages.map((tab) {
          return Column(
            children: [
              currentView(),
              todayView(),
              weeklyView(),
            ],
          );
        },).toList(),
      ),

      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: _tabController,
          tabs: const[
            Tab(icon: Icon(Icons.cloud), text: "Currently"),
            Tab(icon: Icon(Icons.today), text: "Today"),
            Tab(icon: Icon(Icons.calendar_view_week), text: "Weekly"),
          ],
        ),
      ),
    );
  }

  Widget currentView() {
    if (weatherData == null) {
      return const Center(
        child: Text("No weather data"),
      );
    }

    final current = weatherData!["current"];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(displayText),
        Text("Temp: ${current["temperature_2m"]} °C"),
        Text("Wind: ${current["wind_speed_10m"]} km/h"),
        Text("Code: ${current["weather_code"]}"),
      ],
    );
  }

  Widget todayView() {
    if (weatherData == null) {
      return const Center(
        child: Text("No weather data"),
      );
    }

    final hourly = weatherData!["hourly"];

    return ListView.builder(
      itemCount: 24,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(hourly["time"][index]),
          subtitle: Text(
            "Temp: ${hourly["temperature_2m"][index]} °C"
            " | Wind: ${hourly["wind_speed_10m"][index]} km/h"
            " | Code: ${hourly["weather_code"][index]}",
          ),
        );
      },
    );
  }

  Widget weeklyView() {
    if (weatherData == null) {
      return const Center(
        child: Text("No weather data"),
      );
    }

    final daily = weatherData!["daily"];

    return ListView.builder(
      itemCount: daily["time"].length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(daily["time"][index]),
          subtitle: Text(
            "Min: ${daily["temperature_2m_min"][index]} °C"
            " | Max: ${daily["temperature_2m_max"][index]} °C"
            " | Code: ${daily["weather_code"][index]}",
          ),
        );
      },
    );
  }
}
