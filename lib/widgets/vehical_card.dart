import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleCard extends StatefulWidget {
  final Vehicle vehicle;
  final Function(String) onStatusChange;

  const VehicleCard({super.key, required this.vehicle, required this.onStatusChange});

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  @override
  Widget build(BuildContext context) {
    Color statusColor =
    widget.vehicle.status == "Active" ? Colors.green : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.directions_bus, color: Colors.blue),
        title: Text(widget.vehicle.number),
        subtitle: Text("${widget.vehicle.type} - ${widget.vehicle.capacity}"),
        trailing: DropdownButton<String>(
          value: widget.vehicle.status,
          items: const [
            DropdownMenuItem(value: "Active", child: Text("Active")),
            DropdownMenuItem(value: "Idle", child: Text("Idle")),
          ],
          onChanged: (value) {
            if (value != null) {
              widget.onStatusChange(value);
            }
          },
        ),
      ),
    );
  }
}
