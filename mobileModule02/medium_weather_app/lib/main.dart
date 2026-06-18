import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

  final pages = [
    "Currently",
    "Today",
    "Weekly",
  ];

  final TextEditingController _controller = TextEditingController();

  String displayText = "";

  Position? position;
  String errorMessage = "";

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

  void useSearch() {
    setState(() {
      displayText = _controller.text;
      errorMessage = "";
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
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
}
