import 'package:flutter/material.dart';
import 'api_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final Map<String, dynamic>? editMedicine;

  const AddMedicineScreen({super.key, this.editMedicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _compositionController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();
  final _dosageController = TextEditingController();
  final _sideEffectsController = TextEditingController();
  final _warningsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _requiresPrescription = false;
  bool _saving = false;
  DateTime? _expiryDate;

  final List<String> _categories = [
    'Pain Relief',
    'Antibiotics',
    'Vitamins',
    'Mental Wellness',
    'Digestive',
    'Heart',
    'Diabetes',
    'Respiratory',
    'Skin Care',
    'General'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editMedicine != null) {
      _loadMedicineData();
    }
  }

  void _loadMedicineData() {
    final m = widget.editMedicine!;
    _nameController.text = m['name'] ?? '';
    _categoryController.text = m['category'] ?? '';
    _descriptionController.text = m['description'] ?? '';
    _manufacturerController.text = m['manufacturer'] ?? '';
    _compositionController.text = m['composition'] ?? '';
    _batchNumberController.text = m['batchNumber'] ?? '';
    _priceController.text = (m['price'] ?? 0).toString();
    _discountedPriceController.text = (m['discountedPrice'] ?? 0).toString();
    _stockController.text = (m['stock'] ?? 0).toString();
    _unitController.text = m['unit'] ?? 'tablet';
    _dosageController.text = m['dosage'] ?? '';
    _sideEffectsController.text = m['sideEffects'] ?? '';
    _warningsController.text = m['warnings'] ?? '';
    _imageUrlController.text = m['imageUrl'] ?? '';
    _requiresPrescription = m['requiresPrescription'] ?? false;
    if (m['expiryDate'] != null) {
      _expiryDate = DateTime.tryParse(m['expiryDate'].toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    _compositionController.dispose();
    _batchNumberController.dispose();
    _priceController.dispose();
    _discountedPriceController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _dosageController.dispose();
    _sideEffectsController.dispose();
    _warningsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final data = {
      'name': _nameController.text.trim(),
      'category': _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'manufacturer': _manufacturerController.text.trim(),
      'composition': _compositionController.text.trim(),
      'batchNumber': _batchNumberController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'discountedPrice': double.tryParse(_discountedPriceController.text.trim()) ?? 0,
      'stock': int.tryParse(_stockController.text.trim()) ?? 0,
      'unit': _unitController.text.trim(),
      'dosage': _dosageController.text.trim(),
      'sideEffects': _sideEffectsController.text.trim(),
      'warnings': _warningsController.text.trim(),
      'imageUrl': _imageUrlController.text.trim(),
      'requiresPrescription': _requiresPrescription,
      'expiryDate': _expiryDate?.toIso8601String(),
    };

    Map<String, dynamic> response;
    if (widget.editMedicine != null) {
      response = await ApiService.updateMedicine(
        widget.editMedicine!['_id'].toString(),
        data,
      );
    } else {
      response = await ApiService.addMedicine(data);
    }

    if (!mounted) return;

    setState(() => _saving = false);

    if (response['success'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Failed to save medicine')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editMedicine != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _imageSection(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Medicine Name',
                    hint: 'e.g., Crocin 500mg',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown(
                    controller: _categoryController,
                    label: 'Category',
                    items: _categories,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'What is this medicine for',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _manufacturerController,
                    label: 'Manufacturer',
                    hint: 'e.g., Sun Pharma',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _compositionController,
                    label: 'Composition',
                    hint: 'e.g., Paracetamol 500mg',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _priceController,
                          label: 'Price (Rs)',
                          hint: '100',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _discountedPriceController,
                          label: 'Discounted Price (Rs)',
                          hint: '80',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _stockController,
                          label: 'Stock Quantity',
                          hint: '100',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _unitController,
                          label: 'Unit',
                          hint: 'tablet/syrup/capsule',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _dosageController,
                    label: 'Dosage Instructions',
                    hint: 'e.g., 1 tablet twice daily',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _sideEffectsController,
                    label: 'Side Effects',
                    hint: 'e.g., Drowsiness, Nausea',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _warningsController,
                    label: 'Warnings',
                    hint: 'e.g., Do not use during pregnancy',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _batchNumberController,
                    label: 'Batch Number',
                    hint: 'e.g., BN2024001',
                  ),
                  const SizedBox(height: 12),
                  _expiryPicker(),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Requires Prescription'),
                    subtitle: const Text('Customers need prescription to buy'),
                    value: _requiresPrescription,
                    onChanged: (v) => setState(() => _requiresPrescription = v),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _save,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(isEdit ? 'Update Medicine' : 'Add Medicine'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _imageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_imageUrlController.text.isNotEmpty)
            Image.network(
              _imageUrlController.text,
              height: 150,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.medication,
                size: 80,
                color: Colors.grey,
              ),
            )
          else
            const Icon(
              Icons.medication,
              size: 80,
              color: Colors.grey,
            ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _imageUrlController,
            label: 'Image URL',
            hint: 'https://example.com/medicine.jpg',
          ),
        ],
      ),
    );
  }

  Widget _expiryPicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Expiry Date'),
      subtitle: Text(
        _expiryDate != null
            ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
            : 'Not set',
      ),
      trailing: OutlinedButton(
        onPressed: _selectExpiryDate,
        child: const Text('Select'),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required TextEditingController controller,
    required String label,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) => controller.text = v ?? '',
    );
  }
}