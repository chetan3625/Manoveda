import 'package:erptransportexpress/Common%20Widgets/customtable.dart';
import 'package:flutter/material.dart';

import '../Dashboard_Screens/dashboard_screen.dart';

class FinancialsScreen extends StatefulWidget {
  const FinancialsScreen({super.key});

  @override
  State<FinancialsScreen> createState() => _FinancialsScreenState();
}

class _FinancialsScreenState extends State<FinancialsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fleet"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // ✅ Navigate back to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          CustomTable(columns: ["Profit","Loss"], rows: [
            ["5","6"],
            ["5","6"],
            ["5","6"],
            ["5","6"],
          ])
        ],
      )
    );
  }
}
