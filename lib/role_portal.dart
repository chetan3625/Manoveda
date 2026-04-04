import 'package:flutter/material.dart';

import 'api_service.dart';
import 'homepage.dart';

class RolePortalPage extends StatefulWidget {
  const RolePortalPage({super.key});

  @override
  State<RolePortalPage> createState() => _RolePortalPageState();
}

class _RolePortalPageState extends State<RolePortalPage> {
  bool _loading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final me = await ApiService.getMe();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = me['user'] as Map<String, dynamic>?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final role = _user?['role']?.toString() ?? ApiService.userRole ?? 'patient';
    if (role == 'doctor') {
      return const DoctorPortalScreen();
    }
    if (role == 'medical_keeper') {
      return const MedicalKeeperPortalScreen();
    }
    return const PatientPortalScreen();
  }
}

class PatientPortalScreen extends StatefulWidget {
  const PatientPortalScreen({super.key});

  @override
  State<PatientPortalScreen> createState() => _PatientPortalScreenState();
}

class _PatientPortalScreenState extends State<PatientPortalScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getMe(),
      ApiService.getDoctors(),
      ApiService.getAppointments(),
      ApiService.getPrescriptions(),
      ApiService.getMedicines(),
      ApiService.getOrders(),
      ApiService.getNotifications(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = results[0]['user'] as Map<String, dynamic>?;
      _doctors = _list(results[1], 'doctors');
      _appointments = _list(results[2], 'appointments');
      _prescriptions = _list(results[3], 'prescriptions');
      _medicines = _list(results[4], 'medicines');
      _orders = _list(results[5], 'orders');
      _notifications = _list(results[6], 'notifications');
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _book(Map<String, dynamic> doctor) async {
    final response = await ApiService.bookAppointment(
      doctorId: _idOf(doctor),
      date: DateTime.now().add(const Duration(days: 1)),
      time: '10:00 AM',
      type: 'video',
      symptoms: 'Consultation request from portal',
    );
    _snack(response['message']?.toString() ?? 'Appointment requested');
    await _refresh();
  }

  Future<void> _chatWith(String participantId, String title) async {
    final response = await ApiService.createChat(participantId);
    final chat = response['chat'] as Map<String, dynamic>?;
    if (!mounted || chat == null) {
      _snack(response['message']?.toString() ?? 'Unable to start chat');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(chatId: _idOf(chat), title: title),
      ),
    );
  }

  Future<void> _payAppointment(String appointmentId) async {
    final response = await ApiService.createAppointmentPayment(appointmentId);
    _snack(
      response['success'] == true
          ? 'Payment order created: ${response['orderId']}'
          : response['message']?.toString() ?? 'Payment request failed',
    );
  }

  Future<void> _payOrder(String orderId) async {
    final response = await ApiService.createOrderPayment(orderId);
    _snack(
      response['success'] == true
          ? 'Payment order created: ${response['orderId']}'
          : response['message']?.toString() ?? 'Payment request failed',
    );
  }

  Future<void> _placeOrder() async {
    final address = _profile?['address'] as Map<String, dynamic>? ?? {};
    final response = await ApiService.placeOrder(
      shippingAddress: {
        'name': _profile?['name']?.toString() ?? '',
        'phone': _profile?['phone']?.toString() ?? '',
        'street': address['street']?.toString() ?? '',
        'city': address['city']?.toString() ?? '',
        'state': address['state']?.toString() ?? '',
        'pincode': address['pincode']?.toString() ?? '',
      },
    );
    _snack(response['message']?.toString() ?? 'Order placed');
    await _refresh();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  List<Map<String, dynamic>> get _nearbyDoctors {
    final city = _profile?['address']?['city']?.toString().trim().toLowerCase();
    if (city == null || city.isEmpty) {
      return _doctors.take(3).toList();
    }
    final nearby = _doctors.where((doctor) {
      return doctor['address']?['city']?.toString().trim().toLowerCase() == city;
    }).toList();
    return nearby.isEmpty ? _doctors.take(3).toList() : nearby.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Portal'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    title: 'Hello ${_profile?['name'] ?? 'Patient'}',
                    subtitle:
                        'Patient features, nearest doctors, chat, appointments, prescriptions, payments, and medicine ordering are available here.',
                    button: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Homepage()),
                        );
                      },
                      child: const Text('Open Wellness Features'),
                    ),
                  ),
                  _section(
                    'Nearest Doctors',
                    _nearbyDoctors.isEmpty
                        ? [const Text('No doctors available')]
                        : _nearbyDoctors.map((doctor) {
                            return _tile(
                              title: doctor['name']?.toString() ?? 'Doctor',
                              subtitle:
                                  '${doctor['specialization'] ?? 'Consultation'} • Rs ${doctor['consultationFee'] ?? 0}',
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _book(doctor),
                                    child: const Text('Book'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _chatWith(
                                      _idOf(doctor),
                                      doctor['name']?.toString() ?? 'Doctor',
                                    ),
                                    child: const Text('Chat'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                  _section(
                    'Appointments',
                    _appointments.isEmpty
                        ? [const Text('No appointments yet')]
                        : _appointments.map((appointment) {
                            final doctor = appointment['doctor'] as Map<String, dynamic>? ?? {};
                            return _tile(
                              title: doctor['name']?.toString() ?? 'Doctor',
                              subtitle:
                                  '${appointment['status']} • ${appointment['time']} • ${appointment['meetingLink'] ?? 'meeting pending'}',
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  if (appointment['paymentStatus'] != 'paid')
                                    OutlinedButton(
                                      onPressed: () => _payAppointment(_idOf(appointment)),
                                      child: const Text('Pay'),
                                    ),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await ApiService.cancelAppointment(_idOf(appointment));
                                      await _refresh();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                  _section(
                    'Prescriptions',
                    _prescriptions.isEmpty
                        ? [const Text('No prescriptions yet')]
                        : _prescriptions.map((item) {
                            final meds = _listFromValue(item['medicines']);
                            return _tile(
                              title: 'Prescription',
                              subtitle: meds.isEmpty
                                  ? 'No medicines listed'
                                  : meds.map((m) => m['name']).join(', '),
                            );
                          }).toList(),
                  ),
                  _section(
                    'Medicines',
                    [
                      ..._medicines.take(6).map((medicine) {
                        return _tile(
                          title: medicine['name']?.toString() ?? 'Medicine',
                          subtitle:
                              '${medicine['category'] ?? 'General'} • Stock ${medicine['stock'] ?? 0} • Rs ${medicine['discountedPrice'] ?? medicine['price'] ?? 0}',
                          trailing: OutlinedButton(
                            onPressed: () async {
                              await ApiService.addToCart(medicineId: _idOf(medicine));
                              _snack('Added to cart');
                            },
                            child: const Text('Add'),
                          ),
                        );
                      }),
                      FilledButton(
                        onPressed: _placeOrder,
                        child: const Text('Place Order'),
                      ),
                    ],
                  ),
                  _section(
                    'Orders',
                    _orders.isEmpty
                        ? [const Text('No orders yet')]
                        : _orders.map((order) {
                            return _tile(
                              title: 'Order ${_shortId(order)}',
                              subtitle:
                                  '${order['status']} • payment ${order['paymentStatus']} • Rs ${order['totalAmount'] ?? 0}',
                              trailing: order['paymentStatus'] == 'paid'
                                  ? null
                                  : OutlinedButton(
                                      onPressed: () => _payOrder(_idOf(order)),
                                      child: const Text('Pay'),
                                    ),
                            );
                          }).toList(),
                  ),
                  _section(
                    'Notifications',
                    _notifications.isEmpty
                        ? [const Text('No notifications yet')]
                        : _notifications.take(5).map((item) {
                            return _tile(
                              title: item['title']?.toString() ?? 'Notification',
                              subtitle: item['message']?.toString() ?? '',
                            );
                          }).toList(),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatListPage()),
                      );
                    },
                    child: const Text('Open Chats'),
                  ),
                ],
              ),
            ),
    );
  }
}

class DoctorPortalScreen extends StatefulWidget {
  const DoctorPortalScreen({super.key});

  @override
  State<DoctorPortalScreen> createState() => _DoctorPortalScreenState();
}

class _DoctorPortalScreenState extends State<DoctorPortalScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getMe(),
      ApiService.getDoctorAppointments(),
      ApiService.getDoctorPatients(),
      ApiService.getDoctorFeedbacks(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = results[0]['user'] as Map<String, dynamic>?;
      _appointments = _list(results[1], 'appointments');
      _patients = _list(results[2], 'patients');
      _feedbacks = _list(results[3], 'feedbacks');
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _updateStatus(String appointmentId, String status) async {
    await ApiService.updateDoctorAppointment(appointmentId: appointmentId, status: status);
    await _refresh();
  }

  Future<void> _createMeeting(String appointmentId) async {
    await ApiService.createMeetingLink(appointmentId);
    await _refresh();
  }

  Future<void> _sendPrescription(Map<String, dynamic> appointment) async {
    await ApiService.writePrescription(
      patientId: appointment['patient']?['_id']?.toString() ?? '',
      appointmentId: _idOf(appointment),
      medicines: const [
        {
          'name': 'Mind Care Tablet',
          'dosage': '1 tablet',
          'frequency': 'Twice daily',
          'duration': '7 days',
          'instructions': 'After food'
        }
      ],
      notes: 'Auto-generated follow-up prescription from portal',
    );
    await _refresh();
  }

  Future<void> _chatPatient(Map<String, dynamic> patient) async {
    final response = await ApiService.createChat(_idOf(patient));
    final chat = response['chat'] as Map<String, dynamic>?;
    if (!mounted || chat == null) {
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          chatId: _idOf(chat),
          title: patient['name']?.toString() ?? 'Patient',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor ERP Portal'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    title: 'Dr. ${_profile?['name'] ?? ''}',
                    subtitle:
                        'Accept patient requests, create meetings, chat, complete appointments, and send prescriptions.',
                  ),
                  _section(
                    'Appointments',
                    _appointments.isEmpty
                        ? [const Text('No appointments yet')]
                        : _appointments.map((appointment) {
                            final patient = appointment['patient'] as Map<String, dynamic>? ?? {};
                            return _tile(
                              title: patient['name']?.toString() ?? 'Patient',
                              subtitle: '${appointment['status']} • ${appointment['time']} • Rs ${appointment['fee'] ?? 0}',
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _updateStatus(_idOf(appointment), 'confirmed'),
                                    child: const Text('Accept'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _createMeeting(_idOf(appointment)),
                                    child: const Text('Meeting'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _sendPrescription(appointment),
                                    child: const Text('Rx'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _updateStatus(_idOf(appointment), 'completed'),
                                    child: const Text('Done'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                  _section(
                    'Patients',
                    _patients.isEmpty
                        ? [const Text('No patients yet')]
                        : _patients.map((patient) {
                            return _tile(
                              title: patient['name']?.toString() ?? 'Patient',
                              subtitle: patient['email']?.toString() ?? '',
                              trailing: OutlinedButton(
                                onPressed: () => _chatPatient(patient),
                                child: const Text('Chat'),
                              ),
                            );
                          }).toList(),
                  ),
                  _section(
                    'Feedback',
                    _feedbacks.isEmpty
                        ? [const Text('No feedback yet')]
                        : _feedbacks.map((item) {
                            final user = item['user'] as Map<String, dynamic>? ?? {};
                            return _tile(
                              title: '${user['name'] ?? 'Patient'} • ${item['rating'] ?? 0}/5',
                              subtitle: item['review']?.toString() ?? 'No review',
                            );
                          }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class MedicalKeeperPortalScreen extends StatefulWidget {
  const MedicalKeeperPortalScreen({super.key});

  @override
  State<MedicalKeeperPortalScreen> createState() => _MedicalKeeperPortalScreenState();
}

class _MedicalKeeperPortalScreenState extends State<MedicalKeeperPortalScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getMe(),
      ApiService.getMedicalKeeperDashboard(),
      ApiService.getMedicalKeeperMedicines(),
      ApiService.getMedicalKeeperOrders(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = results[0]['user'] as Map<String, dynamic>?;
      _stats = results[1]['stats'] as Map<String, dynamic>?;
      _medicines = _list(results[2], 'medicines');
      _orders = _list(results[3], 'orders');
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _addMedicine() async {
    await ApiService.addMedicine({
      'name': 'Wellness Capsule ${DateTime.now().millisecondsSinceEpoch}',
      'category': 'Mental Wellness',
      'price': 199,
      'stock': 25,
      'description': 'Auto-created store medicine',
      'manufacturer': 'Manoveda Pharmacy',
    });
    await _refresh();
  }

  Future<void> _updateOrder(String id, String status) async {
    await ApiService.updateMedicalOrderStatus(orderId: id, status: status, trackLocation: status);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Keeper Portal'),
        actions: [
          IconButton(onPressed: _addMedicine, icon: const Icon(Icons.add_box)),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    title: _profile?['name']?.toString() ?? 'Medical Store',
                    subtitle: 'Run pharmacy inventory and order fulfillment from one place.',
                  ),
                  _card(
                    title: 'Store Stats',
                    subtitle:
                        'Medicines ${_stats?['totalMedicines'] ?? 0} • Orders ${_stats?['totalOrders'] ?? 0} • Revenue Rs ${_stats?['totalRevenue'] ?? 0}',
                  ),
                  _section(
                    'Inventory',
                    _medicines.isEmpty
                        ? [const Text('No medicines yet')]
                        : _medicines.map((medicine) {
                            return _tile(
                              title: medicine['name']?.toString() ?? 'Medicine',
                              subtitle:
                                  '${medicine['category'] ?? 'General'} • Stock ${medicine['stock'] ?? 0} • Rs ${medicine['price'] ?? 0}',
                            );
                          }).toList(),
                  ),
                  _section(
                    'Orders',
                    _orders.isEmpty
                        ? [const Text('No orders yet')]
                        : _orders.map((order) {
                            final user = order['user'] as Map<String, dynamic>? ?? {};
                            return _tile(
                              title: user['name']?.toString() ?? 'Patient',
                              subtitle:
                                  '${order['status']} • ${order['paymentStatus']} • Rs ${order['totalAmount'] ?? 0}',
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _updateOrder(_idOf(order), 'shipped'),
                                    child: const Text('Ship'),
                                  ),
                                  OutlinedButton(
                                    onPressed: () => _updateOrder(_idOf(order), 'delivered'),
                                    child: const Text('Deliver'),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final response = await ApiService.getChats();
    if (!mounted) {
      return;
    }
    setState(() {
      _chats = _list(response, 'chats');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _chats.map((chat) {
                final title = _chatTitle(chat);
                return ListTile(
                  title: Text(title),
                  subtitle: Text(chat['lastMessage']?.toString() ?? 'No messages yet'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomPage(chatId: _idOf(chat), title: title),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}

class ChatRoomPage extends StatefulWidget {
  final String chatId;
  final String title;

  const ChatRoomPage({super.key, required this.chatId, required this.title});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  bool _sending = false;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final response = await ApiService.getMessages(widget.chatId);
    if (!mounted) {
      return;
    }
    setState(() {
      _messages = _list(response, 'messages').reversed.toList();
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) {
      return;
    }
    setState(() => _sending = true);
    await ApiService.sendMessage(chatId: widget.chatId, content: text);
    _controller.clear();
    await _load();
    if (mounted) {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final sender = message['sender'] as Map<String, dynamic>? ?? {};
                      final mine = _idOf(sender) == ApiService.userId;
                      return Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mine ? Colors.blue : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['content']?.toString() ?? '',
                            style: TextStyle(color: mine ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
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

List<Map<String, dynamic>> _listFromValue(dynamic value) {
  if (value is! List) {
    return [];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _idOf(Map<String, dynamic> item) {
  return item['_id']?.toString() ?? item['id']?.toString() ?? '';
}

String _shortId(Map<String, dynamic> item) {
  final id = _idOf(item);
  return id.length > 6 ? id.substring(0, 6) : id;
}

String _chatTitle(Map<String, dynamic> chat) {
  final groupName = chat['groupName']?.toString();
  if (groupName != null && groupName.isNotEmpty) {
    return groupName;
  }
  final participants = _listFromValue(chat['participants']);
  for (final participant in participants) {
    if (_idOf(participant) != ApiService.userId) {
      return participant['name']?.toString() ?? 'Chat';
    }
  }
  return 'Chat';
}

Widget _card({
  required String title,
  required String subtitle,
  Widget? button,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(subtitle),
        if (button != null) ...[
          const SizedBox(height: 12),
          button,
        ],
      ],
    ),
  );
}

Widget _section(String title, List<Widget> children) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget _tile({
  required String title,
  required String subtitle,
  Widget? trailing,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle),
        if (trailing != null) ...[
          const SizedBox(height: 10),
          trailing,
        ],
      ],
    ),
  );
}
