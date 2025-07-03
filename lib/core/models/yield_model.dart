import 'package:equatable/equatable.dart';

class Yield extends Equatable {
  final int id;
  final int farmerId;
  final int productId;
  final DateTime harvestDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int farmId;
  final double volume;
  final String? farmerName;
  final String? notes;
  final String? productName;
  final String? sector;
  final String? barangay;
  final int? sectorId;
  final double? value;
  final String? images;
  final String? status;
  final double? hectare;

  const Yield({
    required this.id,
    required this.farmerId,
    required this.productId,
    required this.harvestDate,
    this.createdAt,
    this.updatedAt,
    required this.farmId,
    required this.volume,
    this.notes,
    this.value,
    this.status,
    this.barangay,
    this.images,
    this.sector,
    this.sectorId,
    this.farmerName,
    this.hectare,
    this.productName,
  });

  factory Yield.fromJson(Map<String, dynamic> json) {
    // Helper function to log and validate types
    dynamic _parseField(String key, dynamic value,
        {bool expectString = false}) {
      // print('Parsing field "$key": value=$value (type: ${value?.runtimeType})');

      if (expectString && value != null && value is! String) {
        return value.toString(); // Convert to string if expected to be string
      }
      return value;
    }

    return Yield(
      id: json['id'] as int,
      farmerId: json['farmerId'] as int,
      productId: json['productId'] as int,
      harvestDate: DateTime.parse(json['harvestDate'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      farmId: json['farmId'] as int? ?? 0,
      volume: (json['volume'] as num).toDouble(),
      notes: _parseField('notes', json['notes'], expectString: true),
      barangay: _parseField('barangay', json['barangay'], expectString: true),
      sector: _parseField('sector', json['sector'], expectString: true),
      sectorId: json['sectorId'] as int? ?? 0,
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      images: _parseField('images', json['images'], expectString: true),
      farmerName:
          _parseField('farmerName', json['farmerName'], expectString: true),
      productName:
          _parseField('productName', json['productName'], expectString: true),
      status: _parseField('status', json['status'], expectString: true),
      hectare: json['farmArea'] != null
          ? (json['farmArea'] as num).toDouble()
          : null,
    );
  }
  // Convert to JSON (useful for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'product_id': productId,
      'harvest_date': harvestDate.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'farm_id': farmId,
      'volume': volume,
      'notes': notes,
      'value': value,
      'images': images,
      'hectare': hectare,
      'barangay': barangay,
      'sector': sector,
      'sectorId': sectorId,
      'farmerName': farmerName,
      'productName': productName,
      'status': status
    };
  }

  // Sample data for development/demo purposes
  static List<Yield> get sampleYields {
    return [
      Yield(
        id: 1,
        farmerId: 101,
        productId: 1, // Organic Rice
        harvestDate: DateTime(2023, 6, 15),
        createdAt: DateTime(2023, 6, 15),
        updatedAt: DateTime(2023, 6, 15),
        farmId: 201,
        volume: 500,
        notes: 'First harvest of the season',
        value: 2500,
        images: 'https://example.com/rice-harvest.jpg',
      ),
      Yield(
        id: 2,
        farmerId: 102,
        productId: 2, // Free Range Eggs
        harvestDate: DateTime(2023, 6, 10),
        createdAt: DateTime(2023, 6, 10),
        updatedAt: DateTime(2023, 6, 10),
        farmId: 202,
        volume: 1200,
        notes: 'Weekly egg collection',
        value: 3600,
        images: 'https://example.com/eggs-collection.jpg',
      ),
      Yield(
        id: 3,
        farmerId: 103,
        productId: 3, // Fresh Tilapia
        harvestDate: DateTime(2023, 6, 5),
        createdAt: DateTime(2023, 6, 5),
        updatedAt: DateTime(2023, 6, 5),
        farmId: 203,
        volume: 300,
        notes: 'Pond harvest - good yield',
        value: 4500,
        images: 'https://example.com/tilapia-harvest.jpg',
      ),
    ];
  }

  @override
  List<Object?> get props => [
        id,
        farmerId,
        productId,
        harvestDate,
        createdAt,
        updatedAt,
        farmId,
        volume,
        notes,
        value,
        images,
        farmerName,
        sector,
        sectorId,
        productName,
        hectare,
        status,
        barangay
      ];
}
