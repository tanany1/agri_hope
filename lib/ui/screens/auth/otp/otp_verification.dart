import 'package:agri_hope/ui/screens/home_screen.dart';
import 'package:flutter/material.dart';

class OTPVerification extends StatefulWidget {
  static const String routeName = "OTP";

  const OTPVerification({super.key});

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  late String email;
  late String generatedOtp;
  final TextEditingController otpController = TextEditingController();
  String errorText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    email = args['email'];
    generatedOtp = args['generatedOtp'];
  }

  void verifyOtp() {
    if (otpController.text == generatedOtp) {
      setState(() {
        errorText = 'OTP Verified!';
      });
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } else {
      setState(() {
        errorText = 'Invalid OTP!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(title: const Text('OTP Verification'),
        elevation: 20,
        centerTitle: true,
        backgroundColor: Colors.green,),
      body: Center(
        child: Container(
          height: 500,
          width: 500,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30)),
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
                ElevatedButton(onPressed: verifyOtp, child: const Text('Verify')),
                if (errorText.isNotEmpty)
                  Text(errorText,
                      style: TextStyle(
                          color: errorText == 'OTP Verified!'
                              ? Colors.green
                              : Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
