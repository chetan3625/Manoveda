import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:flutter/material.dart';

import '../Dashboard_Screens/dashboard_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: Text("Analytics Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Analytics Screen"),


          ],
        ),
      ),
    );
  }
}
