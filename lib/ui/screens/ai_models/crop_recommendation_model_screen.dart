import 'package:agri_hope/ui/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController humidityController = TextEditingController();
  final TextEditingController tempController = TextEditingController();
  final TextEditingController landNameController = TextEditingController();
  final TextEditingController tagController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  final String apiKey = 'cb17b0b03b1d59110c09ffa366d71224';
  WeatherFactory? weatherFactory;

  final _firestore = FirebaseFirestore.instance;

  String? _validateInput(String? value, String label) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    final RegExp regex = RegExp(r'^\d{0,5}(\.\d{0,2})?$');
    if (!regex.hasMatch(value)) {
      return 'Enter a valid positive number (max 5 digits)';
    }
    final double? number = double.tryParse(value);
    if (number == null || number < 0 || number > 999) {
      return 'Value must be between 0 and 999';
    }
    return null;
  }

  void _updateFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    weatherFactory = WeatherFactory(apiKey);
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args.containsKey('prefilledData')) {
        final data = args['prefilledData'] as Map<String, dynamic>;
        nController.text = data['N'].toStringAsFixed(2);
        pController.text = data['P'].toStringAsFixed(2);
        kController.text = data['K'].toStringAsFixed(2);
        humidityController.text = data['humidity'].toStringAsFixed(2);
        tempController.text = data['temperature'].toStringAsFixed(2);
        _updateFormValidity();
      } else {
        fetchWeatherData();
        showModeSelectionDialog();
      }
    });

    nController.addListener(_updateFormValidity);
    pController.addListener(_updateFormValidity);
    kController.addListener(_updateFormValidity);
    humidityController.addListener(_updateFormValidity);
    tempController.addListener(_updateFormValidity);
  }

  @override
  void dispose() {
    nController.removeListener(_updateFormValidity);
    pController.removeListener(_updateFormValidity);
    kController.removeListener(_updateFormValidity);
    humidityController.removeListener(_updateFormValidity);
    tempController.removeListener(_updateFormValidity);
    nController.dispose();
    pController.dispose();
    kController.dispose();
    humidityController.dispose();
    tempController.dispose();
    super.dispose();
  }

  Future<void> fetchWeatherData() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          showResultDialog("Location services are disabled.");
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            showResultDialog("Location permission denied.");
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showResultDialog("Location permission is permanently denied.");
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      Weather weather = await weatherFactory!.currentWeatherByLocation(
          position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          tempController.text = weather.temperature?.celsius?.toStringAsFixed(2) ?? '0.00';
          humidityController.text = weather.humidity?.toStringAsFixed(2) ?? '0.00';
          _updateFormValidity();
        });
      }
    } catch (e) {
      if (mounted) {
        showResultDialog("Failed to fetch weather data.");
      }
    }
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

  void startAutomaticMode() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          title: Text("Connecting..."),
          content: Text("Connecting to ESP32..."),
        );
      },
    );

    try {
      const String esp32Ip = "192.168.1.100";
      const int esp32Port = 12345;
      final socket = await Socket.connect(esp32Ip, esp32Port, timeout: const Duration(seconds: 5)).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException("Connection to ESP32 timed out after 20 seconds.");
        },
      );

      final dataFuture = socket.first.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          socket.close();
          throw TimeoutException("No data received from ESP32 within 20 seconds.");
        },
      );

      final List<int> data = await dataFuture;
      final String response = String.fromCharCodes(data).trim();
      final Map<String, dynamic> values = jsonDecode(response);

      if (mounted) {
        setState(() {
          nController.text = (values['nitrogen'] ?? -1.0) >= 0 ? values['nitrogen'].toStringAsFixed(2) : '0.00';
          pController.text = (values['phosphorus'] ?? -1.0) >= 0 ? values['phosphorus'].toStringAsFixed(2) : '0.00';
          kController.text = (values['potassium'] ?? -1.0) >= 0 ? values['potassium'].toStringAsFixed(2) : '0.00';
          _updateFormValidity();
        });
      }

      await socket.close();

      if (mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.pop(context);
        }
        showResultDialog("Error: ${e.toString()}");
      }
    }
  }

  Future<void> predictCrop() async {
    if (!_formKey.currentState!.validate()) {
      showResultDialog("Please correct all invalid inputs.");
      return;
    }

    final Uri apiUrl = Uri.parse("http://127.0.0.1:5000/croprecommendation");

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "N": double.tryParse(nController.text) ?? 0.0,
          "P": double.tryParse(pController.text) ?? 0.0,
          "K": double.tryParse(kController.text) ?? 0.0,
          "humidity": double.tryParse(humidityController.text) ?? 0.0,
          "temperature": double.tryParse(tempController.text) ?? 0.0,
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
    final existingLandNames = <String>{};
    try {
      final querySnapshot = await _firestore.collection('measurements').get();
      for (var doc in querySnapshot.docs) {
        existingLandNames.add(doc['land_name'] as String);
      }
    } catch (e) {
      // Handle error silently
    }

    bool useExisting = true;

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

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to save measurements")),
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
          'user_id': user.uid, // Add user_id to link to the authenticated user
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
              child: Form(
                key: _formKey,
                child: GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 5,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 15,
                  children: [
                    buildTextField(nController, "N", "mg/kg"),
                    buildTextField(pController, "P", "mg/kg"),
                    buildTextField(kController, "K", "mg/kg"),
                    buildTextField(humidityController, "Humidity", "%"),
                    buildTextField(tempController, "Temp", "°C"),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isFormValid ? predictCrop : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary2,
                    disabledBackgroundColor: Colors.grey,
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

  Widget buildTextField(TextEditingController controller, String label, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.primary1,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Colors.red),
            suffixText: unit,
            suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) => _validateInput(value, label),
          onChanged: (value) {
            _updateFormValidity();
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(5),
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        ),
      ],
    );
  }
}