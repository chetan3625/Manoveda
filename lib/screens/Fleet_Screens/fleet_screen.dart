import 'package:erptransportexpress/models/card.dart';
import 'package:flutter/material.dart';

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
        backgroundColor: Colors.blue,
        title: Text("FleetScreen",style: TextStyle(
          color: Colors.white,
        ),),


      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: const [
                    SizedBox(width: 12), // सुरुवातीला gap
                    StatCard(icon: Icons.fire_truck, title: "Total Vehicles", value: "245"),
                    SizedBox(width: 12),
                    StatCard(icon: Icons.fire_truck, title: "On Road", value: "120"),
                    SizedBox(width: 12),
                    StatCard(icon: Icons.car_crash, title: "Idle Vehicles", value: "80"),
                    SizedBox(width: 12),
                    StatCard(icon: Icons.build, title: "Under Maintenance", value: "15"),
                    SizedBox(width: 12),
                    StatCard(icon: Icons.event, title: "Upcoming Trips", value: "30"),
                    SizedBox(width: 12),
                    StatCard(icon: Icons.local_gas_station, title: "Fuel Consumption", value: "500L"),
                    SizedBox(width: 12), // शेवटी gap
                  ],
                ),
              ),
            ),
          ),
        ],

      ),
    );
  }
}
