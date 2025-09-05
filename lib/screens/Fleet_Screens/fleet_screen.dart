import 'package:flutter/material.dart';
import '../Dashboard_Screens/dashboard_screen.dart'; // make sure path matches your project

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Fleet Management Screen"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {

                });
              },
              child: const Text("Add Vehicle"),
            ),
          ],
        ),
      ),
    );
  }
}
