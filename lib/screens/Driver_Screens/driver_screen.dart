import 'package:erptransportexpress/Common%20Widgets/CommonAlertBox.dart';
import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/CommonFilter.dart';
import 'package:flutter/material.dart';

import '../../Common Widgets/FleetTableWidget.dart';
import '../../Common Widgets/serachbar.dart';
import '../../models/FilterModel.dart' show FilterModel;
import '../../models/SubFilterOptionModel.dart';
import '../../models/VehicleModel.dart';
import '../../utils/Colors.dart';
import '../../widgets/sidebar.dart';
import '../Dashboard_Screens/dashboard_screen.dart';
import 'AddNewDriverForm.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {

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
  ];

  void deleteFromRow(String vehicleno) {
    setState(() {
      // Logic to delete the vehicle from the list
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      appBar: CommonAppBar(title: Text("DriverScreen")),
      drawer: const Sidebar(),
      floatingActionButton: SizedBox(
        height: 70,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: common_Colors.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNewDriverForm()),
            );
          },
          child: const Text(
            "Add a Driver",
            style: TextStyle(
              color: common_Colors.textColor,
            ),
          ),
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
        ],
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const CommonSearchBar(screen: "Driver Screen"),
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
                  DataColumn(label: Expanded(child: Text("Actions"))),
                ],
                dataRowList: vehicles.map((vehicle) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddNewDriverForm(isDriverEditable: true,)),
                            );
                          },
                          child: const Icon(
                            color: Colors.blue,
                              Icons.remove_red_eye_outlined),
                        ),
                        InkWell(
                          child: const Icon(Icons.edit),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommonAlertBox(
                                  title: "Alert",
                                  content: "Do you want to edit this entry?",
                                  positiveText: "Yes",
                                  onPositivePressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddNewDriverForm(isDriverEditable: false,)),
                                    );
                                  },
                                  negativeText: "No",
                                  onNegativePressed: () {
                                    // The CommonAlertBox will handle popping the dialog
                                  },
                                );
                              },
                            );
                          },
                        ),
                        InkWell(
                          child: const Icon(
                            color: Colors.red,
                            Icons.delete,
                          ),
                          onTap: () {
                            print("delete tapped");
                          },
                        ),
                      ],
                    )),
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