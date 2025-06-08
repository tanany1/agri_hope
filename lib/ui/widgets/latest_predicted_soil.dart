import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_color.dart';

class LatestPredictedSoil extends StatefulWidget {
  const LatestPredictedSoil({super.key});

  @override
  _LatestPredictedSoilState createState() => _LatestPredictedSoilState();
}

class _LatestPredictedSoilState extends State<LatestPredictedSoil> {
  String latestSoil = "No prediction available";
  double? latestConfidence;

  @override
  void initState() {
    super.initState();
    _loadLatestPrediction();
  }

  Future<void> _loadLatestPrediction() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      latestSoil = prefs.getString("latest_soil_type") ?? "No prediction available";
      latestConfidence = prefs.getDouble("latest_soil_confidence");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary1,
        borderRadius: BorderRadius.circular(50),
      ),
      width: 600,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Latest Predicted Soil Type",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Soil Type: $latestSoil",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Confidence: ${latestConfidence != null ? (latestConfidence! * 100).toStringAsFixed(2) : '--'}%",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.primary3,
            ),
          ),
        ],
      ),
    );
  }
}
