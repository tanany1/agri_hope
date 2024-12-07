import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String username;
  final String password;

  EmailService({required this.username, required this.password});

  Future<void> sendOtpEmail({
    required String recipientEmail,
    required String otp,
  }) async {
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Agri Hope App')
      ..recipients.add(recipientEmail)
      ..subject = 'Your OTP Code'
      ..text = 'Your OTP code is: $otp. This code is valid for 5 minutes.';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
    } on MailerException catch (e) {
      print('Message not sent: $e');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
      throw 'Failed to send email';
    }
  }
}
