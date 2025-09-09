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

    // Responsive width
    double cardWidth = screenWidth < 600 ? screenWidth * 0.5 : screenWidth * 0.2;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: cardWidth, // 👈 MediaQuery ने adjust होणार
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Center(
                    child: Text(
                      title,

                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
