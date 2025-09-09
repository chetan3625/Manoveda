class VendorModel {
  String name;
  String contact;
  String email;
  String? contractDetails;
  String? vehiclesOnRent;
  DateTime? contractExpiry;
  double? revenueShare;
  double? pendingPayment;

  VendorModel({
    required this.name,
    required this.contact,
    required this.email,
    this.contractDetails,
    this.vehiclesOnRent,
    this.contractExpiry,
    this.revenueShare,
    this.pendingPayment,
  });

  /// Factory constructor to create VendorModel from JSON
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      email: json['email'] ?? '',
      contractDetails: json['contractDetails'],
      vehiclesOnRent: json['vehiclesOnRent'],
      contractExpiry: json['contractExpiry'] != null
          ? DateTime.tryParse(json['contractExpiry'])
          : null,
      revenueShare: json['revenueShare'] != null
          ? (json['revenueShare'] as num).toDouble()
          : null,
      pendingPayment: json['pendingPayment'] != null
          ? (json['pendingPayment'] as num).toDouble()
          : null,
    );
  }

  /// Convert VendorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "contact": contact,
      "email": email,
      "contractDetails": contractDetails,
      "vehiclesOnRent": vehiclesOnRent,
      "contractExpiry": contractExpiry?.toIso8601String(),
      "revenueShare": revenueShare,
      "pendingPayment": pendingPayment,
    };
  }
}
