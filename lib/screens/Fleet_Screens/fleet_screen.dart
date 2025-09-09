import 'package:erptransportexpress/Common%20Widgets/card.dart';
import 'package:erptransportexpress/Common%20Widgets/serachbar.dart';
import 'package:erptransportexpress/Common%20Widgets/table.dart';
import 'package:erptransportexpress/models/FilterModel.dart';
import 'package:erptransportexpress/models/SubFilterOptionModel.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:flutter/material.dart';

import '../../Common Widgets/filter.dart';
import '../../widgets/sidebar.dart';

class FleetScreen extends StatefulWidget {

  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  final List<VehicleModel> vehicles = [
    VehicleModel("VH001", "Toyota", "Corolla", "Sedan", "Petrol", "MH12AB1234"),
    VehicleModel("VH002", "Honda", "City", "Sedan", "Diesel", "MH14CD5678"),
    VehicleModel("VH003", "Tata", "Nexon", "SUV", "Electric", "MH15EF9012"),
    VehicleModel("VH004", "Hyundai", "i20", "Hatchback", "Petrol", "MH13GH3456"),
  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        title: Text("FleetScreen",style: TextStyle(
          color: Colors.white,
        ),
        ),

      ),
      drawer: Sidebar(),
      body: FleetFilterWidget(
        filters: [
          FilterModel("Vehicle Type",  [SubFilterOptionModel("Truck", 1 , false) , SubFilterOptionModel("Tempo", 2, false) , SubFilterOptionModel("Van", 3 , false)],),
          FilterModel("Fuel Type",  [SubFilterOptionModel("Diesel", 1 , false) , SubFilterOptionModel("Petrol", 2, false) , SubFilterOptionModel("CNG", 3 , false),SubFilterOptionModel("Electric / Hybrid", 4 , false)],),


          // FilterModel("FLeet Type",  [SubFilterOptionModel("Truck", 1)])
          // FilterModel("FLeet Type",  [SubFilterOptionModel("Truck", 1)])
        ],
        child: SingleChildScrollView(

          child: Column(
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
              CustomSearchBar(screen: "Fleetscreen",),
              FleetTableWidget(vehicles: vehicles),
            ],

          ),
        ),
      ),
    );
  }
}
