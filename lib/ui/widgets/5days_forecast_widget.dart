import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';
import '../utils/app_color.dart';

class FiveDayForecastScreen extends StatefulWidget {
  final String apiKey;
  static const String routeName = "5day forecast";

  const FiveDayForecastScreen({required this.apiKey, super.key});

  @override
  State<FiveDayForecastScreen> createState() => _FiveDayForecastScreenState();
}

class _FiveDayForecastScreenState extends State<FiveDayForecastScreen> {
  WeatherFactory? weatherFactory;
  Map<String, Weather>? groupedForecast;
  String locationMessage = "Fetching location...";

  @override
  void initState() {
    super.initState();
    weatherFactory = WeatherFactory(widget.apiKey);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Location permission denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = "Location permission is permanently denied.";
      });
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    fetchFiveDayForecast(position.latitude, position.longitude);
  }

  Future<void> fetchFiveDayForecast(double lat, double lon) async {
    try {
      List<Weather> forecastList =
          await weatherFactory!.fiveDayForecastByLocation(lat, lon);
      setState(() {
        groupedForecast = _groupForecastByDay(forecastList);
        locationMessage = "Forecast for your location";
      });
    } catch (e) {
      debugPrint('Error fetching forecast: $e');
      setState(() {
        locationMessage = "Failed to fetch weather data.";
      });
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: AppColors.primary3,
        centerTitle: true,
        title: const Text(
          '5-Day Forecast',
          style: TextStyle(color: AppColors.white),
        ),
      ),
      body: groupedForecast == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(locationMessage),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8.0),
                children: groupedForecast!.entries.map((entry) {
                  final date = entry.key;
                  final weather = entry.value;

                  return SizedBox(
                    width: 300,
                    child: Card(
                      color: AppColors.primary1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(25.0),
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
                              child: BoxedIcon(
                                _mapWeatherToIcon(
                                    weather.weatherDescription ?? ''),
                                size: 80,
                                color: AppColors.primary5,
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

  IconData _mapWeatherToIcon(String description) {
    description = description.toLowerCase();
    if (description.contains("clear")) {
      return WeatherIcons.day_sunny;
    } else if (description.contains("cloud")) {
      return WeatherIcons.cloud;
    } else if (description.contains("rain") || description.contains("shower")) {
      return WeatherIcons.rain;
    } else if (description.contains("snow")) {
      return WeatherIcons.snow;
    } else if (description.contains("thunder")) {
      return WeatherIcons.thunderstorm;
    } else if (description.contains("mist") || description.contains("fog")) {
      return WeatherIcons.fog;
    } else {
      return WeatherIcons.day_cloudy;
    }
  }
}
