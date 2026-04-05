import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _cartItems = [];
  Map<String, dynamic>? _profile;
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  late Razorpay _razorpay;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _loadData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      ApiService.getCart(),
      ApiService.getMe(),
    ]);
    if (!mounted) return;
    
    setState(() {
      _profile = results[1]['user'] as Map<String, dynamic>?;
      final address = _profile?['address'] as Map<String, dynamic>? ?? {};
      _nameController.text = _profile?['name']?.toString() ?? '';
      _phoneController.text = _profile?['phone']?.toString() ?? '';
      _streetController.text = address['street']?.toString() ?? '';
      _cityController.text = address['city']?.toString() ?? '';
      _stateController.text = address['state']?.toString() ?? '';
      _pincodeController.text = address['pincode']?.toString() ?? '';
      
      final order = results[0]['order'] as Map<String, dynamic>?;
      final items = order?['items'] as List? ?? [];
      _cartItems = items.map((item) => Map<String, dynamic>.from(item)).toList();
      _loading = false;
    });
  }

  int get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + ((item['totalPrice'] ?? 0) as int));
  }

  int get _totalItems {
    return _cartItems.fold(0, (sum, item) => sum + ((item['quantity'] ?? 0) as int));
  }

  Future<void> _updateQuantity(String itemId, int newQty) async {
    if (newQty < 1) return;
    await ApiService.updateCartItem(itemId: itemId, quantity: newQty);
    await _loadData();
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) {
      _snack('Cart is empty');
      return;
    }
    if (_nameController.text.isEmpty || _streetController.text.isEmpty || 
        _cityController.text.isEmpty || _pincodeController.text.isEmpty) {
      _snack('Please fill address');
      return;
    }

    if (_processing) return;
    setState(() => _processing = true);

    try {
      final response = await ApiService.placeOrder(
        shippingAddress: {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
        },
      );
      
      if (response['success'] == true && response['orderId'] != null) {
        await _processPayment(response['orderId'].toString(), _totalAmount);
      } else {
        _snack(response['message'] ?? 'Order failed');
      }
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _processPayment(String orderId, int amount) async {
    final options = {
      'key': 'rzp_test_1DP5sIu0B5FMq2f',
      'amount': amount * 100,
      'currency': 'INR',
      'name': 'Manoveda',
      'description': 'Medicine Order',
      'prefill': {
        'contact': _phoneController.text,
        'email': _profile?['email']?.toString() ?? '',
      },
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _snack('Payment successful! Order placed.');
    Navigator.pop(context, true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _snack('Payment failed: ${response.message}');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('My Cart'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset('assets/lottie/Background_shooting_star.json', 
              fit: BoxFit.cover, repeat: true),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          _loading 
              ? const Center(child: CircularProgressIndicator())
              : _cartItems.isEmpty 
                  ? _emptyCart() 
                  : _buildCartContent(),
        ],
      ),
    );
  }

  Widget _emptyCart() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white54),
          SizedBox(height: 16),
          Text('Your cart is empty', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 8),
          Text('Add medicines from pharmacy', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return _cartItemCard(item);
            },
          ),
        ),
        _addressSection(),
        _checkoutSection(),
      ],
    );
  }

  Widget _cartItemCard(Map<String, dynamic> item) {
    final qty = item['quantity'] ?? 0;
    final price = item['totalPrice'] ?? 0;
    final medicineName = item['name'] ?? 'Medicine';
    final itemId = item['_id']?.toString() ?? item['id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade900.withValues(alpha: 0.8), Colors.blue.shade900.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicineName, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Rs $price', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: () => _updateQuantity(itemId, qty - 1),
                ),
                Text('$qty', style: const TextStyle(color: Colors.white, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => _updateQuantity(itemId, qty + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Address', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Name'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Phone'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _streetController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Street Address'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('City'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _stateController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('State'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pincodeController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Pincode'),
          ),
        ],
      ),
    );
  }

  Widget _checkoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_totalItems items', style: const TextStyle(color: Colors.white70)),
                Text('Total: Rs $_totalAmount', 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processing ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _processing 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white),
      ),
    );
  }
}