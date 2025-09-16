import 'dart:convert';
import 'package:flutter/material.dart';

import '../../Common Widgets/CommonAppBar.dart';
import '../Dashboard_Screens/dashboard_screen.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  List<Map<String, String>> trips = [];

  final TextEditingController tripNameController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController driverController = TextEditingController();

  @override
  void initState() {
    super.initState();

  }




  void _addTripDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Trip"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tripNameController,
              decoration: const InputDecoration(labelText: "Trip Name"),
            ),
            TextField(
              controller: vehicleController,
              decoration: const InputDecoration(labelText: "Vehicle No"),
            ),
            TextField(
              controller: driverController,
              decoration: const InputDecoration(labelText: "Driver Name"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              tripNameController.clear();
              vehicleController.clear();
              driverController.clear();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (tripNameController.text.isNotEmpty &&
                  vehicleController.text.isNotEmpty &&
                  driverController.text.isNotEmpty) {
                setState(() {
                  trips.add({
                    "tripName": tripNameController.text,
                    "vehicle": vehicleController.text,
                    "driver": driverController.text,
                  });
                });

                Navigator.pop(context);

                tripNameController.clear();
                vehicleController.clear();
                driverController.clear();
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteTrip(int index) {
    setState(() {
      trips.removeAt(index);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: Text("Trip Screen")),
      body: trips.isEmpty
          ? const Center(child: Text("No trips added yet"))
          : ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.directions_bus),
              ),
              title: Text(trip["tripName"] ?? ""),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Vehicle: ${trip["vehicle"]}"),
                  Text("Driver: ${trip["driver"]}"),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTrip(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTripDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
