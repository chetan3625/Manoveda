import 'package:flutter/material.dart';
import '../screens/Dashboard_Screens/dashboard_screen.dart';

import '../screens/Documents_Screens/documents_screen.dart';
import '../screens/Financials_Screens/financial_screen.dart';
import '../screens/Fleet_Screens/fleet_screen.dart';

import '../screens/Driver_Screens/driver_screen.dart';
import '../screens/Client_Screens/client_screen.dart';
import '../screens/Trip_Screens/trip_screen.dart';


import '../screens/Analytics_Screens/analytics_screen.dart';
import '../screens/Vendor_Screens/vendor_screeen.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("ERP", style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text("Fleet"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FleetScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text("Vendor"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VendorScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Driver"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DriverScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Client"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ClientScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text("Trip"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TripScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text("Financials"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FinancialsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Documents"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DocumentsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text("Analytics"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
