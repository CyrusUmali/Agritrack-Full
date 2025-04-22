import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/products/profile_widgets/product_header.dart';
import 'package:flareline/pages/products/profile_widgets/key_details_card.dart';
import 'package:flareline/pages/products/profile_widgets/farms_table.dart';
import 'package:flareline/pages/products/profile_widgets/yield_history.dart';

class ProductProfile extends LayoutWidget {
  final Map<String, dynamic> product;

  const ProductProfile({super.key, required this.product});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Product Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductHeader(product: product),
            const SizedBox(height: 24),
            KeyDetailsCard(product: product),
            const SizedBox(height: 16),
            FarmsTable(farms: dummyFarms),
            const SizedBox(height: 16),
            YieldHistory(product: dummyProduct, isMobile: true),
          ],
        ),
      ),
    );
  }
}

final List<Map<String, dynamic>> dummyFarms = [
  {
    'name': 'Mountain View Orchards',
    'location': 'Colorado, USA',
    'area': 210,
    'yield': 7800,
    'status': 'Active',
  },
  {
    'name': 'Riverbend Farm',
    'location': 'Oregon, USA',
    'area': 65,
    'yield': 2400,
    'status': 'active',
  },
  {
    'name': 'Golden Harvest',
    'location': 'Iowa, USA',
    'area': 350,
    'yield': 12500,
    'status': 'Active',
  },
  {
    'name': 'Old Mill Farm',
    'location': 'Vermont, USA',
    'area': 42,
    'yield': 1500,
    'status': 'Inactive',
  },
  {
    'name': 'Prairie Winds',
    'location': 'Nebraska, USA',
    'area': 180,
    'yield': 6700,
    'status': 'Active',
  },
  {
    'name': 'Blue Sky Farms',
    'location': 'Washington, USA',
    'area': 95,
    'yield': 3800,
    'status': 'active',
  },
];
final Map<String, dynamic> dummy = {
  'farmName': 'Green Valley Organic Farm',
  'farmOwner': 'Maria Santos',
  'establishedYear': '2015',
  'farmSize': 8.5,
  'sector': 'Organic Vegetables & Fruits',
  'farmType': 'Organic Certification Pending',
  'barangay': 'San Isidro',
  'municipality': 'Sta. Rosa',
  'province': 'Laguna',
  'coordinates': '14.077557, 121.328938',
  'products': [
    {
      'name': 'Tomatoes',
      'type': 'vegetable',
      'variety': 'Cherry Tomatoes',
      'plantingSeason': 'Year-round',
      'harvestDuration': '60-80 days',
      'yields': [
        {
          'year': '2024',
          'total': 30.1,
          'monthly': [
            1.4,
            1.7,
            2.0,
            2.3,
            2.6,
            2.8,
            2.6,
            2.4,
            2.1,
            1.8,
            1.6,
            1.4
          ],
          'quality': {'a': 85, 'b': 12, 'c': 3},
          'pricePerKg': 45.00
        },
        {
          'year': '2023',
          'total': 28.4,
          'monthly': [
            1.2,
            1.5,
            1.8,
            2.0,
            2.2,
            2.5,
            2.3,
            2.1,
            1.9,
            1.7,
            1.5,
            1.3
          ],
          'quality': {'a': 82, 'b': 15, 'c': 3},
          'pricePerKg': 42.50
        },
        {
          'year': '2022',
          'total': 25.7,
          'monthly': [
            1.0,
            1.3,
            1.6,
            1.8,
            2.0,
            2.3,
            2.2,
            2.0,
            1.8,
            1.6,
            1.4,
            1.2
          ],
          'quality': {'a': 80, 'b': 16, 'c': 4},
          'pricePerKg': 40.00
        },
        {
          'year': '2021',
          'total': 23.2,
          'monthly': [
            0.9,
            1.1,
            1.4,
            1.6,
            1.8,
            2.1,
            2.0,
            1.8,
            1.6,
            1.4,
            1.2,
            1.0
          ],
          'quality': {'a': 78, 'b': 18, 'c': 4},
          'pricePerKg': 38.00
        }
      ]
    },
    {
      'name': 'Lettuce',
      'type': 'vegetable',
      'variety': 'Romaine',
      'plantingSeason': 'Cool season',
      'harvestDuration': '45-55 days',
      'yields': [
        {
          'year': '2024',
          'total': 19.5,
          'monthly': [
            1.7,
            1.9,
            1.8,
            1.4,
            1.0,
            0.7,
            0.6,
            0.8,
            1.2,
            1.6,
            1.8,
            2.0
          ],
          'quality': {'a': 88, 'b': 10, 'c': 2},
          'pricePerKg': 35.00
        },
        {
          'year': '2023',
          'total': 18.2,
          'monthly': [
            1.5,
            1.7,
            1.6,
            1.2,
            0.8,
            0.5,
            0.4,
            0.6,
            1.0,
            1.4,
            1.6,
            1.8
          ],
          'quality': {'a': 85, 'b': 12, 'c': 3},
          'pricePerKg': 32.50
        },
        {
          'year': '2022',
          'total': 15.8,
          'monthly': [
            1.3,
            1.5,
            1.4,
            1.0,
            0.7,
            0.4,
            0.3,
            0.5,
            0.9,
            1.2,
            1.4,
            1.6
          ],
          'quality': {'a': 82, 'b': 15, 'c': 3},
          'pricePerKg': 30.00
        },
        {
          'year': '2021',
          'total': 14.3,
          'monthly': [
            1.1,
            1.3,
            1.2,
            0.9,
            0.6,
            0.3,
            0.2,
            0.4,
            0.8,
            1.1,
            1.3,
            1.5
          ],
          'quality': {'a': 80, 'b': 16, 'c': 4},
          'pricePerKg': 28.00
        }
      ]
    },
    {
      'name': 'Bananas',
      'type': 'fruit',
      'variety': 'Lakatan',
      'plantingSeason': 'Year-round',
      'harvestDuration': '9-12 months',
      'yields': [
        {
          'year': '2024',
          'total': 45.2,
          'monthly': [
            3.4,
            3.7,
            4.0,
            4.3,
            4.6,
            4.8,
            4.6,
            4.4,
            4.1,
            3.8,
            3.6,
            3.4
          ],
          'quality': {'a': 90, 'b': 8, 'c': 2},
          'pricePerKg': 25.00
        },
        {
          'year': '2023',
          'total': 42.5,
          'monthly': [
            3.2,
            3.5,
            3.8,
            4.0,
            4.2,
            4.5,
            4.3,
            4.1,
            3.9,
            3.7,
            3.5,
            3.3
          ],
          'quality': {'a': 88, 'b': 10, 'c': 2},
          'pricePerKg': 23.00
        },
        {
          'year': '2022',
          'total': 39.8,
          'monthly': [
            3.0,
            3.3,
            3.6,
            3.8,
            4.0,
            4.3,
            4.1,
            3.9,
            3.7,
            3.5,
            3.3,
            3.1
          ],
          'quality': {'a': 85, 'b': 12, 'c': 3},
          'pricePerKg': 21.00
        }
      ]
    },
    {
      'name': 'Eggplant',
      'type': 'vegetable',
      'variety': 'Long Purple',
      'plantingSeason': 'Wet season',
      'harvestDuration': '70-85 days',
      'yields': [
        {
          'year': '2024',
          'total': 24.3,
          'monthly': [
            1.2,
            1.5,
            1.8,
            2.3,
            2.8,
            3.1,
            3.0,
            2.8,
            2.5,
            2.0,
            1.6,
            1.3
          ],
          'quality': {'a': 83, 'b': 14, 'c': 3},
          'pricePerKg': 30.00
        },
        {
          'year': '2023',
          'total': 22.1,
          'monthly': [
            1.0,
            1.2,
            1.5,
            2.0,
            2.5,
            2.8,
            2.7,
            2.5,
            2.2,
            1.8,
            1.5,
            1.2
          ],
          'quality': {'a': 80, 'b': 16, 'c': 4},
          'pricePerKg': 28.00
        },
        {
          'year': '2022',
          'total': 20.5,
          'monthly': [
            0.9,
            1.1,
            1.4,
            1.8,
            2.3,
            2.6,
            2.5,
            2.3,
            2.0,
            1.6,
            1.3,
            1.0
          ],
          'quality': {'a': 78, 'b': 18, 'c': 4},
          'pricePerKg': 26.00
        }
      ]
    },
    {
      'name': 'Rice',
      'type': 'grain',
      'variety': 'IR64',
      'plantingSeason': 'Wet season',
      'harvestDuration': '110-120 days',
      'yields': [
        {
          'year': '2024',
          'total': 52.8,
          'monthly': [0, 0, 0, 0, 2.5, 8.2, 12.5, 15.3, 10.2, 4.1, 0, 0],
          'quality': {'a': 75, 'b': 20, 'c': 5},
          'pricePerKg': 18.00
        },
        {
          'year': '2023',
          'total': 50.2,
          'monthly': [0, 0, 0, 0, 2.3, 7.8, 11.9, 14.6, 9.8, 3.8, 0, 0],
          'quality': {'a': 72, 'b': 22, 'c': 6},
          'pricePerKg': 17.00
        },
        {
          'year': '2022',
          'total': 48.6,
          'monthly': [0, 0, 0, 0, 2.1, 7.5, 11.5, 14.1, 9.5, 3.9, 0, 0],
          'quality': {'a': 70, 'b': 24, 'c': 6},
          'pricePerKg': 16.00
        }
      ]
    },
    {
      'name': 'Corn',
      'type': 'grain',
      'variety': 'Yellow',
      'plantingSeason': 'Dry season',
      'harvestDuration': '90-100 days',
      'yields': [
        {
          'year': '2024',
          'total': 38.7,
          'monthly': [0, 0, 1.2, 3.5, 6.2, 8.5, 7.8, 6.2, 3.5, 1.8, 0, 0],
          'quality': {'a': 80, 'b': 16, 'c': 4},
          'pricePerKg': 15.00
        },
        {
          'year': '2023',
          'total': 36.4,
          'monthly': [0, 0, 1.0, 3.2, 5.9, 8.1, 7.4, 5.9, 3.3, 1.6, 0, 0],
          'quality': {'a': 78, 'b': 18, 'c': 4},
          'pricePerKg': 14.50
        },
        {
          'year': '2022',
          'total': 34.2,
          'monthly': [0, 0, 0.9, 3.0, 5.6, 7.8, 7.1, 5.6, 3.1, 1.5, 0, 0],
          'quality': {'a': 75, 'b': 20, 'c': 5},
          'pricePerKg': 14.00
        }
      ]
    },
    {
      'name': 'Carrots',
      'type': 'vegetable',
      'variety': 'Kuroda',
      'plantingSeason': 'Cool season',
      'harvestDuration': '70-80 days',
      'yields': [
        {
          'year': '2024',
          'total': 20.8,
          'monthly': [
            1.2,
            1.5,
            1.8,
            1.5,
            1.2,
            0.8,
            0.5,
            0.7,
            1.2,
            1.8,
            2.2,
            2.4
          ],
          'quality': {'a': 85, 'b': 12, 'c': 3},
          'pricePerKg': 40.00
        },
        {
          'year': '2023',
          'total': 19.3,
          'monthly': [
            1.1,
            1.4,
            1.7,
            1.4,
            1.1,
            0.7,
            0.4,
            0.6,
            1.1,
            1.7,
            2.1,
            2.3
          ],
          'quality': {'a': 83, 'b': 14, 'c': 3},
          'pricePerKg': 38.00
        }
      ]
    },
    {
      'name': 'Poultry',
      'type': 'livestock',
      'variety': 'Broiler',
      'plantingSeason': 'Year-round',
      'harvestDuration': '35-42 days',
      'yields': [
        {
          'year': '2024',
          'total': 1250,
          'monthly': [90, 95, 100, 110, 120, 130, 120, 110, 100, 95, 90, 85],
          'quality': {'a': 88, 'b': 10, 'c': 2},
          'pricePerKg': 120.00
        },
        {
          'year': '2023',
          'total': 1180,
          'monthly': [85, 90, 95, 105, 115, 125, 115, 105, 95, 90, 85, 80],
          'quality': {'a': 85, 'b': 12, 'c': 3},
          'pricePerKg': 115.00
        }
      ]
    }
  ],
  'workers': [
    {
      'name': 'Juan Dela Cruz',
      'role': 'Farm Manager',
      'since': '2016',
      'contact': '09123456789',
      'responsibilities': 'Oversees daily operations, crop planning'
    },
    {
      'name': 'Pedro Santos',
      'role': 'Field Supervisor',
      'since': '2017',
      'contact': '09198765432',
      'responsibilities': 'Manages field workers, quality control'
    },
    {
      'name': 'Maria Gonzales',
      'role': 'Harvest Specialist',
      'since': '2018',
      'contact': '09234567890',
      'responsibilities': 'Leads harvest team, post-harvest handling'
    },
    {
      'name': 'Luis Reyes',
      'role': 'Irrigation Technician',
      'since': '2019',
      'contact': '09345678901',
      'responsibilities': 'Maintains irrigation system, water management'
    }
  ],
  'facilities': [
    'Greenhouse (500 sqm)',
    'Packing house',
    'Cold storage',
    'Organic composting area'
  ],
  'certifications': [
    'Good Agricultural Practices (GAP) training',
    'Organic certification in process'
  ],
  'lastHarvest': '2023-11-15',
  'annualYield': 112.3,
  'market': [
    'Local wet markets',
    'Restaurants in Metro Manila',
    'Organic food stores'
  ]
};
final dummyProduct = {
  'name': 'Wheat',
  'type': 'grain',
  'yields': [
    {
      'year': '2020',
      'monthly': [12, 15, 18, 22, 25, 28, 30, 32, 28, 22, 18, 15],
    },
    {
      'year': '2021',
      'monthly': [14, 16, 20, 24, 27, 30, 33, 35, 30, 24, 19, 16],
    },
    {
      'year': '2022',
      'monthly': [15, 17, 21, 26, 29, 32, 35, 37, 32, 26, 20, 17],
    },
    {
      'year': '2023',
      'monthly': [16, 18, 22, 28, 31, 35, 38, 40, 35, 28, 22, 18],
    },
  ],
};
