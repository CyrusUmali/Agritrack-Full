class ColumnOptions {
  static const Map<String, List<String>> reportColumns = {
    'farmers': [
      'Name',
        
      'Sector',
      'Association',
      'Farms',
      'Products',
      '(Mt | Heads)',
      'Area', 'Contact', 
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
      'area_harvested',
      'volume',
      'value',
      'farm_name',
      'barangay'
    ],
    'barangay': [
      'barangay',
      'product',
      'harvest_date',
      'volume',
      'value',
      'area_harvested',
    ],
    'sectors': [
      'sector_name',
      'product',
      'harvest_date',
      'volume',
      'value',
      'area_harvested',
    ],
    'farmer': [
      'farmer_id',
      'farmer_name',
      'barangay',
      'product',
      'association',
      'volume',
      'total_value',
      'area_harvested',
      'harvest_date',
    ],
  };
}
