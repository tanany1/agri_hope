import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../modal/user_data.dart';
import '../../../utils/app_color.dart';
import '../../../utils/dialog_utils.dart';
import '../../home_screen.dart';
import '../services/email_services.dart';

class OTPVerification extends StatefulWidget {
  static const String routeName = "OTP";

  const OTPVerification({super.key});

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  late String email;
  late String generatedOtp;
  late String password;
  late String username;
  final TextEditingController otpController = TextEditingController();
  final EmailService emailService = EmailService(
    username: 'agriHope422@gmail.com',
    password: 'knjy lqvs hcjm pgrl',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    email = args['email'];
    generatedOtp = args['generatedOtp'];
    password = args['password'];
    username = args['username'];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'OTP Verification',
            style: TextStyle(color: Colors.white),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'An OTP has been sent to $email',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: AppColors.primary5,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: resendOtp,
                    child: const Text(
                      "Didn't receive OTP? Resend OTP",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 150),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary2,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: verifyOtp,
                    child: const Text(
                      'Verify',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void verifyOtp() {
    if (otpController.text.trim() == generatedOtp) {
      _registerAccount();
    } else {
      _showOtpErrorDialog();
    }
  }

  Future<void> resendOtp() async {
    DialogUtils.showLoading(context);
    try {
      // Reuse the existing generatedOtp instead of creating a new one
      await emailService.sendOtpEmail(
        recipientEmail: email,
        otp: generatedOtp,
      );
      DialogUtils.hideLoading(context);
      DialogUtils.showSuccess(context, 'OTP resent to $email');
      otpController.clear(); // Clear input field for user to re-enter
    } catch (e) {
      DialogUtils.hideLoading(context);
      DialogUtils.showError(context, 'Failed to resend OTP. Please try again.');
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

  Future<void> _registerAccount() async {
    DialogUtils.showLoading(context);
    try {
      // Create user in Firebase Auth
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save user data locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('email', email);
      await prefs.setString('uid', credential.user!.uid);
      await prefs.setBool('isLoggedIn', true);

      Provider.of<UserData>(context, listen: false).setUsername(username);

      DialogUtils.hideLoading(context);
      _showSuccessDialog();
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
      DialogUtils.showError(context, 'Registration failed. Please try again.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary1,
        title: Text(
          'Success',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Account registered successfully!',
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            },
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.primary2),
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primary1,
        title: Text(
          'Invalid OTP',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'The OTP you entered is incorrect.',
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              otpController.clear();
              Navigator.of(context).pop();
            },
            child: Text(
              'Re-enter OTP',
              style: TextStyle(color: AppColors.primary2),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'register');
            },
            child: Text(
              'Re-register',
              style: TextStyle(color: AppColors.primary2),
            ),
          ),
        ],
      ),
    );
  }
}