import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';

class FarmersProfile extends LayoutWidget {
  final Map<String, dynamic> farmer;

  const FarmersProfile({super.key, required this.farmer});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Farmer Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return CommonCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 280,
                child: Image.asset(
                  'assets/cover/cover-01.png',
                  height: 280,
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
                    onPressed: () {},
                    icon: const Icon(Icons.camera, color: Colors.white),
                    label: const Text('Edit',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 72,
            backgroundColor: Colors.greenAccent,
            child: Image.asset('assets/user/user-01.png'),
          ),
          const SizedBox(height: 10),
          Text(
            farmer['farmerName'] ?? 'Unknown Farmer',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          FarmerDetailsCard(farmer: farmer),
          FarmDetailsCard(farmer: farmer),
          AnnualRecordsCard(farmer: farmer),
        ],
      ),
    );
  }
}

class FarmerDetailsCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  const FarmerDetailsCard({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildDetailField('Age', farmer['age'] ?? 'Not specified'),
          _buildDetailField('Gender', farmer['gender'] ?? 'Not specified'),
          _buildDetailField('Contact', farmer['contact'] ?? 'Not specified'),
          _buildDetailField('Email', farmer['email'] ?? 'Not specified'),
          _buildDetailField('Address', farmer['address'] ?? 'Not specified'),
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

class FarmDetailsCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  const FarmDetailsCard({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField('Sector', farmer['sector'] ?? 'Not specified'),
          _buildDetailField('Farm Size', '${farmer['farmSize']} hectares'),
          _buildDetailField(
              'Farm Locations', farmer['farmLocations'] ?? 'Not specified'),
          _buildDetailField(
              'Main Products', farmer['mainProducts'] ?? 'Not specified'),
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

class AnnualRecordsCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  const AnnualRecordsCard({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Annual Records',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField(
              'Total Yield per Year', '${farmer['totalYield']} tons'),
          _buildDetailField(
              'Last Harvest', farmer['lastHarvest'] ?? 'Not specified'),
          _buildDetailField(
              'Years of Experience', '${farmer['experience']} years'),
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
