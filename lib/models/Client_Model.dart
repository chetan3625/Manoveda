import 'package:flutter/material.dart';

class ClientModel {
  final String clientId;
  final String companyName;
  final String phoneNumber;
  final String clientEmail;
  final String currentStatus;
  final int totalShipments;
  final DateTime? lastTransactionDate;
  final double? accountBalance;
  final String? startDate;
  final String? endDate;

  ClientModel({
    required this.clientId,
    required this.companyName,
    required this.phoneNumber,
    required this.clientEmail,
    required this.currentStatus,
    required this.totalShipments,
    this.lastTransactionDate,
    this.accountBalance,
    required this.startDate,
    required this.endDate,
  });
}
