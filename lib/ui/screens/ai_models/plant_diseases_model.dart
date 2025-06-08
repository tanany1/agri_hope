import 'dart:io';
import 'package:agri_hope/ui/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; // For logging

class PlantDiseasesDetectionModelScreen extends StatefulWidget {
  static const String routeName = "PlantDiseaseDetectionModel";

  @override
  _PlantDiseasesDetectionModelScreenState createState() =>
      _PlantDiseasesDetectionModelScreenState();
}

class _PlantDiseasesDetectionModelScreenState
    extends State<PlantDiseasesDetectionModelScreen> {
  File? _image;
  String? _predictedDisease;
  double? _confidence;
  String? _statusMessage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger(); // Initialize logger

  // User-friendly error messages
  static const Map<int, String> _httpErrorMessages = {
    400: "Invalid image format. Please upload a valid image.",
    404: "Service unavailable. Please try again later.",
    500: "Server error. Please try again later.",
    503: "Service temporarily unavailable. Please try again later.",
  };

  // Validate image file
  Future<bool> _validateImage(File imageFile) async {
    // Check file size (e.g., max 5MB)
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    final fileSize = await imageFile.length();
    if (fileSize > maxSizeInBytes) {
      setState(() {
        _statusMessage = "Image size exceeds 5MB. Please choose a smaller image.";
        _isLoading = false;
      });
      return false;
    }

    // Check file extension
    final validExtensions = ['.jpg', '.jpeg', '.png'];
    final extension = imageFile.path.toLowerCase();
    if (!validExtensions.any((ext) => extension.endsWith(ext))) {
      setState(() {
        _statusMessage =
        "Unsupported image format. Please use JPG or PNG images.";
        _isLoading = false;
      });
      return false;
    }

    return true;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _predictedDisease = null;
          _confidence = null;
          _statusMessage = null;
          _isLoading = true;
        });

        // Validate image before predicting
        if (await _validateImage(_image!)) {
          await _predictDisease(_image!);
        }
      }
    } catch (e) {
      _logger.e("Failed to pick image: $e");
      setState(() {
        _statusMessage = "Unable to pick image. Please try again.";
        _isLoading = false;
      });
    }
  }

  Future<void> _savePrediction(String detectedDisease, double confidence) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("latest_detected_disease", detectedDisease);
      await prefs.setDouble("latest_confidence", confidence);
    } catch (e) {
      _logger.e("Failed to save prediction: $e");
      setState(() {
        _statusMessage = "Prediction saved, but an issue occurred while storing it.";
      });
    }
  }

  Future<void> _predictDisease(File imageFile) async {
    const String apiUrl = "http://127.0.0.1:5000/plantdisease"; // Update with actual API URL
    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30), // Add timeout
        onTimeout: () {
          throw Exception("Request timed out");
        },
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _predictedDisease = jsonData["predicted_class"];
          _confidence = jsonData["confidence"];
          _statusMessage = "Success";
          _isLoading = false;
        });

        // Save to SharedPreferences
        await _savePrediction(_predictedDisease!, _confidence!);
      } else {
        _logger.e("API request failed: ${response.statusCode}, ${response.body}");
        setState(() {
          _statusMessage = _httpErrorMessages[response.statusCode] ??
              "An error occurred while processing the image. Please try again.";
          _isLoading = false;
        });
      }
    } catch (error) {
      _logger.e("Error predicting disease: $error");
      setState(() {
        _statusMessage = error.toString().contains("timed out")
            ? "Connection timed out. Please check your network and try again."
            : "An error occurred while processing the image. Please try again.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Plant Disease Detection Model",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: AppColors.primary1,
          ),
          width: 600,
          height: 600,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image != null
                    ? Image.file(_image!, height: 200, fit: BoxFit.cover)
                    : const Icon(Icons.image, size: 200, color: Colors.grey),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        label: const Text("Pick from Gallery",
                            style: TextStyle(color: AppColors.white)),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (_statusMessage != null)
                  Text(
                    _statusMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _statusMessage == "Success" ? Colors.green : Colors.red,
                    ),
                  ),
                if (_predictedDisease != null)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Detected Disease: $_predictedDisease",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}