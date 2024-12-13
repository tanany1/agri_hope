import 'package:agri_hope/ui/screens/auth/login/login_screen.dart';
import 'package:agri_hope/ui/screens/auth/otp/otp_verification.dart';
import 'package:agri_hope/ui/screens/auth/register/register_screen.dart';
import 'package:agri_hope/ui/screens/home_screen.dart';
import 'package:agri_hope/ui/screens/splash/splash_screen.dart';
import 'package:agri_hope/ui/widgets/5days_forecast_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        SplashScreen.routeName: (_) => const SplashScreen(),
        OTPVerification.routeName:(_)=> const OTPVerification(),
        FiveDayForecastScreen.routeName:(_)=> FiveDayForecastScreen(apiKey: 'cb17b0b03b1d59110c09ffa366d71224',)
      },
      initialRoute: SplashScreen.routeName,
      debugShowCheckedModeBanner: false,
    );
  }

}
