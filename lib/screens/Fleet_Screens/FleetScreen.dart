import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/CommonCard.dart';
import 'package:erptransportexpress/Common%20Widgets/serachbar.dart';
import 'package:erptransportexpress/models/FilterModel.dart';
import 'package:erptransportexpress/Common Widgets/FleetTableWidget.dart';
import 'package:erptransportexpress/models/SubFilterOptionModel.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/utils/Colors.dart';

import 'package:flutter/material.dart';

import '../../Common Widgets/CommonAlertBox.dart';
import '../../Common Widgets/CommonFilter.dart';
import '../../widgets/sidebar.dart';
import 'EditTableFleetscreen.dart';

class FleetScreen extends StatefulWidget { // Removed 'implements PreferredSizeWidget'

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

      appBar:CommonAppBar(title: Text("FleetScreen")) , // Added const and changed title to a Text widget
      drawer: const Sidebar(),
      floatingActionButton: SizedBox(

        height: 70,
        width: 150,
        child: FloatingActionButton(
//



          backgroundColor: common_Colors.primaryColor,
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const EditTableFleetscreen())
            );
          },
          child: const Text("Add a Vehicle",style: TextStyle(
            color: common_Colors.textColor,
          ),),

        ),
      ),
      body: CommonFilter(
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
                        CommonCard(
                          icon: Icons.fire_truck,
                          title: "Total Vehicles",
                          value: "245",
                        ),
                        SizedBox(width: 12),
                        CommonCard(
                          icon: Icons.fire_truck,
                          title: "On Road",
                          value: "120",
                        ),
                        SizedBox(width: 12),
                        CommonCard(
                          icon: Icons.car_crash,
                          title: "Idle Vehicles",
                          value: "80",
                        ),
                        SizedBox(width: 12),
                        CommonCard(
                          icon: Icons.build,
                          title: "Under Maintenance",
                          value: "15",
                        ),
                        SizedBox(width: 12),
                        CommonCard(
                          icon: Icons.event,
                          title: "Upcoming Trips",
                          value: "30",
                        ),
                        SizedBox(width: 12),
                        CommonCard(
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
              CommonSearchBar(screen: "Fleetscreen",),
              // FleetTableWidget(vehicles: vehicles),
              Common_Table(
                dataColumnList: const [
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
                          child: const Icon(Icons.edit),
                          onTap: (){
                                showDialog(context: context, builder: (BuildContext context){
                  return CommonAlertBox(title: "Alert !", content: "Are you sure to edit this entry ?", positiveText: "Yes", onPositivePressed: (){}, negativeText: "No", onNegativePressed: (){});

                                });
                            print("Edit tapped");
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(

                          child: const Icon(
                              color: Colors.red,
                              Icons.delete),
                          onTap: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return CommonAlertBox(title: "Alert !", content: "Are you sure to delete this entry ?", positiveText: "Yes", onPositivePressed: (){}, negativeText: "No", onNegativePressed: (){});

                            });
                            print("Edit tapped");
                          },
                        ),
                        const SizedBox(
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