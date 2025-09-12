class VendorModel {
  String vendorName;
  String contractId;
  String revenueShare;

  VendorModel({
    required this.vendorName,
    required this.contractId,
    required this.revenueShare,
  });

  // Factory constructor to create VendorModel from JSON
  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      vendorName: json['vendorName'] ?? '',
      contractId: json['contractId'] ?? '',
      revenueShare: json['revenueShare'] ?? '',
    );
  }

  // Convert VendorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      "vendorName": vendorName,
      "contractId": contractId,
      "revenueShare": revenueShare,
    };
  }
}
