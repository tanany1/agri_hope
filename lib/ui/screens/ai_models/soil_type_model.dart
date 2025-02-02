import 'dart:io';
import 'package:agri_hope/ui/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SoilTypeModelScreen extends StatefulWidget {
  static const String routeName = "SoilTypeModel";

  @override
  _SoilTypeModelScreenState createState() => _SoilTypeModelScreenState();
}

class _SoilTypeModelScreenState extends State<SoilTypeModelScreen> {
  File? _image;
  String? _predictedSoil;
  double? _confidence;
  String? _statusMessage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _predictedSoil = null;
          _confidence = null;
          _statusMessage = null;
          _isLoading = true;
        });
        await _predictSoilType(_image!);
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Failed to pick image: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _predictSoilType(File imageFile) async {
    const String apiUrl = "http://127.0.0.1:5000/soiltype";
    try {
      var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _predictedSoil = jsonData["predicted_class"];
          _confidence = jsonData["confidence"];
          _statusMessage = jsonData["status"];
          _isLoading = false;
        });
      } else {
        setState(() {
          _statusMessage = "Failed: ${response.statusCode}, ${response.body}";
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _statusMessage = "Error: ${error.toString()}";
        _isLoading = false;
      });
    }
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
          "Soil Type Model",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.white),
        ),
        elevation: 20,
        centerTitle: true,
        backgroundColor: AppColors.primary3,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(25) , color: AppColors.primary1,),
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
                        icon: const Icon(Icons.photo_library , color: Colors.white,),
                        label: const Text("Pick from Gallery" , style: TextStyle(color: AppColors.white),),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (_statusMessage != null)
                  Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _statusMessage == "Success" ? Colors.green : Colors.red,
                    ),
                  ),
                if (_predictedSoil != null)
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Predicted Soil Type: $_predictedSoil",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
