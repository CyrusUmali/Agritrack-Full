// ignore_for_file: unnecessary_to_list_in_spreads, avoid_print

import 'dart:convert';
import 'package:flareline/services/lanugage_extension.dart';
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
    'HVC': true,
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
    _logBarangays();
  }

  void _logBarangays() {
    final barangayNames =
        widget.barangayManager.barangays.map((b) => b.name).toList();
    final barangayJson = {
      "barangays": barangayNames,
    };
    // print('Barangay List:');
    // print(jsonEncode(barangayJson));
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
    final theme = Theme.of(context);
    final sortedBarangays = List.from(widget.barangayManager.barangays)
      ..sort((a, b) => a.name.compareTo(b.name));

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        border: Border(
          left: BorderSide(
              color: theme.cardTheme.surfaceTintColor ?? Colors.grey,
              width: 2.0),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
                onPressed: widget.onClose,
              ),
              Expanded(
                child: Text(
                  'Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.filter_list, color: theme.iconTheme.color),
                color: theme.cardTheme.color,
                surfaceTintColor: theme.cardTheme.color,
                padding: EdgeInsets.zero,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      height: 0, // This removes the default height constraint
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Container(
                            padding: EdgeInsets.all(
                                8), // Add padding only inside the container
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Farm Type Filters',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    // color: Theme.of(context).cardTheme.color,
                                  ),
                                ),
                                Divider(color: Colors.white.withOpacity(0.5)),
                                ..._tempFilterOptions.entries.map((entry) {
                                  return CheckboxListTile(
                                    title: Text(
                                      entry.key,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                              // color: Colors.white,
                                              ),
                                    ),
                                    value: entry.value,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _tempFilterOptions[entry.key] =
                                            value ?? false;
                                      });
                                    },
                                    // activeColor: Colors.white,
                                    checkColor: Colors.white,
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  );
                                }).toList(),
                              ],
                            ),
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
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search barangays...',
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
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
                child: Text(context.translate('Select All'),
                    style: TextStyle(color: theme.colorScheme.primary)),
                onPressed: () => _toggleAll(true),
              ),
              TextButton(
                child: Text(context.translate('Clear All'),
                    style: TextStyle(color: theme.colorScheme.primary)),
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
                  title: Text(barangay.name, style: theme.textTheme.bodyMedium),
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
                  activeColor: theme.colorScheme.primary,
                  checkColor: Colors.white,
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
            child: Text(context.translate('Apply Filters')),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 40),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
