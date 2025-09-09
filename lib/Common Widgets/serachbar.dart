import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final String screen;

  const CustomSearchBar({super.key, required this.screen});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final doubleScreenWidth=MediaQuery.of(context).size.width;
    double unit = doubleScreenWidth/6;
    final doubleScreenHeight=MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Container(
        width: doubleScreenWidth - doubleScreenWidth*0.06,

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // LHS: Screen Name
              Text(
                widget.screen,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // Flexible gap
              const Spacer(),

              // RHS: Search Bar (with Search Button inside)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),

                      // Text Field
                      Flexible(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Search in ${widget.screen}",
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Search Button inside Search Bar
                      ElevatedButton(

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {
                          String searchText = _controller.text;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Searching for: $searchText")),
                          );
                        },
                        child: const Text(
                          "Search",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Filter Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  backgroundColor: Colors.red,
                ),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                child: const Text(
                  "Filters",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
