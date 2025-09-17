import 'package:flutter/material.dart';

class CustomTable extends StatefulWidget {
  final List<String> columns;          // headings
  final List<List<String>> rows;       // row data

  const CustomTable({
    super.key,
    required this.columns,
    required this.rows, required int width, required int height,
  });

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,   // छोट्या screen वर scroll
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.blue.shade100),
        border: TableBorder.all(color: Colors.grey.shade400),

        // 🔹 Step 1: Columns तयार करायचे
        columns: widget.columns
            .map(
              (col) => DataColumn(
            label: Text(
              col,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
            .toList(),

        // 🔹 Step 2: Rows तयार करायचे
        rows: widget.rows
            .map(
              (row) => DataRow(
            cells: row
                .map(
                  (cell) => DataCell(Text(cell)),
            )
                .toList(),
          ),
        )
            .toList(),
      ),
    );
  }
}
