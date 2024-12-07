import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Center(
        child: Container(
          height: 500,
          width: 500,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.white , borderRadius: BorderRadius.circular(30)),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  children: [
                  const Spacer(),
              const Text("Log in With Your Account", style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold
              ),),
              const Spacer(flex: 2,),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: "Email"
                ),
                validator: (text) {
                  if (text == null || text
                      .trim()
                      .isEmpty) {
                    return "Empty Email are not Allowed";
                  }
                  final bool emailValid =
                  RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(text);
                  if (!emailValid) {
                    return "This Email is not Allowed";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                    labelText: "Password"
                ),
                validator: (text) {
                  if (text == null || text.length < 6) {
                    return "Please Enter Valid Password";
                  }
                  return null;
                },
              ),
              const Spacer(flex: 4,),
              ElevatedButton(onPressed: () {
                login();
              }, child: const Row(
                children: [
                  Text("Log In"),
                  Spacer(),
                  Icon(Icons.arrow_forward),
                ],
              )),
              const SizedBox(height: 10,),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RegisterScreen.routeName);
                },
                child: const Text("Don't have an Account? Sign Up Now",
                  textAlign: TextAlign.center,
                  style: TextStyle(decoration: TextDecoration.underline),),
              ),
              const Spacer(flex: 6,),
            ],
          ),
        ),
      ),),)
    ,
    );
  }

  Future<void> login() async {
    if(!formKey.currentState!.validate()) return;
    try {
      DialogUtils.showLoading(context);
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
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
