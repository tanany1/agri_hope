import 'package:agri_hope/ui/screens/ai_models/crop_recommendation_model_screen.dart';
import 'package:agri_hope/ui/screens/ai_models/soil_type_model.dart';
import 'package:agri_hope/ui/screens/all_models.dart';
import 'package:agri_hope/ui/screens/auth/login/login_screen.dart';
import 'package:agri_hope/ui/screens/auth/otp/otp_verification.dart';
import 'package:agri_hope/ui/screens/auth/register/register_screen.dart';
import 'package:agri_hope/ui/screens/home_screen.dart';
import 'package:agri_hope/ui/screens/settings/settings_screen.dart';
import 'package:agri_hope/ui/screens/splash/splash_screen.dart';
import 'package:agri_hope/ui/widgets/5days_forecast_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'modal/user_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final userProvider = UserData();
  await userProvider.loadUsernameFromPreferences();

  runApp(
    ChangeNotifierProvider(
      create: (_) => userProvider,
      child: MyApp(),
    ),
  );
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        SplashScreen.routeName: (_) => const SplashScreen(),
        OTPVerification.routeName: (_) => const OTPVerification(),
        FiveDayForecastScreen.routeName: (_) => FiveDayForecastScreen(
              apiKey: 'cb17b0b03b1d59110c09ffa366d71224',
            ),
        SettingsScreen.routeName: (_) => SettingsScreen(),
        CropRecommendationModelScreen.routeName: (_) =>
            CropRecommendationModelScreen(),
        AllModels.routeName: (_) => AllModels(),
        SoilTypeModelScreen.routeName: (_) => SoilTypeModelScreen(),
      },
      initialRoute: SplashScreen.routeName,
      debugShowCheckedModeBanner: false,
    );
  }
}
