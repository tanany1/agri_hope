import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/app_color.dart';
import '../../utils/pie_chart.dart';
import '../history_log/history_log_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = "dashboard";

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestore = FirebaseFirestore.instance;

  Map<String, List<LandMeasurement>> landMeasurements = {};
  String? selectedLand;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeasurements();
  }

  Future<void> fetchMeasurements() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to view measurements')),
          );
        }
        return;
      }

      final querySnapshot = await _firestore
          .collection('measurements')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      final measurements = querySnapshot.docs
          .map((doc) => LandMeasurement.fromJson(doc.data(), doc.id))
          .toList();

      landMeasurements = groupBy(measurements, (LandMeasurement m) => m.landName);

      if (selectedLand == null && landMeasurements.isNotEmpty) {
        selectedLand = landMeasurements.keys.first;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e')),
        );
      }
    }
  }

  Widget _buildLandCard(String landName) {
    final measurements = landMeasurements[landName] ?? [];
    final count = measurements.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: selectedLand == landName ? AppColors.primary1 : AppColors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selectedLand == landName ? AppColors.primary3 : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedLand = landName;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                landName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedLand == landName
                      ? AppColors.primary4
                      : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count Measurements',
                style: TextStyle(
                  color: selectedLand == landName
                      ? AppColors.primary3
                      : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary3,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMeasurements,
            color: Colors.white,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Lands',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: landMeasurements.isEmpty
                      ? const Center(child: Text('No lands available'))
                      : ListView(
                    children: landMeasurements.keys
                        .map((landName) => _buildLandCard(landName))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedLand == null
                ? const Center(child: Text('Select a land to view pie charts'))
                : MeasurementPieChart(
              landMeasurements: landMeasurements,
              selectedLand: selectedLand,
            ),
          ),
        ],
      ),
    );
  }
}