import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../modal/user_data.dart';
import '../../../utils/app_color.dart';
import '../../../utils/dialog_utils.dart';
import '../../home_screen.dart';
import '../register/register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    checkLoginState();
  }

  Future<void> checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "AgriHope",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Center(
        child: Container(
          height: 500,
          width: 500,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppColors.primary1, borderRadius: BorderRadius.circular(30)),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    "Log in With Your Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  TextFormField(
                    cursorColor: AppColors.primary5,
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return "Empty Email are not Allowed";
                      }
                      final bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(text);
                      if (!emailValid) {
                        return "This Email is not Allowed";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    cursorColor: AppColors.primary5,
                    obscureText: true,
                    obscuringCharacter: "*",
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (text) {
                      if (text == null || text.length < 6) {
                        return "Please Enter Valid Password";
                      }
                      return null;
                    },
                  ),
                  const Spacer(
                    flex: 4,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary2,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        login();
                      },
                      child: const Row(
                        children: [
                          Text("Log In" , style: TextStyle(color: Colors.white),),
                          Spacer(),
                          Icon(Icons.arrow_forward , color: Colors.white,),
                        ],
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, RegisterScreen.routeName);
                    },
                    child: const Text(
                      "Don't have an Account? Sign Up Now",
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                  SizedBox(height: 20,),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, HomeScreen.routeName);
                    },
                    child: const Text(
                      "Continue as A Guest",
                      textAlign: TextAlign.center,
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                  const Spacer(
                    flex: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    try {
      DialogUtils.showLoading(context);
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 'Guest';
      Provider.of<UserData>(context, listen: false).setUsername(username);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      Provider.of<UserData>(context, listen: false).setUsername(username);
      DialogUtils.hideLoading(context);
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } on FirebaseAuthException catch (e) {
      DialogUtils.hideLoading(context);
      if (e.code == 'user-not-found') {
        DialogUtils.showError(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        DialogUtils.showError(
            context, 'Wrong password provided for that user.');
      } else {
        DialogUtils.showError(
            context, 'Something Went Wrong,Please Try Again Later');
      }
    }
  }
}
