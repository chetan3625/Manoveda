import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VendorDetailsScreen extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const VendorDetailsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vendor Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vendor Name: $name"),
            Text("Email: $email"),
            Text("Phone: $phone"),
          ],
        ),
      ),
    );
  }
}
