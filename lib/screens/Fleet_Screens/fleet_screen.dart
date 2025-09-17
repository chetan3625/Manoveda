import 'package:erptransportexpress/Common%20Widgets/card.dart';
import 'package:erptransportexpress/Common%20Widgets/serachbar.dart';
import 'package:erptransportexpress/models/FilterModel.dart';
import 'package:erptransportexpress/Common Widgets/FleetTableWidget.dart';
import 'package:erptransportexpress/models/SubFilterOptionModel.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/screens/Fleet_Screens/Edit_Table_FleetScreen.dart';
import 'package:erptransportexpress/utils/Colors.dart';
import 'package:erptransportexpress/Common Widgets/uploadComponent.dart';

import 'package:flutter/material.dart';

import '../../Common Wi'
    'dgets/filter.dart';
import '../../widgets/sidebar.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {


  final List<VehicleModel> vehicles = [
    VehicleModel(
      "VH001",
      "Toyota",
      "Corolla",
      "Sedan",
      "Petrol",
      "MH12AB1234",
      "1/2/2025",
      "2/2/2025",
    ),
    VehicleModel(
      "VH002",
      "Honda",
      "City",
      "Sedan",
      "Diesel",
      "MH14CD5678",
      "2/2/2025",
      "3/3/2025",
    ),
    VehicleModel(
      "VH003",
      "Tata",
      "Nexon",
      "SUV",
      "Electric",
      "MH15EF9012",
      "4/4/2025",
      "5/5/2025",
    ),
    VehicleModel(
      "VH004",
      "Hyundai",
      "i20",
      "Hatchback",
      "Petrol",
      "MH13GH3456",
      "6/6/2025",
      "7/7/2025",
    ),
  ];
  void deleteFromRow(String vehicleno){
  setState(() {

  });

  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // FAB position

      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: common_Colors.primaryColor,
        title: Text("FleetScreen", style: TextStyle(color: Colors.white)),
      ),
      drawer: Sidebar(),
      floatingActionButton: SizedBox(

        height: 70,
        width: 150,
        child: FloatingActionButton(
//



          backgroundColor: common_Colors.primaryColor,
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditTableFleetscreen())
            );
          },
        child: Text("Add a Vehicle",style: TextStyle(
          color: common_Colors.textColor,
        ),),

        ),
      ),
      body: FleetFilterWidget(
        filters: [
          FilterModel("Vehicle Type", [
            SubFilterOptionModel("Truck", 1, false),
            SubFilterOptionModel("Tempo", 2, false),
            SubFilterOptionModel("Van", 3, false),
          ]),
          FilterModel("Fuel Type", [
            SubFilterOptionModel("Diesel", 1, false),
            SubFilterOptionModel("Petrol", 2, false),
            SubFilterOptionModel("CNG", 3, false),
            SubFilterOptionModel("Electric / Hybrid", 4, false),
          ]),

          // FilterModel("FLeet Type",  [SubFilterOptionModel("Truck", 1)])
          // FilterModel("FLeet Type",  [SubFilterOptionModel("Truck", 1)])
        ],
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
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
                        StatCard(
                          icon: Icons.fire_truck,
                          title: "Total Vehicles",
                          value: "245",
                        ),
                        SizedBox(width: 12),
                        StatCard(
                          icon: Icons.fire_truck,
                          title: "On Road",
                          value: "120",
                        ),
                        SizedBox(width: 12),
                        StatCard(
                          icon: Icons.car_crash,
                          title: "Idle Vehicles",
                          value: "80",
                        ),
                        SizedBox(width: 12),
                        StatCard(
                          icon: Icons.build,
                          title: "Under Maintenance",
                          value: "15",
                        ),
                        SizedBox(width: 12),
                        StatCard(
                          icon: Icons.event,
                          title: "Upcoming Trips",
                          value: "30",
                        ),
                        SizedBox(width: 12),
                        StatCard(
                          icon: Icons.local_gas_station,
                          title: "Fuel Consumption",
                          value: "500L",
                        ),
                        SizedBox(width: 12), // शेवटी gap
                      ],
                    ),
                  ),
                ),
              ),
              CustomSearchBar(screen: "Fleetscreen", scaffoldKey: _scaffoldKey),
              // FleetTableWidget(vehicles: vehicles),
              FleetTableWidget(
                dataColumnList: [
                  DataColumn(label: Expanded(child: Text("Vehicle No"))),
                  DataColumn(label: Expanded(child: Text("Type"))),
                  DataColumn(label: Expanded(child: Text("Capacity"))),
                  DataColumn(label: Expanded(child: Text("Status"))),
                  DataColumn(label: Expanded(child: Text("Driver"))),
                  DataColumn(label: Expanded(child: Text("Last Service"))),
                  DataColumn(label: Expanded(child: Text("start date"))),
                  DataColumn(label: Expanded(child: Text("enddate"))),
                  DataColumn(label: Expanded(child: Text("Actions")))

                ],
                dataRowList:

                vehicles.map((vehicle) {
                  return DataRow(cells: [
                    DataCell(Text(vehicle.vehileNo)),
                    DataCell(Text(vehicle.type)),
                    DataCell(Text(vehicle.capacity)),
                    DataCell(
                      Text(
                        vehicle.status,
                        style: TextStyle(
                          color: vehicle.status == "Available"
                              ? Colors.green
                              : vehicle.status == "In Transit"
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                    DataCell(Text(vehicle.driver)),
                    DataCell(Text(vehicle.lastService)),
                    DataCell(Text(vehicle.startdate)),
                    DataCell(Text(vehicle.enddate)),
                    DataCell(Row(
                      children: [
                        InkWell(
                            child: Icon(Icons.edit),
                        onTap: (){
                              print("Edit tapped");
                        },),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(

                          child: Icon(
                            color: Colors.red,
                              Icons.delete),
                          onTap: (){
                            print("delete tapped");
                          },
                        ),
                        SizedBox(
                          width: 10,
                        ),


                      ],
                    ))

                  ]);
                }).toList(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
