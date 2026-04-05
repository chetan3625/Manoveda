import 'package:flutter/material.dart';
import 'api_service.dart';

class MedicalKeeperStoresScreen extends StatefulWidget {
  const MedicalKeeperStoresScreen({super.key});

  @override
  State<MedicalKeeperStoresScreen> createState() => _MedicalKeeperStoresScreenState();
}

class _MedicalKeeperStoresScreenState extends State<MedicalKeeperStoresScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _keepers = [];
  Map<String, dynamic>? _selectedKeeper;
  List<Map<String, dynamic>> _medicines = [];
  bool _loadingMedicines = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final response = await ApiService.getMedicalKeepers();
    if (!mounted) return;
    setState(() {
      _keepers = _list(response, 'keepers');
      _loading = false;
    });
  }

  Future<void> _loadKeeperMedicines(String keeperId) async {
    setState(() => _loadingMedicines = true);
    final response = await ApiService.getMedicalKeeperStoreMedicines(keeperId);
    if (!mounted) return;
    setState(() {
      _medicines = _list(response, 'medicines');
      _loadingMedicines = false;
    });
  }

  void _selectKeeper(Map<String, dynamic> keeper) {
    setState(() => _selectedKeeper = keeper);
    _loadKeeperMedicines(keeper['_id'].toString());
  }

  Future<void> _addToCart(Map<String, dynamic> medicine) async {
    await ApiService.addToCartFromKeeper(
      keeperId: _selectedKeeper!['_id'].toString(),
      medicineId: medicine['_id'].toString(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Stores'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _selectedKeeper == null
              ? _keeperList()
              : _storeView(),
    );
  }

  Widget _keeperList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _keepers.length,
      itemBuilder: (context, index) {
        final keeper = _keepers[index];
        return _keeperCard(keeper);
      },
    );
  }

  Widget _keeperCard(Map<String, dynamic> keeper) {
    final address = keeper['address'] as Map<String, dynamic>? ?? {};
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.local_pharmacy, color: Colors.blue),
        ),
        title: Text(
          keeper['name']?.toString() ?? 'Medical Store',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${address['street'] ?? ''}, ${address['city'] ?? ''}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _selectKeeper(keeper),
      ),
    );
  }

  Widget _storeView() {
    final address = _selectedKeeper!['address'] as Map<String, dynamic>? ?? {};
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedKeeper = null),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedKeeper!['name']?.toString() ?? 'Store',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${address['street'] ?? ''}, ${address['city'] ?? ''}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingMedicines
              ? const Center(child: CircularProgressIndicator())
              : _medicines.isEmpty
                  ? const Center(child: Text('No medicines available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _medicines.length,
                      itemBuilder: (context, index) {
                        return _medicineCard(_medicines[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _medicineCard(Map<String, dynamic> medicine) {
    final price = medicine['price'] ?? 0;
    final discountedPrice = medicine['discountedPrice'] ?? price;
    final hasDiscount = discountedPrice < price;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (medicine['imageUrl'] != null && medicine['imageUrl'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    medicine['imageUrl'].toString(),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.medication),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.medication, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine['name']?.toString() ?? 'Medicine',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine['category']?.toString() ?? '',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    if (medicine['requiresPrescription'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Rx Required',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (hasDiscount)
                Text(
                  'Rs $price',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              if (hasDiscount) const SizedBox(width: 8),
              Text(
                'Rs $discountedPrice',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: hasDiscount ? Colors.green : Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                'Stock: ${medicine['stock'] ?? 0}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: medicine['stock'] > 0
                    ? () => _addToCart(medicine)
                    : null,
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _list(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is! List) {
    return [];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}