import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agri_hope/ui/screens/home_screen.dart';
import 'package:agri_hope/ui/utils/app_color.dart';
import '../../../utils/dialog_utils.dart';

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
  final TextEditingController otpController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    email = args['email'];
    generatedOtp = args['generatedOtp'];
    password = args['password'];
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
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 50),
                  TextField(
                    controller: otpController,
                    decoration: const InputDecoration(labelText: 'Enter OTP'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 200),
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
                    child: const Text('Verify',
                        style: TextStyle(color: Colors.white)),
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
    if (otpController.text == generatedOtp) {
      _registerAccount();
    } else {
      _showOtpErrorDialog();
    }
  }

  void _registerAccount() async {
    DialogUtils.showLoading(context);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
        title: const Text('Success'),
        content: const Text('Account registered successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            },
            child: const Text('OK'),
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
        title: const Text('Invalid OTP'),
        content: const Text('The OTP you entered is incorrect.'),
        actions: [
          TextButton(
            onPressed: () {
              otpController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Re-enter OTP'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, 'register');
            },
            child: const Text('Re-register'),
          ),
        ],
      ),
    );
  }
}
