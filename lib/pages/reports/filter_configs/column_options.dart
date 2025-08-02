class ColumnOptions {
  static const Map<String, List<String>> reportColumns = {
    'farmers': [
      'Name',
      'Contact',
      'Barangay',
      'Sector',
      'Association',
      'Farms',
      'Products',
      '(Mt | Heads)',
      'Area',
    ],
    'livestock': [
      'Farm Name',
      'Owner',
      'Barangay',
      'Farm Type',
      'Product',
    ],
    'products': [
      'product',
      'sector',
      'harvest_date',
      'volume',
      'value',
      'farm_name',
      'barangay'
    ],
    'barangay': [
      'Barangay',
      'Total Farmers',
      'Total Farms',
      'Area (Ha)',
      'Average Yield',
    ],
    'sectors': [
      'Sector',
      'Number of Farmer',
      'Total Production',
    ],
    'farmer': [
      'farmer_id',
      'farmer_name',
      'barangay',
      'product',
      'association',
      'volume',
      'total_value',
      'harvest_date',
    ],
  };
}
