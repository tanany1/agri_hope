import 'package:agri_hope/ui/screens/ai_models/crop_recommendation_model_screen.dart';
import 'package:agri_hope/ui/screens/all_models.dart';
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
            Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AllModels.routeName);
                        },
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            height: MediaQuery.of(context).size.height * 0.5,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                ),
                                Image.asset(
                                  "assets/img/Ai Models (2).png",
                                  height: 200,
                                  width: 200,
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                Text("AI Models",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.42,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Latest Used Model",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text("Crop Recommendation" , style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400 , color: Colors.white),),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.42,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Text(
                                  "Latest Recommended Crop",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold),
                                ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text("Rice" ,style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400 , color: Colors.white),),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
