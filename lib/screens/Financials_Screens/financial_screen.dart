import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
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
      appBar: CommonAppBar(title: Text("Financials Screen")),
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
