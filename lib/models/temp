import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';

class FleetTableWidget extends StatelessWidget {
  final List<DataRow> dataRowList;
  final List<DataColumn> dataColumnList;

  const FleetTableWidget({super.key,  required this.dataRowList ,  required this.dataColumnList});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: screenWidth), // 👈 minWidth = screen width
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: DataTable(
            dividerThickness: 2,
            headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
            border: TableBorder.all(color: Colors.blueGrey),
            // Stretch column cells equally
            columnSpacing: 40, // space between columns (tune as you like)
            columns: dataColumnList,
            rows:dataRowList,
          ),
        ),
      ),
    );
  }
}
