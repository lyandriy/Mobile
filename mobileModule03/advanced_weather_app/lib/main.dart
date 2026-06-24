import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'widgets/weather_widget.dart';
import 'models/current_weather.dart';
import 'models/hourly_weather.dart';
import 'models/city.dart';
import 'models/daily_weather.dart';

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
  List<HourlyWeather> todayWeather = [];
  List<DailyWeather> weeklyWeather = [];
  CurrentWeather? currentWeather;
  City? selectedCity;
  bool selectingCity = false;
  

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

    if (cities.isNotEmpty) {
      selectCity(cities[0]);
    }
    
  }

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return "Clear sky";

      case 1:
        return "Mainly clear";

      case 2:
        return "Partly cloudy";

      case 3:
        return "Overcast";

      case 61:
        return "Rain";

      default:
        return "Unknown";
    }
  }

  Future<void> getCurrentWeather(double latitude, double longitude) async {

    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=$latitude"
      "&longitude=$longitude"
      "&current=temperature_2m,weather_code,wind_speed_10m"
      "&hourly=temperature_2m,weather_code,wind_speed_10m"
      "&daily=weather_code,temperature_2m_max,temperature_2m_min"
      "&forecast_days=7",
    );
    try{
      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() {
          errorMessage = "Unable to get weather";
        });
        return;
      }

      final data = jsonDecode(response.body);

      List<HourlyWeather> hourlyList = [];

      List times = data["hourly"]["time"];
      List temperatures = data["hourly"]["temperature_2m"];
      List windSpeeds = data["hourly"]["wind_speed_10m"];
      List weatherCodes = data["hourly"]["weather_code"];

      for (int i = 0; i < 24; i++) {
        hourlyList.add(
          HourlyWeather(
            time: times[i],
            temperature: temperatures[i].toDouble(),
            windSpeed: windSpeeds[i].toDouble(),
            weatherCode: weatherCodes[i],
          ),
        );
      }

      List<DailyWeather> dailyList = [];

      List dates = data["daily"]["time"];
      List maxTemperatures = data["daily"]["temperature_2m_max"];
      List minTemperatures = data["daily"]["temperature_2m_min"];
      List dailyWeatherCodes = data["daily"]["weather_code"];

      for (int i = 0; i < dates.length; i++) {
        dailyList.add(
          DailyWeather(
            date: dates[i],
            maxTemperature: maxTemperatures[i].toDouble(),
            minTemperature: minTemperatures[i].toDouble(),
            weatherCode: dailyWeatherCodes[i],
          ),
        );
      }

      setState(() {
        currentWeather = CurrentWeather(
          temperature: data["current"]["temperature_2m"].toDouble(),
          windSpeed: data["current"]["wind_speed_10m"].toDouble(),
          weatherCode: data["current"]["weather_code"],
        );
        todayWeather = hourlyList;
        weeklyWeather = dailyList;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Connection error";
      });
    }
  }

  Future<void> searchCity() async {
    String city = _controller.text;

    final url = Uri.parse(
      "https://geocoding-api.open-meteo.com/v1/search?name=$city&count=5",
    );

    try{
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
    selectingCity = true;

    setState(() {
      selectedCity = city;
      displayText =
          "${city.name}, ${city.region}, ${city.country}";

      _controller.text = city.name;
      errorMessage = "";
      cities = [];
    });

    selectingCity = false;

    await getCurrentWeather(
      city.latitude,
      city.longitude,
    );
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

    await getCurrentWeather(
      currentPosition.latitude,
      currentPosition.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {

    String location = "Unknown location";

    if (selectedCity != null) {
      location =
          "${selectedCity!.name}, ${selectedCity!.region}, ${selectedCity!.country}";
    } else if (position != null) {
      location =
          "${position!.latitude}, ${position!.longitude}";
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
      
              const Icon(
                Icons.search,
                color: Colors.grey,
              ),
      
              const SizedBox(width: 8),

              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (text) {
                     if (!selectingCity) {
                      searchCity();
                     }
                  },
                  decoration: const InputDecoration(
                    hintText: "Search city...",
                    border: InputBorder.none,
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: pages.map((tab) {
            return SingleChildScrollView(
              child:  Column(
                children: [
                  const SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          displayText.isEmpty ? tab : "$tab\n$displayText",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24),
                        ),

                        if (tab == "Currently" && currentWeather != null)
                          CurrentWeatherWidget(
                            weather: currentWeather!,
                            location: location,
                            description: getWeatherDescription(
                              currentWeather!.weatherCode,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: cities.isNotEmpty
                        ? ListView.builder(
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
                          )
                        : tab == "Today" && todayWeather.isNotEmpty
                            ? TodayWeatherWidget(
                                todayWeather: todayWeather,
                                getDescription: getWeatherDescription,
                              )
                            : tab == "Weekly" && weeklyWeather.isNotEmpty
                                ? WeeklyWeatherWidget(
                                    weeklyWeather: weeklyWeather,
                                    getDescription: getWeatherDescription,
                                  )
                                : const SizedBox(),
                  ),
                ],
              ),
            );
          },).toList(),
        ),
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
}

