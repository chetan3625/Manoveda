import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:erptransportexpress/utils/Colors.dart'; // तुझा colors file

class EditTableFleetscreen extends StatefulWidget {
  const EditTableFleetscreen({super.key});

  @override
  State<EditTableFleetscreen> createState() => _EditTableFleetscreenState();
}

class _EditTableFleetscreenState extends State<EditTableFleetscreen> {
  List<VehicleModel> vehicles = [];

  // Controllers for TextFields
  final TextEditingController vehNoController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController driverController = TextEditingController();
  final TextEditingController lastServiceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  void _addVehicle() {
    // It's good practice to check if the widget is still mounted
    // before calling setState, especially if _addVehicle could be
    // called from an async callback in the future.
    if (!mounted) return;

    setState(() {
      vehicles.add(VehicleModel(
        vehNoController.text,
        typeController.text,
        capacityController.text,
        statusController.text,
        driverController.text,
        lastServiceController.text,
        startDateController.text,
        endDateController.text,
      ));
    });

    // Clear TextFields after adding
    vehNoController.clear();
    typeController.clear();
    capacityController.clear();
    statusController.clear();
    driverController.clear();
    lastServiceController.clear();
    startDateController.clear();
    endDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Define a common border style to avoid repetition
    final OutlineInputBorder textFieldBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey), // You can customize the color
      borderRadius: BorderRadius.circular(8.0), // Optional: for rounded corners
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: common_Colors.textColor),
        title: Text(
          "Vehicle Management",
          style: TextStyle(color: common_Colors.textColor),
        ),
        backgroundColor: common_Colors.primaryColor,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(

          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,// Added SingleChildScrollView to prevent overflow
            child: Row(
              children: [
                // Form to add vehicle
                Container(
                  width: screenWidth*0.3,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: vehNoController,
                            decoration: InputDecoration(
                              labelText: "Vehicle No",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: typeController,
                            decoration: InputDecoration(
                              labelText: "Type",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: capacityController,
                            decoration: InputDecoration(
                              labelText: "Capacity",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: statusController,
                            decoration: InputDecoration(
                              labelText: "Status",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: driverController,
                            decoration: InputDecoration(
                              labelText: "Driver",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: lastServiceController,
                            decoration: InputDecoration(
                              labelText: "Last Service",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: "Start Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: "End Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 20),
                          commonButton(
                            text: "Add Vehicle",
                            onPressed: () {
                              _addVehicle(); // Correctly call the function
                              print(vehicles);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth*0.3,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: vehNoController,
                            decoration: InputDecoration(
                              labelText: "Vehicle No",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: typeController,
                            decoration: InputDecoration(
                              labelText: "Type",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: capacityController,
                            decoration: InputDecoration(
                              labelText: "Capacity",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: statusController,
                            decoration: InputDecoration(
                              labelText: "Status",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: driverController,
                            decoration: InputDecoration(
                              labelText: "Driver",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: lastServiceController,
                            decoration: InputDecoration(
                              labelText: "Last Service",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: "Start Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: "End Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 20),
                          commonButton(
                            text: "Add Vehicle",
                            onPressed: () {
                              _addVehicle(); // Correctly call the function
                              print(vehicles);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth*0.3,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: vehNoController,
                            decoration: InputDecoration(
                              labelText: "Vehicle No",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: typeController,
                            decoration: InputDecoration(
                              labelText: "Type",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: capacityController,
                            decoration: InputDecoration(
                              labelText: "Capacity",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: statusController,
                            decoration: InputDecoration(
                              labelText: "Status",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: driverController,
                            decoration: InputDecoration(
                              labelText: "Driver",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: lastServiceController,
                            decoration: InputDecoration(
                              labelText: "Last Service",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: "Start Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: "End Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 20),
                          commonButton(
                            text: "Add Vehicle",
                            onPressed: () {
                              _addVehicle(); // Correctly call the function
                              print(vehicles);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: screenWidth*0.3,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: vehNoController,
                            decoration: InputDecoration(
                              labelText: "Vehicle No",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: typeController,
                            decoration: InputDecoration(
                              labelText: "Type",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: capacityController,
                            decoration: InputDecoration(
                              labelText: "Capacity",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: statusController,
                            decoration: InputDecoration(
                              labelText: "Status",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: driverController,
                            decoration: InputDecoration(
                              labelText: "Driver",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: lastServiceController,
                            decoration: InputDecoration(
                              labelText: "Last Service",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: startDateController,
                            decoration: InputDecoration(
                              labelText: "Start Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: endDateController,
                            decoration: InputDecoration(
                              labelText: "End Date",
                              border: textFieldBorder, // Apply the defined border
                            ),
                          ),
                          SizedBox(height: 20),
                          commonButton(
                            text: "Add Vehicle",
                            onPressed: () {
                              _addVehicle(); // Correctly call the function
                              print(vehicles);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                )




              ],
            ),
          ),
        ),
      ),
    );
  }
}
