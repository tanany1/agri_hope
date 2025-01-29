import 'package:agri_hope/ui/widgets/model_card_widget.dart';
import 'package:flutter/material.dart';

import 'ai_models/crop_recommendation_model_screen.dart';


class AllModels extends StatelessWidget {
  static const String routeName = "All Models";
  const AllModels({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> models = [
      {
        "imagePath": "assets/img/crop_icon.png",
        "modelName": "Crop Recommendation",
        "modelNumber": "Model 1",
        "routeName": CropRecommendationModelScreen.routeName,
      },
      {
        "imagePath": "assets/img/soil_fertile.png",
        "modelName": "Soil Fertile",
        "modelNumber": "Model 2 (Coming Soon)",
        // "routeName": WeatherPredictionScreen.routeName,
      },
      {
        "imagePath": "assets/img/plant disease.png",
        "modelName": "Plant Disease Detection",
        "modelNumber": "Model 3 (Coming Soon)",
        // "routeName": DiseaseDetectionScreen.routeName,
      },
      {
        "imagePath": "assets/img/soil type.png",
        "modelName": "Soil Type Analysis",
        "modelNumber": "Model 4 (Coming Soon)",
        // "routeName": SoilAnalysisScreen.routeName,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Agri Hope",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: models.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 25,
            crossAxisSpacing: 25,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final model = models[index];
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, model["routeName"]!);
              },
              child: ModelCardWidget(
                imagePath: model["imagePath"]!,
                modelName: model["modelName"]!,
                modelNumber: model["modelNumber"]!,
              ),
            );
          },
        ),
      ),
    );
  }
}
