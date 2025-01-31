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
      width: 100,
      height: 200,
      decoration: BoxDecoration(
          color: AppColors.primary5, borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 150,
              width: 150,
            ),
            SizedBox(height: 50,),
            Text(
              modelName,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold , color: AppColors.primary4),
            )
          ],
        ),
      ),
    );
  }
}
