import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ApiService {
  static const String baseUrl = 'https://manoveda-backend.onrender.com/api';
  static const String socketUrl = 'https://manoveda-backend.onrender.com';
  static const String publicBaseUrl = 'https://manoveda-backend.onrender.com';

  static String? token;
  static String? userRole;
  static String? userId;
  static Map<String, dynamic>? currentUser;

  static io.Socket? socket;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userRole = prefs.getString('role');
    userId = prefs.getString('userId');

    final rawUser = prefs.getString('currentUser');
    if (rawUser != null && rawUser.isNotEmpty) {
      currentUser = jsonDecode(rawUser) as Map<String, dynamic>;
    }
  }

  static Future<void> saveSession({
    required String newToken,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    await prefs.setString('role', user['role']?.toString() ?? 'patient');
    await prefs.setString(
      'userId',
      user['id']?.toString() ?? user['_id']?.toString() ?? '',
    );
    await prefs.setString('currentUser', jsonEncode(user));

    token = newToken;
    userRole = user['role']?.toString();
    userId = user['id']?.toString() ?? user['_id']?.toString();
    currentUser = user;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userId');
    await prefs.remove('currentUser');
    token = null;
    userRole = null;
    userId = null;
    currentUser = null;
    disconnectSocket();
  }

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    late http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await http.delete(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      default:
        throw UnsupportedError('Unsupported method $method');
    }

    if (response.body.isEmpty) {
      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
      };
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return {
      'success': response.statusCode >= 200 && response.statusCode < 300,
      'data': decoded,
    };
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'patient',
    String? phone,
    String? specialization,
    int? experience,
    String? qualification,
    double? consultationFee,
  }) async {
    final data = await _request(
      'POST',
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
        'specialization': specialization,
        'experience': experience,
        'qualification': qualification,
        'consultationFee': consultationFee,
      },
    );

    if (data['success'] == true) {
      await saveSession(
        newToken: data['token'] as String,
        user: data['user'] as Map<String, dynamic>,
      );
    }
    return data;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (data['success'] == true) {
      await saveSession(
        newToken: data['token'] as String,
        user: data['user'] as Map<String, dynamic>,
      );
    }
    return data;
  }

  static Future<Map<String, dynamic>> getMe() async {
    final data = await _request('GET', '/auth/me');
    if (data['success'] == true && data['user'] is Map<String, dynamic>) {
      currentUser = data['user'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', jsonEncode(currentUser));
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    return _request('PUT', '/auth/profile', body: data);
  }

  static Future<Map<String, dynamic>> getDoctors({String? search}) async {
    final queryParams = search != null && search.trim().isNotEmpty
        ? '?search=${Uri.encodeQueryComponent(search)}'
        : '';
    return _request('GET', '/patient/doctors$queryParams');
  }

  static Future<Map<String, dynamic>> bookAppointment({
    required String doctorId,
    required DateTime date,
    required String time,
    String type = 'video',
    String consultationMode = 'scheduled',
    String? symptoms,
  }) async {
    return _request(
      'POST',
      '/patient/appointments',
      body: {
        'doctorId': doctorId,
        'date': date.toIso8601String(),
        'time': time,
        'type': type,
        'consultationMode': consultationMode,
        'symptoms': symptoms,
      },
    );
  }

  static Future<Map<String, dynamic>> getAppointments({String? status}) async {
    final queryParams = status != null
        ? '?status=${Uri.encodeQueryComponent(status)}'
        : '';
    return _request('GET', '/patient/appointments$queryParams');
  }

  static Future<Map<String, dynamic>> cancelAppointment(String id) async {
    return _request('PUT', '/patient/appointments/$id/cancel');
  }

  static Future<Map<String, dynamic>> getPrescriptions() async {
    return _request('GET', '/patient/prescriptions');
  }

  static Future<Map<String, dynamic>> getMedicines({String? search}) async {
    final queryParams = search != null && search.trim().isNotEmpty
        ? '?search=${Uri.encodeQueryComponent(search)}'
        : '';
    return _request('GET', '/patient/medicines$queryParams');
  }

  static Future<Map<String, dynamic>> addToCart({
    required String medicineId,
    int quantity = 1,
  }) async {
    return _request(
      'POST',
      '/patient/cart',
      body: {'medicineId': medicineId, 'quantity': quantity},
    );
  }

  static Future<Map<String, dynamic>> getCart() async {
    return _request('GET', '/patient/cart');
  }

  static Future<Map<String, dynamic>> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    return _request(
      'PUT',
      '/patient/cart',
      body: {'itemId': itemId, 'quantity': quantity},
    );
  }

  static Future<Map<String, dynamic>> placeOrder({
    required Map<String, String> shippingAddress,
    String paymentMethod = 'online',
  }) async {
    return _request(
      'POST',
      '/patient/orders',
      body: {
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
      },
    );
  }

  static Future<Map<String, dynamic>> getOrders({String? status}) async {
    final queryParams = status != null
        ? '?status=${Uri.encodeQueryComponent(status)}'
        : '';
    return _request('GET', '/patient/orders$queryParams');
  }

  static Future<Map<String, dynamic>> addFeedback({
    required String doctorId,
    required int rating,
    String? review,
    String? appointmentId,
  }) async {
    return _request(
      'POST',
      '/patient/feedback',
      body: {
        'doctorId': doctorId,
        'appointmentId': appointmentId,
        'rating': rating,
        'review': review,
      },
    );
  }

  static Future<Map<String, dynamic>> getNotifications() async {
    return _request('GET', '/patient/notifications');
  }

  static Future<Map<String, dynamic>> markNotificationRead(String id) async {
    return _request('PUT', '/patient/notifications/$id/read');
  }

  static Future<Map<String, dynamic>> getChats() async {
    return _request('GET', '/chat/chats');
  }

  static Future<Map<String, dynamic>> createChat(
    String participantId, {
    String? appointmentId,
  }) async {
    return _request(
      'POST',
      '/chat/chats',
      body: {'participantId': participantId, 'appointmentId': appointmentId},
    );
  }

  static Future<Map<String, dynamic>> getMessages(String chatId) async {
    return _request('GET', '/chat/chats/$chatId/messages');
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String content,
  }) async {
    return _request(
      'POST',
      '/chat/chats/$chatId/messages',
      body: {'content': content, 'messageType': 'text'},
    );
  }

  static Future<Map<String, dynamic>> getDoctorPatients() async {
    return _request('GET', '/doctor/patients');
  }

  static Future<Map<String, dynamic>> getDoctorAppointments({
    String? status,
  }) async {
    final queryParams = status != null
        ? '?status=${Uri.encodeQueryComponent(status)}'
        : '';
    return _request('GET', '/doctor/appointments$queryParams');
  }

  static Future<Map<String, dynamic>> updateDoctorAppointment({
    required String appointmentId,
    String? status,
    String? notes,
    String? meetingLink,
    String? rejectionReason,
  }) async {
    return _request(
      'PUT',
      '/doctor/appointments/$appointmentId',
      body: {
        'status': status,
        'notes': notes,
        'meetingLink': meetingLink,
        'rejectionReason': rejectionReason,
      },
    );
  }

  static Future<Map<String, dynamic>> createMeetingLink(
    String appointmentId,
  ) async {
    return _request(
      'POST',
      '/doctor/meeting-link',
      body: {'appointmentId': appointmentId},
    );
  }

  static Future<Map<String, dynamic>> writePrescription({
    required String patientId,
    required String appointmentId,
    required String diagnosis,
    required List<Map<String, dynamic>> medicines,
    String? notes,
    DateTime? followUpDate,
  }) async {
    return _request(
      'POST',
      '/doctor/prescription',
      body: {
        'patientId': patientId,
        'appointmentId': appointmentId,
        'diagnosis': diagnosis,
        'medicines': medicines,
        'notes': notes,
        'followUpDate': followUpDate?.toIso8601String(),
      },
    );
  }

  static Future<Map<String, dynamic>> getDoctorPrescriptions() async {
    return _request('GET', '/doctor/prescriptions');
  }

  static Future<Map<String, dynamic>> getDoctorFeedbacks() async {
    return _request('GET', '/doctor/feedbacks');
  }

  static Future<Map<String, dynamic>> getDoctorNotifications() async {
    return _request('GET', '/doctor/notifications');
  }

  static Future<Map<String, dynamic>> markDoctorNotificationRead(
    String id,
  ) async {
    return _request('PUT', '/doctor/notifications/$id/read');
  }

  // Micro-Features: Search & Filter
  
  static Future<Map<String, dynamic>> searchDoctorPatients({String? query}) async {
    final queryParams = query != null && query.trim().isNotEmpty
        ? '?query=${Uri.encodeQueryComponent(query)}'
        : '';
    return _request('GET', '/doctor/patients/search$queryParams');
  }

  static Future<Map<String, dynamic>> getDoctorPatientDetails(String patientId) async {
    return _request('GET', '/doctor/patients/$patientId');
  }

  static Future<Map<String, dynamic>> searchDoctorAppointments({
    String? query,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final params = <String, String>{};
    if (query != null && query.trim().isNotEmpty) params['query'] = query;
    if (status != null) params['status'] = status;
    if (dateFrom != null) params['dateFrom'] = dateFrom.toIso8601String();
    if (dateTo != null) params['dateTo'] = dateTo.toIso8601String();
    
    final queryString = params.isEmpty
        ? ''
        : '?' + params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    return _request('GET', '/doctor/appointments/search$queryString');
  }

  // Micro-Features: Appointment Management

  static Future<Map<String, dynamic>> markAppointmentPriority({
    required String appointmentId,
    required bool isPriority,
  }) async {
    return _request(
      'PUT',
      '/doctor/appointments/$appointmentId/priority',
      body: {'isPriority': isPriority},
    );
  }

  static Future<Map<String, dynamic>> bulkAppointmentAction({
    required List<String> appointmentIds,
    required String action,
  }) async {
    return _request(
      'POST',
      '/doctor/appointments/bulk-action',
      body: {'appointmentIds': appointmentIds, 'action': action},
    );
  }

  static Future<Map<String, dynamic>> markAppointmentComplete(String appointmentId) async {
    return _request('POST', '/doctor/appointment/$appointmentId/complete');
  }

  static Future<Map<String, dynamic>> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTime,
    String? reason,
  }) async {
    return _request(
      'POST',
      '/doctor/appointment/$appointmentId/reschedule',
      body: {
        'newDate': newDate.toIso8601String(),
        'newTime': newTime,
        'reason': reason,
      },
    );
  }

  static Future<Map<String, dynamic>> getUpcomingAppointmentsDetails() async {
    return _request('POST', '/doctor/upcoming-appointments');
  }

  // Micro-Features: Feedback Management

  static Future<Map<String, dynamic>> searchDoctorFeedbacks({
    String? query,
    int? ratingFrom,
    int? ratingTo,
  }) async {
    final params = <String, String>{};
    if (query != null && query.trim().isNotEmpty) params['query'] = query;
    if (ratingFrom != null) params['ratingFrom'] = ratingFrom.toString();
    if (ratingTo != null) params['ratingTo'] = ratingTo.toString();
    
    final queryString = params.isEmpty
        ? ''
        : '?' + params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    return _request('GET', '/doctor/feedbacks/search$queryString');
  }

  static Future<Map<String, dynamic>> replyToFeedback({
    required String feedbackId,
    required String reply,
  }) async {
    return _request(
      'PUT',
      '/doctor/feedbacks/$feedbackId/reply',
      body: {'reply': reply},
    );
  }

  static Future<Map<String, dynamic>> deleteDoctorFeedback(String feedbackId) async {
    return _request('DELETE', '/doctor/feedbacks/$feedbackId');
  }

  // Micro-Features: Notification Management

  static Future<Map<String, dynamic>> searchDoctorNotifications({
    String? query,
    String? type,
  }) async {
    final params = <String, String>{};
    if (query != null && query.trim().isNotEmpty) params['query'] = query;
    if (type != null) params['type'] = type;
    
    final queryString = params.isEmpty
        ? ''
        : '?' + params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    return _request('GET', '/doctor/notifications/search$queryString');
  }

  static Future<Map<String, dynamic>> markAllDoctorNotificationsRead() async {
    return _request('PUT', '/doctor/notifications/mark-all-read');
  }

  static Future<Map<String, dynamic>> deleteDoctorNotification(String notificationId) async {
    return _request('DELETE', '/doctor/notifications/$notificationId');
  }

  // Micro-Features: Statistics & Analytics

  static Future<Map<String, dynamic>> getDoctorDashboardStats({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final params = <String, String>{};
    if (dateFrom != null) params['dateFrom'] = dateFrom.toIso8601String();
    if (dateTo != null) params['dateTo'] = dateTo.toIso8601String();
    
    final queryString = params.isEmpty
        ? ''
        : '?' + params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&');
    return _request('GET', '/doctor/dashboard/stats$queryString');
  }

  static Future<Map<String, dynamic>> getMedicalKeeperDashboard({String? timeRange}) async {
    final query = timeRange != null ? '?timeRange=$timeRange' : '';
    return _request('GET', '/medical-keeper/dashboard$query');
  }

  static Future<Map<String, dynamic>> getMedicalKeeperAnalytics({String? period}) async {
    final query = period != null ? '?period=$period' : '';
    return _request('GET', '/medical-keeper/analytics$query');
  }

  static Future<Map<String, dynamic>> getMedicalKeeperMedicines() async {
    return _request('GET', '/medical-keeper/medicines');
  }

  static Future<Map<String, dynamic>> addMedicine(
    Map<String, dynamic> body,
  ) async {
    return _request('POST', '/medical-keeper/medicines', body: body);
  }

  static Future<Map<String, dynamic>> updateMedicine(
    String id,
    Map<String, dynamic> body,
  ) async {
    return _request('PUT', '/medical-keeper/medicines/$id', body: body);
  }

  static Future<Map<String, dynamic>> deleteMedicine(String id) async {
    return _request('DELETE', '/medical-keeper/medicines/$id');
  }

  static Future<Map<String, dynamic>> getMedicalKeeperOrders({
    String? status,
  }) async {
    final queryParams = status != null
        ? '?status=${Uri.encodeQueryComponent(status)}'
        : '';
    return _request('GET', '/medical-keeper/orders$queryParams');
  }

  static Future<Map<String, dynamic>> getMedicalKeepers() async {
    return _request('GET', '/patient/medical-keepers');
  }

  static Future<Map<String, dynamic>> getMedicalKeeperStoreMedicines(
    String keeperId,
  ) async {
    return _request('GET', '/patient/medical-keeper/$keeperId/medicines');
  }

  static Future<Map<String, dynamic>> addToCartFromKeeper({
    required String keeperId,
    required String medicineId,
    int quantity = 1,
  }) async {
    return _request(
      'POST',
      '/patient/cart',
      body: {
        'keeperId': keeperId,
        'medicineId': medicineId,
        'quantity': quantity,
      },
    );
  }

  static Future<Map<String, dynamic>> updateMedicalOrderStatus({
    required String orderId,
    required String status,
    String? trackLocation,
  }) async {
    return _request(
      'PUT',
      '/medical-keeper/orders/$orderId',
      body: {'status': status, 'trackLocation': trackLocation},
    );
  }

  static Future<Map<String, dynamic>> createAppointmentPayment(
    String appointmentId,
  ) async {
    return _request(
      'POST',
      '/payment/appointment',
      body: {'appointmentId': appointmentId},
    );
  }

  static Future<Map<String, dynamic>> createOrderPayment(String orderId) async {
    return _request('POST', '/payment/order', body: {'orderId': orderId});
  }

  static Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    String? orderId,
    String? appointmentId,
    required String type,
  }) async {
    return _request(
      'POST',
      '/payment/verify',
      body: {
        'razorpayPaymentId': razorpayPaymentId,
        'razorpayOrderId': razorpayOrderId,
        'razorpaySignature': razorpaySignature,
        'orderId': orderId,
        'appointmentId': appointmentId,
        'type': type,
      },
    );
  }

  static Future<Map<String, dynamic>> getPayments() async {
    return _request('GET', '/payment');
  }

  static String absoluteUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      return '';
    }
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }
    return '$publicBaseUrl$pathOrUrl';
  }

  static void connectSocket() {
    if (token == null) {
      return;
    }

    socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket!.connect();
  }

  static void disconnectSocket() {
    socket?.disconnect();
    socket = null;
  }
}
