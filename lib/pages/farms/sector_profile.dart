import 'package:flareline/pages/farmers/sector_farmers.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';

class SectorProfile extends LayoutWidget {
  final Map<String, dynamic> sector;

  const SectorProfile({super.key, required this.sector});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Sector Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return SectorProfileDesktop(sector: sector);
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return SectorProfileMobile(sector: sector);
  }
}

class SectorProfileDesktop extends StatelessWidget {
  final Map<String, dynamic> sector;

  const SectorProfileDesktop({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
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
            sector['sectorName'] ?? 'Unknown Sector',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SectorDetailsCard(sector: sector),
          SectorStatisticsCard(sector: sector),
          AnnualYieldReportCard(sector: sector),
        ],
      ),
    );
  }
}

class SectorProfileMobile extends StatelessWidget {
  final Map<String, dynamic> sector;

  const SectorProfileMobile({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CommonCard(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 180,
                  child: Image.asset(
                    'assets/cover/cover-01.png',
                    height: 180,
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
              radius: 48,
              backgroundColor: Colors.greenAccent,
              child: Image.asset('assets/user/user-01.png'),
            ),
            const SizedBox(height: 10),
            Text(
              sector['sectorName'] ?? 'Unknown Sector',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SectorDetailsCard(sector: sector),
            SectorStatisticsCard(sector: sector),
            AnnualYieldReportCard(sector: sector),
          ],
        ),
      ),
    );
  }
}

class SectorDetailsCard extends StatelessWidget {
  final Map<String, dynamic> sector;
  const SectorDetailsCard({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sector Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField(
              'Sector Name', sector['sectorName'] ?? 'Not specified'),
          _buildDetailField(
              'Description', sector['description'] ?? 'Not specified'),
          const SizedBox(height: 16),
          const FarmersPerSectorWidget(),
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

class SectorStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> sector;
  const SectorStatisticsCard({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sector Statistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField('Total Farmers',
              sector['totalFarmers']?.toString() ?? 'Not specified'),
          _buildDetailField(
              'Total Land Area', '${sector['totalLandArea']} hectares'),
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

class AnnualYieldReportCard extends StatelessWidget {
  final Map<String, dynamic> sector;
  const AnnualYieldReportCard({super.key, required this.sector});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Annual Yield Report',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDetailField(
              'Annual Yield', '${sector['annualYieldReport']} tons'),
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
