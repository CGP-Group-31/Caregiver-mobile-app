import 'package:flutter/material.dart';
import '../auth/theme.dart';

class WeeklyReportsPage extends StatefulWidget {
  const WeeklyReportsPage({super.key});

  @override
  State<WeeklyReportsPage> createState() => _WeeklyReportsPageState();
}

class _WeeklyReportsPageState extends State<WeeklyReportsPage> {
  String selectedWeek = "Week 1 - March 2024";
  final List<String> weeks = ["Week 1 - March 2024", "Week 2 - March 2024", "Week 3 - March 2024"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        title: const Text("Weekly Reports", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Week", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.descriptionText)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedWeek,
              items: weeks.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
              onChanged: (v) => setState(() => selectedWeek = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),
            const Text("AI Health Analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: const Text(
                "John has shown consistent improvement in hydration levels this week. However, heart rate was slightly higher on Tuesday evening. Recommend continued monitoring and a light walk tomorrow.",
                style: TextStyle(fontSize: 15, color: AppColors.descriptionText, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
