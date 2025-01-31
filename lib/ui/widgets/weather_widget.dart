import 'package:agri_hope/ui/utils/app_color.dart';
import 'package:agri_hope/ui/widgets/5days_forecast_widget.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final String apiKey = 'cb17b0b03b1d59110c09ffa366d71224';
  final String ipApiUrl = 'http://ip-api.com/json/';
  WeatherFactory? weatherFactory;
  Weather? currentWeather;

  @override
  void initState() {
    super.initState();
    weatherFactory = WeatherFactory(apiKey);
    fetchLocationAndWeather();
  }

  Future<void> fetchLocationAndWeather() async {
    try {
      final response = await http.get(Uri.parse(ipApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        double lat = data['lat'];
        double lon = data['lon'];
        String city = data['city'];
        Weather weather =
            await weatherFactory!.currentWeatherByLocation(lat, lon);
        setState(() {
          currentWeather = weather;
        });
      } else {
        throw Exception('Failed to fetch location');
      }
    } catch (e) {
      debugPrint('Error fetching location or weather: $e');
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
          child: currentWeather == null
              ? Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentWeather!.areaName ?? "Unknown Location",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${currentWeather!.temperature?.celsius?.toStringAsFixed(1) ?? '--'}°C",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 8),
                        Text(
                          currentWeather!.weatherDescription ?? "Clear Sky",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Spacer(),
                    Image.asset(
                      "assets/img/weather.png",
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
