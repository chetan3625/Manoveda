import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Super compact responsive sizes
    double cardWidth = screenWidth < 600
        ? screenWidth * 0.50 // 2 cards per row in mobile
        : screenWidth * 0.15; // 5-6 cards per row in desktop

    double cardHeight = 100; // fixed, very small

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Colors.blue, // 🔹 Blue border
            width: 2,
          ),
        ),
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 👈 evenly spread
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Row: icon + title
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 👈 center row items
                children: [
                  Icon(icon, color: Colors.blue, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              // Value
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
