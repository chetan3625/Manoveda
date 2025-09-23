import 'package:erptransportexpress/Common%20Widgets/CommonAlertBox.dart';
import 'package:erptransportexpress/Common%20Widgets/CommonAppBar.dart';
import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:erptransportexpress/Common%20Widgets/serachbar.dart';

import 'package:erptransportexpress/screens/Client_Screens/addclient.dart';
import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/FilterModel.dart';
import 'package:erptransportexpress/models/SubFilterOptionModel.dart';
import '../../Common Widgets/CommonFilter.dart';
import '../../Common Widgets/Common_Table.dart';
import '../../models/client_model.dart';
import '../../utils/Colors.dart' show common_Colors;
import '../Dashboard_Screens/dashboard_screen.dart';

class ClientScreen extends StatefulWidget implements PreferredSizeWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}

class _ClientScreenState extends State<ClientScreen> {
  List<ClientModel> demoClients = [
    ClientModel(
      clientId: "CLT001",
      companyName: "Tata Motors Logistics",
      phoneNumber: "+91-9876543210",
      clientEmail: "logistics@tatamotors.com",
      currentStatus: "Active",
      totalShipments: 145,
      startDate: "2022-01-15",
      endDate: "2024-01-14",
    ),
    ClientModel(
      clientId: "CLT002",
      companyName: "Reliance Industries",
      phoneNumber: "+91-9876543211",
      clientEmail: "shipping@reliance.com",
      currentStatus: "Active",
      totalShipments: 289,
      startDate: "2021-11-20",
      endDate: "2023-11-19",
    ),
    ClientModel(
      clientId: "CLT003",
      companyName: "Mahindra Logistics",
      phoneNumber: "+91-9876543212",
      clientEmail: "operations@mahindralogistics.com",
      currentStatus: "Pending",
      totalShipments: 67,
      startDate: "2023-03-01",
      endDate: "2025-02-28",
    ),
    ClientModel(
      clientId: "CLT004",
      companyName: "Blue Dart Express",
      phoneNumber: "+91-9876543213",
      clientEmail: "corporate@bluedart.com",
      currentStatus: "Active",
      totalShipments: 432,
      startDate: "2020-07-10",
      endDate: "2023-07-09",
    ),
    ClientModel(
      clientId: "CLT005",
      companyName: "Flipkart Supply Chain",
      phoneNumber: "+91-9876543214",
      clientEmail: "vendor@flipkart.com",
      currentStatus: "Active",
      totalShipments: 1205,
      startDate: "2019-05-05",
      endDate: "2024-05-04",
    ),
    ClientModel(
      clientId: "CLT006",
      companyName: "Amazon Transportation",
      phoneNumber: "+91-9876543215",
      clientEmail: "logistics@amazon.in",
      currentStatus: "Active",
      totalShipments: 2567,
      startDate: "2018-12-01",
      endDate: "2023-11-30",
    ),
    ClientModel(
      clientId: "CLT007",
      companyName: "Delhivery Private Ltd",
      phoneNumber: "+91-9876543216",
      clientEmail: "partnerships@delhivery.com",
      currentStatus: "Inactive",
      totalShipments: 89,
      startDate: "2022-08-25",
      endDate: "2023-08-24", // Example of an inactive client whose contract might have ended
    ),
    ClientModel(
      clientId: "CLT008",
      companyName: "ITC Infotech",
      phoneNumber: "+91-9876543217",
      clientEmail: "transport@itc.in",
      currentStatus: "Active",
      totalShipments: 178,
      startDate: "2023-02-10",
      endDate: "2025-02-09",
    ),
    ClientModel(
      clientId: "CLT009",
      companyName: "Godrej Industries",
      phoneNumber: "+91-9876543218",
      clientEmail: "supply@godrej.com",
      currentStatus: "Active",
      totalShipments: 234,
      startDate: "2021-06-18",
      endDate: "2024-06-17",
    ),
    ClientModel(
      clientId: "CLT010",
      companyName: "Maruti Suzuki India",
      phoneNumber: "+91-9876543219",
      clientEmail: "logistics@marutisuzuki.com",
      currentStatus: "Active",
      totalShipments: 789,
      startDate: "2020-09-01",
      endDate: "2025-08-31",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    void LoadMoreClient(){
      setState(() {
        demoClients.addAll(demoClients);
      });
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: SizedBox(
          height: 50,
          width: 190,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddClient())); // Added const
            },
            child: const Text( // Added const
              "Add Client",
              style: TextStyle(color: Colors.white),
            ),
          )),
      appBar: CommonAppBar(title: Text("ClienScreen")),
      body: CommonFilter(
        filters: [
          FilterModel("Status", [
            SubFilterOptionModel("Pending", 1, false),
            SubFilterOptionModel("In-Transit", 2, false),
            SubFilterOptionModel("Delivered", 3, false),
            SubFilterOptionModel("Cancelled", 4, false),
            SubFilterOptionModel("Delayed", 5, false),
          ]),
          FilterModel("Mode of Payment", [
            SubFilterOptionModel("Cash", 1, false),
            SubFilterOptionModel("Card", 2, false),
            SubFilterOptionModel("Online", 3, false),
            SubFilterOptionModel("Credit", 4, false),
          ]),
        ],
        child: Column(
          children: [
            CommonSearchBar(screen: "ClientScreen"),
            Expanded( // Added Expanded here if Common_Table is scrollable internally
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Common_Table(
                  dataRowList: demoClients.map((client) { // Changed 'demoClients' to 'client' for clarity
                    return DataRow(cells: [
                      DataCell(Text(client.clientId)),
                      DataCell(Text(client.companyName)),
                      DataCell(Text(client.phoneNumber)),
                      DataCell(Text(client.clientEmail)),
                      DataCell(Text(client.currentStatus)),
                      DataCell(Text(client.totalShipments.toString())),
                      DataCell(Text(client.startDate.toString())),
                      DataCell(Text(client.endDate.toString())),
                      // Added Total Shipments
                      // Assuming the next 3 columns are for actions or are currently empty placeholders
                      // If they are actions, you'd put IconButton or similar here.
                     // Placeholder for 'start date' or an action
                      DataCell(Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                        children: [
                          InkWell(
                            onTap: () {
                              print("View detail tapped");
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddClient(isClientEditable: true,)));
                            },
                            child: Icon(
                                color: Colors.blueAccent,
                                Icons.remove_red_eye_outlined),
                          ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(context: context, builder: (BuildContext context){
                              return CommonAlertBox(title: "Alert !", content: "Are you sure to edit this entry ?", positiveText: "Yes", onPositivePressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddClient(isClientEditable: false,)));
                              }, negativeText: "No", onNegativePressed: (){});

                            });
                            print("Edit tapped");
                                          },
                            child: Icon(Icons.edit)),

                          SizedBox(
                            width: 10,
                          ),
                        InkWell(
                          onTap: () {
                            showDialog(context: context, builder: (BuildContext context){
                              return CommonAlertBox(title: "Alert !", content: "Are You Sure to delete this client ?", positiveText: "Yes", onPositivePressed: (){}, negativeText: "No", onNegativePressed: (){});

                            });
                            print("delete tapped");
                          },
                          child: Icon(
                            color: Colors.red,
                              Icons.delete),

                        ),
                          SizedBox(
                            width: 10,
                          ),

                      ],)), // Placeholder for 'Actions'
                    ]);
                  }).toList(), // Convert the Iterable from .map() to a List<DataRow>
                  dataColumnList: const [ // Added const for performance if columns don't change
                    DataColumn(label: Expanded(child: Text("Client ID"))), // Changed header
                    DataColumn(label: Expanded(child: Text("Company"))),   // Changed header
                    DataColumn(label: Expanded(child: Text("Phone"))),      // Changed header
                    DataColumn(label: Expanded(child: Text("Email"))),      // Changed header
                    DataColumn(label: Expanded(child: Text("Status"))),     // Changed header (was correct)
                    DataColumn(label: Expanded(child: Text("Shipments"))),  // Added header
                    DataColumn(label: Expanded(child: Text("Last Service"))),
                    DataColumn(label: Expanded(child: Text("Start Date"))), // Corrected "start date"
                    DataColumn(label: Expanded(child: Text("Actions"))),
                  ],
                  onPressed: LoadMoreClient,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
