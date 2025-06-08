import 'package:agri_hope/ui/screens/history_log/history_log_screen.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_color.dart';

class MeasurementPieChart extends StatefulWidget {
  final Map<String, List<LandMeasurement>> landMeasurements;
  final String? selectedLand;

  const MeasurementPieChart({
    Key? key,
    required this.landMeasurements,
    required this.selectedLand,
  }) : super(key: key);

  @override
  State<MeasurementPieChart> createState() => _MeasurementPieChartState();
}

class _MeasurementPieChartState extends State<MeasurementPieChart> {
  String selectedMetric = 'N'; // Default metric is Nitrogen
  bool showAverage = false;
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedLand == null ||
        !widget.landMeasurements.containsKey(widget.selectedLand) ||
        widget.landMeasurements[widget.selectedLand]!.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${showAverage ? 'Average' : 'Tag'} Distribution for ${widget.selectedLand}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Toggle between tag data and average
                    Switch(
                      value: showAverage,
                      onChanged: (value) {
                        setState(() {
                          showAverage = value;
                          touchedIndex = -1;
                        });
                      },
                      activeColor: AppColors.primary3,
                    ),
                    const SizedBox(width: 8),
                    Text(showAverage ? 'Average View' : 'Tag View'),
                    const SizedBox(width: 16),
                    // Metric selector dropdown
                    DropdownButton<String>(
                      value: selectedMetric,
                      underline: Container(
                        height: 2,
                        color: AppColors.primary3,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedMetric = value!;
                          touchedIndex = -1;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'N', child: Text('Nitrogen (N)')),
                        DropdownMenuItem(value: 'P', child: Text('Phosphorus (P)')),
                        DropdownMenuItem(value: 'K', child: Text('Potassium (K)')),
                        DropdownMenuItem(value: 'humidity', child: Text('Humidity')),
                        DropdownMenuItem(value: 'temperature', child: Text('Temperature')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: showAverage
                            ? _generateAverageSections()
                            : _generateTagSections(),
                      ),
                    ),
                  ),
                  // Legend
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: _buildLegend(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateTagSections() {
    final measurements = widget.landMeasurements[widget.selectedLand!]!;

    // Group by tag
    final Map<String, List<LandMeasurement>> tagGroups = {};
    for (var measurement in measurements) {
      if (!tagGroups.containsKey(measurement.tag)) {
        tagGroups[measurement.tag] = [];
      }
      tagGroups[measurement.tag]!.add(measurement);
    }

    // Get values for the selected metric
    final List<MapEntry<String, double>> tagValues = tagGroups.entries.map((entry) {
      double sum = 0;
      for (var measurement in entry.value) {
        sum += _getMetricValue(measurement, selectedMetric);
      }
      return MapEntry(entry.key, sum / entry.value.length);
    }).toList();

    // Calculate total for percentage
    double total = tagValues.fold(0, (sum, entry) => sum + entry.value);

    // Generate sections
    return tagValues.asMap().entries.map((entry) {
      final index = entry.key;
      final tagName = entry.value.key;
      final value = entry.value.value;
      final percent = total > 0 ? (value / total) * 100 : 0;

      final isTouched = touchedIndex == index;
      final double fontSize = isTouched ? 16 : 12;
      final double radius = isTouched ? 110 : 100;

      return PieChartSectionData(
        color: _getTagColor(index),
        value: value,
        title: isTouched ? tagName : '${percent.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  List<PieChartSectionData> _generateAverageSections() {
    final measurements = widget.landMeasurements[widget.selectedLand!]!;

    // Calculate metric distribution for averages
    double n = measurements.map((m) => m.n).average;
    double p = measurements.map((m) => m.p).average;
    double k = measurements.map((m) => m.k).average;
    double humidity = measurements.map((m) => m.humidity).average;
    double temperature = measurements.map((m) => m.temperature).average;

    List<MapEntry<String, double>> metrics = [
      MapEntry('N', n),
      MapEntry('P', p),
      MapEntry('K', k),
      MapEntry('humidity', humidity),
      MapEntry('temperature', temperature),
    ];

    double total = metrics.fold(0, (sum, metric) => sum + metric.value);

    return metrics.asMap().entries.map((entry) {
      final index = entry.key;
      final metricName = entry.value.key;
      final value = entry.value.value;
      final percent = total > 0 ? (value / total) * 100 : 0;

      final isTouched = touchedIndex == index;
      final double fontSize = isTouched ? 16 : 12;
      final double radius = isTouched ? 110 : 100;

      return PieChartSectionData(
        color: _getMetricColor(metricName),
        value: value,
        title: isTouched ? _getMetricDisplayName(metricName) : '${percent.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titlePositionPercentageOffset: 0.55,
      );
    }).toList();
  }

  Widget _buildLegend() {
    if (showAverage) {
      // Show metric names and values
      final measurements = widget.landMeasurements[widget.selectedLand!]!;
      double n = measurements.map((m) => m.n).average;
      double p = measurements.map((m) => m.p).average;
      double k = measurements.map((m) => m.k).average;
      double humidity = measurements.map((m) => m.humidity).average;
      double temperature = measurements.map((m) => m.temperature).average;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem('Nitrogen (N)', n.toStringAsFixed(2), _getMetricColor('N')),
          _buildLegendItem('Phosphorus (P)', p.toStringAsFixed(2), _getMetricColor('P')),
          _buildLegendItem('Potassium (K)', k.toStringAsFixed(2), _getMetricColor('K')),
          _buildLegendItem('Humidity', humidity.toStringAsFixed(2), _getMetricColor('humidity')),
          _buildLegendItem('Temperature', temperature.toStringAsFixed(2), _getMetricColor('temperature')),
        ],
      );
    } else {
      // Show tags and their selected metric values
      final measurements = widget.landMeasurements[widget.selectedLand!]!;

      // Group by tag
      final Map<String, List<LandMeasurement>> tagGroups = {};
      for (var measurement in measurements) {
        if (!tagGroups.containsKey(measurement.tag)) {
          tagGroups[measurement.tag] = [];
        }
        tagGroups[measurement.tag]!.add(measurement);
      }

      // Get average values for each tag
      final List<MapEntry<String, double>> tagValues = tagGroups.entries.map((entry) {
        double sum = 0;
        for (var measurement in entry.value) {
          sum += _getMetricValue(measurement, selectedMetric);
        }
        return MapEntry(entry.key, sum / entry.value.length);
      }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: tagValues.asMap().entries.map((entry) {
          final index = entry.key;
          final tag = entry.value.key;
          final value = entry.value.value;

          return _buildLegendItem(
              'Tag: $tag',
              '${selectedMetric}: ${value.toStringAsFixed(2)}',
              _getTagColor(index)
          );
        }).toList(),
      );
    }
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMetricValue(LandMeasurement measurement, String metric) {
    switch (metric) {
      case 'N': return measurement.n;
      case 'P': return measurement.p;
      case 'K': return measurement.k;
      case 'humidity': return measurement.humidity;
      case 'temperature': return measurement.temperature;
      default: return 0;
    }
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'N': return Colors.blue;
      case 'P': return Colors.green;
      case 'K': return Colors.red;
      case 'humidity': return Colors.purple;
      case 'temperature': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _getMetricDisplayName(String metric) {
    switch (metric) {
      case 'N': return 'Nitrogen';
      case 'P': return 'Phosphorus';
      case 'K': return 'Potassium';
      case 'humidity': return 'Humidity';
      case 'temperature': return 'Temperature';
      default: return metric;
    }
  }

  Color _getTagColor(int index) {
    // List of colors for different tags
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    return colors[index % colors.length];
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double size;
  final Color borderColor;

  const _Badge(
      this.label, {
        required this.size,
        required this.borderColor,
      });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.15),
      child: Center(
        child: FittedBox(
          child: Text(
            label,
            style: TextStyle(
              color: borderColor,
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}