import 'package:agri_hope/ui/screens/ai_models/soil_type_model.dart';
import 'package:agri_hope/ui/widgets/model_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_color.dart';
import 'ai_models/crop_recommendation_model_screen.dart';
import 'ai_models/plant_diseases_model.dart';

class AllModels extends StatelessWidget {
  static const String routeName = "All Models";

  Future<void> saveModelName(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_used_model', modelName);
  }
  const AllModels({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> models = [
      {
        "imagePath": "assets/img/crop_icon.png",
        "modelName": "Crop Recommendation",
        "routeName": CropRecommendationModelScreen.routeName,
      },
      {
        "imagePath": "assets/img/soil type.png",
        "modelName": "Soil Type Analysis",
        "routeName": SoilTypeModelScreen.routeName,
      },
      {
        "imagePath": "assets/img/plant disease.png",
        "modelName": "Plant Disease Detection",
        "routeName": PlantDiseasesDetectionModelScreen.routeName,
      },
      // {
      //   "imagePath": "assets/img/soil_fertile.png",
      //   "modelName": "Soil Fertile (Coming Soon)",
      //   // "routeName": WeatherPredictionScreen.routeName,
      // },
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "AgriHope",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary3,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 900,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: models.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final model = models[index];
                return InkWell(
                  onTap:  () async {
                    await saveModelName(model["modelName"]!);
                    Navigator.pushNamed(context, model["routeName"]!);
                  },
                  child: ModelCardWidget(
                    imagePath: model["imagePath"]!,
                    modelName: model["modelName"]!,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
