import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../widgets/chat_bot_widget.dart';
import '../widgets/side_menu_widget.dart';
import '../widgets/weather_widget.dart';
import 'all_models.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = "Home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenuWidget(),
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "AgriHope",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: AppColors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  const WeatherWidget(),
                  Container(
                    width: 1400,
                    height: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AllModels.routeName);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary5,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/img/Ai Models.png",
                                      height: 250,
                                      width: 250,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "AI Models",
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary1,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      width: 600,
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(20.0),
                                      child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Latest Used Model",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary4,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Crop Recommendation",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary1,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      width: 600,
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(20.0),
                                      child: const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Latest Recommended Crop",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary4,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Rice",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ChatBotIcon(),
        ],
      ),
    );
  }
}
