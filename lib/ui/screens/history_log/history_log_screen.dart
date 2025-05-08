import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/app_color.dart';
import '../ai_models/crop_recommendation_model_screen.dart';

class LandMeasurement {
  final String id; // Changed to String for Firestore document ID
  late final String tag;
  final DateTime timestamp;
  final double n;
  final double p;
  final double k;
  final double humidity;
  final double temperature;
  String landName;

  LandMeasurement({
    required this.id,
    required this.tag,
    required this.timestamp,
    required this.n,
    required this.p,
    required this.k,
    required this.humidity,
    required this.temperature,
    required this.landName,
  });

  factory LandMeasurement.fromJson(Map<String, dynamic> json, String docId) {
    return LandMeasurement(
      id: docId,
      tag: json['tag'] ?? 'Tag-$docId',
      timestamp: DateTime.parse(json['timestamp']),
      n: json['n']?.toDouble() ?? 0.0,
      p: json['p']?.toDouble() ?? 0.0,
      k: json['k']?.toDouble() ?? 0.0,
      humidity: json['humidity']?.toDouble() ?? 0.0,
      temperature: json['temperature']?.toDouble() ?? 0.0,
      landName: json['land_name'] ?? 'Land-$docId',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'timestamp': timestamp.toIso8601String(),
      'n': n,
      'p': p,
      'k': k,
      'humidity': humidity,
      'temperature': temperature,
      'land_name': landName,
    };
  }
}

class HistoryLogScreen extends StatefulWidget {
  static const String routeName = "history";
  const HistoryLogScreen({super.key});

  @override
  State<HistoryLogScreen> createState() => _HistoryLogScreenState();
}

class _HistoryLogScreenState extends State<HistoryLogScreen> {
  final _firestore = FirebaseFirestore.instance;

  Map<String, List<LandMeasurement>> landMeasurements = {};
  List<String> selectedTags = [];
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
      final querySnapshot = await _firestore
          .collection('measurements')
          .orderBy('timestamp', descending: true)
          .get();

      final measurements = querySnapshot.docs
          .map((doc) => LandMeasurement.fromJson(doc.data(), doc.id))
          .toList();

      landMeasurements = groupBy(measurements, (LandMeasurement m) => m.landName);

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

  Future<void> _exportToCSV() async {
    if (selectedLand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a land first')),
      );
      return;
    }

    final measurements = landMeasurements[selectedLand!] ?? [];
    if (measurements.isEmpty) return;

    List<List<dynamic>> csvData = [
      ['Tag', 'Timestamp', 'N', 'P', 'K', 'Humidity', 'Temperature'],
    ];

    for (var measurement in measurements) {
      csvData.add([
        measurement.tag,
        DateFormat('yyyy-MM-dd HH:mm').format(measurement.timestamp),
        measurement.n,
        measurement.p,
        measurement.k,
        measurement.humidity,
        measurement.temperature,
      ]);
    }

    csvData.add([
      'Average',
      '',
      measurements.map((m) => m.n).average,
      measurements.map((m) => m.p).average,
      measurements.map((m) => m.k).average,
      measurements.map((m) => m.humidity).average,
      measurements.map((m) => m.temperature).average,
    ]);

    try {
      // Use getApplicationDocumentsDirectory() for desktop (app-specific directory)
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/${selectedLand}_measurements.csv';
      final file = File(path);

      String csv = const ListToCsvConverter().convert(csvData);
      await file.writeAsString(csv);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV exported to $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e')),
        );
      }
    }
  }

  void _sendToAIModel() {
    if (selectedLand == null || selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a land and at least one tag')),
      );
      return;
    }

    final measurements = landMeasurements[selectedLand!]!
        .where((m) => selectedTags.contains(m.tag))
        .toList();

    if (measurements.isEmpty) return;

    double avgN = measurements.map((m) => m.n).average;
    double avgP = measurements.map((m) => m.p).average;
    double avgK = measurements.map((m) => m.k).average;
    double avgTemp = measurements.map((m) => m.temperature).average;
    double avgHumidity = measurements.map((m) => m.humidity).average;

    Navigator.of(context).pushNamed(
      CropRecommendationModelScreen.routeName,
      arguments: {
        'prefilledData': {
          'N': avgN,
          'P': avgP,
          'K': avgK,
          'temperature': avgTemp,
          'humidity': avgHumidity,
        }
      },
    );
  }

  Future<void> _updateLandName(String oldName, String newName) async {
    if (oldName == newName || newName.isEmpty) return;

    try {
      // Update all documents with the old land_name
      final querySnapshot = await _firestore
          .collection('measurements')
          .where('land_name', isEqualTo: oldName)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'land_name': newName});
      }
      await batch.commit();

      // Update locally
      final measurements = landMeasurements[oldName] ?? [];
      for (var measurement in measurements) {
        measurement.landName = newName;
      }

      landMeasurements[newName] = measurements;
      landMeasurements.remove(oldName);

      setState(() {
        selectedLand = newName;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Land name updated to $newName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update land name: $e')),
        );
      }
    }
  }

  Future<void> _updateMeasurementTag(
      LandMeasurement measurement, String newTag) async {
    if (measurement.tag == newTag || newTag.isEmpty) return;

    try {
      // Update in Firestore
      await _firestore
          .collection('measurements')
          .doc(measurement.id)
          .update({'tag': newTag});

      // Update locally
      setState(() {
        measurement.tag = newTag;
        if (selectedTags.contains(measurement.tag)) {
          selectedTags.remove(measurement.tag);
          selectedTags.add(newTag);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tag updated to $newTag')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update tag: $e')),
        );
      }
    }
  }

  Future<void> _deleteLand(String landName) async {
    try {
      final querySnapshot = await _firestore
          .collection('measurements')
          .where('land_name', isEqualTo: landName)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Update locally
      landMeasurements.remove(landName);
      if (selectedLand == landName) {
        selectedLand = null;
        selectedTags.clear();
      }
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Land "$landName" deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete land: $e')),
        );
      }
    }
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    final TextEditingController controller =
    TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String landName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "$landName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLand(landName);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
            selectedTags = [];
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(
                      'Land Name',
                      landName,
                          (newName) => _updateLandName(landName, newName),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(landName),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementsTable() {
    if (selectedLand == null) {
      return const Center(
        child: Text('Select a land to view measurements'),
      );
    }

    final measurements = landMeasurements[selectedLand!] ?? [];
    if (measurements.isEmpty) {
      return const Center(
        child: Text('No measurements available for this land'),
      );
    }

    double avgN = measurements.map((m) => m.n).average;
    double avgP = measurements.map((m) => m.p).average;
    double avgK = measurements.map((m) => m.k).average;
    double avgHumidity = measurements.map((m) => m.humidity).average;
    double avgTemp = measurements.map((m) => m.temperature).average;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedLand!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _exportToCSV,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary2,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _sendToAIModel,
                    icon: const Icon(Icons.science),
                    label: const Text('To AI Model'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary3,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(AppColors.primary1),
                columns: const [
                  DataColumn(label: Text('Select')),
                  DataColumn(label: Text('Tag')),
                  DataColumn(label: Text('Timestamp')),
                  DataColumn(label: Text('N')),
                  DataColumn(label: Text('P')),
                  DataColumn(label: Text('K')),
                  DataColumn(label: Text('Humidity')),
                  DataColumn(label: Text('Temperature')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: [
                  ...measurements.map((measurement) => DataRow(
                    selected: selectedTags.contains(measurement.tag),
                    onSelectChanged: (selected) {
                      setState(() {
                        if (selected != null && selected) {
                          selectedTags.add(measurement.tag);
                        } else {
                          selectedTags.remove(measurement.tag);
                        }
                      });
                    },
                    cells: [
                      DataCell(Checkbox(
                        value: selectedTags.contains(measurement.tag),
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              selectedTags.add(measurement.tag);
                            } else {
                              selectedTags.remove(measurement.tag);
                            }
                          });
                        },
                      )),
                      DataCell(Text(measurement.tag)),
                      DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                          .format(measurement.timestamp))),
                      DataCell(Text(measurement.n.toStringAsFixed(2))),
                      DataCell(Text(measurement.p.toStringAsFixed(2))),
                      DataCell(Text(measurement.k.toStringAsFixed(2))),
                      DataCell(
                          Text(measurement.humidity.toStringAsFixed(2))),
                      DataCell(
                          Text(measurement.temperature.toStringAsFixed(2))),
                      DataCell(IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditDialog(
                          'Tag',
                          measurement.tag,
                              (newTag) =>
                              _updateMeasurementTag(measurement, newTag),
                        ),
                      )),
                    ],
                  )),
                  DataRow(
                    color:
                    MaterialStateProperty.all(AppColors.primary1.withOpacity(0.2)),
                    cells: [
                      const DataCell(Text('')),
                      const DataCell(
                          Text('AVERAGE', style: TextStyle(fontWeight: FontWeight.bold))),
                      const DataCell(Text('')),
                      DataCell(Text(avgN.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(avgP.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(avgK.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(avgHumidity.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(avgTemp.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      const DataCell(Text('')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "History Log",
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
            child: _buildMeasurementsTable(),
          ),
        ],
      ),
    );
  }
}

extension IterableExtension<T extends num> on Iterable<T> {
  double get average => isEmpty ? 0 : reduce((a, b) => (a + b) as T) / length;
}