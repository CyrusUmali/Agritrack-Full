import 'package:flareline/pages/farmers/sector_farmers.dart';
import 'package:flareline/pages/farms/farms_table.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_header.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_kpi.dart';
import 'package:flareline/pages/sectors/sector_profile/sector_overview.dart';

class SectorProfile extends LayoutWidget {
  final Map<String, dynamic> sector;

  const SectorProfile({super.key, required this.sector});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Sector Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SectorHeader(sector: sector),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectorKpiCards(sector: sector),
                const SizedBox(height: 24),
                SectorOverviewPanel(sector: sector),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft, // Aligns text to the left
                child: Text(
                  "Farmers in this Sector",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10), // Adds spacing
              FarmersPerSectorWidget(),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft, // Aligns text to the left
                child: Text(
                  "Farms in this Sector",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10), // Adds spacing
              FarmsTableWidget(),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SectorHeader(sector: sector, isMobile: true),
          const SizedBox(height: 64),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectorKpiCards(sector: sector, isMobile: true),
                const SizedBox(height: 16),
                SectorOverviewPanel(sector: sector, isMobile: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft, // Aligns text to the left
                child: Text(
                  "Farmers in this Sector",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10), // Adds spacing
              FarmersPerSectorWidget(),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Align(
                alignment: Alignment.centerLeft, // Aligns text to the left
                child: Text(
                  "Farms in this Sector",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10), // Adds spacing
              FarmsTableWidget(),
            ],
          )
        ],
      ),
    );
  }
}
