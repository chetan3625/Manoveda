import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
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
      appBar: CommonAppBar(title: Text("Documents Screen")),
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
