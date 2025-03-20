import 'package:flareline/pages/yields/add_yield_modal.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/yields/grid_card.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/yields/yields_table.dart';
import 'package:flareline/pages/sectors/year_filter_dropdown.dart'; // Import the new widget

class YieldsPage extends LayoutWidget {
  const YieldsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Yields';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    // State to hold the selected year
    int selectedYear = DateTime.now().year;

    return Column(
      children: [
        // Year Filter Dropdown
        Align(
          alignment: Alignment.centerRight, // Aligns the content to the right
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Ensures the Row takes only the space it needs
            children: [
              // Add Farmer Button on the left
              ElevatedButton(
                onPressed: () {
                  // Add your logic for the "Add Farmer" button here
                  print("Add Farmer button pressed");

                  AddYieldModal.show(
                    context: context,
                    onYieldAdded:
                        (String cropType, double yieldAmount, DateTime date) {},
                  );
                },
                child: const Text("Add Yield"),
              ),
              const SizedBox(
                  width: 16), // Add spacing between the button and the dropdown
              // Year Filter Dropdown
              YearFilterDropdown(
                selectedYear: selectedYear,
                onYearChanged: (int? newValue) {
                  if (newValue != null) {
                    // Update the selected year
                    selectedYear = newValue;
                    // You can add logic here to refresh the data based on the selected year
                    print("Selected Year: $selectedYear");
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectorsGridCard(),
        const SizedBox(height: 16),
        const YieldsWidget(),
        const SizedBox(height: 16),
      ],
    );
  }
}
