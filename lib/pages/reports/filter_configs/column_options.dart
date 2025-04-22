class ColumnOptions {
  static const Map<String, List<String>> reportColumns = {
    'farmers': [
      'Name',
      'Contact',
      'Barangay',
      'Sector',
      'Farms',
      'Products',
    ],
    'farms': [
      'Farm Name',
      'Owner',
      'Barangay',
      'Farm Type',
      'Area (ha)',
      'Primary Crop',
    ],
    'crops': [
      'Crop',
      'Variety',
      'Planting Date',
      'Harvest Date',
      'Yield (kg/ha)',
      'Farm',
      'Barangay',
      'Farmer',
    ],
    'barangay': [
      'Barangay',
      'Total Farmers',
      'Total Farms',
      'Primary Sector',
      'Main Crops',
      'Average Yield',
    ],
    'sectors': [
      'Sector',
      'Number of Members',
      'Total Production',
      'Average Income',
    ],
  };
}
