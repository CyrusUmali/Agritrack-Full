import 'package:flareline/pages/test/map_widget/map_panel/map_panel_row.dart';
import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flutter/material.dart'; // For Colors

class YearlyFilterDropdown extends StatelessWidget {
  final String yearlyFilter;
  final Function(String) onYearChanged;

  const YearlyFilterDropdown({
    Key? key,
    required this.yearlyFilter,
    required this.onYearChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: yearlyFilter,
      items: ["2018", "2019", "2020", "2021", "2022", "2023"]
          .map((year) => DropdownMenuItem<String>(
                value: year,
                child: Text(year),
              ))
          .toList(),
      onChanged: (newYear) {
        if (newYear != null) {
          onYearChanged(newYear);
        }
      },
      isExpanded: true,
      hint: Text("Select Year"),
    );
  }
}

class PolygonDetailsSection extends StatelessWidget {
  final String fishCageOwner;
  final double areaHa;
  final double stockingDensity;
  final String fishVariety;
  final String yearlyFilter;
  final double averageKgValuePHP;
  final Function(String) onYearChanged;

  const PolygonDetailsSection({
    Key? key,
    required this.fishCageOwner,
    required this.areaHa,
    required this.stockingDensity,
    required this.fishVariety,
    required this.yearlyFilter,
    required this.averageKgValuePHP,
    required this.onYearChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(title: "Fish Cage Owner:", value: fishCageOwner),
        InfoRow(title: "Area (Ha):", value: areaHa.toString()),
        InfoRow(
            title: "Stocking Density (fish/m²):",
            value: stockingDensity.toString()),
        InfoRow(title: "Fish Variety:", value: fishVariety),
        SizedBox(height: 20),
        Text(
          "Average Price (PHP) - Yearly Filter: $yearlyFilter",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        InfoRow(
            title: "Average Price per KG (PHP):",
            value: averageKgValuePHP.toString()),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: YearlyFilterDropdown(
            yearlyFilter: yearlyFilter,
            onYearChanged: onYearChanged,
          ),
        ),
      ],
    );
  }
}

class LocationCoordinatesSection extends StatelessWidget {
  final TextEditingController latController;
  final TextEditingController lngController;

  const LocationCoordinatesSection({
    Key? key,
    required this.latController,
    required this.lngController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          "Location Coordinates:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        InfoRow(title: "Latitude:", value: latController.text),
        InfoRow(title: "Longitude:", value: lngController.text),
        SizedBox(height: 20),
      ],
    );
  }
}

class PinStyleDropdown extends StatelessWidget {
  final PinStyle selectedPinStyle;
  final Function(PinStyle) onPinStyleChanged;

  const PinStyleDropdown({
    Key? key,
    required this.selectedPinStyle,
    required this.onPinStyleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Select Pin Style:", style: TextStyle(fontSize: 16)),
        DropdownButton<PinStyle>(
          value: selectedPinStyle,
          items: PinStyle.values
              .map((style) => DropdownMenuItem<PinStyle>(
                    value: style,
                    child: Text(style.toString().split('.').last),
                  ))
              .toList(),
          onChanged: (newPinStyle) {
            if (newPinStyle != null) {
              onPinStyleChanged(newPinStyle);
            }
          },
        ),
      ],
    );
  }
}
