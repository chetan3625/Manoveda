import 'package:erptransportexpress/Common%20Widgets/common_buttons.dart';
import 'package:flutter/material.dart';
import 'package:erptransportexpress/models/VehicleModel.dart';

class Common_Table extends StatefulWidget {
  final List<DataRow> dataRowList;
  final List<DataColumn> dataColumnList;
  final VoidCallback onPressed;

  const Common_Table({
    super.key,
    required this.dataRowList,
    required this.dataColumnList,
    required this.onPressed,
  });

  @override
  State<Common_Table> createState() => _Common_TableState();
}

class _Common_TableState extends State<Common_Table> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: screenWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), // 👈 added vertical padding
              child: DataTable(
                dividerThickness: 2,
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
                border: TableBorder.all(color: Colors.blueGrey),
                columnSpacing: 40,
                columns: widget.dataColumnList,
                rows: widget.dataRowList,
              ),
            ),
          ),
          CommonButton(
            text: "Load More",
            onPressed: widget.onPressed,
          ),
        ],
      ),
    );
  }
}
