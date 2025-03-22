import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flutter/material.dart';

class FarmListPanel extends StatefulWidget {
  final PolygonManager polygonManager;
  final Function(int) onPolygonSelected;

  const FarmListPanel({
    Key? key,
    required this.polygonManager,
    required this.onPolygonSelected,
  }) : super(key: key);

  @override
  _FarmListPanelState createState() => _FarmListPanelState();
}

class _FarmListPanelState extends State<FarmListPanel> {
  String searchQuery = '';
  Map<String, bool> filterOptions = {
    'Filter 1': false,
    'Filter 2': false,
    'Filter 3': false,
  };

  List<PolygonData> get filteredPolygons {
    if (searchQuery.isEmpty) {
      return widget.polygonManager.polygons;
    }
    return widget.polygonManager.polygons
        .where((polygon) =>
            polygon.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Width of the panel
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and Filter Row
          Row(
            children: [
              // Search Input
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search farms...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 8), // Spacing between search and filter button
              // Filter Button
              PopupMenuButton<String>(
                icon: Icon(Icons.filter_list),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(),
                        ...filterOptions.entries.map((entry) {
                          return CheckboxListTile(
                            title: Text(entry.key),
                            value: entry.value,
                            onChanged: (bool? value) {
                              setState(() {
                                filterOptions[entry.key] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16), // Spacing between search/filter and list
          Text(
            'Farms',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPolygons.length,
              itemBuilder: (context, index) {
                final polygon = filteredPolygons[index];
                return ListTile(
                  title: Text(polygon.name),
                  tileColor: widget.polygonManager.selectedPolygonIndex == index
                      ? Colors.blue.withOpacity(0.3)
                      : null,
                  onTap: () {
                    widget.onPolygonSelected(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
