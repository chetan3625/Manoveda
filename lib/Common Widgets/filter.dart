import 'package:erptransportexpress/models/FilterModel.dart';
import 'package:flutter/material.dart';

class FleetFilterWidget extends StatefulWidget {
  final Widget child; // main content of the screen
  final List<FilterModel> filters; // filter options
  final double drawerWidth;

  const FleetFilterWidget({
    super.key,
    required this.child,
    required this.filters,
    this.drawerWidth = 300,
  });

  @override
  State<FleetFilterWidget> createState() => _FleetFilterWidgetState();
}

class _FleetFilterWidgetState extends State<FleetFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Right-side drawer
      endDrawer: Drawer(
        width: widget.drawerWidth,
        child: SafeArea(
          child: Column(

            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filters",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Filter options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: widget.filters.map((filterModel) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            filterModel.tittle,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Column(
                          children: filterModel.subOptions.map((subFilterModel) {
                            return StatefulBuilder(
                              builder: (context, setStateSB) {
                                return CheckboxListTile(
                                  title: Text(subFilterModel.subTittle),
                                  value: subFilterModel.isSelected,
                                  onChanged: (val) {
                                    setStateSB(() {
                                      subFilterModel.isSelected = val!;
                                    });
                                  },
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const Divider(),

                                             ],
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5)
                        ),
                        backgroundColor: Colors.red
                    ),
                    onPressed: (){

                    },
                    child: Text("Apply", style: TextStyle(
                        color: Colors.white
                    ),)
                ),
              )

            ],
          ),
        ),
      ),

      // Main content
      body: Builder(
        builder: (context) => Stack(
          children: [
            widget.child,
            // Filter button




          ],
        ),
      ),
    );
  }
}
