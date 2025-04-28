class Device {
  final String? id;
  final String model;
  final String manufacturer;
  final String category;
  final int powerConsumption;

  Device({
    this.id,
    required this.model,
    required this.manufacturer,
    required this.category,
    required this.powerConsumption,
  });

  Device copyWith({
    String? id,
    String? model,
    String? manufacturer,
    String? category,
    int? powerConsumption,
  }) {
    return Device(
      id: id ?? this.id,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      powerConsumption: powerConsumption ?? this.powerConsumption,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'manufacturer': manufacturer,
      'category': category,
      'powerConsumption': powerConsumption,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model': model,
      'manufacturer': manufacturer,
      'category': category,
      'powerConsumption': powerConsumption,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      model: json['model'],
      manufacturer: json['manufacturer'],
      category: json['category'],
      powerConsumption: json['powerConsumption'] is num
          ? (json['powerConsumption'] as num).toInt()
          : 0,
    );
  }

  factory Device.fromMap(Map<String, dynamic> map, String id) {
    return Device(
      id: id,
      model: map['model'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
      category: map['category'] ?? '',
      powerConsumption: map['powerConsumption'] is num
          ? (map['powerConsumption'] as num).toInt()
          : 0,
    );
  }
}
