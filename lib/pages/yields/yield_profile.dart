import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/pages/layout.dart';

class YieldProfile extends LayoutWidget {
  final Map<String, dynamic> yieldData;

  const YieldProfile({super.key, required this.yieldData});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Yield Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return CommonCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Header Section
          Stack(
            children: [
              SizedBox(
                height: 200,
                child: Image.asset(
                  'assets/cover/cover-02.png', // Replace with your image
                  height: 200,
                  width: double.maxFinite,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  color: Colors.blueAccent,
                  child: TextButton.icon(
                    onPressed: () {
                      // Add edit functionality here
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Farmer Information
          Text(
            yieldData['farmerName'] ?? 'Unknown Farmer',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Sections
          FarmerInformationCard(yieldData: yieldData),
          SectorProductDetailsCard(yieldData: yieldData),
          PreviousYieldReportsCard(yieldData: yieldData),
          YieldComparisonCard(yieldData: yieldData),
        ],
      ),
    );
  }
}

// Farmer Information Card
class FarmerInformationCard extends StatelessWidget {
  final Map<String, dynamic> yieldData;

  const FarmerInformationCard({super.key, required this.yieldData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farmer Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField('Farmer Name', yieldData['farmerName'] ?? 'N/A'),
          _buildDetailField('Contact', yieldData['contact'] ?? 'N/A'),
          _buildDetailField('Farm Size', yieldData['farmSize'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

// Sector & Product Details Card
class SectorProductDetailsCard extends StatelessWidget {
  final Map<String, dynamic> yieldData;

  const SectorProductDetailsCard({super.key, required this.yieldData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sector & Product Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField('Sector', yieldData['sector'] ?? 'N/A'),
          _buildDetailField('Product', yieldData['product'] ?? 'N/A'),
          _buildDetailField('Area', yieldData['area'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

// Previous Yield Reports Card
class PreviousYieldReportsCard extends StatelessWidget {
  final Map<String, dynamic> yieldData;

  const PreviousYieldReportsCard({super.key, required this.yieldData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Previous Yield Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField('Last Harvest', yieldData['lastHarvest'] ?? 'N/A'),
          _buildDetailField(
              'Reported Yield', yieldData['reportedYield'] ?? 'N/A'),
          _buildDetailField(
              'Date Reported', yieldData['dateReported'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

// Yield Comparison Card
class YieldComparisonCard extends StatelessWidget {
  final Map<String, dynamic> yieldData;

  const YieldComparisonCard({super.key, required this.yieldData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comparison with Expected Yield',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField(
              'Reported Yield', yieldData['reportedYield'] ?? 'N/A'),
          _buildDetailField(
              'Expected Yield', yieldData['expectedYield'] ?? 'N/A'),
          _buildDetailField('Difference', yieldData['difference'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
