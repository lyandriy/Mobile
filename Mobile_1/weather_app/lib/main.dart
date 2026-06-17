import 'package:flutter/material.dart';

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
    Center(child:Text("Currently", style: TextStyle(fontSize: 24))),
    Center(child: Text("Today", style: TextStyle(fontSize: 24))),
    Center(child: Text("Weekly", style: TextStyle(fontSize: 24))),
  ];

  final TextEditingController _controller = TextEditingController();

  String displayText = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    });
  }

  void useGeo() {
    setState(() {
      displayText = "Geolocation";
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
                decoration: InputDecoracion(
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
            child: Text(
              desplayText.isEmpty
                ? tab.child.toString()
                : "${(tab as Center).child is Text ? (tab.child as Text).data : ''} - $displayText",
              style: const TextStyle(fontSize: 24),
            ),
          ),
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
