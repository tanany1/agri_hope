import 'package:agri_hope/ui/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  final List<double> predefinedData = [50, 40, 30, 25.5, 65.3, 6.5 , 200];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, showModeSelectionDialog);
  }

  void showModeSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Select Mode"),
        content: const Text("Choose how to input data."),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary2,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Manual" , style:  TextStyle(color: Colors.white),),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary2,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              startAutomaticMode();
            },
            child: const Text("Automatic" , style:  TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void startAutomaticMode() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {});
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pop(context);
                fillAutomaticData();
              });
            });
            return AlertDialog(
              title: const Text("Connecting..."),
              content: const Text("Connecting to hardware..."),
            );
          },
        );
      },
    );
  }

  void fillAutomaticData() {
    setState(() {
      nController.text = predefinedData[0].toString();
      pController.text = predefinedData[1].toString();
      kController.text = predefinedData[2].toString();
      tempController.text = predefinedData[3].toString();
      humidityController.text = predefinedData[4].toString();
      phController.text = predefinedData[5].toString();
      rainfallController.text = predefinedData[6].toString();
    });
  }

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
        surfaceTintColor: AppColors.primary1,
        title: const Text("Crop Recommendation"),
        content: Text(message),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(AppColors.primary2),
              foregroundColor: WidgetStateProperty.all<Color>(AppColors.white),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Agri Hope",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25) , color: AppColors.primary2,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Model 1", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("Crop Recommendation", style: TextStyle(color: AppColors.primary4 , fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.article_outlined, size: 40, color: AppColors.white),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 5,
                crossAxisSpacing: 25,
                mainAxisSpacing: 15,
                children: [
                  buildTextField(nController, "N"),
                  buildTextField(pController, "P"),
                  buildTextField(kController, "K"),
                  buildTextField(humidityController, "Humidity"),
                  buildTextField(phController, "PH"),
                  buildTextField(tempController, "Temp"),
                  buildTextField(rainfallController, "Rainfall"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: predictCrop,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary2,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Recommend", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primary1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
