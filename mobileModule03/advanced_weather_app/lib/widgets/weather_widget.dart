import 'package:flutter/material.dart';
import '../models/current_weather.dart';
import '../models/hourly_weather.dart';
import '../models/daily_weather.dart';
import '../models/city.dart';
import 'package:fl_chart/fl_chart.dart';

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
        Text(
          location,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

      const SizedBox(height: 20),

      Icon(
        getWeatherIcon(weather.weatherCode),
        size: 80,
      ),

      Text(
        "${weather.temperature} °C",
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),

      Text("Weather: $description"),

      Text("Wind: ${weather.windSpeed} km/h"),
      ],
    );
  }
}

class TodayWeatherWidget extends StatelessWidget {
  final List<HourlyWeather> todayWeather;
  final String Function(int) getDescription;

  const TodayWeatherWidget({
    super.key,
    required this.todayWeather,
     required this.getDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: todayWeather.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      entry.value.temperature,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: todayWeather.length,
            itemBuilder: (context, index) {
              HourlyWeather hour = todayWeather[index];
              String time = hour.time.split("T")[1];

              return ListTile(
                title: Text(
                  "${time}  | "
                  "Temperature: ${hour.temperature} °C  | "
                  "Weather: ${getDescription(hour.weatherCode)} | "
                  "Wind: ${hour.windSpeed} km/h",
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class WeeklyWeatherWidget extends StatelessWidget {
  final List<DailyWeather> weeklyWeather;
  final String Function(int) getDescription;

  const WeeklyWeatherWidget({
    super.key,
    required this.weeklyWeather,
    required this.getDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Column(
            children: [
              const Text(
                "Weekly temperatures",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: true),

                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();

                            if (index < 0 || index >= weeklyWeather.length) {
                              return const Text("");
                            }

                            return Text(
                              weeklyWeather[index].date.substring(5),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                        ),
                      ),
                    ),

                    lineBarsData: [
                      LineChartBarData(
                        spots: weeklyWeather.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.maxTemperature,
                          );
                        }).toList(),
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),

                      LineChartBarData(
                        spots: weeklyWeather.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            entry.value.minTemperature,
                          );
                        }).toList(),
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: weeklyWeather.length,
            itemBuilder: (context, index) {
              DailyWeather day = weeklyWeather[index];

              return ListTile(
                title: Text(
                  "${day.date} | "
                  "Min: ${day.minTemperature} °C | "
                  "Max: ${day.maxTemperature} °C | "
                  "Weather: ${getDescription(day.weatherCode)}",
                ),
              );
            },
          ),
        ),
      ],
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