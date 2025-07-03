import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class Farm extends Equatable {
  final int id;
  final String name;
  final String? owner;
  final String? description;
  final int? farmerId;
  final String? barangay;
  final int? volume;
  final List<LatLng>? vertices;
  final String? sector;
  final int? sectorId;
  final double? hectare;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? products;

  const Farm({
    required this.id,
    required this.name,
    this.volume,
    this.owner,
    this.farmerId,
    this.products, // Add products to constructor
    this.description,
    this.barangay,
    this.vertices,
    this.sector,
    this.sectorId,
    this.hectare,
    this.createdAt,
    this.updatedAt,
  });

  factory Farm.fromJson(Map<String, dynamic> json) {
    List<LatLng>? parseVertices(dynamic verticesData) {
      if (verticesData == null) return null;
      if (verticesData is List) {
        return verticesData
            .where((point) =>
                point is Map && point['lat'] != null && point['lng'] != null)
            .map((point) => LatLng(
                  (point['lat'] as num).toDouble(),
                  (point['lng'] as num).toDouble(),
                ))
            .toList();
      }
      return null;
    }

    List<String>? parseProducts(dynamic productsData) {
      if (productsData == null) return null;
      if (productsData is List) {
        return productsData
            .whereType<String>() // Only keep String items
            .toList();
      }
      return null;
    }

    return Farm(
      id: json['id'] as int? ?? 0,
      farmerId: json['farmerId'] as int? ?? 0,
      volume: (json['yield'] as Map<String, dynamic>?)?['volume'] as int? ??
          0, // Fixed this li
      name: json['name'] as String? ?? 'Unknown Farm',
      owner: json['farmerName'] as String?,
      description: json['description'] as String?,
      sector: json['sectorName'] as String?,
      sectorId: json['sectorId'] as int? ?? 0,
      barangay: json['parentBarangay'] as String?,
      products: parseProducts(json['products']), // Parse products
      hectare: (json['area'] as num?)?.toDouble(),
      vertices: parseVertices(json['vertices']),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'farmerId': farmerId,
      'volume': volume,
      'owner': owner,
      'description': description,
      'barangay': barangay,
      'products': products, // Add products to JSON
      'hectare': hectare,
      'sector': sector,
      'sectorId': sectorId,
      'vertices': vertices
          ?.map((point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static List<Farm> get sampleFarms {
    return [
      Farm(
        id: 1,
        name: 'Golden Grains Rice Farm',
        owner: 'Juan Dela Cruz',
        description: 'Primary rice production farm in San Juan',
        barangay: 'San Juan',
        products: ['Rice', 'Corn'], // Add sample products
        hectare: 5.2,
        vertices: [
          LatLng(14.6760, 121.0437),
          LatLng(14.6765, 121.0442),
          LatLng(14.6770, 121.0439),
          LatLng(14.6768, 121.0433),
        ],
      ),
      // ... (other sample farms)
    ];
  }

  @override
  List<Object?> get props => [
        id,
        name,
        farmerId,
        owner,
        description,
        barangay,
        volume,
        vertices,
        products, // Add products to props
        sector,
        sectorId,
        hectare,
        createdAt,
        updatedAt,
      ];
}
