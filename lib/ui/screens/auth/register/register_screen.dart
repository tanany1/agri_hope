import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../modal/user_data.dart';
import '../../../utils/app_color.dart';
import '../../../utils/dialog_utils.dart';
import '../otp/otp_verification.dart';
import '../services/email_services.dart';

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
  final EmailService emailService = EmailService(
    username: 'agriHope422@gmail.com',
    password: 'knjy lqvs hcjm pgrl',
  );

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
                    "Sign Up a New Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(flex: 2),
                  TextFormField(
                    cursorColor: AppColors.primary5,
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
                    cursorColor: AppColors.primary5,
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return "Empty Emails are not Allowed";
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
                        return "Please Enter a Valid Password";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    obscuringCharacter: "*",
                    controller: rePasswordController,
                    decoration: const InputDecoration(labelText: "Re-Password"),
                    validator: (text) {
                      if (text == null || text.length < 6) {
                        return "Please Enter a Valid Password";
                      }
                      if (text != passwordController.text) {
                        return "Passwords do not Match";
                      }
                      return null;
                    },
                  ),
                  const Spacer(flex: 4),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary2,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: registerAccount,
                      child: const Row(
                        children: [
                          Text("Create an Account" , style: TextStyle(color: Colors.white),),
                          Spacer(),
                          Icon(Icons.arrow_forward , color: Colors.white,),
                        ],
                      )),
                  const Spacer(flex: 6),
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
    DialogUtils.showLoading(context);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      DialogUtils.hideLoading(context);
      final String username = userNameController.text;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      Provider.of<UserData>(context, listen: false).setUsername(username);
      final String otp = generateOTP();
      await emailService.sendOtpEmail(
        recipientEmail: emailController.text,
        otp: otp,
      );
      Navigator.pushReplacementNamed(
        context,
        OTPVerification.routeName,
        arguments: {
          'email': emailController.text,
          'generatedOtp': otp,
        },
      );
    } on FirebaseAuthException catch (e) {
      DialogUtils.hideLoading(context);
      if (e.code == 'weak-password') {
        DialogUtils.showError(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        DialogUtils.showError(
            context, 'The account already exists for that email.');
      } else {
        DialogUtils.showError(
            context, 'Something went wrong. Please try again later.');
      }
    } catch (e) {
      DialogUtils.hideLoading(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  String generateOTP({int length = 6}) {
    final Random random = Random();
    String otp = '';
    for (int i = 0; i < length; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }
}
