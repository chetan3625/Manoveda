import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:manoveda/splashscreen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'add_medicine_screen.dart';
import 'api_service.dart';
import 'homepage.dart';
import 'medical_keeper_stores_screen.dart';
import 'wellness_repository.dart';
import 'affirmations.dart';
import 'breathingexercise.dart';
import 'grounding.dart';
import 'jouneralentry.dart';
import 'meditationscreen.dart';
import 'mind_games_screen.dart';
import 'mood_tracker.dart';
import 'music_therapy.dart';
import 'schedule_screen.dart';
import 'voice_chatbot_screen.dart';
import 'mood_detection_screen.dart';
import 'yoga_screen.dart';
import 'aboutus.dart';

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
    if (!mounted) return;
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
    if (role == 'doctor') return const DoctorPortalScreen();
    if (role == 'medical_keeper') return const MedicalKeeperPortalScreen();
    return const PatientPortalScreen();
  }
}

enum PatientSection {
  overview,
  doctors,
  appointments,
  chats,
  prescriptions,
  notifications,
  pharmacy,
  wellness,
}

class PatientPortalScreen extends StatefulWidget {
  const PatientPortalScreen({super.key});

  @override
  State<PatientPortalScreen> createState() => _PatientPortalScreenState();
}

class _PatientPortalScreenState extends State<PatientPortalScreen> {
  bool _loading = true;
  PatientSection _section = PatientSection.overview;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _prescriptions = [];
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _chats = [];

  String _quote = 'Take one calm step at a time. Progress still counts.';
  String _author = 'Mindful reminder';
  bool _loadingQuote = false;
  bool _loadingDashboard = true;
  DashboardSummary? _summary;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    ApiService.connectSocket();
    ApiService.socket?.on('notification', _socketRefresh);
    ApiService.socket?.on('message_notification', _socketRefresh);
    _refresh();
    _fetchQuote();
  }

  @override
  void dispose() {
    _razorpay.clear();
    ApiService.socket?.off('notification', _socketRefresh);
    ApiService.socket?.off('message_notification', _socketRefresh);
    super.dispose();
  }

  void _socketRefresh(dynamic _) {
    if (mounted) _refresh(silent: true);
  }

  Future<void> _refresh({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getMe(),
      ApiService.getDoctors(),
      ApiService.getAppointments(),
      ApiService.getPrescriptions(),
      ApiService.getNotifications(),
      ApiService.getMedicines(),
      ApiService.getOrders(),
      ApiService.getChats(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0]['user'] as Map<String, dynamic>?;
      _doctors = _list(results[1], 'doctors');
      _appointments = _list(results[2], 'appointments');
      _prescriptions = _list(results[3], 'prescriptions');
      _notifications = _list(results[4], 'notifications');
      _medicines = _list(results[5], 'medicines');
      _orders = _list(results[6], 'orders');
      _chats = _list(results[7], 'chats');
      _loading = false;
    });
    setState(() => _loadingDashboard = true);
    final summary = await WellnessRepository.instance.buildDashboardSummary();
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _loadingDashboard = false;
    });
  }

  Future<void> _fetchQuote() async {
    if (mounted) {
      setState(() => _loadingQuote = true);
    }
    try {
      final response = await http
          .get(
            Uri.parse('https://api.api-ninjas.com/v1/quotes'),
            headers: const {
              'X-Api-Key': 'jA774RYMHWSVHd+w2I0Eyg==3mYvpCdfzwHeWXCd',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (!mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final item =
            data.isNotEmpty ? data.first as Map<String, dynamic> : null;
        setState(() {
          _quote = (item?['quote'] as String?) ?? 'Take one calm step at a time. Progress still counts.';
          _author = (item?['author'] as String?) ?? 'Mindful reminder';
          _loadingQuote = false;
        });
      } else {
        _setFallbackQuote();
      }
    } catch (_) {
      if (mounted) {
        _setFallbackQuote();
      }
    }
  }

  void _setFallbackQuote() {
    setState(() {
      _quote = 'Take one calm step at a time. Progress still counts.';
      _author = 'Mindful reminder';
      _loadingQuote = false;
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle payment success
    if (_currentPaymentAppointmentId != null) {
      _verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
        appointmentId: _currentPaymentAppointmentId,
        type: 'appointment',
      );
    } else if (_currentOrderId != null) {
      _verifyPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
        orderId: _currentOrderId,
        type: 'order',
      );
    }
    _currentPaymentAppointmentId = null;
    _currentOrderId = null;
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    _snack('Payment failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
    _snack('External wallet selected: ${response.walletName}');
  }

  String? _currentPaymentAppointmentId;
  String? _currentOrderId;

  Future<void> _verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    String? appointmentId,
    String? orderId,
    required String type,
  }) async {
    try {
      final response = await ApiService.verifyPayment(
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
        appointmentId: appointmentId,
        orderId: orderId,
        type: type,
      );

      if (response['success'] == true) {
        _snack('Payment successful!');
        await _refresh();
      } else {
        _snack('Payment verification failed');
      }
    } catch (e) {
      _snack('Payment verification error');
    }
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Loginpage()),
    );
  }

  Future<void> _requestAppointment(Map<String, dynamic> doctor) async {
    final request = await showDialog<_AppointmentDraft>(
      context: context,
      builder: (_) => _AppointmentRequestDialog(
        doctorName: doctor['name']?.toString() ?? 'Doctor',
      ),
    );
    if (request == null) return;
    final response = await ApiService.bookAppointment(
      doctorId: _idOf(doctor),
      date: request.date,
      time: request.timeLabel,
      type: request.type,
      consultationMode: request.consultationMode,
      symptoms: request.symptoms,
    );
    _snack(response['message']?.toString() ?? 'Appointment request sent');
    await _refresh();
    if (mounted) setState(() => _section = PatientSection.appointments);
  }

  Future<void> _payForAppointment(Map<String, dynamic> appointment) async {
    try {
      final response = await ApiService.createAppointmentPayment(
        _idOf(appointment),
      );

      if (response['success'] == true) {
        final orderId = response['orderId'];
        final amount = appointment['fee'] ?? 0;

        _currentPaymentAppointmentId = _idOf(appointment);

        var options = {
          'key': 'rzp_test_SZhuwFJP2o00Zw', // Razorpay test key
          'amount': (amount * 100).toInt(), // Amount in paise
          'name': 'Manoveda',
          'order_id': orderId,
          'description': 'Appointment Payment',
          'prefill': {
            'contact': _profile?['phone'] ?? '',
            'email': _profile?['email'] ?? '',
          },
          'theme': {
            'color': '#3B82F6',
          }
        };

        _razorpay.open(options);
      } else {
        _snack(response['message']?.toString() ?? 'Payment unavailable');
      }
    } catch (e) {
      _snack('Error creating payment order');
    }
  }

  Future<void> _openAppointmentChat(Map<String, dynamic> appointment) async {
    final doctor = appointment['doctor'] as Map<String, dynamic>? ?? {};
    final response = await ApiService.createChat(
      _idOf(doctor),
      appointmentId: _idOf(appointment),
    );
    final chat = response['chat'] as Map<String, dynamic>?;
    if (chat == null || !mounted) {
      _snack(response['message']?.toString() ?? 'Chat is locked');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          chatId: _idOf(chat),
          title: doctor['name']?.toString() ?? 'Doctor',
        ),
      ),
    );
    await _refresh(silent: true);
  }

  Future<void> _openLink(String title, String url) async {
    if (url.isEmpty) {
      _snack('$title is not available yet');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LinkWebViewPage(title: title, url: url),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(_patientTitle(_section)),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(_profile?['name']?.toString() ?? 'Patient'),
                accountEmail: Text(_profile?['email']?.toString() ?? ''),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              _patientDrawerTile(
                PatientSection.overview,
                Icons.dashboard_outlined,
                'Dashboard',
              ),
              _patientDrawerTile(
                PatientSection.doctors,
                Icons.medical_services_outlined,
                'Doctors',
              ),
              _patientDrawerTile(
                PatientSection.appointments,
                Icons.event_note_outlined,
                'Appointments',
              ),
              _patientDrawerTile(
                PatientSection.chats,
                Icons.chat_bubble_outline,
                'Chats',
              ),
              _patientDrawerTile(
                PatientSection.prescriptions,
                Icons.description_outlined,
                'Prescriptions',
              ),
              _patientDrawerTile(
                PatientSection.notifications,
                Icons.notifications_outlined,
                'Notifications',
              ),
              _patientDrawerTile(
                PatientSection.pharmacy,
                Icons.local_pharmacy_outlined,
                'Pharmacy',
              ),
              _patientDrawerTile(
                PatientSection.wellness,
                Icons.favorite,
                'Wellness Features',
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Wellness Tools', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              ),
              _wellnessToolTile(Icons.self_improvement, 'Meditation', () => _openPage(const MeditationScreen())),
              _wellnessToolTile(Icons.air, 'Breathing', () => _openPage(const BreathingExerciseScreen())),
              _wellnessToolTile(Icons.music_note, 'Music Therapy', () => _openPage(const MusicTherapyScreen())),
              _wellnessToolTile(Icons.edit_note, 'Journal', () => _openPage(const JournalEntryScreen())),
              _wellnessToolTile(Icons.fitness_center, 'Yoga', () => _openPage(const YogaScreen())),
              _wellnessToolTile(Icons.psychology_alt, 'Mind Games', () => _openPage(const MindGamesScreen())),
              _wellnessToolTile(Icons.mood, 'Mood Tracker', () => _openPage(const MoodTrackerScreen())),
              _wellnessToolTile(Icons.auto_awesome, 'Affirmations', () => _openPage(const AffirmationsScreen())),
              _wellnessToolTile(Icons.park, 'Grounding', () => _openPage(const GroundingScreen())),
              _wellnessToolTile(Icons.face_retouching_natural, 'Mood Detection', () => _openPage(const MoodDetectionScreen())),
              _wellnessToolTile(Icons.smart_toy, 'AI Voice Assistant', () => _openPage(const VoiceChatbotScreen())),
              _wellnessToolTile(Icons.history_toggle_off, 'Wellness Timeline', () => _openPage(const ScheduleScreen())),
              _wellnessToolTile(Icons.info_outline, 'About Us', () => _openPage(const AboutUsScreen())),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFF3B82F6)),
                title: const Text('Go to Homepage'),
                onTap: () => _goToHomepage(),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/Background_shooting_star.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: _patientBody(),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _patientDrawerTile(
    PatientSection section,
    IconData icon,
    String label,
  ) {
    return ListTile(
      selected: _section == section,
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        setState(() => _section = section);
      },
    );
  }

  Widget _wellnessToolTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3B82F6)),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _goToHomepage() async {
    Navigator.pop(context);
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const Homepage()));
  }

  List<Widget> _patientBody() {
    if (_section == PatientSection.overview) {
      return [
        _heroCard(
          title: 'Welcome ${_profile?['name'] ?? 'Patient'}',
          subtitle:
              'Request doctors, wait for approval, pay online, unlock chat, join video, and access prescription PDFs.',
          action: FilledButton(
            onPressed: () => setState(() => _section = PatientSection.wellness),
            child: const Text('Go to Wellness'),
          ),
        ),
        _statsWrap([
          _StatCard(
            'Doctors',
            '${_doctors.length}',
            Icons.medical_services_outlined,
          ),
          _StatCard(
            'Appointments',
            '${_appointments.length}',
            Icons.calendar_month_outlined,
          ),
          _StatCard('Chats', '${_chats.length}', Icons.chat_outlined),
          _StatCard(
            'Prescriptions',
            '${_prescriptions.length}',
            Icons.description_outlined,
          ),
        ]),
        ..._doctorCards(limit: 3),
        ..._appointmentCards(limit: 2),
      ];
    }
    if (_section == PatientSection.doctors) {
      return _doctorCards();
    }
    if (_section == PatientSection.appointments) {
      return _appointmentCards();
    }
    if (_section == PatientSection.chats) {
      return _chatCards();
    }
    if (_section == PatientSection.prescriptions) {
      return _prescriptionCards();
    }
    if (_section == PatientSection.notifications) {
      return _notificationCards(_notifications, patientSide: true);
    }
    if (_section == PatientSection.pharmacy) {
      return _pharmacyCards();
    }
    if (_section == PatientSection.wellness) {
      return _wellnessBody();
    }
    return [];
  }

  List<Widget> _wellnessBody() {
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"$_quote"',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '- $_author',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      if (_loadingDashboard)
        const Center(child: CircularProgressIndicator())
      else if (_summary != null)
        _buildDashboard(_summary!)
      else
        const Text('No dashboard data'),
    ];
  }

  Widget _buildDashboard(DashboardSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Greeting: ${summary.greeting}'),
            Text('Today Score: ${summary.todayScore}'),
            Text('Mindful Minutes: ${summary.totalMindfulMinutes}'),
          ],
        ),
      ),
    );
  }

  List<Widget> _doctorCards({int? limit}) {
    final items = limit == null ? _doctors : _doctors.take(limit).toList();
    if (items.isEmpty) {
      return [_emptyCard('No doctors are available right now.')];
    }
    return [
      _sectionHeader(
        'Doctors',
        'Dynamically fetched doctors available for consultation.',
      ),
      ...items.map(
        (doctor) => _contentCard(
          title: doctor['name']?.toString() ?? 'Doctor',
          subtitle:
              '${doctor['specialization'] ?? 'General'}\nExperience: ${doctor['experience'] ?? 0} years\nAvailability: ${doctor['isAvailable'] == true ? 'Available' : 'Offline'}',
          footer: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('Fee Rs ${doctor['consultationFee'] ?? 0}')),
              FilledButton(
                onPressed: () => _requestAppointment(doctor),
                child: const Text('Request Appointment'),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _appointmentCards({int? limit}) {
    final items = limit == null
        ? _appointments
        : _appointments.take(limit).toList();
    if (items.isEmpty) return [_emptyCard('No appointments yet.')];
    return [
      _sectionHeader(
        'Appointments',
        'Track approval, payment, chat, and consultation status.',
      ),
      ...items.map((appointment) {
        final doctor = appointment['doctor'] as Map<String, dynamic>? ?? {};
        final canPay =
            appointment['status'] == 'accepted' &&
            appointment['paymentStatus'] != 'paid';
        final unlocked =
            appointment['status'] == 'confirmed' &&
            appointment['paymentStatus'] == 'paid';
        final prescription =
            appointment['prescription'] as Map<String, dynamic>?;
        return _contentCard(
          title: doctor['name']?.toString() ?? 'Doctor',
          subtitle:
              '${appointment['type']} • ${appointment['consultationMode'] ?? 'scheduled'}\n${_formatAppointmentDate(appointment)}\nStatus: ${appointment['status']} | Payment: ${appointment['paymentStatus']}',
          footer: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canPay)
                FilledButton(
                  onPressed: () => _payForAppointment(appointment),
                  child: const Text('Pay Now'),
                ),
              if (unlocked)
                OutlinedButton(
                  onPressed: () => _openAppointmentChat(appointment),
                  child: const Text('Open Chat'),
                ),
              if (unlocked && appointment['type'] == 'video')
                OutlinedButton(
                  onPressed: () => _openLink(
                    'Video Consultation',
                    appointment['meetingLink']?.toString() ?? '',
                  ),
                  child: Text(
                    appointment['consultationMode'] == 'instant'
                        ? 'Start Video'
                        : 'Join Video',
                  ),
                ),
              if (prescription != null)
                OutlinedButton(
                  onPressed: () => _openLink(
                    'Prescription PDF',
                    ApiService.absoluteUrl(prescription['pdfUrl']?.toString()),
                  ),
                  child: const Text('View Prescription'),
                ),
            ],
          ),
        );
      }),
    ];
  }

  List<Widget> _chatCards() {
    if (_chats.isEmpty) {
      return [_emptyCard('Chat unlocks only after acceptance and payment.')];
    }
    return [
      _sectionHeader(
        'Chats',
        'Real-time chat sessions linked to confirmed appointments.',
      ),
      ..._chats.map(
        (chat) => _contentCard(
          title: _chatTitle(chat),
          subtitle: chat['lastMessage']?.toString() ?? 'No messages yet',
          footer: OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ChatRoomPage(chatId: _idOf(chat), title: _chatTitle(chat)),
              ),
            ),
            child: const Text('Open Chat'),
          ),
        ),
      ),
    ];
  }

  List<Widget> _prescriptionCards() {
    if (_prescriptions.isEmpty) {
      return [_emptyCard('No prescription PDFs available yet.')];
    }
    return [
      _sectionHeader(
        'Prescriptions',
        'Consultation prescriptions generated as PDFs on the server.',
      ),
      ..._prescriptions.map((item) {
        final doctor = item['doctor'] as Map<String, dynamic>? ?? {};
        final medicines = _listFromValue(
          item['medicines'],
        ).map((m) => m['name']).join(', ');
        return _contentCard(
          title: 'Dr. ${doctor['name'] ?? 'Doctor'}',
          subtitle:
              'Diagnosis: ${item['diagnosis'] ?? 'Not provided'}\nMedicines: $medicines',
          footer: OutlinedButton(
            onPressed: () => _openLink(
              'Prescription PDF',
              ApiService.absoluteUrl(item['pdfUrl']?.toString()),
            ),
            child: const Text('View / Download'),
          ),
        );
      }),
    ];
  }

  List<Widget> _notificationCards(
    List<Map<String, dynamic>> items, {
    required bool patientSide,
  }) {
    if (items.isEmpty) return [_emptyCard('No notifications yet.')];
    return [
      _sectionHeader(
        'Notifications',
        'Live dashboard alerts from appointments, payments, and prescriptions.',
      ),
      ...items.map(
        (item) => _contentCard(
          title: item['title']?.toString() ?? 'Notification',
          subtitle:
              '${item['message'] ?? ''}\n${_formatDate(item['createdAt']?.toString())}',
          footer: item['isRead'] == true
              ? null
              : TextButton(
                  onPressed: () async {
                    if (patientSide) {
                      await ApiService.markNotificationRead(_idOf(item));
                    } else {
                      await ApiService.markDoctorNotificationRead(_idOf(item));
                    }
                    await _refresh(silent: true);
                  },
                  child: const Text('Mark Read'),
                ),
        ),
      ),
    ];
  }

  List<Widget> _pharmacyCards() {
    return [
      _sectionHeader(
        'Pharmacy',
        'Continue medicine ordering from the patient dashboard.',
      ),
      ..._medicines
          .take(6)
          .map(
            (medicine) => _contentCard(
              title: medicine['name']?.toString() ?? 'Medicine',
              subtitle:
                  '${medicine['category'] ?? 'General'} • Stock ${medicine['stock'] ?? 0}\nRs ${medicine['discountedPrice'] ?? medicine['price'] ?? 0}',
              footer: OutlinedButton(
                onPressed: () async {
                  await ApiService.addToCart(medicineId: _idOf(medicine));
                  _snack('Added to cart');
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ),
      FilledButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicalKeeperStoresScreen()),
        ),
        child: const Text('Browse Stores'),
      ),
      const SizedBox(height: 12),
      ..._orders.map(
        (order) => _contentCard(
          title: 'Order ${_shortId(order)}',
          subtitle:
              'Status: ${order['status']} | Payment: ${order['paymentStatus']}\nRs ${order['totalAmount'] ?? 0}',
          footer: order['paymentStatus'] == 'paid'
              ? null
              : OutlinedButton(
                  onPressed: () async {
                    try {
                      final response = await ApiService.createOrderPayment(
                        _idOf(order),
                      );

                      if (response['success'] == true) {
                        final orderId = response['orderId'];
                        final amount = order['totalAmount'] ?? 0;

                        _currentPaymentAppointmentId = null; // Not an appointment
                        _currentOrderId = _idOf(order);

                        var options = {
                          'key': 'rzp_test_SZhuwFJP2o00Zw', // Razorpay test key
                          'amount': (amount * 100).toInt(), // Amount in paise
                          'name': 'Manoveda',
                          'order_id': orderId,
                          'description': 'Order Payment',
                          'prefill': {
                            'contact': _profile?['phone'] ?? '',
                            'email': _profile?['email'] ?? '',
                          },
                          'theme': {
                            'color': '#3B82F6',
                          }
                        };

                        _razorpay.open(options);
                      } else {
                        _snack(response['message']?.toString() ?? 'Payment unavailable');
                      }
                    } catch (e) {
                      _snack('Error creating payment order');
                    }
                  },
                  child: const Text('Pay Order'),
                ),
        ),
      ),
    ];
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
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    ApiService.connectSocket();
    ApiService.socket?.on('notification', _socketRefresh);
    _refresh();
  }

  @override
  void dispose() {
    ApiService.socket?.off('notification', _socketRefresh);
    super.dispose();
  }

  void _socketRefresh(dynamic _) {
    if (mounted) _refresh(silent: true);
  }

  Future<void> _refresh({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    final results = await Future.wait([
      ApiService.getMe(),
      ApiService.getDoctorAppointments(),
      ApiService.getDoctorPatients(),
      ApiService.getDoctorFeedbacks(),
      ApiService.getDoctorNotifications(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0]['user'] as Map<String, dynamic>?;
      _appointments = _list(results[1], 'appointments');
      _patients = _list(results[2], 'patients');
      _feedbacks = _list(results[3], 'feedbacks');
      _notifications = _list(results[4], 'notifications');
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Loginpage()),
    );
  }

  Future<void> _accept(Map<String, dynamic> appointment) async {
    final response = await ApiService.updateDoctorAppointment(
      appointmentId: _idOf(appointment),
      status: 'accepted',
    );
    _snack(response['message']?.toString() ?? 'Appointment updated');
    await _refresh();
  }

  Future<void> _reject(Map<String, dynamic> appointment) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason == null) return;
    await ApiService.updateDoctorAppointment(
      appointmentId: _idOf(appointment),
      status: 'rejected',
      rejectionReason: reason.isEmpty ? 'Doctor rejected the request' : reason,
    );
    await _refresh();
  }

  Future<void> _createMeeting(Map<String, dynamic> appointment) async {
    final response = await ApiService.createMeetingLink(_idOf(appointment));
    _snack(response['message']?.toString() ?? 'Meeting link created');
    await _refresh();
  }

  Future<void> _writePrescription(Map<String, dynamic> appointment) async {
    final draft = await showDialog<_PrescriptionDraft>(
      context: context,
      builder: (_) => const _PrescriptionDialog(),
    );
    if (draft == null) return;
    final response = await ApiService.writePrescription(
      patientId: appointment['patient']?['_id']?.toString() ?? '',
      appointmentId: _idOf(appointment),
      diagnosis: draft.diagnosis,
      medicines: draft.medicines,
      notes: draft.notes,
      followUpDate: draft.followUpDate,
    );
    _snack(response['message']?.toString() ?? 'Prescription created');
    await _refresh();
  }

  Future<void> _openDoctorChat(Map<String, dynamic> appointment) async {
    final patient = appointment['patient'] as Map<String, dynamic>? ?? {};
    final response = await ApiService.createChat(
      _idOf(patient),
      appointmentId: _idOf(appointment),
    );
    final chat = response['chat'] as Map<String, dynamic>?;
    if (chat == null || !mounted) {
      _snack(response['message']?.toString() ?? 'Chat unavailable');
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

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
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
                  _heroCard(
                    title: 'Dr. ${_profile?['name'] ?? ''}',
                    subtitle:
                        'Receive appointment requests, accept or reject them, wait for payment, unlock chat, run video consultations, and generate prescription PDFs.',
                  ),
                  _sectionHeader(
                    'Requests',
                    'Pending and active appointments from patients.',
                  ),
                  ..._appointments.map((appointment) {
                    final patient =
                        appointment['patient'] as Map<String, dynamic>? ?? {};
                    final unlocked =
                        appointment['status'] == 'confirmed' &&
                        appointment['paymentStatus'] == 'paid';
                    return _contentCard(
                      title: patient['name']?.toString() ?? 'Patient',
                      subtitle:
                          '${appointment['type']} • ${appointment['consultationMode'] ?? 'scheduled'}\n${_formatAppointmentDate(appointment)}\nStatus: ${appointment['status']} | Payment: ${appointment['paymentStatus']}',
                      footer: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (appointment['status'] == 'pending')
                            FilledButton(
                              onPressed: () => _accept(appointment),
                              child: const Text('Accept'),
                            ),
                          if (appointment['status'] == 'pending')
                            OutlinedButton(
                              onPressed: () => _reject(appointment),
                              child: const Text('Reject'),
                            ),
                          if (unlocked)
                            OutlinedButton(
                              onPressed: () => _openDoctorChat(appointment),
                              child: const Text('Chat'),
                            ),
                          if (unlocked)
                            OutlinedButton(
                              onPressed: () => _createMeeting(appointment),
                              child: const Text('Create Video Link'),
                            ),
                          if ((appointment['meetingLink']?.toString() ?? '')
                              .isNotEmpty)
                            OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LinkWebViewPage(
                                    title: 'Consultation Room',
                                    url:
                                        appointment['meetingLink']
                                            ?.toString() ??
                                        '',
                                  ),
                                ),
                              ),
                              child: const Text('Open Meeting'),
                            ),
                          if (unlocked)
                            OutlinedButton(
                              onPressed: () => _writePrescription(appointment),
                              child: const Text('Create Prescription'),
                            ),
                        ],
                      ),
                    );
                  }),
                  ..._buildNotificationSection(
                    _notifications,
                    onMarkRead: (id) async {
                      await ApiService.markDoctorNotificationRead(id);
                      await _refresh(silent: true);
                    },
                    emptyMessage: 'No doctor notifications yet.',
                    subtitle:
                        'Live request and payment alerts for the doctor dashboard.',
                  ),
                  _sectionHeader(
                    'Patients',
                    'People connected to your appointments.',
                  ),
                  ..._patients.map(
                    (patient) => _contentCard(
                      title: patient['name']?.toString() ?? 'Patient',
                      subtitle:
                          '${patient['email'] ?? ''}\n${patient['phone'] ?? ''}',
                    ),
                  ),
                  _sectionHeader('Feedback', 'Recent feedback.'),
                  ..._feedbacks.map((item) {
                    final user = item['user'] as Map<String, dynamic>? ?? {};
                    return _contentCard(
                      title:
                          '${user['name'] ?? 'Patient'} • ${item['rating'] ?? 0}/5',
                      subtitle: item['review']?.toString() ?? 'No review',
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class MedicalKeeperPortalScreen extends StatefulWidget {
  const MedicalKeeperPortalScreen({super.key});

  @override
  State<MedicalKeeperPortalScreen> createState() =>
      _MedicalKeeperPortalScreenState();
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
    if (!mounted) return;
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
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Loginpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Keeper Portal'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
            ),
            icon: const Icon(Icons.add_box),
          ),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _heroCard(
                  title: _profile?['name']?.toString() ?? 'Medical Store',
                  subtitle: 'Manage medicine inventory and pharmacy orders.',
                ),
                _statsWrap([
                  _StatCard(
                    'Medicines',
                    '${_stats?['totalMedicines'] ?? 0}',
                    Icons.medication_outlined,
                  ),
                  _StatCard(
                    'Orders',
                    '${_stats?['totalOrders'] ?? 0}',
                    Icons.local_shipping_outlined,
                  ),
                  _StatCard(
                    'Revenue',
                    'Rs ${_stats?['totalRevenue'] ?? 0}',
                    Icons.currency_rupee,
                  ),
                ]),
                ..._medicines.map(
                  (m) => _contentCard(
                    title: m['name']?.toString() ?? 'Medicine',
                    subtitle:
                        '${m['category'] ?? 'General'} • Stock ${m['stock'] ?? 0}\nRs ${m['discountedPrice'] ?? m['price'] ?? 0}',
                  ),
                ),
                ..._orders.map(
                  (o) => _contentCard(
                    title: 'Order ${_shortId(o)}',
                    subtitle:
                        '${o['status']} • ${o['paymentStatus']}\nRs ${o['totalAmount'] ?? 0}',
                  ),
                ),
              ],
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
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    ApiService.connectSocket();
    ApiService.socket?.emit('join_chat', widget.chatId);
    ApiService.socket?.on('new_message', _handleMessage);
    _load();
  }

  @override
  void dispose() {
    ApiService.socket?.emit('leave_chat', widget.chatId);
    ApiService.socket?.off('new_message', _handleMessage);
    _controller.dispose();
    super.dispose();
  }

  void _handleMessage(dynamic raw) {
    if (raw is! Map) return;
    final message = Map<String, dynamic>.from(raw);
    if ((message['chat']?.toString() ?? '') != widget.chatId) return;
    if (!mounted) return;
    setState(() {
      final exists = _messages.any((m) => _idOf(m) == _idOf(message));
      if (!exists) _messages.insert(0, message);
    });
  }

  Future<void> _load() async {
    final response = await ApiService.getMessages(widget.chatId);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(_list(response, 'messages'));
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    ApiService.socket?.emit('send_message', {
      'chatId': widget.chatId,
      'content': text,
      'messageType': 'text',
    });
    _controller.clear();
    if (mounted) setState(() => _sending = false);
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
                      final sender =
                          message['sender'] as Map<String, dynamic>? ?? {};
                      final mine = _idOf(sender) == ApiService.userId;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: mine
                                ? const Color(0xFF0F62FE)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: mine
                                ? null
                                : Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            message['content']?.toString() ?? '',
                            style: TextStyle(
                              color: mine ? Colors.white : Colors.black87,
                            ),
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
                        hintText: 'Type message',
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

class LinkWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const LinkWebViewPage({super.key, required this.title, required this.url});

  @override
  State<LinkWebViewPage> createState() => _LinkWebViewPageState();
}

class _LinkWebViewPageState extends State<LinkWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: _controller),
    );
  }
}

class _AppointmentRequestDialog extends StatefulWidget {
  final String doctorName;

  const _AppointmentRequestDialog({required this.doctorName});

  @override
  State<_AppointmentRequestDialog> createState() =>
      _AppointmentRequestDialogState();
}

class _AppointmentRequestDialogState extends State<_AppointmentRequestDialog> {
  final TextEditingController _symptomsController = TextEditingController();
  String _mode = 'scheduled';
  String _type = 'video';
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request ${widget.doctorName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _mode,
              items: const [
                DropdownMenuItem(
                  value: 'instant',
                  child: Text('Instant consultation'),
                ),
                DropdownMenuItem(
                  value: 'scheduled',
                  child: Text('Schedule for later'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _mode = value ?? 'scheduled'),
              decoration: const InputDecoration(labelText: 'Mode'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'video', child: Text('Video')),
                DropdownMenuItem(value: 'chat', child: Text('Chat')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'video'),
              decoration: const InputDecoration(labelText: 'Consultation type'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormat('dd MMM yyyy').format(_date)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Time'),
              subtitle: Text(_time.format(context)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
            ),
            TextField(
              controller: _symptomsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Symptoms / reason',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final date = DateTime(
              _date.year,
              _date.month,
              _date.day,
              _time.hour,
              _time.minute,
            );
            Navigator.pop(
              context,
              _AppointmentDraft(
                consultationMode: _mode,
                type: _type,
                date: date,
                timeLabel: _time.format(context),
                symptoms: _symptomsController.text.trim(),
              ),
            );
          },
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}

class _PrescriptionDialog extends StatefulWidget {
  const _PrescriptionDialog();

  @override
  State<_PrescriptionDialog> createState() => _PrescriptionDialogState();
}

class _PrescriptionDialogState extends State<_PrescriptionDialog> {
  final TextEditingController _diagnosis = TextEditingController();
  final TextEditingController _medicine = TextEditingController(
    text: 'Medicine',
  );
  final TextEditingController _dosage = TextEditingController(text: '1 tablet');
  final TextEditingController _frequency = TextEditingController(
    text: 'Twice daily',
  );
  final TextEditingController _duration = TextEditingController(text: '5 days');
  final TextEditingController _instructions = TextEditingController(
    text: 'After food',
  );
  final TextEditingController _notes = TextEditingController();
  DateTime? _followUpDate;

  @override
  void dispose() {
    _diagnosis.dispose();
    _medicine.dispose();
    _dosage.dispose();
    _frequency.dispose();
    _duration.dispose();
    _instructions.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Digital Prescription'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _diagnosis,
              decoration: const InputDecoration(labelText: 'Diagnosis'),
            ),
            TextField(
              controller: _medicine,
              decoration: const InputDecoration(labelText: 'Medicine'),
            ),
            TextField(
              controller: _dosage,
              decoration: const InputDecoration(labelText: 'Dosage'),
            ),
            TextField(
              controller: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            TextField(
              controller: _duration,
              decoration: const InputDecoration(labelText: 'Duration'),
            ),
            TextField(
              controller: _instructions,
              decoration: const InputDecoration(labelText: 'Instructions'),
            ),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _followUpDate = picked);
              },
              child: Text(
                _followUpDate == null
                    ? 'Add follow-up date'
                    : 'Follow-up: ${DateFormat('dd MMM yyyy').format(_followUpDate!)}',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              _PrescriptionDraft(
                diagnosis: _diagnosis.text.trim().isEmpty
                    ? 'General consultation'
                    : _diagnosis.text.trim(),
                medicines: [
                  {
                    'name': _medicine.text.trim(),
                    'dosage': _dosage.text.trim(),
                    'frequency': _frequency.text.trim(),
                    'duration': _duration.text.trim(),
                    'instructions': _instructions.text.trim(),
                  },
                ],
                notes: _notes.text.trim(),
                followUpDate: _followUpDate,
              ),
            );
          },
          child: const Text('Generate PDF'),
        ),
      ],
    );
  }
}

class _AppointmentDraft {
  final String consultationMode;
  final String type;
  final DateTime date;
  final String timeLabel;
  final String symptoms;

  const _AppointmentDraft({
    required this.consultationMode,
    required this.type,
    required this.date,
    required this.timeLabel,
    required this.symptoms,
  });
}

class _PrescriptionDraft {
  final String diagnosis;
  final List<Map<String, dynamic>> medicines;
  final String notes;
  final DateTime? followUpDate;

  const _PrescriptionDraft({
    required this.diagnosis,
    required this.medicines,
    required this.notes,
    required this.followUpDate,
  });
}

class _StatCard {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(this.label, this.value, this.icon);
}

Widget _heroCard({
  required String title,
  required String subtitle,
  Widget? action,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0F62FE), Color(0xFF4DA1FF)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: Colors.white)),
        if (action != null) ...[const SizedBox(height: 12), action],
      ],
    ),
  );
}

Widget _statsWrap(List<_StatCard> cards) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map(
            (card) => SizedBox(
              width: 165,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDCEBFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(card.icon, color: const Color(0xFF0F62FE)),
                    const SizedBox(height: 10),
                    Text(
                      card.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(card.label),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

Widget _sectionHeader(String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitle),
      ],
    ),
  );
}

Widget _contentCard({
  required String title,
  required String subtitle,
  Widget? footer,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(subtitle),
        if (footer != null) ...[const SizedBox(height: 14), footer],
      ],
    ),
  );
}

Widget _emptyCard(String message) =>
    _contentCard(title: 'Nothing here yet', subtitle: message);

List<Widget> _buildNotificationSection(
  List<Map<String, dynamic>> items, {
  required Future<void> Function(String id) onMarkRead,
  required String emptyMessage,
  required String subtitle,
}) {
  if (items.isEmpty) {
    return [_emptyCard(emptyMessage)];
  }
  return [
    _sectionHeader('Notifications', subtitle),
    ...items.map(
      (item) => _contentCard(
        title: item['title']?.toString() ?? 'Notification',
        subtitle:
            '${item['message'] ?? ''}\n${_formatDate(item['createdAt']?.toString())}',
        footer: item['isRead'] == true
            ? null
            : TextButton(
                onPressed: () => onMarkRead(_idOf(item)),
                child: const Text('Mark Read'),
              ),
      ),
    ),
  ];
}

List<Map<String, dynamic>> _list(Map<String, dynamic> source, String key) {
  final value = source[key];
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<Map<String, dynamic>> _listFromValue(dynamic value) {
  if (value is! List) return [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String _idOf(Map<String, dynamic> item) =>
    item['_id']?.toString() ?? item['id']?.toString() ?? '';

String _shortId(Map<String, dynamic> item) {
  final id = _idOf(item);
  return id.length > 6 ? id.substring(0, 6) : id;
}

String _chatTitle(Map<String, dynamic> chat) {
  final participants = _listFromValue(chat['participants']);
  for (final participant in participants) {
    if (_idOf(participant) != ApiService.userId) {
      return participant['name']?.toString() ?? 'Chat';
    }
  }
  return chat['groupName']?.toString() ?? 'Chat';
}

String _formatAppointmentDate(Map<String, dynamic> appointment) {
  return '${_formatDate(appointment['date']?.toString(), dateOnly: true)} at ${appointment['time'] ?? ''}';
}

String _formatDate(String? raw, {bool dateOnly = false}) {
  if (raw == null || raw.isEmpty) return 'Unknown';
  final parsed = DateTime.tryParse(raw)?.toLocal();
  if (parsed == null) return raw;
  return dateOnly
      ? DateFormat('dd MMM yyyy').format(parsed)
      : DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
}

String _patientTitle(PatientSection section) {
  switch (section) {
    case PatientSection.overview:
      return 'Patient Dashboard';
    case PatientSection.doctors:
      return 'Doctors';
    case PatientSection.appointments:
      return 'Appointments';
    case PatientSection.chats:
      return 'Chats';
    case PatientSection.prescriptions:
      return 'Prescriptions';
    case PatientSection.notifications:
      return 'Notifications';
    case PatientSection.pharmacy:
      return 'Pharmacy';
    case PatientSection.wellness:
      return 'Wellness';
  }
  }
