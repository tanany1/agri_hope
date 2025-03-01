import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_color.dart';

class LastUsedModelWidget extends StatefulWidget {
  const LastUsedModelWidget({super.key});

  @override
  State<LastUsedModelWidget> createState() => _LastUsedModelWidgetState();
}

class _LastUsedModelWidgetState extends State<LastUsedModelWidget>
    with WidgetsBindingObserver {
  String lastUsedModel = "No model used recently";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLastUsedModel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLastUsedModel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLastUsedModel();
    }
  }

  Future<void> _loadLastUsedModel() async {
    final prefs = await SharedPreferences.getInstance();
    String? model = prefs.getString('last_used_model');
    setState(() {
      lastUsedModel = model ?? "No model used recently";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary1,
        borderRadius: BorderRadius.circular(50),
      ),
      width: 600,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Last Used Model",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lastUsedModel,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary2,
            ),
          ),
        ],
      ),
    );
  }
}
