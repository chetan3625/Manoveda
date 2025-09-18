import 'package:erptransportexpress/Common%20Widgets/serachbar.dart';
import 'package:erptransportexpress/models/FilterModel.dart';
import 'package:erptransportexpress/Common Widgets/FleetTableWidget.dart';
import 'package:erptransportexpress/models/SubFilterOptionModel.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/screens/Fleet_Screens/AddNewVehicleForm.dart';
import 'package:erptransportexpress/utils/Colors.dart';
import 'package:flutter/material.dart';
import '../../Common Widgets/CommonAlertBox.dart';
import '../../Common Widgets/CommonAppBar.dart';
import '../../Common Widgets/CommonCard.dart';
import '../../Common Widgets/CommonFilter.dart';
import '../../widgets/sidebar.dart';



class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen> {
  final isEditable=false;
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

  void deleteFromRow(String vehicleno) {
    setState(() {
      vehicles.removeWhere((vehicle) => vehicle.vehileNo == vehicleno);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: const CommonAppBar(title: Text("FleetScreen")),
      drawer: const Sidebar(),
      floatingActionButton: SizedBox(
        height: 70,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: common_Colors.primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddNewVehicleForm()),
            );
          },
          child: const Text(
            "Add a Vehicle",
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: const [
                        SizedBox(width: 12),
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
                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ),
              const CommonSearchBar(screen: "Fleetscreen"),
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
                              MaterialPageRoute(
                                builder: (context) => AddNewVehicleForm(
                                  isEditable: true, // For "view" mode, set this to false
                                ),
                              ),
                            );
                          },
                          child: const Icon(
                            color: Colors.lightBlue,
                            Icons.remove_red_eye_outlined,
                          ),
                        ),
                        InkWell(
                          child: const Icon(Icons.edit),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommonAlertBox(
                                  title: "Alert !",
                                  content: "Are you sure to edit this entry?",
                                  positiveText: "Yes",
                                  onPositivePressed: () {
                                    isEditable : true;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddNewVehicleForm(
                                          vehicle: vehicle,
                                          isEditable: false, // For "edit" mode, set this to true
                                        ),
                                      ),
                                    );
                                  },
                                  negativeText: "No",
                                  onNegativePressed: () {
                                    Navigator.of(context).pop();
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommonAlertBox(
                                  title: "Alert !",
                                  content: "Are you sure to delete this entry?",
                                  positiveText: "Yes",
                                  onPositivePressed: () {
                                    deleteFromRow(vehicle.vehileNo);
                                    Navigator.of(context).pop();
                                  },
                                  negativeText: "No",
                                  onNegativePressed: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            );
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