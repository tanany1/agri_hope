import 'package:agri_hope/ui/utils/dialog_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = "register";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController userNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController rePasswordController = TextEditingController();
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
          color: Colors.white,
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    "Sign Up a New Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  TextFormField(
                    controller: userNameController,
                    decoration: const InputDecoration(labelText: "User Name"),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return "Please Enter a Valid Name";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
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
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (text) {
                      if (text == null || text.length < 6) {
                        return "Please Enter Valid Password";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: rePasswordController,
                    decoration: const InputDecoration(labelText: "Re-Password"),
                    validator: (text) {
                      if (text == null || text.length < 6) {
                        return "Please Enter Valid Password";
                      }
                      if (text != passwordController.text) {
                        return "Passwords does not Match";
                      }
                      return null;
                    },
                  ),
                  const Spacer(
                    flex: 4,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        registerAccount();
                      },
                      child: const Row(
                        children: [
                          Text("Create an Account"),
                          Spacer(),
                          Icon(Icons.arrow_forward),
                        ],
                      )),
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

  void registerAccount() async {
    if (!formKey.currentState!.validate()) return;
    try {
      DialogUtils.showLoading(context);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      DialogUtils.hideLoading(context);
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    } on FirebaseAuthException catch (e) {
      DialogUtils.hideLoading(context);
      if (e.code == 'weak-password') {
        DialogUtils.showError(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        DialogUtils.showError(
            context, 'The account already exists for that email.');
      } else {
        DialogUtils.showError(
            context, 'Something Went Wrong,Please Try Again Later');
      }
    }
  }
}
