SizedBox(
  height: 240,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: LineChart(
      LineChartData(
        minX: 0,
        maxX: todayWeather.length - 1,

        gridData: const FlGridData(show: true),

        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white),
        ),

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
              interval: 3,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();

                if (index < 0 || index >= todayWeather.length) {
                  return const SizedBox();
                }

                String hour = todayWeather[index]
                    .time
                    .split("T")[1]
                    .substring(0, 2);

                return Text(
                  "$hour h",
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
            spots: todayWeather.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.temperature,
              );
            }).toList(),
            isCurved: true,
            barWidth: 4,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    ),
  ),
),