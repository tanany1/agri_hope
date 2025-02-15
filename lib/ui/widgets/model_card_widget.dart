import 'package:flutter/material.dart';

import '../utils/app_color.dart';

class ModelCardWidget extends StatelessWidget {
  ModelCardWidget(
      {super.key, required this.modelName, required this.imagePath});

  String imagePath;
  String modelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 150,
      height: 150,
      decoration: BoxDecoration(
          color: AppColors.primary5, borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              modelName,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary4),
            )
          ],
        ),
      ),
    );
  }
}
