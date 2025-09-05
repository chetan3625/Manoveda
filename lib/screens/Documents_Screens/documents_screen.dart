import 'package:flutter/material.dart';
import '../Dashboard_Screens/dashboard_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
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
            const Text("Document Screen"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {

                });
              },
              child: const Text("Add document"),
            ),
          ],
        ),
      ),
    );
  }
}
