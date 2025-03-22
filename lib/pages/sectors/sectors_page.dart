import 'package:flareline/pages/sectors/sector_table.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/sectors/grid_card.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/sectors/sector_farmers.dart';
import 'package:flareline/pages/sectors/year_filter_dropdown.dart'; // Import the new widget

import 'package:flareline/pages/sectors/sector_line_Chart.dart';
import 'package:flareline/pages/sectors/sector_bar_Chart.dart';

class SectorsPage extends LayoutWidget {
  const SectorsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Sectors';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    // State to hold the selected year
    int selectedYear = DateTime.now().year;

    return Column(
      children: [
        // Year Filter Dropdown
        YearFilterDropdown(
          selectedYear: selectedYear,
          onYearChanged: (int? newValue) {
            if (newValue != null) {
              // Update the selected year
              selectedYear = newValue;
              // You can add logic here to refresh the data based on the selected year
            }
          },
        ),
        const SizedBox(height: 16),
        const SectorsGridCard(),
        const SizedBox(height: 16),

        SectorTableWidget(),
        // const FarmersPerSectorWidget(),
        const SizedBox(height: 16),

        SectorLineChart(),
        const SizedBox(height: 16),
        SectorBarChart()
        // const SectorYieldAndGrowthWidget(),
      ],
    );
  }
}
