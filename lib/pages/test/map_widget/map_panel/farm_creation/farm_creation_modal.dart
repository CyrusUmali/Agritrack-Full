
import 'package:flareline/core/theme/global_colors.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:flareline/pages/test/map_widget/polygon_manager.dart';
import 'package:flareline/pages/test/map_widget/pin_style.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flareline/core/models/farmer_model.dart'; 
import 'package:provider/provider.dart';

class FarmCreationModal {
  static Future<bool> show({
    required BuildContext context,
    required PolygonData polygon,
    required Function(String) onNameChanged,
    required Function(PinStyle) onPinStyleChanged,
    required List<Farmer> farmers,
    required Function(int?, String?) onFarmerChanged,
  }) async {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    if (isLargeScreen) {
      return await _showLargeScreenModal(
        context: context,
        polygon: polygon,
        onNameChanged: onNameChanged,
        onPinStyleChanged: onPinStyleChanged,
        farmers: farmers,
        onFarmerChanged: onFarmerChanged,
        theme: theme,
      );
    } else {
      return await _showSmallScreenModal(
        context: context,
        polygon: polygon,
        onNameChanged: onNameChanged,
        onPinStyleChanged: onPinStyleChanged,
        farmers: farmers,
        onFarmerChanged: onFarmerChanged,
        theme: theme,
      );
    }
  }



  


  static Future<bool> _showLargeScreenModal({
    required BuildContext context,
    required PolygonData polygon,
    required Function(String) onNameChanged,
    required Function(PinStyle) onPinStyleChanged,
    required List<Farmer> farmers,
    required Function(int?, String?) onFarmerChanged,
    required ThemeData theme,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nameController = TextEditingController(text: polygon.name);
    PinStyle selectedPinStyle = polygon.pinStyle;
    
    int? selectedFarmerId;
    String? selectedFarmerName;
    bool isFarmerValid = false;
    bool isNameValid = polygon.name.isNotEmpty;
    
    // Auto-select farmer if user is a farmer
    if (userProvider.isFarmer && userProvider.farmer != null) {
      selectedFarmerId = userProvider.farmer!.id;
      selectedFarmerName = userProvider.farmer!.name;
      isFarmerValid = true;
      onFarmerChanged(selectedFarmerId, selectedFarmerName);
    } else {
      // Use existing polygon owner if available
      selectedFarmerId = polygon.owner != null ? int.tryParse(polygon.owner!) : null;
      isFarmerValid = selectedFarmerId != null;
      
      // Find initial farmer name if ID exists
      if (selectedFarmerId != null) {
        final farmer = farmers.firstWhere(
          (f) => f.id == selectedFarmerId,
          orElse: () => Farmer(id: -1, name: 'Unknown', sector: ''),
        );
        selectedFarmerName = farmer.name;
      }
    }

    final farmerOptions = farmers.map((farmer) => farmer.name).toList();
    final farmerTextController = TextEditingController(text: selectedFarmerName);

    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  insetPadding: const EdgeInsets.all(20),
                  backgroundColor: Theme.of(context).cardTheme.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Create New Farm',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Farm Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? GlobalColors.darkerCardColor
                                    : Colors.grey.shade50,
                            errorText: isNameValid ? null : 'Name is required',
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                          onChanged: (value) {
                            setState(() {
                              isNameValid = value.isNotEmpty;
                            });
                            onNameChanged(value);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Only show farmer selection if user is not a farmer
                        if (!userProvider.isFarmer)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '') {
                                    return farmerOptions;
                                  }
                                  return farmerOptions.where((String option) {
                                    return option.toLowerCase().contains(
                                        textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (String selection) {
                                  final selectedFarmer = farmers.firstWhere(
                                      (farmer) => farmer.name == selection);
                                  setState(() {
                                    selectedFarmerId = selectedFarmer.id;
                                    selectedFarmerName = selectedFarmer.name;
                                    isFarmerValid = true;
                                  });
                                  onFarmerChanged(
                                      selectedFarmerId, selectedFarmerName);
                                  farmerTextController.text = selectedFarmerName!;
                                },
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController textEditingController,
                                    FocusNode focusNode,
                                    VoidCallback onFieldSubmitted) {
                                  return TextField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      labelText: 'Farmer',
                                      hintText: 'Search for a farmer...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? GlobalColors.darkerCardColor
                                          : Colors.grey.shade50,
                                      errorStyle:
                                          const TextStyle(color: Colors.red),
                                      suffixIcon:
                                          textEditingController.text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear,
                                                      size: 20),
                                                  onPressed: () {
                                                    textEditingController.clear();
                                                    setState(() {
                                                      selectedFarmerId = null;
                                                      selectedFarmerName = null;
                                                      isFarmerValid = false;
                                                    });
                                                    onFarmerChanged(null, null);
                                                  },
                                                )
                                              : null,
                                    ),
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        setState(() {
                                          selectedFarmerId = null;
                                          selectedFarmerName = null;
                                          isFarmerValid = false;
                                        });
                                        onFarmerChanged(null, null);
                                      }
                                    },
                                  );
                                },
                                optionsViewBuilder: (BuildContext context,
                                    AutocompleteOnSelected<String> onSelected,
                                    Iterable<String> options) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? GlobalColors.darkerCardColor
                                          : Colors.grey.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: 200,
                                          maxWidth:
                                              MediaQuery.of(context).size.width *
                                                      0.5 -
                                                  48,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder:
                                              (BuildContext context, int index) {
                                            final String option =
                                                options.elementAt(index);
                                            return ListTile(
                                              title: Text(option),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (!isFarmerValid)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4.0, left: 12.0),
                                  child: Text(
                                    'Please select a farmer',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        else
                          // Show selected farmer info for farmer users
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, 
                                     color: Colors.green.shade600, 
                                     size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Farmer: ${userProvider.farmer!.name}',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFarmerValid && isNameValid
                                    ? FlarelineColors.primary
                                    : Colors.grey.shade300,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isFarmerValid && isNameValid
                                  ? () {
                                      onNameChanged(nameController.text);
                                      Navigator.of(context).pop(true);
                                    }
                                  : null,
                              child: const Text('Create Farm'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ) ??
        false;
  }


  static Future<bool> _showSmallScreenModal({
    required BuildContext context,
    required PolygonData polygon,
    required Function(String) onNameChanged,
    required Function(PinStyle) onPinStyleChanged,
    required List<Farmer> farmers,
    required Function(int?, String?) onFarmerChanged,
    required ThemeData theme, 
  }) async {
    // Move all state variables and controllers outside the modal builder
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nameController = TextEditingController(text: polygon.name);
    final farmerTextController = TextEditingController();
    
    PinStyle selectedPinStyle = polygon.pinStyle;
    int? selectedFarmerId;
    String? selectedFarmerName;
    bool isFarmerValid = false;
    bool isNameValid = polygon.name.isNotEmpty;
    
    // Auto-select farmer if user is a farmer
    if (userProvider.isFarmer && userProvider.farmer != null) {
      selectedFarmerId = userProvider.farmer!.id;
      selectedFarmerName = userProvider.farmer!.name;
      isFarmerValid = true;
      onFarmerChanged(selectedFarmerId, selectedFarmerName);
    } else {
      // Use existing polygon owner if available
      selectedFarmerId = polygon.owner != null ? int.tryParse(polygon.owner!) : null;
      isFarmerValid = selectedFarmerId != null;
      
      // Find initial farmer name if ID exists
      if (selectedFarmerId != null) { 
        final farmer = farmers.firstWhere(
          (f) => f.id == selectedFarmerId,
          orElse: () => Farmer(id: -1, name: 'Unknown', sector: ''),
        );
        selectedFarmerName = farmer.name;
        farmerTextController.text = selectedFarmerName ?? '';
      }
    }

    final farmerOptions = farmers.map((farmer) => farmer.name).toList();

    return await WoltModalSheet.show(
      context: context,
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            backgroundColor: Theme.of(context).cardTheme.color,
            hasSabGradient: false,
            topBar: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Farm',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 24, color: Colors.black54),
                    onPressed: () => Navigator.of(modalContext).pop(false),
                  ),
                ],
              ),
            ),
            isTopBarLayerAlwaysVisible: true,
            child: _ModalContent(
              nameController: nameController,
              farmerTextController: farmerTextController,
              userProvider: userProvider,
              farmers: farmers,
              farmerOptions: farmerOptions,
              onNameChanged: onNameChanged,
              onFarmerChanged: onFarmerChanged,
              initialSelectedFarmerId: selectedFarmerId,
              initialSelectedFarmerName: selectedFarmerName,
              initialIsFarmerValid: isFarmerValid,
              initialIsNameValid: isNameValid,
            ),
            stickyActionBar: _StickyActionBar(
              modalContext: modalContext,
              nameController: nameController,
              onNameChanged: onNameChanged,
            ),
          )
        ];
      },
      modalTypeBuilder: (context) => WoltModalType.bottomSheet(),
      onModalDismissedWithBarrierTap: () => Navigator.of(context).pop(false),
    );
  }
}

// Separate stateful widget for the modal content
class _ModalContent extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController farmerTextController;
  final UserProvider userProvider;
  final List<Farmer> farmers;
  final List<String> farmerOptions;
  final Function(String) onNameChanged;
  final Function(int?, String?) onFarmerChanged;
  final int? initialSelectedFarmerId;
  final String? initialSelectedFarmerName;
  final bool initialIsFarmerValid;
  final bool initialIsNameValid;

  const _ModalContent({
    required this.nameController,
    required this.farmerTextController,
    required this.userProvider,
    required this.farmers,
    required this.farmerOptions,
    required this.onNameChanged,
    required this.onFarmerChanged,
    required this.initialSelectedFarmerId,
    required this.initialSelectedFarmerName,
    required this.initialIsFarmerValid,
    required this.initialIsNameValid,
  });

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  late int? selectedFarmerId;
  late String? selectedFarmerName;
  late bool isFarmerValid;
  late bool isNameValid;

  @override
  void initState() {
    super.initState();
    selectedFarmerId = widget.initialSelectedFarmerId;
    selectedFarmerName = widget.initialSelectedFarmerName;
    isFarmerValid = widget.initialIsFarmerValid;
    isNameValid = widget.initialIsNameValid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(
              labelText: 'Farm Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade400,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? GlobalColors.darkerCardColor
                  : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorText: isNameValid ? null : 'Name is required',
              errorStyle: const TextStyle(color: Colors.red),
            ),
            onChanged: (value) {
              setState(() {
                isNameValid = value.isNotEmpty;
              });
              widget.onNameChanged(value);
            },
          ),
          const SizedBox(height: 16),
          // Only show farmer selection if user is not a farmer
          if (!widget.userProvider.isFarmer)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<String>.empty();
                    }
                    return widget.farmerOptions.where((String option) {
                      return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    final selectedFarmer = widget.farmers.firstWhere(
                        (farmer) => farmer.name == selection);
                    setState(() {
                      selectedFarmerId = selectedFarmer.id;
                      selectedFarmerName = selectedFarmer.name;
                      isFarmerValid = true;
                    });
                    widget.onFarmerChanged(selectedFarmerId, selectedFarmerName);
                    widget.farmerTextController.text = selectedFarmerName!;
                  },
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) {
                    // Use the provided controller instead of creating a new one
                    if (widget.farmerTextController.text != textEditingController.text) {
                      textEditingController.text = widget.farmerTextController.text;
                    }
                    
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Farmer',
                        hintText: 'Search for a farmer...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        errorStyle: const TextStyle(color: Colors.red),
                        suffixIcon: textEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  textEditingController.clear();
                                  widget.farmerTextController.clear();
                                  setState(() {
                                    selectedFarmerId = null;
                                    selectedFarmerName = null;
                                    isFarmerValid = false;
                                  });
                                  widget.onFarmerChanged(null, null);
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        widget.farmerTextController.text = value;
                        if (value.isEmpty) {
                          setState(() {
                            selectedFarmerId = null;
                            selectedFarmerName = null;
                            isFarmerValid = false;
                          });
                          widget.onFarmerChanged(null, null);
                        }
                      },
                    );
                  },
                  optionsViewBuilder: (BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? GlobalColors.darkerCardColor
                            : Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: 200,
                            maxWidth: MediaQuery.of(context).size.width - 32,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                title: Text(option),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (!isFarmerValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                    child: Text(
                      'Please select a farmer',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            )
          else
            // Show selected farmer info for farmer users
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, 
                       color: Colors.green.shade600, 
                       size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Farmer: ${widget.userProvider.farmer!.name}',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// Separate stateful widget for the sticky action bar
class _StickyActionBar extends StatefulWidget {
  final BuildContext modalContext;
  final TextEditingController nameController;
  final Function(String) onNameChanged;

  const _StickyActionBar({
    required this.modalContext,
    required this.nameController,
    required this.onNameChanged,
  });

  @override
  State<_StickyActionBar> createState() => _StickyActionBarState();
}

class _StickyActionBarState extends State<_StickyActionBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.nameController.text.isNotEmpty
              ? FlarelineColors.primary
              : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: widget.nameController.text.isNotEmpty
            ? () {
                widget.onNameChanged(widget.nameController.text);
                Navigator.of(widget.modalContext).pop(true);
              }
            : null,
        child: const Text(
          'Create Farm',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }











}







////



