import 'package:flutter/material.dart';
import '../models/current_weather.dart';
import '../models/hourly_weather.dart';
import '../models/daily_weather.dart';
import '../models/city.dart';

class CurrentWeatherWidget extends StatelessWidget {
  final CurrentWeather weather;
  final String description;
  final String location;

  const CurrentWeatherWidget({
    super.key,
    required this.weather,
    required this.location,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          getWeatherIcon(weather.weatherCode),
          size: 80,
        ),
    
        Text("Temperature: ${weather.temperature} °C"),
    
        Text("Weather: ${weather.weatherCode}"),
    
        Text("Wind: ${weather.windSpeed} km/h"),
      ],
    );
  }
}

class TodayWeatherWidget extends StatelessWidget {
  final List<HourlyWeather> todayWeather;

  const TodayWeatherWidget({
    super.key,
    required this.todayWeather,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todayWeather.length,
      itemBuilder: (context, index) {
        HourlyWeather hour = todayWeather[index];

        return ListTile(
          title: Text(hour.time),
          subtitle: Text(
            "Temperature: ${hour.temperature} °C\n"
            "Wind: ${hour.windSpeed} km/h",
          ),
        );
      },
    );
  }
}

class WeeklyWeatherWidget extends StatelessWidget {
  final List<DailyWeather> weeklyWeather;

  const WeeklyWeatherWidget({
    super.key,
    required this.weeklyWeather,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: weeklyWeather.length,
      itemBuilder: (context, index) {
        DailyWeather day = weeklyWeather[index];

        return ListTile(
          title: Text(day.date),
          subtitle: Text(
            "Min: ${day.minTemperature} °C\n"
            "Max: ${day.maxTemperature} °C\n"
            "Weather: ${day.weatherCode}",
          ),
        );
      },
    );
  }
}

IconData getWeatherIcon(int code) {
  switch (code) {
    case 0:
      return Icons.wb_sunny;

    case 1:
    case 2:
      return Icons.cloud_queue;

    case 3:
      return Icons.cloud;

    case 61:
      return Icons.grain;

    default:
      return Icons.help_outline;
  }
}