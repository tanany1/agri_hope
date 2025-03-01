import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_color.dart';

class LatestRecommendedCrop extends StatefulWidget {
  const LatestRecommendedCrop({super.key});

  @override
  _LatestRecommendedCropState createState() => _LatestRecommendedCropState();
}

class _LatestRecommendedCropState extends State<LatestRecommendedCrop> {
  String latestCrop = "No recommendation available";

  @override
  void initState() {
    super.initState();
    _loadLatestCrop();
  }

  Future<void> _loadLatestCrop() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedMessage = prefs.getString('last_result_message');

    setState(() {
      if (storedMessage != null) {
        latestCrop = storedMessage.replaceAll("We recommend you ", "");
      } else {
        latestCrop = "No recommendation available";
      }
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
            "Latest Recommended Crop",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            latestCrop,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary2,
            ),
          ),
        ],
      ),
    );
  }
}
