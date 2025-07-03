class ColumnOptions {
  static const Map<String, List<String>> reportColumns = {
    'farmers': [
      'Name',
      'Contact',
      'Barangay',
      'Sector',
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
    'crops': [
      'Crop',
      'Barangay',
      'No. of Ha',
      '% of Total',
      'Volume (MT)',
      'Farm',
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
      'Crop/Livestock',
      'Sector',
      'Area Ha',
      '(Mt || Heads)',
      'Date Recorded',
      'Remarks',
    ],
  };
}
