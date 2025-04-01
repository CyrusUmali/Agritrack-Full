// ignore_for_file: unnecessary_to_list_in_spreads, avoid_print

import 'dart:convert';

import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flutter/material.dart';

class BarangayFilterPanel extends StatefulWidget {
  final BarangayManager barangayManager;
  final List<String> selectedBarangays;
  final VoidCallback onClose;
  final Function(List<String>, Map<String, bool>) onFiltersChanged;

  static Map<String, bool> filterOptions = {
    'Rice': true,
    'Fishery': true,
    'Corn': true,
    'Organic': true,
    'Livestock': true,
    'Highvaluecrop': true,
  };

  const BarangayFilterPanel({
    Key? key,
    required this.barangayManager,
    required this.selectedBarangays,
    required this.onFiltersChanged,
    required this.onClose,
  }) : super(key: key);

  @override
  _BarangayFilterPanelState createState() => _BarangayFilterPanelState();
}

class _BarangayFilterPanelState extends State<BarangayFilterPanel> {
  late List<String> _tempSelectedBarangays;
  late Map<String, bool> _tempFilterOptions;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tempSelectedBarangays = List.from(widget.selectedBarangays);
    _tempFilterOptions = Map.from(BarangayFilterPanel.filterOptions);

    // Log the barangay list in the requested format
    _logBarangays();
  }

  void _logBarangays() {
    final barangayNames =
        widget.barangayManager.barangays.map((b) => b.name).toList();
    final barangayJson = {
      "barangays": barangayNames,
    };
    print('Barangay List:');
    print(jsonEncode(barangayJson));
  }

  void _toggleAll(bool selectAll) {
    setState(() {
      _tempSelectedBarangays = selectAll
          ? widget.barangayManager.barangays.map((b) => b.name).toList()
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sort barangays A-Z
    final sortedBarangays = List.from(widget.barangayManager.barangays)
      ..sort((a, b) => a.name.compareTo(b.name));

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey, width: 2.0)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: widget.onClose,
              ),
              Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.filter_list),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            children: [
                              Text('Farm Type Filters',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Divider(),
                              ..._tempFilterOptions.entries.map((entry) {
                                return CheckboxListTile(
                                  title: Text(entry.key),
                                  value: entry.value,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _tempFilterOptions[entry.key] =
                                          value ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ],
                          );
                        },
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Barangays',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search barangays...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Text('Select All'),
                onPressed: () => _toggleAll(true),
              ),
              TextButton(
                child: Text('Clear All'),
                onPressed: () => _toggleAll(false),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: sortedBarangays
                  .where((barangay) => barangay.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()))
                  .map((barangay) {
                return CheckboxListTile(
                  title: Text(barangay.name),
                  value: _tempSelectedBarangays.contains(barangay.name),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        if (!_tempSelectedBarangays.contains(barangay.name)) {
                          _tempSelectedBarangays.add(barangay.name);
                        }
                      } else {
                        _tempSelectedBarangays.remove(barangay.name);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onFiltersChanged(List.from(_tempSelectedBarangays),
                  Map.from(_tempFilterOptions));
              widget.onClose();
            },
            child: Text('Apply Filters'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }
}
