import 'package:agri_hope/ui/screens/ai_models/crop_recommendation_model_screen.dart';
import 'package:agri_hope/ui/widgets/model_card_widget.dart';
import 'package:agri_hope/ui/widgets/side_menu_widget.dart';
import 'package:agri_hope/ui/widgets/weather_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../modal/user_data.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "Home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserData>(context).username;
    return Scaffold(
      drawer: const SideMenuWidget(),
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text(
          "Agri Hope",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const WeatherWidget(),
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, CropRecommendationModelScreen.routeName);
                  },
                  child: ModelCardWidget(
                    imagePath: "assets/img/crop_icon.png",
                    modelName: "Crop Recommendation",
                    modelNumber: "Model 1",
                  ),
                ),
                SizedBox(width: 30,),
                // InkWell(
                //   onTap: (){},
                //   child: ModelCardWidget(
                //     imagePath: "assets/img/soil_fertile.png",
                //     modelName: "Soil Fertile",
                //     modelNumber: "Model 2",
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
