import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/vehical_card.dart';

import '../../models/VehicalModel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Vehicle> vehicles = [
    Vehicle(number: "MH12AB1234", type: "Truck", capacity: "10 T", status: "Active"),
    Vehicle(number: "MH12AB5678", type: "Tanker", capacity: "12 T", status: "Active"),
    Vehicle(number: "MH12AB9012", type: "Trailer", capacity: "20 T", status: "Idle"),
    Vehicle(number: "MH12AB3841", type: "Truck", capacity: "10 T", status: "Active"),
  ];

  int get totalVehicles => vehicles.length;
  int get activeVehicles =>
      vehicles.where((v) => v.status == "Active").length;

  @override
  Widget build(BuildContext context) {
    double activePercentage = (activeVehicles / totalVehicles) * 100;

    return Scaffold(
      drawer: const Sidebar(),
      appBar: CommonAppBar(title: Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: "Total Vehicles",
                    value: totalVehicles.toString(),
                    icon: Icons.local_shipping,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: "Active Vehicles",
                    value: "${activePercentage.toStringAsFixed(0)}%",
                    icon: Icons.pie_chart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) => VehicleCard(
                  vehicle: vehicles[index],
                  onStatusChange: (newStatus) {
                    setState(() {
                      vehicles[index] =
                          vehicles[index].copyWith(status: newStatus);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
