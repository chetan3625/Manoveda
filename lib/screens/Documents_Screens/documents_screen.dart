// document_compliance_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/custom_form_filed.dart';
import '../../widgets/sidebar.dart';
import '../Dashboard_Screens/dashboard_screen.dart';

enum DocType { insurance, permit, driverLicense, other }

class ComplianceDocument {
  final String id;
  final String name;
  final String? path;
  final DocType type;
  final DateTime expiryDate;
  final String notes;

  ComplianceDocument({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.expiryDate,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'type': type.toString().split('.').last,
    'expiryDate': expiryDate.toIso8601String(),
    'notes': notes,
  };
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  // Documents store (in-memory). Replace with secure storage / cloud later.
  final List<ComplianceDocument> _documents = [];

  // form controllers
  final TextEditingController _nameController = TextEditingController();
  DocType _selectedType = DocType.insurance;
  DateTime _selectedExpiry = DateTime.now().add(const Duration(days: 365));
  final TextEditingController _notesController = TextEditingController();

  // File picker selected file info (for form)
  String? _pickedFilePath;
  String? _pickedFileName;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _pickFileForForm() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _pickedFileName = file.name;
        _pickedFilePath = file.path; // may be null in web; for mobile it's ok
      });
    }
  }

  void _saveDocument() {
    final name =
    _nameController.text.trim().isEmpty ? (_pickedFileName ?? 'Unnamed') : _nameController.text.trim();

    if (_pickedFileName == null && _pickedFilePath == null) {
      _showSnack('Please pick a document file first');
      return;
    }


    final doc = ComplianceDocument(
      id: _generateId(),
      name: name,
      path: _pickedFilePath,
      type: _selectedType,
      expiryDate: _selectedExpiry,
      notes: _notesController.text.trim(),
    );

    setState(() {
      _documents.insert(0, doc);
      // clear form
      _pickedFileName = null;
      _pickedFilePath = null;
      _nameController.clear();
      _notesController.clear();
      _selectedExpiry = DateTime.now().add(const Duration(days: 365));
    });
    _showSnack('Document saved.');
  }
  List<ComplianceDocument> get _allDocuments => _documents;

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';

  void _showSnack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: AppBar(
        title: const Text('Document & Compliance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Upload / Create document card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Add / Upload Document', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    ElevatedButton.icon(
                      onPressed: _pickFileForForm,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pick file'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_pickedFileName ?? 'No file chosen')),
                  ]),
                  const SizedBox(height: 8),
                  CustomFormField(
                    allowOnlyNumbers: false,
                    caplebal: 'Document name',
                    label: 'Name',
                    hint: 'E.g., Insurance policy for Truck 123',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Text('Type: '),
                    const SizedBox(width: 8),
                    DropdownButton<DocType>(
                      value: _selectedType,
                      onChanged: (v) => setState(() => _selectedType = v ?? DocType.other),
                      items: DocType.values
                          .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t == DocType.insurance
                            ? 'Insurance'
                            : t == DocType.permit
                            ? 'Permit'
                            : t == DocType.driverLicense
                            ? 'Driver License'
                            : 'Other'),
                      ))
                          .toList(),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedExpiry,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) setState(() => _selectedExpiry = picked);
                      },
                      child: Text('Expiry: ${_formatDate(_selectedExpiry)}'),
                    )
                  ]),
                  const SizedBox(height: 8),
                  CustomFormField(
                    allowOnlyNumbers: false,
                    caplebal: 'Notes',
                    label: 'Notes',
                    hint: 'Optional note or description',
                    controller: _notesController,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveDocument,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Document'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Clear form
                          setState(() {
                            _pickedFileName = null;
                            _pickedFilePath = null;
                            _nameController.clear();
                            _notesController.clear();
                            _selectedExpiry = DateTime.now().add(const Duration(days: 365));
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 12),

            // All documents list
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('All Documents', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_allDocuments.isEmpty)
                    const Text('No documents saved yet.')

                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
