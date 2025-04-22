class FilterOptions {
  static const Map<String, String> reportTypes = {
    'farmers': 'Farmers List',
    'farms': 'Farms List',
    'crops': 'Crops & Yield',
    'barangay': 'Barangay Data',
    'sectors': 'Sector Performance',
  };

  static const List<String> barangays = [
    'Brgy. 1',
    'Brgy. 2',
    'Brgy. 3',
    'Brgy. 4',
    'Brgy. 5',
    'Brgy. 6',
    'Brgy. 7',
    'Brgy. 8',
    'Brgy. 9',
    'Brgy. 10',
    'Brgy. 11',
    'Brgy. 12'
  ];

  static const List<String> sectors = [
    'Fisherfolk',
    'Farmers',
    'Livestock',
    'Agri-Entrepreneurs'
  ];

  static const List<String> farmTypes = [
    'Crop Farm',
    'Fish Farm',
    'Livestock Farm',
    'Mixed'
  ];

  static const List<String> crops = [
    'Rice',
    'Corn',
    'Vegetables',
    'Fruits',
    'Root Crops'
  ];

  static const List<String> farms = ['Farm A', 'Farm B', 'Farm C', 'Farm D'];

  static const List<String> comparisonMetrics = [
    'Barangay',
    'Sector',
    'Crop Type',
    'Time Period'
  ];
}
