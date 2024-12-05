import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
          color: Colors.red, borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              "Weather Widget",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
            ),
            Spacer(),
            Image.asset(
              "assets/img/weather.png",
            )
          ],
        ),
      ),
    );
  }
}
