import 'package:flutter/material.dart';

class ModelCardWidget extends StatelessWidget {
  ModelCardWidget(
      {super.key, required this.modelNumber, required this.modelName, required this.imagePath});

  String imagePath;
  String modelNumber;
  String modelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 200,
      decoration: BoxDecoration(
          color: Colors.green, borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 150,
              width: 150,
            ),
            Spacer(),
            Text(
              modelNumber,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              modelName,
              style: TextStyle(fontSize: 24),
            )
          ],
        ),
      ),
    );
  }
}
