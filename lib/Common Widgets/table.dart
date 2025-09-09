import 'package:erptransportexpress/models/VehicleModel.dart';
import 'package:flutter/material.dart';

class FleetTableWidget extends StatelessWidget {
  final List<VehicleModel> vehicles;

  const FleetTableWidget({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    final doubleScreenWidth=MediaQuery.of(context).size.width;
    final doubleScreenHeight=MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // कॉलम जास्त झाले तर स्क्रोल होईल
      child: Container(
        width: doubleScreenWidth - doubleScreenWidth*0.06,
        height:doubleScreenHeight*1,
        child: DataTable(
          dividerThickness: 2,
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
          border: TableBorder.all(color: Colors.blueGrey), // बॉर्डर
          columns: const [
            DataColumn(label: Text("Vehicle No")),
            DataColumn(label: Text("Type")),
            DataColumn(label: Text("Capacity")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Driver")),
            DataColumn(label: Text("Last Service")),
          ],
          rows: vehicles.map((vehicle) {
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
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
