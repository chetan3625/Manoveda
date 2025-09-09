import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VendorProfileScreen extends StatelessWidget {
  final Map<String, String> vendor;

  const VendorProfileScreen({super.key, required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vendor["name"]!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Contact: ${vendor["contact"]}"),
            Text("Email: ${vendor["email"]}"),
            const SizedBox(height: 20),
            const Text("Contracts, Vehicles, Revenue sharing, Payments will come here."),
          ],
        ),
      ),
    );
  }
}
