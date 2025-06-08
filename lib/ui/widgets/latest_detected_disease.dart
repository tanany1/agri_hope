import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_color.dart';

class LatestDetectedDisease extends StatefulWidget {
  const LatestDetectedDisease({super.key});

  @override
  _LatestDetectedDiseaseState createState() => _LatestDetectedDiseaseState();
}

class _LatestDetectedDiseaseState extends State<LatestDetectedDisease> {
  String detectedDisease = "No Detection available";
  double? latestConfidence;

  @override
  void initState() {
    super.initState();
    _loadLatestDetectedDisease();
  }

  Future<void> _loadLatestDetectedDisease() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      detectedDisease = prefs.getString("latest_detected_disease") ?? "No Detection available";
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
            "Latest Detected Disease",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Detected Disease: $detectedDisease",
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
