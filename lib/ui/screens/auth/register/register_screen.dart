import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
              color: AppColors.primary1,
              borderRadius: BorderRadius.circular(30)),
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    "Sign Up a New Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(flex: 2),
                  TextFormField(
                    cursorColor: AppColors.primary1,
                    controller: userNameController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: "UserName",
                      filled: true,
                      fillColor: AppColors.primary5,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (text) {
                      if (text == null || text.trim().isEmpty) {
                        return "Please Enter a Valid Name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    cursorColor: AppColors.primary1,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: "Email",
                      filled: true,
                      fillColor: AppColors.primary5,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                  const SizedBox(height: 20),
                  TextFormField(
                    cursorColor: AppColors.primary1,
                    obscureText: !_isPasswordVisible,
                    obscuringCharacter: "*",
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: "Password",
                      filled: true,
                      fillColor: AppColors.primary5,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (text) {
                      if (text == null || text.length < 8) {
                        return "Please Enter a Valid Password";
                      }
                      final bool passwordValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]")
                          .hasMatch(text);
                      if (!passwordValid) {
                        return "This Password is not Allowed";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    cursorColor: AppColors.primary1,
                    obscureText: !_isRePasswordVisible,
                    obscuringCharacter: "*",
                    controller: rePasswordController,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.white),
                      labelText: "Re-Password",
                      filled: true,
                      fillColor: AppColors.primary5,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isRePasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isRePasswordVisible = !_isRePasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (text) {
                      if (text == null || text.length < 8) {
                        return "Please Enter a Valid Password";
                      }
                      final bool passwordValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]")
                          .hasMatch(text);
                      if (!passwordValid) {
                        return "This Password is not Allowed";
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: registerAccount,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Create an Account",
                          style: TextStyle(color: AppColors.white),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
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
      // Save password to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('password', passwordController.text);

      // Generate OTP
      final String otp = generateOTP();
      await emailService.sendOtpEmail(
        recipientEmail: emailController.text,
        otp: otp,
      );
      DialogUtils.hideLoading(context);
      DialogUtils.showSuccess(
          context, 'OTP sent to ${emailController.text}. Please verify.');

      Navigator.pushNamed(
        context,
        OTPVerification.routeName,
        arguments: {
          'email': emailController.text,
          'generatedOtp': otp,
          'password': passwordController.text,
          'username': userNameController.text,
        },
      );
    } catch (e) {
      DialogUtils.hideLoading(context);
      DialogUtils.showError(
          context, 'Failed to send OTP. Please try again. Error: $e');
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