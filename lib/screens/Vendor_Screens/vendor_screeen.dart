import 'package:erptransportexpress/screens/Vendor_Screens/edit_table_vendor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Common Widgets/FleetTableWidget.dart';
import '../../Common Widgets/card.dart';
import '../../Common Widgets/filter.dart';
import '../../Common Widgets/serachbar.dart';
import '../../models/FilterModel.dart';
import '../../models/SubFilterOptionModel.dart';
import '../../models/VehicleModel.dart';
import '../../utils/Colors.dart';
import '../../widgets/custom_form_filed.dart';
import '../../widgets/sidebar.dart';
import '../Fleet_Screens/Edit_Table_FleetScreen.dart';


class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});


  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
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
        title: Text("Vendor Screen", style: TextStyle(color: Colors.white)),
      ),
      drawer: Sidebar(),
      floatingActionButton: SizedBox(

        height: 70,
        width: 150,
        child: FloatingActionButton(

          backgroundColor: common_Colors.primaryColor,
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditTableVendorScreen())
            );
          },
          child: Text("Add a Vendor",style: TextStyle(
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
              CustomSearchBar(screen: "Vendor Screen", scaffoldKey: _scaffoldKey),
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

