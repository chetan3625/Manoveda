import 'package:erptransportexpress/Common%20Widgets/CommonAlertBox.dart';
import 'package:erptransportexpress/Common%20Widgets/CommonFilter.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/screens/Vendor_Screens/AddNewVendorForm.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Common Widgets/Common_Table.dart' show Common_Table;
import '../../Common Widgets/serachbar.dart';
import '../../models/FilterModel.dart';
import '../../models/SubFilterOptionModel.dart';
import '../../models/VehicleModel.dart';
import '../../utils/Colors.dart';
import '../../widgets/custom_form_filed.dart';
import '../../widgets/sidebar.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
   final isVendorEditable=false;
   final List<VehicleModel> vehicles2 = [
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    void LoadMoreVendor(){
      setState(() {
        vehicles.addAll(vehicles2);
      });
    }
    return Scaffold(
      drawer: const Sidebar(),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: common_Colors.primaryColor,
        title: const Text("Vendor Screen", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 150,
        child: FloatingActionButton(
          backgroundColor: common_Colors.primaryColor,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewVendorForm()));
          },
          child: const Text("Add a Vendor", style: TextStyle(
            color: common_Colors.textColor,
          )),
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
              const CommonSearchBar(screen: "Vendor Screen"),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {

                            Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddNewVendorForm(isVendorEditable: true,)));

                              isVendorEditable:false;

                          },
                          child: const Icon(
                            color: Colors.blue,
                              Icons.remove_red_eye_outlined),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          child:  Icon(Icons.edit),
                          onTap: () {

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CommonAlertBox(
                                  title: "Alert !",
                                  content: Text("Are You Sure to Edit Vendor Entry"),
                                  positiveText: "Yes",
                                  onPositivePressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  AddNewVendorForm(isVendorEditable: false,)));
                                  },
                                  negativeText: "No",
                                  onNegativePressed: () {},
                                );
                              },
                            );
                              isVendorEditable:true;

                          },
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          child: const Icon(
                            color: Colors.red,
                            Icons.delete,
                          ),
                          onTap: () {
                            showDialog(context: context, builder: (BuildContext context) {
                              return CommonAlertBox(
                                title: "Alert !",
                                content: Text("Are You Sure to Delete Vendor Entry"),
                                positiveText: "Yes",
                                onPositivePressed: () {},
                                negativeText: "No",
                                onNegativePressed: () {},
                              );
                            });
                          },
                        ),
                      ],
                    ),

                    ),
                  ]
                  );
                }).toList(),
                onPressed: LoadMoreVendor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}