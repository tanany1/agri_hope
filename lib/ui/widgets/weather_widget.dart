import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

import '../utils/app_color.dart';
import '../widgets/5days_forecast_widget.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final String apiKey = 'cb17b0b03b1d59110c09ffa366d71224';
  WeatherFactory? weatherFactory;
  Weather? currentWeather;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    weatherFactory = WeatherFactory(apiKey);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          errorMessage = "Location services are disabled.";
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            errorMessage = "Location permission denied.";
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          errorMessage = "Location permission is permanently denied.";
        });
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to get location.";
        });
      }
    }
  }

  Future<void> fetchWeather(double latitude, double longitude) async {
    try {
      Weather weather =
          await weatherFactory!.currentWeatherByLocation(latitude, longitude);
      if (mounted) {
        setState(() {
          currentWeather = weather;
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Failed to retrieve weather data.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, FiveDayForecastScreen.routeName);
      },
      child: Container(
        width: 1400,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primary5,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: errorMessage != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          errorMessage = null;
                        });
                        _determinePosition();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary3,
                      ),
                    ),
                  ],
                )
              : currentWeather == null
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentWeather!.areaName ?? "Unknown Location",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${currentWeather!.temperature?.celsius?.toStringAsFixed(1) ?? '--'}°C",
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentWeather!.weatherDescription ?? "Clear Sky",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const Spacer(),
                        BoxedIcon(
                          _mapWeatherToIcon(
                              currentWeather!.weatherDescription ?? ''),
                          size: 80,
                          color: AppColors.primary1,
                        ),
                      ],
                    ),
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
