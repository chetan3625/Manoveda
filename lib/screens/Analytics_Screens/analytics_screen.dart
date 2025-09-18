// analytics_dashboard.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';

/// Models
class Vehicle {
  final String id;
  final String name;
  final bool active;
  Vehicle({required this.id, required this.name, required this.active});
}

class Trip {
  final String id;
  final String vehicleId;
  final String client;
  final String routeName;
  final DateTime date;
  final double revenue;
  final double cost;
  final String vendorId;
  Trip({
    required this.id,
    required this.vehicleId,
    required this.client,
    required this.routeName,
    required this.date,
    required this.revenue,
    required this.cost,
    required this.vendorId,
  });
  double get profit => revenue - cost;
}

class Expense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String vendorId;
  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.vendorId,
  });
}

class Vendor {
  final String id;
  final String name;
  Vendor({required this.id, required this.name});
}

class VendorPerf {
  final String vendorId;
  final String vendorName;
  double totalRevenue = 0;
  double totalCost = 0;
  double totalExpenses = 0;
  int trips = 0;
  VendorPerf({required this.vendorId, required this.vendorName});
  double get profit => totalRevenue - (totalCost + totalExpenses);
}

/// Screen
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // sample in-memory data
  late List<Vehicle> vehicles;
  late List<Trip> trips;
  late List<Expense> expenses;
  late List<Vendor> vendors;

  // date filters
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initSampleData();
  }

  void _initSampleData() {
    vendors = [
      Vendor(id: 'v1', name: 'SpeedTransports'),
      Vendor(id: 'v2', name: 'BlueLogistics'),
      Vendor(id: 'v3', name: 'PrimeHaul'),
    ];

    vehicles = [
      Vehicle(id: 'veh1', name: 'TRK-1001', active: true),
      Vehicle(id: 'veh2', name: 'TRK-1002', active: false),
      Vehicle(id: 'veh3', name: 'TRK-1003', active: true),
      Vehicle(id: 'veh4', name: 'TRK-1004', active: false),
      Vehicle(id: 'veh5', name: 'TRK-1005', active: true),
    ];

    final rand = Random(42);
    final clientNames = ['ACME', 'BetaCorp', 'Gamma Traders', 'Delta Movers'];
    final routeNames = ['Delhi-Mumbai', 'Mumbai-Pune', 'Pune-Bengaluru', 'Bengaluru-Chennai'];

    trips = List.generate(20, (i) {
      final vendor = vendors[rand.nextInt(vendors.length)];
      final vehicle = vehicles[rand.nextInt(vehicles.length)];
      final client = clientNames[i % clientNames.length];
      final route = routeNames[i % routeNames.length];
      final date = DateTime.now().subtract(Duration(days: rand.nextInt(60)));
      final revenue = 5000 + rand.nextInt(45000);
      final cost = revenue * (0.4 + rand.nextDouble() * 0.4);
      return Trip(
        id: 'trip${i + 1}',
        vehicleId: vehicle.id,
        client: client,
        routeName: route,
        date: date,
        revenue: revenue.toDouble(),
        cost: double.parse(cost.toStringAsFixed(2)),
        vendorId: vendor.id,
      );
    });

    expenses = [
      Expense(id: 'e1', category: 'Fuel', amount: 4200, date: DateTime.now().subtract(const Duration(days: 5)), vendorId: 'v1'),
      Expense(id: 'e2', category: 'Maintenance', amount: 12000, date: DateTime.now().subtract(const Duration(days: 20)), vendorId: 'v2'),
      Expense(id: 'e3', category: 'Toll', amount: 800, date: DateTime.now().subtract(const Duration(days: 3)), vendorId: 'v1'),
      Expense(id: 'e4', category: 'Rental', amount: 20000, date: DateTime.now().subtract(const Duration(days: 40)), vendorId: 'v3'),
      Expense(id: 'e5', category: 'Fuel', amount: 3600, date: DateTime.now().subtract(const Duration(days: 12)), vendorId: 'v2'),
    ];
  }

  // Filtering helpers
  List<Trip> get _filteredTrips => trips.where((t) => !t.date.isBefore(_from) && !t.date.isAfter(_to)).toList();
  List<Expense> get _filteredExpenses => expenses.where((e) => !e.date.isBefore(_from) && !e.date.isAfter(_to)).toList();

  // 1. Fleet utilization
  Map<String, int> computeFleetUtilization() {
    final active = vehicles.where((v) => v.active).length;
    final idle = vehicles.length - active;
    return {'active': active, 'idle': idle, 'total': vehicles.length};
  }

  // 2. Revenue by client & route
  Map<String, double> revenueByClient() {
    final map = <String, double>{};
    for (var t in _filteredTrips) {
      map[t.client] = (map[t.client] ?? 0) + t.revenue;
    }
    return map;
  }

  Map<String, double> revenueByRoute() {
    final map = <String, double>{};
    for (var t in _filteredTrips) {
      map[t.routeName] = (map[t.routeName] ?? 0) + t.revenue;
    }
    return map;
  }

  // 3. Expense breakdown
  Map<String, double> expenseBreakdown() {
    final map = <String, double>{};
    for (var e in _filteredExpenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  // 4. Vendor performance
  Map<String, VendorPerf> computeVendorPerformance() {
    final map = <String, VendorPerf>{};
    for (var v in vendors) {
      map[v.id] = VendorPerf(vendorId: v.id, vendorName: v.name);
    }

    for (var t in _filteredTrips) {
      final vp = map[t.vendorId];
      if (vp != null) {
        vp.totalRevenue += t.revenue;
        vp.totalCost += t.cost;
        vp.trips += 1;
      }
    }

    for (var e in _filteredExpenses) {
      final vp = map[e.vendorId];
      if (vp != null) vp.totalExpenses += e.amount;
    }

    return map;
  }

  // 5. Top profitable & loss-making trips/clients
  List<Trip> topProfitableTrips(int n) {
    final sorted = List<Trip>.from(_filteredTrips)..sort((a, b) => b.profit.compareTo(a.profit));
    return sorted.take(n).toList();
  }

  List<Trip> topLossMakingTrips(int n) {
    final sorted = List<Trip>.from(_filteredTrips)..sort((a, b) => a.profit.compareTo(b.profit));
    return sorted.take(n).toList();
  }

  List<MapEntry<String, double>> topProfitableClients(int n) {
    final map = <String, double>{};
    for (var t in _filteredTrips) {
      map[t.client] = (map[t.client] ?? 0) + (t.revenue - t.cost);
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(n).toList();
  }

  List<MapEntry<String, double>> topLossClients(int n) {
    final map = <String, double>{};
    for (var t in _filteredTrips) {
      map[t.client] = (map[t.client] ?? 0) + (t.revenue - t.cost);
    }
    final entries = map.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    return entries.take(n).toList();
  }

  // UI helpers
  Widget _barRow(String label, double value, double maxValue, {Color color = Colors.blue}) {
    final maxBarWidth = 160.0;
    // compute raw width, then clamp with double bounds so result is a double
    final rawWidth = maxValue <= 0 ? 0.0 : (value / maxValue) * maxBarWidth;
    final barWidth = rawWidth.clamp(0.0, maxBarWidth);

    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        const SizedBox(width: 8),
        Container(
          height: 14,
          width: barWidth, // now a double
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(width: 8),
        Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(context: context, initialDate: _from, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(context: context, initialDate: _to, firstDate: _from, lastDate: DateTime.now());
    if (picked != null) setState(() => _to = picked);
  }

  void _showCsvExport(String label, String csv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('CSV export: $label'),
        content: SizedBox(width: double.maxFinite, child: SingleChildScrollView(child: SelectableText(csv))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _exportSummaryCsv() {
    final sb = StringBuffer();
    sb.writeln('Report,From,To');
    sb.writeln('Analytics,${_from.toIso8601String()},${_to.toIso8601String()}');
    sb.writeln('');
    sb.writeln('Fleet Utilization,Active,Idle,Total');
    final fu = computeFleetUtilization();
    sb.writeln('Fleet,${fu['active']},${fu['idle']},${fu['total']}');
    sb.writeln('');
    sb.writeln('Revenue by Client,Client,Revenue');
    revenueByClient().forEach((k, v) => sb.writeln('Client,$k,${v.toStringAsFixed(2)}'));
    sb.writeln('');
    sb.writeln('Revenue by Route,Route,Revenue');
    revenueByRoute().forEach((k, v) => sb.writeln('Route,$k,${v.toStringAsFixed(2)}'));
    sb.writeln('');
    sb.writeln('Expense Breakdown,Category,Amount');
    expenseBreakdown().forEach((k, v) => sb.writeln('Expense,$k,${v.toStringAsFixed(2)}'));
    _showCsvExport('Analytics summary', sb.toString());
  }

  @override
  Widget build(BuildContext context) {
    final fu = computeFleetUtilization();
    final revClients = revenueByClient();
    final revRoutes = revenueByRoute();
    final expBreak = expenseBreakdown();
    final vendorsPerf = computeVendorPerformance();
    final topProfTrips = topProfitableTrips(5);
    final topLossTrips = topLossMakingTrips(5);
    final topProfClients = topProfitableClients(5);
    final topLossClientEntries = topLossClients(5);

    final maxRev = [
      if (revClients.isNotEmpty) revClients.values.reduce(max),
      if (revRoutes.isNotEmpty) revRoutes.values.reduce(max),
      1.0
    ].fold<double>(0, (prev, e) => max(prev, e));
    final maxExp = expBreak.isNotEmpty ? expBreak.values.reduce(max) : 1.0;

    // Convert maps to sorted lists for consistent UI rendering
    final revClientsList = revClients.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final revRoutesList = revRoutes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final expBreakList = expBreak.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final vendorPerfList = vendorsPerf.values.toList()..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Dashboard'),
        actions: [
          IconButton(
            onPressed: _exportSummaryCsv,
            icon: const Icon(Icons.download),
            tooltip: 'Export summary CSV',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // date filters
            Row(children: [
              ElevatedButton(onPressed: _pickFromDate, child: Text('From: ${_from.toShortDateString()}')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _pickToDate, child: Text('To: ${_to.toShortDateString()}')),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _from = DateTime.now().subtract(const Duration(days: 30));
                    _to = DateTime.now();
                  });
                },
                child: const Text('Last 30d'),
              ),
              const Spacer(),
              Text('Trips: ${_filteredTrips.length}  •  Expenses: ${_filteredExpenses.length}'),
            ]),
            const SizedBox(height: 12),

            // summary cards
            Row(
              children: [
                _summaryCard('Fleet Utilization', '${fu['active']}/${fu['total']} active', Icons.directions_car, Colors.blue),
                const SizedBox(width: 8),
                _summaryCard('Total Revenue', '₹${_filteredTrips.fold(0.0, (s, t) => s + t.revenue).toStringAsFixed(0)}', Icons.currency_rupee, Colors.green),
                const SizedBox(width: 8),
                _summaryCard('Total Expenses', '₹${_filteredExpenses.fold(0.0, (s, e) => s + e.amount).toStringAsFixed(0)}', Icons.money, Colors.red),
              ],
            ),
            const SizedBox(height: 12),

            // analytics sections
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Fleet utilization'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text('Active: ${fu['active']}', style: const TextStyle(fontSize: 16)),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(value: (fu['active']! / (fu['total']!.toDouble())), minHeight: 12),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Idle: ${fu['idle']}', style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('Total: ${fu['total']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Revenue by client'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: revClientsList.isEmpty
                              ? [const Text('No revenue in selected range.')]
                              : revClientsList.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: _barRow(e.key, e.value, maxRev, color: Colors.green.shade700),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Revenue by route'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: revRoutesList.isEmpty
                              ? [const Text('No route revenue.')]
                              : revRoutesList.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: _barRow(e.key, e.value, maxRev),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Expense breakdown'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: expBreakList.isEmpty
                              ? [const Text('No expenses in selected range.')]
                              : expBreakList.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: _barRow(e.key, e.value, maxExp, color: Colors.orange.shade700),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Vendor performance'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: vendorPerfList.isEmpty
                              ? [const Text('No vendor data.')]
                              : vendorPerfList.map((vp) => ListTile(
                            title: Text(vp.vendorName),
                            subtitle: Text('Trips: ${vp.trips}  •  Revenue: ₹${vp.totalRevenue.toStringAsFixed(0)}  •  Expenses: ₹${vp.totalExpenses.toStringAsFixed(0)}'),
                            trailing: Text('Profit ₹${vp.profit.toStringAsFixed(0)}', style: TextStyle(color: vp.profit >= 0 ? Colors.green : Colors.red)),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Top profitable trips'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: topProfTrips.isEmpty
                              ? [const Text('No trips.')]
                              : topProfTrips.map((t) => ListTile(
                            title: Text('${t.id} • ${t.client} • ${t.routeName}'),
                            subtitle: Text('${t.date.toShortDateString()} • Revenue ₹${t.revenue.toStringAsFixed(0)} • Cost ₹${t.cost.toStringAsFixed(0)}'),
                            trailing: Text('Profit ₹${t.profit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green)),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Top loss-making trips'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: topLossTrips.isEmpty
                              ? [const Text('No trips.')]
                              : topLossTrips.map((t) => ListTile(
                            title: Text('${t.id} • ${t.client} • ${t.routeName}'),
                            subtitle: Text('${t.date.toShortDateString()} • Revenue ₹${t.revenue.toStringAsFixed(0)} • Cost ₹${t.cost.toStringAsFixed(0)}'),
                            trailing: Text('Profit ₹${t.profit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red)),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Top profitable clients'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: topProfClients.isEmpty
                              ? [const Text('No client profits.')]
                              : topProfClients.map((e) => ListTile(
                            title: Text(e.key),
                            trailing: Text('Profit ₹${e.value.toStringAsFixed(0)}'),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle('Top loss-making clients'),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: topLossClientEntries.isEmpty
                              ? [const Text('No client losses.')]
                              : topLossClientEntries.map((e) => ListTile(
                            title: Text(e.key),
                            trailing: Text('Profit ₹${e.value.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red)),
                          )).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
    );
  }
}

/// Small helpers/extensions
extension DateHelpers on DateTime {
  String toShortDateString() => '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-${year}';
}

extension _IterableSorted<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) {
    final copy = List<T>.from(this);
    copy.sort(compare);
    return copy;
  }
}






