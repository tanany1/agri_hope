import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class FiveDayForecastScreen extends StatefulWidget {
  final String apiKey;
  static const String routeName="5day forecast";

  const FiveDayForecastScreen({required this.apiKey, super.key});

  @override
  State<FiveDayForecastScreen> createState() => _FiveDayForecastScreenState();
}

class _FiveDayForecastScreenState extends State<FiveDayForecastScreen> {
  WeatherFactory? weatherFactory;
  Map<String, Weather>? groupedForecast;

  @override
  void initState() {
    super.initState();
    weatherFactory = WeatherFactory(widget.apiKey);
    fetchFiveDayForecast();
  }

  Future<void> fetchFiveDayForecast() async {
    try {
      List<Weather> forecastList =
      await weatherFactory!.fiveDayForecastByCityName('Cairo');
      setState(() {
        groupedForecast = _groupForecastByDay(forecastList);
      });
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
    }
  }

  Map<String, Weather> _groupForecastByDay(List<Weather> forecastList) {
    final Map<String, Weather> dailyForecast = {};
    for (var weather in forecastList) {
      final dateString = weather.date?.toLocal().toString().split(' ')[0];
      if (dateString != null && !dailyForecast.containsKey(dateString)) {
        dailyForecast[dateString] = weather;
      }
    }
    return dailyForecast;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('5-Day Forecast'),
      ),
      body: groupedForecast == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8.0),
          children: groupedForecast!.entries.map((entry) {
            final date = entry.key;
            final weather = entry.value;

            return SizedBox(
              width: 250,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.weatherDescription?.toUpperCase() ??
                            'No Description',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${weather.temperature?.celsius?.toStringAsFixed(1) ?? '--'}°C",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.air,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Wind: ${weather.windSpeed?.toStringAsFixed(1) ?? '--'} m/s",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Image.asset(
                          "assets/img/weather.png",
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
