import 'package:flareline/pages/test/map_widget/map_panel/map_color_picker.dart';
import 'package:flareline/pages/test/map_widget/map_panel/map_panel_row.dart';
import 'package:flareline/pages/test/map_widget/map_panel/map_poly_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:latlong2/latlong.dart';
import 'pin_style.dart'; // Import the shared file
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';

class PolygonInfoPanel extends StatefulWidget {
  final PolygonData polygon;
  final Function(LatLng) onUpdateCenter;
  final Function(PinStyle) onUpdatePinStyle;
  final Function(Color) onUpdateColor;
  final Function() onSave;

  const PolygonInfoPanel({
    Key? key,
    required this.polygon,
    required this.onUpdateCenter,
    required this.onUpdatePinStyle,
    required this.onUpdateColor,
    required this.onSave,
  }) : super(key: key);

  @override
  _PolygonInfoPanelState createState() => _PolygonInfoPanelState();
}

class _PolygonInfoPanelState extends State<PolygonInfoPanel> {
  late TextEditingController latController;
  late TextEditingController lngController;
  PinStyle selectedPinStyle = PinStyle.rice;
  Color selectedColor = Colors.blue;

  // Sample data for fish cage info
  String fishCageOwner = "Juan Dela Cruz";
  double areaHa = 15.5; // in hectares
  double stockingDensity = 5.5; // fish per square meter
  double averageKgValuePHP = 200.0; // average kg price in PHP
  String fishVariety = "Tilapia";
  String yearlyFilter = "2018"; // Default year

  @override
  void initState() {
    super.initState();
    latController =
        TextEditingController(text: widget.polygon.center.latitude.toString());
    lngController =
        TextEditingController(text: widget.polygon.center.longitude.toString());
    selectedColor = widget.polygon.color;
  }

  @override
  void dispose() {
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onUpdateColor(selectedColor);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      constraints:
          BoxConstraints(maxHeight: 400), // Limit the height of the panel
      child: SingleChildScrollView(
        // Make the panel scrollable
        child: ExpansionTile(
          title: Text(
            "Fish Cage: ${widget.polygon.name}",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          children: [
            PolygonDetailsSection(
              fishCageOwner: fishCageOwner,
              areaHa: areaHa,
              stockingDensity: stockingDensity,
              fishVariety: fishVariety,
              yearlyFilter: yearlyFilter,
              averageKgValuePHP: averageKgValuePHP,
              onYearChanged: (newYear) {
                setState(() {
                  yearlyFilter = newYear;
                });
              },
            ),
            if (widget.polygon.description != null)
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  "Description: ${widget.polygon.description}",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            LocationCoordinatesSection(
              latController: latController,
              lngController: lngController,
            ),
            PinStyleDropdown(
              selectedPinStyle: selectedPinStyle,
              onPinStyleChanged: (newPinStyle) {
                setState(() {
                  selectedPinStyle = newPinStyle;
                  widget.onUpdatePinStyle(selectedPinStyle);
                });
              },
            ),
            ColorPickerButton(
              selectedColor: selectedColor,
              onColorPicked: _showColorPicker,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onSave();
              },
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
