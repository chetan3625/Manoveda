import 'dart:convert';

import '../models/AdminModel.dart';

Future<void> saveUserModel(String key, AdminModel user) async {
  final jsonString = jsonEncode(user.toJson());
  await saveString(key, jsonString);
}
saveString(String key, String jsonString) {
}
