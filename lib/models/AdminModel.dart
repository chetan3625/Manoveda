
class AdminModel {
  final String password;
  final String email;
  AdminModel({

    required this.email,
    required this.password,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      email: json['email'] ?? '',
      password: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
