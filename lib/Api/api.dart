import 'dart:convert';
import 'package:erptransportexpress/Api/pref.dart';
import 'package:http/http.dart' as http;
import '../models/AdminModel.dart';
import '../models/VendorModel.dart';
import 'ReturnRespons.dart';

const String baseUrl = "http://192.168.1.14:5000";

Future<ReturnDynamicResponse<T>?> postRequest<T>({
  required String endpoint,
  required Map<String, dynamic> body,
  required T Function(Map<String, dynamic>) fromJson,
}) async {
  try {
    print('Calling API: $baseUrl/$endpoint');

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body.map((key, value) => MapEntry(key, value.toString())),
    );

    final jsonResponseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final status = jsonResponseData['status'];
      if (status == 200) {
        ///  Wrap result in `ReturnDynamicResponse`
        return ReturnDynamicResponse<T>(
          success: true,
          message: jsonResponseData['message'] ?? "Success",
          data: fromJson(jsonResponseData['data']),
        );
      } else {
        return ReturnDynamicResponse<T>(
          success: false,
          message: jsonResponseData['message'] ?? "Unexpected error",
          data: null,
        );
      }
    } else {
      return ReturnDynamicResponse<T>(
        success: false,
        message: jsonResponseData['error'] ?? "Unexpected error",
        data: null,
      );
    }
  } catch (e) {
    print("Error: $e");
    return ReturnDynamicResponse<T>(
      success: false,
      message: e.toString(),
      data: null,
    );
  }
}






Future<ReturnDynamicResponse<AdminModel>?> getAdminLoginData(String email, String password) async {
  const String keyUserModel = 'sp_user_model';
  final user = await postRequest<AdminModel>(
    endpoint: "login", // API endpoint
    body: {
      "email": email,
      "password": password,
    },
    fromJson: (data) => AdminModel.fromJson(data),
  );

  if (user != null) {
    await saveUserModel(keyUserModel, user as AdminModel);
  }
  return user;
}

///  Get Vendors returns a list
Future<Object> getVendors() async {
  final vendors = await postRequest<List<VendorModel>>(
    endpoint: "vendors",
    body: {}, // send empty body (or add filters if required)
    fromJson: (data) {
      final list = (data as List)
          .map((e) => VendorModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return list;
    },
  );

  return vendors ?? [];
}

///   Add vendor
Future<ReturnDynamicResponse<VendorModel>?> addVendor(VendorModel vendor) async {
  return await postRequest<VendorModel>(
    endpoint: "vendors",
    body: vendor.toJson(),
    fromJson: (data) => VendorModel.fromJson(Map<String, dynamic>.from(data)),
  );
}





