import 'package:agri_hope/ui/widgets/latest_predicted_soil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../utils/app_color.dart';
import '../widgets/chat_bot_widget.dart';
import '../widgets/latest_recommended_crop.dart';
import '../widgets/latest_used_model.dart';
import '../widgets/side_menu_widget.dart';
import '../widgets/weather_widget.dart';
import 'all_models.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "Home";
  final bool shouldRefresh;

  const HomeScreen({super.key, this.shouldRefresh = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }
  bool shouldRefresh = false;

  @override
  void didPopNext() {
    setState(() {
      shouldRefresh = !shouldRefresh;
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<String?> _getLastUsedModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_used_model');
  }

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
            color: AppColors.white,
          ),
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
                  SizedBox(
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
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: LastUsedModelWidget(
                                    key: ValueKey(shouldRefresh),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  flex: 1,
                                  child: FutureBuilder<String?>(
                                    future: _getLastUsedModel(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      String? lastUsedModel = snapshot.data;
                                      if (lastUsedModel == "Crop Recommendation") {
                                        return const LatestRecommendedCrop();
                                      } else if (lastUsedModel == "Soil Type Analysis") {
                                        return const LatestPredictedSoil();
                                      } else {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary1,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          width: 600,
                                          margin: const EdgeInsets.all(10),
                                          padding: const EdgeInsets.all(20.0),
                                          child: const Center(
                                            child: Text(
                                              "No model used recently",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary4,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  )

                                ),

                              ],
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
