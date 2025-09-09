import 'package:flutter/material.dart';
import '../Dashboard_Screens/dashboard_screen.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  @override


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            //  Navigate back to Dashboard
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
            const Text(" Vendor Screen "),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {

                });
              },
              child: const Text("Add Vendor"),
            ),
          ],
        ),
      ),
    );
  }
}
