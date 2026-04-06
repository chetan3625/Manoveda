import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:manoveda/splashscreen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
import 'cart_screen.dart';

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
  cart,
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
  int _cartCount = 0;
  int _cartTotal = 0;
 
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
    try {
      final results = await Future.wait([
        ApiService.getMe(),
        ApiService.getDoctors(),
        ApiService.getAppointments(),
        ApiService.getPrescriptions(),
        ApiService.getNotifications(),
        ApiService.getMedicalKeepers(),
        ApiService.getOrders(),
        ApiService.getChats(),
        ApiService.getCart(),
      ]);
      if (!mounted) return;
      
      final order = results[8]['order'] as Map<String, dynamic>?;
      final cartItems = order?['items'] as List? ?? [];
      
      // Check for API errors
      final prescriptionsResponse = results[3];
      final prescriptionsSuccess = prescriptionsResponse['success'] != false;
      final prescriptions = prescriptionsSuccess ? _list(prescriptionsResponse, 'prescriptions') : <Map<String, dynamic>>[];
      if (!prescriptionsSuccess && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(prescriptionsResponse['message'] ?? 'Error loading prescriptions')),
        );
      }
      
      setState(() {
        _profile = results[0]['user'] as Map<String, dynamic>?;
        _doctors = _list(results[1], 'doctors');
        _appointments = _list(results[2], 'appointments');
        _prescriptions = prescriptions;
        _notifications = _list(results[4], 'notifications');
        _medicines = _list(results[5], 'keepers');
        _cartCount = cartItems.length;
        _cartTotal = cartItems.fold(0, (sum, item) => sum + ((item['totalPrice'] ?? 0) as int));
        _medicines = _list(results[5], 'medicines');
        _orders = _list(results[6], 'orders');
        _chats = _list(results[7], 'chats');
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _loading = false);
    }
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
    // Handle payment failure with detailed logging
    print('Payment Error: Code=${response.code}, Description=${response.message}');
    String errorMsg = response.message ?? 'Unknown error';
    
    if (errorMsg.contains('Invalid OTP')) {
      errorMsg = 'Invalid OTP: Please enter 000000 (six zeros) or any 6-digit number';
    } else if (errorMsg.contains('Card')) {
      errorMsg = 'Card error: Try card 4111 1111 1111 1111';
    }
    
    _snack('Payment failed: $errorMsg');
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

        print('Payment Order Created: orderId=$orderId, amount=$amount');

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
        print('Payment creation failed: ${response['message']}');
      }
    } catch (e) {
      _snack('Error creating payment order: $e');
      print('Error: $e');
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

  bool _isPdfUrl(String url) {
    final parsed = Uri.tryParse(url);
    final path = parsed?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.pdf');
  }

  bool _shouldPreferExternalOpen(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    const externalHosts = <String>[
      'meet.jit.si',
      'meet.google.com',
      'zoom.us',
      'teams.microsoft.com',
      'web.skype.com',
    ];
    return externalHosts.any((item) => host == item || host.endsWith('.$item'));
  }

  Future<bool> _tryLaunchUrl(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      return await launchUrl(uri, mode: mode);
    } catch (_) {
      return false;
    }
  }

  Future<void> _openPdfLink(String title, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack('Unable to open $title. The PDF link is invalid.');
      return;
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerPage(title: title, url: url),
      ),
    );
  }

  Future<void> _openLink(String title, String url) async {
    if (url.isEmpty) {
      _snack('$title is not available yet');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack('Unable to open $title. The link is invalid.');
      return;
    }

    if (_isPdfUrl(url)) {
      await _openPdfLink(title, url);
      return;
    }

    if (_shouldPreferExternalOpen(url)) {
      final openedExternally = await _tryLaunchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (openedExternally) {
        return;
      }

      final openedInBrowser = await _tryLaunchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (openedInBrowser) {
        return;
      }
    }

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LinkWebViewPage(
          title: title,
          url: url,
          fallbackUrl: url,
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
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  accountName: Text(_profile?['name']?.toString() ?? 'Patient', style: const TextStyle(color: Colors.white)),
                  accountEmail: Text(_profile?['email']?.toString() ?? '', style: const TextStyle(color: Colors.white)),
                  currentAccountPicture: CircleAvatar(
                    child: Image.asset(
                      'assets/Icons/patient.jpg',
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 30),
                    ),
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
                PatientSection.wellness,
                Icons.favorite,
                'Wellness Features',
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Wellness Tools', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Cart & Pharmacy', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
              _patientDrawerTile(
                PatientSection.pharmacy,
                Icons.local_pharmacy_outlined,
                'Pharmacy',
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart, color: Colors.white),
                title: const Text('Cart', style: TextStyle(color: Colors.white)),
                onTap: () => _openCart(),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Go to Homepage', style: TextStyle(color: Colors.white)),
                onTap: () => _goToHomepage(),
              ),
            ],
            ),
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
                    clipBehavior: Clip.antiAlias,
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
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        setState(() => _section = section);
      },
    );
  }

  Widget _wellnessToolTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _openCart() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
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
    if (_section == PatientSection.cart) {
      return _cartBody();
    }
    if (_section == PatientSection.wellness) {
      return _wellnessBody();
    }
    return [];
  }

  List<Widget> _cartBody() {
    return [
      _sectionHeader('Shopping Cart', 'View items and proceed to checkout'),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _openPage(const CartScreen()),
          child: const Text('Open Cart'),
        ),
      ),
    ];
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
        ''
      ),
      ...items.map(
        (doctor) => _contentCard(
          title: Text(doctor['name']?.toString() ?? 'Doctor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(
              '${doctor['specialization'] ?? 'General'}\nExperience: ${doctor['experience'] ?? 0} years\nAvailability: ${doctor['isAvailable'] == true ? 'Available' : 'Offline'}',
              style: const TextStyle(color: Colors.white70),
          ),
          avatarPath: 'assets/Icons/doctor.png',
          footer: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Fee Rs ${doctor['consultationFee'] ?? 0}')),
                FilledButton(
                  onPressed: () => _requestAppointment(doctor),
                  child: const Text('Request'),
                ),
              ],
            ),
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
        '',
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
          title: Text(doctor['name']?.toString() ?? 'Doctor'),
          subtitle: Text(
              '${appointment['type']} • ${appointment['consultationMode'] ?? 'scheduled'}\n${_formatAppointmentDate(appointment)}\nStatus: ${appointment['status']} | Payment: ${appointment['paymentStatus']}',
          ),
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
          title: Text(_chatTitle(chat), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(chat['lastMessage']?.toString() ?? 'No messages yet', style: const TextStyle(color: Colors.white70)),
          avatarPath: 'assets/Icons/patient.jpg',
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

  Future<void> _generateAndShowPdf(Map<String, dynamic> prescription) async {
    try {
      print('Generating PDF for prescription: $prescription');
      final pdf = pw.Document();
      final doctor = prescription['doctor'] as Map<String, dynamic>? ?? {};
      final medicines = _listFromValue(prescription['medicines']);

      print('Doctor: $doctor');
      print('Medicines: $medicines');

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Prescription', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Doctor: Dr. ${doctor['name'] ?? 'Doctor'}'),
                pw.Text('Patient: ${_profile?['name'] ?? 'Patient'}'),
                pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
                pw.SizedBox(height: 20),
                pw.Text('Diagnosis: ${prescription['diagnosis'] ?? 'Not provided'}'),
                pw.SizedBox(height: 20),
                pw.Text('Medicines:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...medicines.map((m) => pw.Text('- ${m['name'] ?? ''} ${m['dosage'] ?? ''} ${m['frequency'] ?? ''}')),
                pw.SizedBox(height: 20),
                pw.Text('Instructions: ${prescription['instructions'] ?? 'Follow prescribed dosage.'}'),
              ],
            );
          },
        ),
      );

      print('PDF document created, saving to file...');
      
      // Get the documents directory
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/prescription_${prescription['_id']}.pdf');
      
      // Save PDF to file
      await file.writeAsBytes(await pdf.save());
      print('PDF saved to: ${file.path}');
      
      // Open the PDF file
      print('Opening PDF...');
      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        print('PDF opened successfully');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ PDF saved to:\n${file.path}'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green[700],
          ),
        );
      }
      
    } catch (e) {
      print('ERROR generating PDF: $e');
      print('Stack trace: ${StackTrace.current}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
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
          title: Text('Dr. ${doctor['name'] ?? 'Doctor'}'),
          subtitle: Text(
              'Diagnosis: ${item['diagnosis'] ?? 'Not provided'}\nMedicines: $medicines',
          ),
          footer: ElevatedButton(
            onPressed: () => _openLink(
              'Prescription PDF',
              ApiService.absoluteUrl(item['pdfUrl']?.toString()),
            ),
            child: const Text('View PDF'),
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
          title: Text(item['title']?.toString() ?? 'Notification'),
          subtitle: Text(
              '${item['message'] ?? ''}\n${_formatDate(item['createdAt']?.toString())}'),
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
        'Browse medical stores and order medicines.',
      ),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MedicalKeeperStoresScreen()),
          ),
          icon: const Icon(Icons.store),
          label: const Text('Browse Medical Stores'),
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() => _section = PatientSection.cart);
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Go to Cart'),
        ),
      ),
      const SizedBox(height: 12),
      ..._orders.map(
        (order) => _contentCard(
          title: Text('Order ${_shortId(order)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(
              'Status: ${order['status']} | Payment: ${order['paymentStatus']}\nRs ${order['totalAmount'] ?? 0}',
              style: const TextStyle(color: Colors.white70)),
          avatarPath: 'assets/Icons/patient.jpg',
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

                        print('Order Payment Created: orderId=$orderId, amount=$amount');

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
                        print('Order payment creation failed: ${response['message']}');
                      }
                    } catch (e) {
                      _snack('Error creating payment order: $e');
                      print('Error: $e');
                    }
                  },
                  child: const Text('Pay Order'),
                ),
        ),
      ),
    ];
  }
}

enum DoctorSection {
  dashboard,
  patients,
  appointments,
  upcomingAppointments,
  feedbacks,
  notifications,
}

class DoctorPortalScreen extends StatefulWidget {
  const DoctorPortalScreen({super.key});

  @override
  State<DoctorPortalScreen> createState() => _DoctorPortalScreenState();
}

class _DoctorPortalScreenState extends State<DoctorPortalScreen> {
  bool _loading = true;
  DoctorSection _section = DoctorSection.dashboard;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> _feedbacks = [];
  List<Map<String, dynamic>> _notifications = [];

  // Search & Filter Controllers
  final TextEditingController _patientSearchController = TextEditingController();
  final TextEditingController _appointmentSearchController = TextEditingController();
  final TextEditingController _feedbackSearchController = TextEditingController();
  final TextEditingController _notificationSearchController = TextEditingController();
  
  // Bulk action state
  Set<String> _selectedAppointments = {};
  bool _bulkMode = false;
  
  // Filter state
  DateTime? _appointmentDateFrom;
  DateTime? _appointmentDateTo;
  String? _appointmentStatusFilter;
  int? _feedbackRatingFrom;
  int? _feedbackRatingTo;
  String? _notificationTypeFilter;

  @override
  void initState() {
    super.initState();
    ApiService.connectSocket();
    ApiService.socket?.on('notification', _socketRefresh);
    _refresh();
  }

  @override
  void dispose() {
    _patientSearchController.dispose();
    _appointmentSearchController.dispose();
    _feedbackSearchController.dispose();
    _notificationSearchController.dispose();
    ApiService.socket?.off('notification', _socketRefresh);
    super.dispose();
  }

  void _socketRefresh(dynamic _) {
    if (mounted) _refresh(silent: true);
  }

  Future<void> _searchPatients(String query) async {
    if (query.isEmpty) {
      await _refresh();
      return;
    }
    final result = await ApiService.searchDoctorPatients(query: query);
    if (mounted) {
      setState(() {
        _patients = _list(result, 'patients');
      });
    }
  }

  Future<void> _searchAppointments() async {
    final query = _appointmentSearchController.text.trim();
    final result = await ApiService.searchDoctorAppointments(
      query: query.isEmpty ? null : query,
      status: _appointmentStatusFilter,
      dateFrom: _appointmentDateFrom,
      dateTo: _appointmentDateTo,
    );
    if (mounted) {
      setState(() {
        _appointments = _list(result, 'appointments');
      });
    }
  }

  Future<void> _searchFeedbacks() async {
    final query = _feedbackSearchController.text.trim();
    final result = await ApiService.searchDoctorFeedbacks(
      query: query.isEmpty ? null : query,
      ratingFrom: _feedbackRatingFrom,
      ratingTo: _feedbackRatingTo,
    );
    if (mounted) {
      setState(() {
        _feedbacks = _list(result, 'feedbacks');
      });
    }
  }

  Future<void> _searchNotifications() async {
    final query = _notificationSearchController.text.trim();
    final result = await ApiService.searchDoctorNotifications(
      query: query.isEmpty ? null : query,
      type: _notificationTypeFilter,
    );
    if (mounted) {
      setState(() {
        _notifications = _list(result, 'notifications');
      });
    }
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

  // Micro-Feature: Appointment Actions

  Future<void> _markAppointmentPriority(Map<String, dynamic> appointment) async {
    final isPriority = !(appointment['isPriority'] ?? false);
    final response = await ApiService.markAppointmentPriority(
      appointmentId: _idOf(appointment),
      isPriority: isPriority,
    );
    _snack(response['message']?.toString() ?? 'Priority updated');
    await _refresh();
  }

  Future<void> _markAppointmentComplete(Map<String, dynamic> appointment) async {
    final response = await ApiService.markAppointmentComplete(_idOf(appointment));
    _snack(response['message']?.toString() ?? 'Appointment marked as completed');
    await _refresh();
  }

  Future<void> _rescheduleAppointment(Map<String, dynamic> appointment) async {
    final currentDate = DateTime.tryParse(appointment['date']?.toString() ?? '') ?? DateTime.now();
    final currentTime = appointment['time']?.toString() ?? '10:00';

    final date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.parse('$currentDate $currentTime')),
    );
    if (time == null) return;

    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reschedule Reason'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason (optional)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, reasonController.text.trim()),
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
    if (reason == null) return;

    final newDate = date;
    final newTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final response = await ApiService.rescheduleAppointment(
      appointmentId: _idOf(appointment),
      newDate: newDate,
      newTime: newTime,
      reason: reason.isEmpty ? null : reason,
    );
    _snack(response['message']?.toString() ?? 'Appointment rescheduled');
    await _refresh();
  }

  Future<void> _bulkAppointmentAction(String action) async {
    if (_selectedAppointments.isEmpty) {
      _snack('Please select appointments first');
      return;
    }

    final confirmMessage = action == 'accept' ? 'Accept ${_selectedAppointments.length} appointments?'
      : action == 'reject' ? 'Reject ${_selectedAppointments.length} appointments?'
      : action == 'mark-priority' ? 'Mark ${_selectedAppointments.length} appointments as priority?'
      : 'Remove priority from ${_selectedAppointments.length} appointments?';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Bulk Action'),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await ApiService.bulkAppointmentAction(
      appointmentIds: _selectedAppointments.toList(),
      action: action,
    );
    _snack(response['message']?.toString() ?? 'Bulk action completed');
    setState(() {
      _selectedAppointments.clear();
      _bulkMode = false;
    });
    await _refresh();
  }

  // Micro-Feature: Feedback Actions

  Future<void> _replyToFeedback(Map<String, dynamic> feedback) async {
    final replyController = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reply to Feedback'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(labelText: 'Your reply'),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, replyController.text.trim()),
            child: const Text('Reply'),
          ),
        ],
      ),
    );
    if (reply == null || reply.isEmpty) return;

    final response = await ApiService.replyToFeedback(
      feedbackId: _idOf(feedback),
      reply: reply,
    );
    _snack(response['message']?.toString() ?? 'Reply sent');
    await _refresh();
  }

  Future<void> _deleteFeedback(Map<String, dynamic> feedback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await ApiService.deleteDoctorFeedback(_idOf(feedback));
    _snack(response['message']?.toString() ?? 'Feedback deleted');
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

  Future<void> _openMeetingLink(String url) async {
    if (url.isEmpty) {
      _snack('Consultation Room is not available yet');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack('Unable to open consultation room. The link is invalid.');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) {
        return;
      }
    } catch (_) {}

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LinkWebViewPage(
          title: 'Consultation Room',
          url: url,
          fallbackUrl: url,
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  int _getTotalPatientsThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final uniquePatients = <String>{};
    
    for (final appointment in _appointments) {
      final createdAt = appointment['createdAt'];
      if (createdAt != null) {
        try {
          final date = DateTime.parse(createdAt.toString());
          if (date.isAfter(monthStart) && date.isBefore(now.add(const Duration(days: 1)))) {
            final patientId = appointment['patient']?['_id']?.toString();
            if (patientId != null) uniquePatients.add(patientId);
          }
        } catch (_) {}
      }
    }
    return uniquePatients.length;
  }

  double _getTotalEarningsThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    double total = 0;
    
    for (final appointment in _appointments) {
      if (appointment['paymentStatus'] == 'paid' && appointment['status'] == 'confirmed') {
        final createdAt = appointment['createdAt'];
        if (createdAt != null) {
          try {
            final date = DateTime.parse(createdAt.toString());
            if (date.isAfter(monthStart) && date.isBefore(now.add(const Duration(days: 1)))) {
              final fee = appointment['fee'];
              if (fee != null) total += (fee is int ? fee.toDouble() : fee as double);
            }
          } catch (_) {}
        }
      }
    }
    return total;
  }

  int _getPendingAppointments() {
    return _appointments.where((a) => a['status'] == 'pending').length;
  }

  List<Map<String, dynamic>> _getUpcomingAppointments() {
    final now = DateTime.now();
    final upcoming = <Map<String, dynamic>>[];
    final patientLastAppts = <String, Map<String, dynamic>>{};

    for (final appointment in _appointments) {
      if (appointment['status'] == 'confirmed' && appointment['paymentStatus'] == 'paid') {
        final patientId = appointment['patient']?['_id']?.toString() ?? '';
        if (patientId.isNotEmpty) {
          if (patientLastAppts[patientId] == null) {
            patientLastAppts[patientId] = appointment;
          } else {
            final lastDate = DateTime.tryParse(patientLastAppts[patientId]!['createdAt']?.toString() ?? '');
            final currentDate = DateTime.tryParse(appointment['createdAt']?.toString() ?? '');
            if (lastDate != null && currentDate != null && currentDate.isAfter(lastDate)) {
              patientLastAppts[patientId] = appointment;
            }
          }
        }
      }
    }

    for (final patientId in patientLastAppts.keys) {
      final lastAppt = patientLastAppts[patientId]!;
      final lastDate = DateTime.tryParse(lastAppt['createdAt']?.toString() ?? '');
      if (lastDate != null) {
        final duration = lastAppt['duration'] ?? 30;
        final nextDate = lastDate.add(Duration(days: duration));
        if (nextDate.isAfter(now)) {
          upcoming.add({
            ...lastAppt,
            'nextAppointmentDate': nextDate.toIso8601String(),
            'daysUntilNextAppt': nextDate.difference(now).inDays,
          });
        }
      }
    }

    upcoming.sort((a, b) => (a['daysUntilNextAppt'] as int).compareTo(b['daysUntilNextAppt'] as int));
    return upcoming;
  }

  String _getSectionTitle() {
    switch (_section) {
      case DoctorSection.dashboard:
        return 'Dashboard';
      case DoctorSection.patients:
        return 'All Patients';
      case DoctorSection.appointments:
        return 'Appointment Requests';
      case DoctorSection.upcomingAppointments:
        return 'Upcoming Appointments';
      case DoctorSection.feedbacks:
        return 'Patient Feedback';
      case DoctorSection.notifications:
        return 'Notifications';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getSectionTitle()),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  accountName: Text('Dr. ${_profile?['name'] ?? 'Doctor'}', style: const TextStyle(color: Colors.white)),
                  accountEmail: Text('${_profile?['specialization'] ?? 'General'}', style: const TextStyle(color: Colors.white)),
                  currentAccountPicture: CircleAvatar(
                    child: Image.asset(
                      'assets/Icons/doctor.png',
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.white),
                  title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                  selected: _section == DoctorSection.dashboard,
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _section = DoctorSection.dashboard);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.white),
                  title: const Text('All Patients', style: TextStyle(color: Colors.white)),
                  selected: _section == DoctorSection.patients,
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _section = DoctorSection.patients);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.white),
                  title: const Text('Appointment Requests', style: TextStyle(color: Colors.white)),
                  selected: _section == DoctorSection.appointments,
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _section = DoctorSection.appointments);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_available, color: Colors.white),
                  title: const Text('Upcoming Appointments', style: TextStyle(color: Colors.white)),
                  selected: _section == DoctorSection.upcomingAppointments,
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _section = DoctorSection.upcomingAppointments);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.white),
                  title: const Text('Feedback', style: TextStyle(color: Colors.white)),
                  selected: _section == DoctorSection.feedbacks,
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _section = DoctorSection.feedbacks);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.white),
                  title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                  selected: _section == DoctorSection.notifications,
                  selectedTileColor: Colors.white.withValues(alpha: 0.1),
                  onTap: () {
                    setState(() => _section = DoctorSection.notifications);
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white30),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text('Logout', style: TextStyle(color: Colors.white)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: _buildSectionBody(),
            ),
    );
  }

  Widget _buildSectionBody() {
    switch (_section) {
      case DoctorSection.dashboard:
        return _buildDashboard();
      case DoctorSection.patients:
        return _buildPatientsView();
      case DoctorSection.appointments:
        return _buildAppointmentsView();
      case DoctorSection.upcomingAppointments:
        return _buildUpcomingAppointmentsView();
      case DoctorSection.feedbacks:
        return _buildFeedbackView();
      case DoctorSection.notifications:
        return _buildNotificationsView();
    }
  }

  Widget _buildDashboard() {
    final dashboardAppointments = _dashboardAppointments();
    final dashboardPatients = _dashboardPatients();
    final dashboardFeedbacks = _dashboardFeedbacks();
    final dashboardNotifications = _dashboardNotifications();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heroCard(
          title: 'Dr. ${_profile?['name'] ?? ''}',
          subtitle:
              'Receive appointment requests, accept or reject them, wait for payment, unlock chat, run video consultations, and generate prescription PDFs.',
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 900
                ? 3
                : width >= 560
                    ? 2
                    : 1;
            final aspectRatio = width >= 900
                ? 1.25
                : width >= 560
                    ? 1.45
                    : 2.6;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _statCard(
                  icon: Icons.people,
                  title: _getTotalPatientsThisMonth().toString(),
                  subtitle: 'Patients\nThis Month',
                  color: Colors.blue,
                ),
                _statCard(
                  icon: Icons.currency_rupee,
                  title: '₹${_getTotalEarningsThisMonth().toStringAsFixed(0)}',
                  subtitle: 'Earnings\nThis Month',
                  color: Colors.green,
                ),
                _statCard(
                  icon: Icons.schedule,
                  title: _getPendingAppointments().toString(),
                  subtitle: 'Pending\nAppointments',
                  color: Colors.orange,
                ),
              ],
            );
          },
        ),
                  const SizedBox(height: 24),
                  _sectionHeader(
                    'Requests',
                    'Pending and active appointments from patients.',
                  ),
                  if (dashboardAppointments.isEmpty)
                    _emptyCard('No request data available')
                  else
                    ...dashboardAppointments.map((appointment) {
                    final patient =
                        appointment['patient'] as Map<String, dynamic>? ?? {};
                    final unlocked =
                        appointment['status'] == 'confirmed' &&
                        appointment['paymentStatus'] == 'paid';
                    final title = _displayText(patient['name']) ??
                        _displayText(appointment['patientName']) ??
                        'Request ${_shortId(appointment)}';
                    final details = [
                      _displayText(appointment['type']),
                      _displayText(appointment['consultationMode']),
                      _displayAppointmentDate(appointment),
                      _displayStatusLine(appointment),
                    ].whereType<String>().join('\n');

                    return _contentCard(
                      title: Text(title),
                      subtitle: Text(details),
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
                              onPressed: () => _openMeetingLink(
                                appointment['meetingLink']?.toString() ?? '',
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
                    dashboardNotifications,
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
                  if (dashboardPatients.isEmpty)
                    _emptyCard('No patient data available')
                  else
                    ...dashboardPatients.map(
                    (patient) => _contentCard(
                      title: Text(
                        _displayText(patient['name']) ??
                            'Patient ${_shortId(patient)}',
                      ),
                      subtitle: Text(
                        [
                          _displayText(patient['email']),
                          _displayText(patient['phone']),
                        ].whereType<String>().join('\n'),
                      ),
                    ),
                  ),
                  _sectionHeader('Feedback', 'Recent feedback.'),
                  if (dashboardFeedbacks.isEmpty)
                    _emptyCard('No feedback data available')
                  else
                    ...dashboardFeedbacks.map((item) {
                    final user = item['user'] as Map<String, dynamic>? ?? {};
                    final reviewer = _displayText(user['name']) ??
                        'Feedback ${_shortId(item)}';
                    final review = _displayText(item['review']);
                    final rating = item['rating']?.toString();
                    return _contentCard(
                      title: Text(
                        rating != null && rating.isNotEmpty
                            ? '$reviewer • $rating/5'
                            : reviewer,
                      ),
                      subtitle: Text(review ?? ''),
                    );
                  }),
                ],
              );
  }

  Widget _buildPatientsView() {
    final patients = _dashboardPatients();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _patientSearchController,
          decoration: InputDecoration(
            labelText: 'Search patients',
            hintText: 'Name, email, or phone',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _patientSearchController.text.isEmpty 
              ? null 
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _patientSearchController.clear();
                    _searchPatients('');
                  },
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (query) {
            setState(() {});
            if (query.isNotEmpty) {
              _searchPatients(query);
            }
          },
        ),
        const SizedBox(height: 16),
        if (patients.isEmpty)
          _emptyCard('No patients found')
        else
          ...patients.map(
            (patient) => _contentCard(
              title: Text(
                _displayText(patient['name']) ??
                    'Patient ${_shortId(patient)}',
              ),
              subtitle: Text(
                  [
                    _displayText(patient['email']),
                    _displayText(patient['phone']),
                    _displayRegisteredDate(patient),
                  ].whereType<String>().join('\n')),
            ),
          ),
      ],
    );
  }

  Widget _buildAppointmentsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar
        TextField(
          controller: _appointmentSearchController,
          decoration: InputDecoration(
            labelText: 'Search appointments',
            hintText: 'Patient name, email or phone',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _appointmentSearchController.text.isEmpty 
              ? null 
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _appointmentSearchController.clear();
                    _appointmentStatusFilter = null;
                    _appointmentDateFrom = null;
                    _appointmentDateTo = null;
                    setState(() {});
                    _refresh();
                  },
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (_) {
            setState(() {});
            _searchAppointments();
          },
        ),
        const SizedBox(height: 12),
        
        // Filter bar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Status filter dropdown
            DropdownMenu<String?>(
              initialSelection: _appointmentStatusFilter,
              onSelected: (value) {
                setState(() => _appointmentStatusFilter = value);
                _searchAppointments();
              },
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All status'),
                const DropdownMenuEntry(value: 'pending', label: 'Pending'),
                const DropdownMenuEntry(value: 'accepted', label: 'Accepted'),
                const DropdownMenuEntry(value: 'confirmed', label: 'Confirmed'),
                const DropdownMenuEntry(value: 'completed', label: 'Completed'),
                const DropdownMenuEntry(value: 'rejected', label: 'Rejected'),
              ],
            ),
            
            // Date from
            Tooltip(
              message: _appointmentDateFrom == null ? 'Select from date' : _formatDate(_appointmentDateFrom!.toIso8601String()),
              child: FilledButton.tonal(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _appointmentDateFrom ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _appointmentDateFrom = date);
                    _searchAppointments();
                  }
                },
                child: Text(_appointmentDateFrom == null ? 'From date' : _formatDate(_appointmentDateFrom!.toIso8601String())),
              ),
            ),
            
            // Date to
            Tooltip(
              message: _appointmentDateTo == null ? 'Select to date' : _formatDate(_appointmentDateTo!.toIso8601String()),
              child: FilledButton.tonal(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _appointmentDateTo ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => _appointmentDateTo = date);
                    _searchAppointments();
                  }
                },
                child: Text(_appointmentDateTo == null ? 'To date' : _formatDate(_appointmentDateTo!.toIso8601String())),
              ),
            ),
            
            // Clear filters
            if (_appointmentStatusFilter != null || _appointmentDateFrom != null || _appointmentDateTo != null)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _appointmentStatusFilter = null;
                    _appointmentDateFrom = null;
                    _appointmentDateTo = null;
                  });
                  _searchAppointments();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear filters'),
              ),
          ],
        ),
        // Bulk action controls
        if (_bulkMode)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Text('${_selectedAppointments.length} selected'),
                const Spacer(),
                OutlinedButton(
                  onPressed: () => _bulkAppointmentAction('accept'),
                  child: const Text('Accept All'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _bulkAppointmentAction('reject'),
                  child: const Text('Reject All'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _bulkAppointmentAction('mark-priority'),
                  child: const Text('Mark Priority'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedAppointments.clear();
                    _bulkMode = false;
                  }),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        
        // Toggle bulk mode button
        if (!_bulkMode)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _bulkMode = true),
              icon: const Icon(Icons.checklist),
              label: const Text('Bulk Actions'),
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Appointments list
        if (_appointments.isEmpty)
          _emptyCard('No appointment requests found')
        else
          ..._appointments.map((appointment) {
            final patient = appointment['patient'] as Map<String, dynamic>? ?? {};
            final unlocked = appointment['status'] == 'confirmed' && appointment['paymentStatus'] == 'paid';
            final isPriority = appointment['isPriority'] ?? false;
            final appointmentId = _idOf(appointment);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _contentCard(
                title: Row(
                  children: [
                    if (_bulkMode)
                      Checkbox(
                        value: _selectedAppointments.contains(appointmentId),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedAppointments.add(appointmentId);
                            } else {
                              _selectedAppointments.remove(appointmentId);
                            }
                          });
                        },
                      ),
                    Expanded(
                      child: Text(
                        patient['name']?.toString() ?? 'Patient',
                        style: TextStyle(
                          color: isPriority ? Colors.orange : null,
                          fontWeight: isPriority ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                    if (isPriority)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PRIORITY',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                    '${appointment['type']} • ${appointment['consultationMode'] ?? 'scheduled'}\n${_formatAppointmentDate(appointment)}\nStatus: ${appointment['status']} | Payment: ${appointment['paymentStatus']}',
                ),
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
                    // Priority toggle
                    OutlinedButton.icon(
                      onPressed: () => _markAppointmentPriority(appointment),
                      icon: Icon(isPriority ? Icons.star : Icons.star_border),
                      label: Text(isPriority ? 'Remove Priority' : 'Mark Priority'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isPriority ? Colors.orange : null,
                      ),
                    ),
                    // Complete button
                    if (unlocked && appointment['status'] != 'completed')
                      OutlinedButton.icon(
                        onPressed: () => _markAppointmentComplete(appointment),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark Complete'),
                      ),
                    // Reschedule button
                    if (appointment['status'] == 'confirmed' || appointment['status'] == 'accepted')
                      OutlinedButton.icon(
                        onPressed: () => _rescheduleAppointment(appointment),
                        icon: const Icon(Icons.schedule),
                        label: const Text('Reschedule'),
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
                    if ((appointment['meetingLink']?.toString() ?? '').isNotEmpty)
                      OutlinedButton(
                        onPressed: () => _openMeetingLink(
                          appointment['meetingLink']?.toString() ?? '',
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
              ),
            );
          }),
      ],
    );
  }

  Widget _buildUpcomingAppointmentsView() {
    final upcoming = _getUpcomingAppointments();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader('Upcoming Appointments', 'Automatically scheduled based on previous appointment duration'),
        if (upcoming.isEmpty)
          _emptyCard('No upcoming appointments scheduled')
        else
          ...upcoming.map((appt) {
            final patient = appt['patient'] as Map<String, dynamic>? ?? {};
            final nextDate = DateTime.tryParse(appt['nextAppointmentDate']?.toString() ?? '');
            final isPriority = appt['isPriority'] ?? false;
            final appointmentId = appt['_id']?.toString() ?? '';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPriority ? Colors.orange.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isPriority ? Colors.orange.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          patient['name']?.toString() ?? 'Patient',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: isPriority ? Colors.orange : Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (isPriority)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'PRIORITY',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPriority ? Colors.orange : Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'In ${appt['daysUntilNextAppt']} days',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scheduled: ${nextDate != null ? _formatDate(nextDate.toIso8601String()) : 'TBD'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${appt['type'] ?? 'Consultation'} • ${appt['consultationMode'] ?? 'scheduled'}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _markAppointmentPriority(appt),
                        icon: Icon(isPriority ? Icons.star : Icons.star_border),
                        label: Text(isPriority ? 'Remove Priority' : 'Mark Priority'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isPriority ? Colors.orange : Colors.white,
                          side: BorderSide(color: isPriority ? Colors.orange : Colors.white.withValues(alpha: 0.5)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _rescheduleAppointment(appt),
                        icon: const Icon(Icons.schedule),
                        label: const Text('Reschedule'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _markAppointmentComplete(appt),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark Complete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFeedbackView() {
    final feedbacks = _dashboardFeedbacks();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar
        TextField(
          controller: _feedbackSearchController,
          decoration: InputDecoration(
            labelText: 'Search feedbacks',
            hintText: 'Patient name or feedback text',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _feedbackSearchController.text.isEmpty 
              ? null 
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _feedbackSearchController.clear();
                    _feedbackRatingFrom = null;
                    _feedbackRatingTo = null;
                    setState(() {});
                    _refresh();
                  },
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (_) {
            setState(() {});
            _searchFeedbacks();
          },
        ),
        const SizedBox(height: 12),
        
        // Rating filter
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DropdownMenu<int?>(
              initialSelection: _feedbackRatingFrom,
              onSelected: (value) {
                setState(() => _feedbackRatingFrom = value);
                _searchFeedbacks();
              },
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'Min rating'),
                const DropdownMenuEntry(value: 1, label: '⭐ 1+'),
                const DropdownMenuEntry(value: 2, label: '⭐ 2+'),
                const DropdownMenuEntry(value: 3, label: '⭐ 3+'),
                const DropdownMenuEntry(value: 4, label: '⭐ 4+'),
                const DropdownMenuEntry(value: 5, label: '⭐ 5'),
              ],
            ),
            if (_feedbackRatingFrom != null)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _feedbackRatingFrom = null);
                  _searchFeedbacks();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Feedbacks list
        if (feedbacks.isEmpty)
          _emptyCard('No feedbacks found')
        else
          ...feedbacks.map((item) {
            final user = item['user'] as Map<String, dynamic>? ?? {};
            final hasReply = item['reply'] != null && item['reply'].toString().isNotEmpty;
            final reviewer = _displayText(user['name']) ?? 'Feedback ${_shortId(item)}';
            final review = _displayText(item['review']) ?? '';
             
            return _contentCard(
              title: Text(
                item['rating'] != null
                    ? '$reviewer • ${item['rating']}/5 ⭐'
                    : reviewer,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review),
                  if (hasReply) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Reply:',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['reply'].toString(),
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          if (item['repliedAt'] != null)
                            Text(
                              'Replied on ${_formatDate(item['repliedAt'].toString())}',
                              style: const TextStyle(fontSize: 12, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              footer: Row(
                children: [
                  if (!hasReply)
                    TextButton.icon(
                      onPressed: () => _replyToFeedback(item),
                      icon: const Icon(Icons.reply),
                      label: const Text('Reply'),
                    ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _deleteFeedback(item),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildNotificationsView() {
    final notifications = _dashboardNotifications();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search and filter row
        TextField(
          controller: _notificationSearchController,
          decoration: InputDecoration(
            labelText: 'Search notifications',
            hintText: 'Title or message',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _notificationSearchController.text.isEmpty 
              ? null 
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _notificationSearchController.clear();
                    _notificationTypeFilter = null;
                    setState(() {});
                    _refresh();
                  },
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (_) {
            setState(() {});
            _searchNotifications();
          },
        ),
        const SizedBox(height: 12),
        
        // Type filter
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DropdownMenu<String?>(
              initialSelection: _notificationTypeFilter,
              onSelected: (value) {
                setState(() => _notificationTypeFilter = value);
                _searchNotifications();
              },
              dropdownMenuEntries: [
                const DropdownMenuEntry(value: null, label: 'All types'),
                const DropdownMenuEntry(value: 'appointment', label: 'Appointment'),
                const DropdownMenuEntry(value: 'payment', label: 'Payment'),
                const DropdownMenuEntry(value: 'feedback', label: 'Feedback'),
                const DropdownMenuEntry(value: 'message', label: 'Message'),
              ],
            ),
            
            // Mark all read button
            if (notifications.any((n) => !(n['isRead'] ?? false)))
              FilledButton.icon(
                onPressed: () async {
                  await ApiService.markAllDoctorNotificationsRead();
                  _snack('All notifications marked as read');
                  await _refresh(silent: true);
                },
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Mark all read'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Notifications list
        if (notifications.isEmpty)
          _emptyCard('No doctor notifications yet')
        else
          ..._buildNotificationSection(
            notifications,
            onMarkRead: (id) async {
              await ApiService.markDoctorNotificationRead(id);
              await _refresh(silent: true);
            },
            onDelete: (id) async {
              await ApiService.deleteDoctorNotification(id);
              _snack('Notification deleted');
              await _refresh(silent: true);
            },
            emptyMessage: 'No notifications.',
            subtitle: 'Live request and payment alerts for the doctor dashboard.',
          ),
      ],
    );
  }

  List<Map<String, dynamic>> _dashboardAppointments() {
    return _appointments.where((appointment) {
      final patient = appointment['patient'] as Map<String, dynamic>? ?? {};
      return _displayText(patient['name']) != null ||
          _displayText(appointment['patientName']) != null ||
          _displayText(appointment['type']) != null ||
          _displayText(appointment['consultationMode']) != null ||
          _displayText(appointment['status']) != null ||
          _displayText(appointment['paymentStatus']) != null ||
          _displayAppointmentDate(appointment) != null;
    }).toList();
  }

  List<Map<String, dynamic>> _dashboardPatients() {
    return _patients.where((patient) {
      return _displayText(patient['name']) != null ||
          _displayText(patient['email']) != null ||
          _displayText(patient['phone']) != null ||
          _displayRegisteredDate(patient) != null;
    }).toList();
  }

  List<Map<String, dynamic>> _dashboardFeedbacks() {
    return _feedbacks.where((item) {
      final user = item['user'] as Map<String, dynamic>? ?? {};
      return _displayText(user['name']) != null ||
          _displayText(item['review']) != null ||
          item['rating'] != null ||
          _displayText(item['reply']) != null;
    }).toList();
  }

  List<Map<String, dynamic>> _dashboardNotifications() {
    return _notifications.where((item) {
      return _displayText(item['title']) != null ||
          _displayText(item['message']) != null ||
          _displayText(item['type']) != null ||
          _displayNotificationDate(item) != null;
    }).toList();
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
  int _selectedIndex = 0;
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(_selectedIndex == 0 ? 'Dashboard' : _selectedIndex == 1 ? 'Products' : _selectedIndex == 2 ? 'Orders' : 'Settings'),
        actions: [
          if (_selectedIndex == 1) IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicineScreen())),
            icon: const Icon(Icons.add),
          ),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset('assets/lottie/Background_shooting_star.json', fit: BoxFit.cover, repeat: true),
          ),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
          _loading ? const Center(child: CircularProgressIndicator()) : _buildBody(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: const Color(0xFF1E3A8A),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard, color: Colors.white), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2, color: Colors.white), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.local_shipping, color: Colors.white), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.settings, color: Colors.white), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _dashboardTab();
      case 1: return _productsTab();
      case 2: return _ordersTab();
      case 3: return _settingsTab();
      default: return _dashboardTab();
    }
  }

  Widget _dashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _heroCard(
          title: _profile?['name']?.toString() ?? 'Medical Store',
          subtitle: 'Seller Dashboard - Pharma Management',
        ),
        _sectionHeader('Overview', 'Today\'s Performance'),
        Row(
          children: [
            Expanded(child: _statCard('Revenue', 'Rs ${_stats?['totalRevenue'] ?? 0}', Icons.currency_rupee, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Orders', '${_stats?['totalOrders'] ?? 0}', Icons.shopping_cart, Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statCard('Pending', '${_stats?['pendingOrders'] ?? 0}', Icons.pending, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Delivered', '${_stats?['deliveredOrders'] ?? 0}', Icons.check_circle, Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        _sectionHeader('Inventory', 'Stock Overview'),
        Row(
          children: [
            Expanded(child: _statCard('Medicines', '${_stats?['totalMedicines'] ?? 0}', Icons.medication, Colors.purple)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Low Stock', '${_stats?['lowStock'] ?? 0}', Icons.warning, Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        _sectionHeader('Recent Orders', 'Latest Orders'),
        ...(_orders.isEmpty ? [_emptyCard('No orders yet')] : _orders.take(5).map((o) => _contentCard(
          title: Text('Order ${_shortId(o)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text('${o['status']} • Rs ${o['totalAmount'] ?? 0}', style: const TextStyle(color: Colors.white70)),
          avatarPath: 'assets/Icons/patient.jpg',
        ))),
      ],
    );
  }

  Widget _productsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader('My Medicines', '${_medicines.length} products'),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicineScreen())),
            icon: const Icon(Icons.add),
            label: const Text('Add New Medicine'),
          ),
        ),
        const SizedBox(height: 16),
        ..._medicines.map((m) => _contentCard(
          title: Text(m['name']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text('${m['category']} • Stock: ${m['stock']} • Rs ${m['discountedPrice'] ?? m['price']}', style: const TextStyle(color: Colors.white70)),
          footer: Wrap(
            children: [
              OutlinedButton(onPressed: () {}, child: const Text('Edit')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () {}, child: const Text('Stock')),
            ],
          ),
        )),
      ],
    );
  }

  Widget _ordersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader('All Orders', '${_orders.length} orders'),
        ..._orders.map((o) {
          final user = o['user'] as Map<String, dynamic>? ?? {};
          return _contentCard(
            title: Text('Order ${_shortId(o)} - ${user['name'] ?? 'Patient'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Status: ${o['status']} | Payment: ${o['paymentStatus']} | Rs ${o['totalAmount'] ?? 0}', style: const TextStyle(color: Colors.white70)),
            avatarPath: 'assets/Icons/patient.jpg',
            footer: Wrap(
              children: [
                if (o['status'] == 'confirmed')
                  OutlinedButton(onPressed: () {}, child: const Text('Ship')),
                if (o['status'] == 'shipped')
                  OutlinedButton(onPressed: () {}, child: const Text('Deliver')),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _settingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionHeader('Store Settings', 'Manage your pharmacy'),
        _contentCard(
          title: const Text('Store Name', style: TextStyle(color: Colors.white)),
          subtitle: Text(_profile?['name']?.toString() ?? 'Not set', style: const TextStyle(color: Colors.white70)),
          footer: OutlinedButton(onPressed: () {}, child: const Text('Edit')),
        ),
        _contentCard(
          title: const Text('Address', style: TextStyle(color: Colors.white)),
          subtitle: const Text('Tap to update delivery address', style: TextStyle(color: Colors.white70)),
          footer: OutlinedButton(onPressed: () {}, child: const Text('Edit')),
        ),
        _contentCard(
          title: const Text('Account', style: TextStyle(color: Colors.white)),
          subtitle: Text(_profile?['email']?.toString() ?? '', style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                                : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['content']?.toString() ?? '',
                            style: const TextStyle(
                              color: Colors.white,
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
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        hintText: 'Type message',
                        hintStyle: TextStyle(color: Colors.white),
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
  final String? fallbackUrl;

  const LinkWebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.fallbackUrl,
  });

  @override
  State<LinkWebViewPage> createState() => _LinkWebViewPageState();
}

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewerPage({super.key, required this.title, required this.url});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _hasError = false;

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open PDF externally.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load this PDF inside the app.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openExternally,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Open Externally'),
                    ),
                  ],
                ),
              ),
            )
          : SfPdfViewer.network(
              widget.url,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              onDocumentLoadFailed: (_) {
                if (!mounted) return;
                setState(() {
                  _hasError = true;
                });
              },
            ),
    );
  }
}

class _LinkWebViewPageState extends State<LinkWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage = error.description.isNotEmpty
                  ? error.description
                  : 'Unable to load webpage on this device.';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  Future<void> _openExternally() async {
    final target = widget.fallbackUrl ?? widget.url;
    final uri = Uri.tryParse(target);
    if (uri == null) return;

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No supported app or browser found.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link externally.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openExternally,
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Externally'),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
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
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: cards
          .map(
            (card) => Flexible(
              fit: FlexFit.loose,
              child: Container(
                constraints: const BoxConstraints(minWidth: 140, maxWidth: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.3),
                      Colors.purple.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(card.icon, color: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      card.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(card.label, style: const TextStyle(color: Colors.white)),
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
  return Container(
    margin: const EdgeInsets.only(bottom: 16, top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    ),
  );
}

Widget _contentCard({
  required Widget title,
  required Widget subtitle,
  Widget? footer,
  String? avatarPath,
  Color? gradientColor1,
  Color? gradientColor2,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          gradientColor1 ?? Colors.blue.withValues(alpha: 0.3),
          gradientColor2 ?? Colors.purple.withValues(alpha: 0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avatarPath != null) ...[
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1E3A8A),
            child: Image.asset(
              avatarPath,
              errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 6),
              subtitle,
              if (footer != null) ...[const SizedBox(height: 14), footer],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _emptyCard(String message) => _contentCard(
  title: const Text('Nothing here yet', style: TextStyle(color: Colors.white70)),
  subtitle: Text(message, style: const TextStyle(color: Colors.white54)),
);

Widget _statCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

List<Widget> _buildNotificationSection(
  List<Map<String, dynamic>> items, {
  required Future<void> Function(String id) onMarkRead,
  Future<void> Function(String id)? onDelete,
  required String emptyMessage,
  required String subtitle,
}) {
  if (items.isEmpty) {
    return [_emptyCard(emptyMessage)];
  }
  return [
    _sectionHeader('Notifications', subtitle),
    ...items.map(
      (item) {
        final title = _displayText(item['title']) ??
            _displayText(item['type']) ??
            'Notification ${_shortId(item)}';
        final subtitleText = [
          _displayText(item['message']),
          _displayNotificationDate(item),
        ].whereType<String>().join('\n');

        return _contentCard(
          title: Text(title),
          subtitle: Text(subtitleText),
          footer: Row(
            children: [
              if (item['isRead'] != true)
                TextButton(
                  onPressed: () => onMarkRead(_idOf(item)),
                  child: const Text('Mark Read'),
                ),
              if (onDelete != null)
                TextButton(
                  onPressed: () => onDelete(_idOf(item)),
                  child: const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
        );
      },
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

String? _displayText(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}

String? _displayAppointmentDate(Map<String, dynamic> appointment) {
  final date = appointment['date']?.toString();
  final time = _displayText(appointment['time']);
  if ((date == null || date.isEmpty) && time == null) {
    return null;
  }
  final formattedDate = date == null || date.isEmpty
      ? null
      : _formatDate(date, dateOnly: true);
  if (formattedDate == null) {
    return time;
  }
  return time == null ? formattedDate : '$formattedDate at $time';
}

String? _displayStatusLine(Map<String, dynamic> item) {
  final status = _displayText(item['status']);
  final payment = _displayText(item['paymentStatus']);
  if (status == null && payment == null) {
    return null;
  }
  if (status != null && payment != null) {
    return 'Status: $status | Payment: $payment';
  }
  return status != null ? 'Status: $status' : 'Payment: $payment';
}

String? _displayRegisteredDate(Map<String, dynamic> patient) {
  final createdAt = patient['createdAt']?.toString();
  if (createdAt == null || createdAt.isEmpty) {
    return null;
  }
  return 'Registered: ${_formatDate(createdAt)}';
}

String? _displayNotificationDate(Map<String, dynamic> item) {
  final createdAt = item['createdAt']?.toString();
  if (createdAt == null || createdAt.isEmpty) {
    return null;
  }
  return _formatDate(createdAt);
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
    case PatientSection.cart:
      return 'Cart';
    case PatientSection.wellness:
      return 'Wellness';
  }
  }
