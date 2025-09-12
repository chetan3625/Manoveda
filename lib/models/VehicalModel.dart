class Vehicle {
  final String number;
  final String type;
  final String capacity;
  final String status;

  Vehicle({
    required this.number,
    required this.type,
    required this.capacity,
    required this.status,
  });

  Vehicle copyWith({
    String? number,
    String? type,
    String? capacity,
    String? status,
  }) {
    return Vehicle(
      number: number ?? this.number,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
    );
  }
}
