import 'package:flutter/material.dart';
import '../Dashboard_Screens/dashboard_screen.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {

  List<Map<String, String>> vendors = [
    {"name": "ABC Transport", "contact": "9876543210", "email": "abc@gmail.com"},
    {"name": "XYZ Logistics", "contact": "9123456789", "email": "xyz@gmail.com"},
  ];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void _addVendor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Vendor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(labelText: "Contact"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              nameController.clear();
              contactController.clear();
              emailController.clear();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  contactController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                setState(() {
                  vendors.add({
                    "name": nameController.text,
                    "contact": contactController.text,
                    "email": emailController.text,
                  });
                });
                Navigator.pop(context);

                // Clear fields after saving
                nameController.clear();
                contactController.clear();
                emailController.clear();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendors"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
      ),
      body: ListView.builder(
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.business),
              ),
              title: Text(vendor["name"]!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Contact: ${vendor["contact"]}"),
                  Text("Email: ${vendor["email"]}"),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    vendors.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVendor,
        child: const Icon(Icons.add),
      ),
    );
  }
}