import 'package:flutter/material.dart';
import '../utils/app_color.dart';

abstract class DialogUtils {
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primary1,
          content: Row(
            children: [
              Text(
                "Loading...",
                style: TextStyle(color: AppColors.black),
              ),
              const Spacer(),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary2),
              ),
            ],
          ),
        );
      },
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.primary1,
          title: Text(
            "Error",
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(color: AppColors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(color: AppColors.primary2),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showSuccess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.primary1,
          title: Text(
            "Success",
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(color: AppColors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(color: AppColors.primary2),
              ),
            ),
          ],
        );
      },
    );
  }
}