import 'package:agri_hope/ui/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

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
  final TextEditingController landNameController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  final List<double> predefinedData = [48.73, 38.42, 27.81, 23.57, 62.00121];
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args.containsKey('prefilledData')) {
        final data = args['prefilledData'] as Map<String, dynamic>;
        nController.text = data['N'].toString();
        pController.text = data['P'].toString();
        kController.text = data['K'].toString();
        tempController.text = data['temperature'].toString();
        humidityController.text = data['humidity'].toString();
      } else {
        showModeSelectionDialog();
      }
    });
  }

  void showModeSelectionDialog() {
    if (!mounted) return;
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
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Manual", style: TextStyle(color: Colors.white)),
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
              if (mounted) Navigator.pop(context);
              startAutomaticMode();
            },
            child: const Text("Automatic", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void startAutomaticMode() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Connecting..."),
          content: const Text("Connecting to hardware..."),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
      fillAutomaticData();
    });
  }

  void fillAutomaticData() {
    if (!mounted) return;
    setState(() {
      nController.text = predefinedData[0].toString();
      pController.text = predefinedData[1].toString();
      kController.text = predefinedData[2].toString();
      tempController.text = predefinedData[3].toString();
      humidityController.text = predefinedData[4].toString();
    });
  }

  Future<void> predictCrop() async {
    final Uri apiUrl = Uri.parse("http://127.0.0.1:5000/croprecommendation");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "N": double.tryParse(nController.text) ?? 0.0,
          "P": double.tryParse(pController.text) ?? 0.0,
          "K": double.tryParse(kController.text) ?? 0.0,
          "temperature": double.tryParse(tempController.text) ?? 0.0,
          "humidity": double.tryParse(humidityController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        await saveResultMessage(result["message"]);
        showResultDialog(result["message"]);
      } else {
        showResultDialog("Error: Unable to fetch prediction");
      }
    } catch (e) {
      showResultDialog("Error: Unable to fetch prediction");
    }
  }

  Future<void> saveResultMessage(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_result_message', message);
  }

  Future<void> saveMeasurementToDatabase() async {
    final existingLandNames = <String>{}; // Set to avoid duplicates
    try {
      final querySnapshot = await _firestore.collection('measurements').get();
      for (var doc in querySnapshot.docs) {
        existingLandNames.add(doc['land_name'] as String);
      }
    } catch (e) {
      // Handle error silently
    }

    bool useExisting = true; // Toggle between existing and new name

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Save Measurement"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("Choose Existing"),
                      value: true,
                      groupValue: useExisting,
                      onChanged: (value) {
                        setState(() {
                          useExisting = value ?? true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text("New Name"),
                      value: false,
                      groupValue: useExisting,
                      onChanged: (value) {
                        setState(() {
                          useExisting = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (useExisting && existingLandNames.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Land Name",
                    hintText: "Select a land name",
                  ),
                  value: landNameController.text.isNotEmpty
                      ? landNameController.text
                      : null,
                  items: existingLandNames.map((landName) {
                    return DropdownMenuItem<String>(
                      value: landName,
                      child: Text(landName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      landNameController.text = value;
                    }
                  },
                ),
              if (!useExisting || existingLandNames.isEmpty)
                TextField(
                  controller: landNameController,
                  decoration: const InputDecoration(
                    labelText: "Land Name",
                    hintText: "Enter a name for this land",
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: "Tag",
                  hintText: "Enter a tag for this measurement (optional)",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (landNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Land name is required")),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    ).then((value) async {
      if (value != true) return;

      if (landNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Land name is required")),
        );
        return;
      }

      final tag = tagController.text.isNotEmpty
          ? tagController.text
          : "Tag-${const Uuid().v4().substring(0, 6)}";

      try {
        final data = {
          'land_name': landNameController.text,
          'tag': tag,
          'timestamp': DateTime.now().toIso8601String(),
          'n': double.tryParse(nController.text) ?? 0.0,
          'p': double.tryParse(pController.text) ?? 0.0,
          'k': double.tryParse(kController.text) ?? 0.0,
          'humidity': double.tryParse(humidityController.text) ?? 0.0,
          'temperature': double.tryParse(tempController.text) ?? 0.0,
        };

        await _firestore.collection('measurements').add(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Measurement saved successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save measurement: $e")),
        );
      }
    });
  }

  void showResultDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: AppColors.primary1,
        title: const Text("Crop Recommendation"),
        content: Text(message),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor:
              MaterialStateProperty.all<Color>(AppColors.primary2),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.pop(context);
              }
            },
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "AgriHope",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.white,
          ),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: AppColors.primary2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Model 1",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text("Crop Recommendation",
                        style: TextStyle(
                            color: AppColors.primary4,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.article_outlined,
                    size: 40, color: AppColors.white),
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
                  buildTextField(tempController, "Temp"),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: predictCrop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary2,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Recommend",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: saveMeasurementToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary3,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Save to History",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
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
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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