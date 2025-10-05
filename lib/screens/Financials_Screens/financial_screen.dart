// financials_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../widgets/custom_form_filed.dart';
import '../../widgets/sidebar.dart';
import '../Dashboard_Screens/dashboard_screen.dart';

enum InvoiceType { perTrip, monthly, contract }

class Invoice {
  final String id;
  final String partyName;
  final InvoiceType type;
  final DateTime date;
  final double amountBeforeGST;
  final double gstRate;
  final String notes;
  Invoice({
    required this.id,
    required this.partyName,
    required this.type,
    required this.date,
    required this.amountBeforeGST,
    required this.gstRate,
    required this.notes,
  });

  double get gstAmount => amountBeforeGST * gstRate / 100.0;
  double get total => amountBeforeGST + gstAmount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'partyName': partyName,
    'type': type.toString().split('.').last,
    'date': date.toIso8601String(),
    'amountBeforeGST': amountBeforeGST,
    'gstRate': gstRate,
    'gstAmount': gstAmount,
    'total': total,
    'notes': notes,
  };
}

class Expense {
  final String id;
  final String category;
  final DateTime date;
  final double amount;
  final String notes;
  Expense({
    required this.id,
    required this.category,
    required this.date,
    required this.amount,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'date': date.toIso8601String(),
    'amount': amount,
    'notes': notes,
  };
}

class FinancialsScreen extends StatefulWidget {
  const FinancialsScreen({Key? key}) : super(key: key);

  @override
  State<FinancialsScreen> createState() => _FinancialsScreenState();
}

class _FinancialsScreenState extends State<FinancialsScreen>
    with SingleTickerProviderStateMixin {
  // Data stores
  final List<Invoice> _invoices = [];
  final List<Expense> _expenses = [];

  // Invoice form controllers
  final TextEditingController _partyController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _gstController = TextEditingController(text: '18');
  final TextEditingController _notesController = TextEditingController();
  InvoiceType _selectedType = InvoiceType.perTrip;
  DateTime _selectedInvoiceDate = DateTime.now();

  // Expense form controllers
  final TextEditingController _expenseCategoryController = TextEditingController();
  final TextEditingController _expenseAmountController = TextEditingController();
  final TextEditingController _expenseNotesController = TextEditingController();
  DateTime _selectedExpenseDate = DateTime.now();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // sample data (optional)
    _invoices.add(
      Invoice(
        id: _generateId(),
        partyName: 'Sample Client A',
        type: InvoiceType.perTrip,
        date: DateTime.now().subtract(const Duration(days: 10)),
        amountBeforeGST: 8000,
        gstRate: 18,
        notes: 'Trip to Pune',
      ),
    );
    _expenses.add(
      Expense(
        id: _generateId(),
        category: 'Fuel',
        date: DateTime.now().subtract(const Duration(days: 2)),
        amount: 4200,
        notes: 'Diesel refill',
      ),
    );
  }

  @override
  void dispose() {
    _partyController.dispose();
    _amountController.dispose();
    _gstController.dispose();
    _notesController.dispose();
    _expenseCategoryController.dispose();
    _expenseAmountController.dispose();
    _expenseNotesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  double get totalRevenue =>
      _invoices.fold(0.0, (sum, inv) => sum + inv.total);

  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get profit => totalRevenue - totalExpenses;

  void _createInvoice({bool asEstimate = false}) {
    final party = _partyController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final gst = double.tryParse(_gstController.text.trim()) ?? 0.0;

    if (party.isEmpty || amount <= 0) {
      _showSnack('Enter valid party and amount');
      return;
    }

    final inv = Invoice(
      id: _generateId(),
      partyName: party,
      type: _selectedType,
      date: _selectedInvoiceDate,
      amountBeforeGST: amount,
      gstRate: gst,
      notes: _notesController.text.trim() + (asEstimate ? ' (ESTIMATE)' : ''),
    );

    setState(() {
      _invoices.insert(0, inv);
    });

    _clearInvoiceForm();
    _showSnack(asEstimate ? 'Estimate saved' : 'Invoice created');
  }

  void _clearInvoiceForm() {
    _partyController.clear();
    _amountController.clear();
    _gstController.text = '18';
    _notesController.clear();
    _selectedType = InvoiceType.perTrip;
    _selectedInvoiceDate = DateTime.now();
  }

  void _addExpense() {
    final cat = _expenseCategoryController.text.trim();
    final amount = double.tryParse(_expenseAmountController.text.trim()) ?? 0.0;
    if (cat.isEmpty || amount <= 0) {
      _showSnack('Enter valid expense category and amount');
      return;
    }
    final exp = Expense(
      id: _generateId(),
      category: cat,
      date: _selectedExpenseDate,
      amount: amount,
      notes: _expenseNotesController.text.trim(),
    );
    setState(() {
      _expenses.insert(0, exp);
    });
    _expenseCategoryController.clear();
    _expenseAmountController.clear();
    _expenseNotesController.clear();
    _selectedExpenseDate = DateTime.now();
    _showSnack('Expense added');
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Widget _buildInvoiceForm() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Use your CustomFormField for party
            CustomFormField(
              allowOnlyNumbers: false,
              caplebal: 'Client / Party',
              label: 'Party name',
              hint: 'Enter client or company name',
              controller: _partyController,
              keyboardType: TextInputType.text,
              isPassword: false,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomFormField(
                    allowOnlyNumbers: true,
                    caplebal: 'Amount (before GST)',
                    label: 'Amount',
                    hint: 'Enter amount',
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 240,
                  child: CustomFormField(
                    allowOnlyNumbers: true,
                    caplebal: 'GST %',
                    label: 'GST',
                    hint: '18',
                    controller: _gstController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                DropdownButton<InvoiceType>(
                  value: _selectedType,
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                  items: InvoiceType.values.map((t) {
                    final text = t == InvoiceType.perTrip
                        ? 'Per Trip'
                        : t == InvoiceType.monthly
                        ? 'Monthly'
                        : 'Contract';
                    return DropdownMenuItem(value: t, child: Text(text));
                  }).toList(),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedInvoiceDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _selectedInvoiceDate = picked);
                  },
                  child: Text('Invoice Date: ${_selectedInvoiceDate.toShortDateString()}'),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            CustomFormField(
              allowOnlyNumbers: false,
              caplebal: 'Notes',
              label: 'Notes / Description',
              hint: 'E.g., route details, contract ref',
              controller: _notesController,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _createInvoice(asEstimate: true),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Save Estimate'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _createInvoice(asEstimate: false),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Create Invoice'),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList() {
    if (_invoices.isEmpty) {
      return const Center(child: Text('No invoices yet'));
    }
    return ListView.builder(
      itemCount: _invoices.length,
      itemBuilder: (context, idx) {
        final inv = _invoices[idx];
        return ListTile(
          leading: const Icon(Icons.receipt),
          title: Text('${inv.partyName} — ₹${inv.total.toStringAsFixed(2)}'),
          subtitle: Text('${inv.type.toString().split('.').last.toUpperCase()} • ${inv.date.toShortDateString()}'),
          trailing: PopupMenuButton<String>(
            onSelected: (s) {
              if (s == 'view') {
                _showInvoiceDialog(inv);
              } else if (s == 'delete') {
                setState(() => _invoices.removeAt(idx));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'view', child: Text('View')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab() {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                CustomFormField(
                  allowOnlyNumbers: false,
                  caplebal: 'Category',
                  label: 'Expense category',
                  hint: 'Fuel / Toll / Rental / Maintenance',
                  controller: _expenseCategoryController,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomFormField(
                        allowOnlyNumbers: true,
                        caplebal: 'Amount',
                        label: 'Amount',
                        hint: 'Enter expense amount',
                        controller: _expenseAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedExpenseDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _selectedExpenseDate = picked);
                      },
                      child: Text('Date: ${_selectedExpenseDate.toShortDateString()}'),
                    ),
                  ],
                ),
                CustomFormField(
                  allowOnlyNumbers: false,
                  caplebal: 'Notes',
                  label: 'Notes',
                  hint: 'Optional notes',
                  controller: _expenseNotesController,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _addExpense,
                      child: const Text('Add Expense'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Clear
                        _expenseCategoryController.clear();
                        _expenseAmountController.clear();
                        _expenseNotesController.clear();
                        _selectedExpenseDate = DateTime.now();
                      },
                      child: const Text('Clear'),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _expenses.isEmpty
              ? const Center(child: Text('No expenses yet'))
              : ListView.builder(
            itemCount: _expenses.length,
            itemBuilder: (context, idx) {
              final e = _expenses[idx];
              return ListTile(
                leading: const Icon(Icons.money_off),
                title: Text('${e.category} — ₹${e.amount.toStringAsFixed(2)}'),
                subtitle: Text('${e.date.toShortDateString()} • ${e.notes}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => _expenses.removeAt(idx)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfitabilityTab() {
    final Map<InvoiceType, double> breakdown = {
      for (var t in InvoiceType.values) t: 0.0
    };
    for (var inv in _invoices) {
      breakdown[inv.type] = (breakdown[inv.type] ?? 0) + inv.total;
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Card(child: ListTile(title: const Text('Total Revenue'), trailing: Text('₹${totalRevenue.toStringAsFixed(2)}'))),
          Card(child: ListTile(title: const Text('Total Expenses'), trailing: Text('₹${totalExpenses.toStringAsFixed(2)}'))),
          Card(
            child: ListTile(
              title: const Text('Profit / (Loss)'),
              trailing: Text(
                '₹${profit.toStringAsFixed(2)}',
                style: TextStyle(color: profit >= 0 ? Colors.green[700] : Colors.red[700], fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Align(alignment: Alignment.centerLeft, child: Text('Revenue breakdown by type:', style: TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: breakdown.entries.map((e) {
                final label = e.key == InvoiceType.perTrip ? 'Per Trip' : e.key == InvoiceType.monthly ? 'Monthly' : 'Contract';
                return ListTile(title: Text(label), trailing: Text('₹${e.value.toStringAsFixed(2)}'));
              }).toList(),
            ),
          ),
         
        ],
      ),
    );
  }

  void _showInvoiceDialog(Invoice inv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Invoice ${inv.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Party: ${inv.partyName}'),
            Text('Type: ${inv.type.toString().split('.').last}'),
            Text('Date: ${inv.date.toShortDateString()}'),
            const SizedBox(height: 8),
            Text('Amount before GST: ₹${inv.amountBeforeGST.toStringAsFixed(2)}'),
            Text('GST (${inv.gstRate}%): ₹${inv.gstAmount.toStringAsFixed(2)}'),
            Text('Total: ₹${inv.total.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Notes: ${inv.notes}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () {
              // Print JSON (simulated print to console)
              // ignore: avoid_print
              print(jsonEncode(inv.toJson()));
              Navigator.pop(context);
              _showSnack('Invoice  printed to console.');
            },
            child: const Text('Print '),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),

      appBar: AppBar(
        title: const Text('Financials & Billing'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Invoices'),
            Tab(text: 'Expenses'),
            Tab(text: 'Profitability'),

          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Invoices
          Column(
            children: [
              Expanded(flex: 0, child: _buildInvoiceForm()),
              Expanded(child: _buildInvoicesList()),
            ],
          ),

          // Expenses
          _buildExpensesTab(),

          // Profitability
          _buildProfitabilityTab(),

          // Documents / Uploads (uses your uploadDoc)

        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Quick action to show totals
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Quick Summary'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Revenue: ₹${totalRevenue.toStringAsFixed(2)}'),
                  Text('Expenses: ₹${totalExpenses.toStringAsFixed(2)}'),
                  Text('Profit: ₹${profit.toStringAsFixed(2)}', style: TextStyle(color: profit >= 0 ? Colors.green : Colors.red)),
                ],
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
            ),
          );
        },
        icon: const Icon(Icons.summarize),
        label: const Text('Summary'),
      ),
    );
  }
}

// small date helper
extension DateHelpers on DateTime {
  String toShortDateString() => '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-${year}';
}
