import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropRecommendationModelScreen extends StatefulWidget {
  static const String routeName = "crop Recommendation Model";

  const CropRecommendationModelScreen({super.key});

  @override
  _CropRecommendationModelScreenState createState() =>
      _CropRecommendationModelScreenState();
}

class _CropRecommendationModelScreenState
    extends State<CropRecommendationModelScreen> {
  final TextEditingController nController = TextEditingController();
  final TextEditingController pController = TextEditingController();
  final TextEditingController kController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController phController = TextEditingController();
  final TextEditingController rainfallController = TextEditingController();

  Future<void> predictCrop() async {
    final Uri apiUrl = Uri.parse("http://127.0.0.1:5000/croprecommendation");

    final response = await http.post(
      apiUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "N": double.parse(nController.text),
        "P": double.parse(pController.text),
        "K": double.parse(kController.text),
        "temperature": double.parse(tempController.text),
        "humidity": double.parse(humidityController.text),
        "ph": double.parse(phController.text),
        "rainfall": double.parse(rainfallController.text),
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      showResultDialog(result["message"]);
    } else {
      showResultDialog("Error: Unable to fetch prediction");
    }
  }

  void showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Crop Recommendation"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crop Recommendation Model",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.grey,
          ),
          width: 800,
          height: 700,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: GridView(
                  children: [
                    buildTextField(nController, "N"),
                    buildTextField(pController, "P"),
                    buildTextField(kController, "K"),
                    buildTextField(tempController, "Temperature"),
                    buildTextField(humidityController, "Humidity"),
                    buildTextField(phController, "PH"),
                    buildTextField(rainfallController, "Rainfall"),
                  ],
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    mainAxisExtent: 60,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: predictCrop,
                  child: Text(
                    "Predict",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 16),
    );
  }
}
