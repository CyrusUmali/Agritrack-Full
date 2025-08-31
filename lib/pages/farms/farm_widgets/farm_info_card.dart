import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/test/map_widget/stored_polygons.dart';
import 'package:flareline/pages/widget/combo_box.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class FarmInfoCard extends StatefulWidget {
  final Map<String, dynamic> farm;
  final bool isMobile;
  final Function(Map<String, dynamic>) onSave;

  const FarmInfoCard({
    super.key,
    required this.farm,
    required this.onSave,
    this.isMobile = false,
  });

  @override
  State<FarmInfoCard> createState() => _FarmInfoCardState();
}

class _FarmInfoCardState extends State<FarmInfoCard> {
  late Map<String, dynamic> _editedFarm;
  bool _hasChanges = false;
  bool _isEditing = false;
  final List<String> _sectors = [
    'HVC',
    'Livestock',
    'Corn',
    'Fishery',
    'Organic',
    'Rice'
  ];
  late List<String> barangayNames = [];
  List<dynamic> _farmers = [];

  @override
  void initState() {
    super.initState();
    _editedFarm = Map<String, dynamic>.from(widget.farm);
    _editedFarm['sector'] =
        _editedFarm['sector']?.toString() ?? 'Mixed Farming';
    _editedFarm['status'] = _editedFarm['status']?.toString() ?? 'Active';

    context.read<FarmerBloc>().add(LoadFarmers());

    _editedFarm['products'] = (_editedFarm['products'] as List?)
            ?.map((p) => p is Map ? p['name'].toString() : p.toString())
            .toList() ??
        [];

    barangayNames = barangays.map((b) => b['name'] as String).toList();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing && _hasChanges) {
        _saveChanges();
      }
    });
  }

  void _handleFieldChange(String field, dynamic value) {
    setState(() {
      _editedFarm[field] = value;
      _hasChanges = true;
    });
  }

  void _saveChanges() {
    final selectedFarmer = _farmers.firstWhere(
      (farmer) => farmer['name'] == _editedFarm['farmOwner'],
      orElse: () => {'id': '', 'name': ''},
    );

    int getSectorId(String? sector) {
      if (sector == null) return 0;
      switch (sector) {
        case 'Rice':
          return 1;
        case 'Corn':
          return 2;
        case 'HVC':
          return 3;
        case 'Livestock':
          return 4;
        case 'Fishery':
          return 5;
        case 'Organic':
          return 6;
        default:
          return 0;
      }
    }

    final saveData = {
      'farmName': _editedFarm['farmName'] ?? '',
      'farmerId': selectedFarmer['id'] ?? '',
      'sectorId': getSectorId(_editedFarm['sector']?.toString()),
      'products': _editedFarm['products'] ?? [],
      'barangayName': _editedFarm['barangay'] ?? '',
      'status': _editedFarm['status'] ?? 'Active',
    };

    print('Saved farm data: $saveData');
    widget.onSave(saveData);

    setState(() {
      _hasChanges = false;
    });
  }

  String _getProductDisplayName(dynamic product) {
    if (product == null) return '';
    if (product is String && product.contains(':')) {
      return product.split(':').last.trim();
    } else if (product is Map) {
      return product['name']?.toString() ?? '';
    }
    return product.toString();
  }

  Widget _buildStatusField() {
    const statusOptions = ['Active', 'Inactive'];
    final userProvider = context.read<UserProvider>();
    final isFarmerUser = userProvider.isFarmer;

    if (_isEditing && !isFarmerUser) {
      // Normal edit mode for non-farmer users (admin, etc.)
      return buildComboBox(
          context: context,
          hint: 'Select Status',
          options: statusOptions,
          selectedValue: _editedFarm['status'] ?? 'Active',
          onSelected: (value) => _handleFieldChange('status', value),
          width: widget.isMobile ? 150 : 180,
          height: 30);
    } else if (_isEditing && isFarmerUser) {
      // Locked field for farmer users - show as read-only with lock icon
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              _editedFarm['status'] ?? 'Active',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    } else {
      // Read-only mode (not editing)
      return Text(
        _editedFarm['status'] ?? 'Active',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  _editedFarm['status'] == 'Active' ? Colors.green : Colors.red,
            ),
      );
    }
  }

  Widget _buildOwnerField() {
    // Use context.read to get the UserProvider
    final userProvider = context.read<UserProvider>();
    final isFarmerUser = userProvider.isFarmer;

    // If user is a farmer and we're in edit mode, show locked field
    if (_isEditing && !isFarmerUser) {
      // Normal edit mode for non-farmer users (admin, etc.)
      return buildComboBox(
          context: context,
          hint: 'Select Farm Owner',
          options: _farmers.map((farmer) => farmer['name'].toString()).toList(),
          selectedValue: _editedFarm['farmOwner'] ?? '',
          onSelected: (value) => _handleFieldChange('farmOwner', value),
          width: widget.isMobile ? 150 : 180,
          height: 30);
    } else if (_isEditing && isFarmerUser) {
      // Locked field for farmer users - show as read-only with lock icon
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _editedFarm['farmOwner'] ?? 'Unknown Owner',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                overflow: widget.isMobile ? TextOverflow.ellipsis : null,
              ),
            ),
          ],
        ),
      );
    } else {
      // Read-only mode (not editing)
      return TextFormField(
        initialValue:
            'Owned by: ${_editedFarm['farmOwner'] ?? 'Unknown Owner'}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: widget.isMobile ? 12 : null,
            ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        readOnly: true,
      );
    }
  }

  Widget _buildSectorField() {
    if (_isEditing) {
      return buildComboBox(
          context: context,
          hint: 'Select Sector',
          options: _sectors,
          selectedValue: _editedFarm['sector']?.toString() ?? _sectors.first,
          onSelected: (value) => _handleFieldChange('sector', value),
          width: widget.isMobile ? 150 : 180,
          height: 30);
    } else {
      return Text(
        _editedFarm['sector']?.toString() ?? 'Not specified',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: widget.isMobile ? 12 : null,
            ),
      );
    }
  }

  Widget _buildLocationField() {
    if (_isEditing) {
      return buildComboBox(
          context: context,
          hint: 'Select Barangay',
          options: barangayNames,
          selectedValue: _editedFarm['barangay'] ?? '',
          onSelected: (value) => _handleFieldChange('barangay', value),
          width: widget.isMobile ? 150 : 180,
          height: 30);
    } else {
      return Text(
        '${_editedFarm['barangay'] ?? ''}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: widget.isMobile ? 12 : null,
            ),
      );
    }
  }

  // Mobile-specific info sections
  Widget _buildMobileInfoSection({
    required IconData icon,
    required String label,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? GlobalColors.darkerCardColor
            : GlobalColors.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmerBloc, FarmerState>(
      listener: (context, state) {
        if (state is FarmersLoaded) {
          setState(() {
            _farmers = state.farmers
                .map((farmer) => {
                      'id': farmer.id,
                      'name': farmer.name,
                    })
                .toList();
          });
        }
      },
      child: Stack(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section with farm name and avatar
                  widget.isMobile
                      ? Column(
                          children: [
                            // Avatar centered on mobile
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? GlobalColors.darkerCardColor
                                  : GlobalColors.surfaceColor,
                              child: Icon(
                                Icons.agriculture,
                                size: 32,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Farm info below avatar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  initialValue: _editedFarm['farmName'] ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  textAlign: TextAlign.center,
                                  readOnly: !_isEditing,
                                  onChanged: _isEditing
                                      ? (value) =>
                                          _handleFieldChange('farmName', value)
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Center(child: _buildOwnerField()),
                                const SizedBox(height: 4),
                                Center(child: _buildStatusField()),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? GlobalColors.darkerCardColor
                                  : GlobalColors.surfaceColor,
                              child: Icon(
                                Icons.agriculture,
                                size: 40,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    initialValue: _editedFarm['farmName'] ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    readOnly: !_isEditing,
                                    onChanged: _isEditing
                                        ? (value) => _handleFieldChange(
                                            'farmName', value)
                                        : null,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildOwnerField(),
                                  const SizedBox(height: 4),
                                  _buildStatusField(),
                                ],
                              ),
                            ),
                          ],
                        ),

                  const Divider(height: 32),

                  // Info sections - different layout for mobile vs desktop
                  widget.isMobile
                      ? Column(
                          children: [
                            // Mobile: Stack info sections vertically
                            _buildMobileInfoSection(
                              icon: Icons.business,
                              label: 'Primary Sector',
                              content: _buildSectorField(),
                            ),
                            _buildMobileInfoSection(
                              icon: Icons.location_on,
                              label: 'Location',
                              content: _buildLocationField(),
                            ),
                            if (_editedFarm['farmSize'] != null)
                              _buildMobileInfoSection(
                                icon: Icons.agriculture,
                                label: 'Farm Size',
                                content: Text(
                                  '${_editedFarm['farmSize']} hectares',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                          ],
                        )
                      : Container(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              // Primary Sector
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minWidth: 200),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? GlobalColors.darkerCardColor
                                        : GlobalColors.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(minWidth: 200),
                                        child: IntrinsicWidth(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? GlobalColors.darkerCardColor
                                                  : GlobalColors.surfaceColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2, right: 8),
                                                  child: Icon(
                                                    Icons.business,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Primary Sector',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _buildSectorField(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Location
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(minWidth: 200),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? GlobalColors.darkerCardColor
                                        : GlobalColors.surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(minWidth: 200),
                                        child: IntrinsicWidth(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? GlobalColors.darkerCardColor
                                                  : GlobalColors.surfaceColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2, right: 8),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Location',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _buildLocationField(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Farm Size
                              if (_editedFarm['farmSize'] != null)
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(minWidth: 200),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? GlobalColors.darkerCardColor
                                          : GlobalColors.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              minWidth: 200),
                                          child: IntrinsicWidth(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? GlobalColors
                                                        .darkerCardColor
                                                    : GlobalColors.surfaceColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2, right: 8),
                                                    child: Icon(
                                                      Icons.agriculture,
                                                      size: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Farm Size',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelSmall
                                                            ?.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '${_editedFarm['farmSize']} hectares',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                  const SizedBox(height: 16),

                  // Products section
                  Container(
                    padding: EdgeInsets.all(widget.isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? GlobalColors.darkerCardColor
                          : GlobalColors.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.inventory,
                              size: widget.isMobile ? 16 : 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Products',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.isMobile ? 14 : null,
                                  ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_editedFarm['products'].isEmpty)
                          Text(
                            'No products added yet',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: widget.isMobile ? 12 : null,
                            ),
                          )
                        else
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: widget.isMobile ? 100 : 120,
                            ),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: widget.isMobile ? 4 : 8,
                                runSpacing: widget.isMobile ? 4 : 8,
                                children: List.generate(
                                  _editedFarm['products'].length,
                                  (index) => Chip(
                                    backgroundColor:
                                        Theme.of(context).cardTheme.color,
                                    label: Text(
                                      _getProductDisplayName(
                                          _editedFarm['products'][index]),
                                      style: TextStyle(
                                        fontSize: widget.isMobile ? 11 : null,
                                      ),
                                    ),
                                    deleteIcon: Icon(
                                      Icons.close,
                                      size: widget.isMobile ? 14 : 16,
                                    ),
                                    materialTapTargetSize: widget.isMobile
                                        ? MaterialTapTargetSize.shrinkWrap
                                        : MaterialTapTargetSize.padded,
                                    visualDensity: widget.isMobile
                                        ? VisualDensity.compact
                                        : VisualDensity.standard,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: FloatingActionButton.small(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? GlobalColors.darkerCardColor
                  : GlobalColors.surfaceColor,
              onPressed: _toggleEditing,
              child: Icon(
                _isEditing
                    ? (_hasChanges ? Icons.save : Icons.close)
                    : Icons.edit,
                size: widget.isMobile ? 18 : 24,
              ),
              tooltip: _isEditing
                  ? (_hasChanges ? 'Save Changes' : 'Cancel Editing')
                  : 'Edit Farm',
            ),
          ),
        ],
      ),
    );
  }
}
