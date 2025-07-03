import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddYieldModal extends StatefulWidget {
  final Function(
    int cropTypeId,
    int farmerId,
    int farmId, // Changed from int
    double yieldAmount,
    double? areaHa,
    DateTime date,
    String notes,
    List<XFile> images,
  ) onYieldAdded;

  const AddYieldModal({Key? key, required this.onYieldAdded}) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required List<Product> products,
    required List<Farm> farms,
    required List<Farmer> farmers,
    required Function(
      int cropTypeId,
      int farmerId,
      int farmId,
      double yieldAmount,
      double? areaHa,
      DateTime date,
      String notes,
      List<XFile> images,
    ) onYieldAdded,
  }) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentKey = GlobalKey<_AddYieldModalContentState>();
    bool isLoading = false;

    await ModalDialog.show(
      context: context,
      title: 'Add Yield Record',
      showTitle: true,
      showTitleDivider: true,
      modalType: screenWidth < 600 ? ModalType.small : ModalType.medium,
      child: _AddYieldModalContent(
          key: contentKey,
          onLoadingStateChanged: (loading) {
            isLoading = loading;
          },
          onYieldAdded: onYieldAdded,
          products: products,
          farms: farms,
          farmers: farmers),
      footer: _AddYieldModalFooter(
        onSubmit: () {
          if (contentKey.currentState != null && !isLoading) {
            contentKey.currentState!._submitYield();
          }
        },
        onCancel: () => Navigator.of(context).pop(),
        isLoading: isLoading,
      ),
    );
  }

  @override
  State<AddYieldModal> createState() => _AddYieldModalState();
}

class _AddYieldModalState extends State<AddYieldModal> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _AddYieldModalContent extends StatefulWidget {
  final Function(bool) onLoadingStateChanged;
  final Function(
    int cropTypeId,
    int farmerId,
    int farmId,
    double yieldAmount,
    double? areaHa,
    DateTime date,
    String notes,
    List<XFile> images,
  ) onYieldAdded;
  final List<Product> products;
  final List<Farm> farms;
  final List<Farmer> farmers;
  const _AddYieldModalContent({
    Key? key,
    required this.onLoadingStateChanged,
    required this.onYieldAdded,
    required this.products,
    required this.farmers,
    required this.farms,
  }) : super(key: key);

  @override
  State<_AddYieldModalContent> createState() => _AddYieldModalContentState();
}

class _AddYieldModalContentState extends State<_AddYieldModalContent> {
  final TextEditingController yieldAmountController = TextEditingController();
  final TextEditingController areaHaController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  TextEditingController farmAreaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  Product? selectedProduct;
  Farmer? selectedFarmer;
  Farm? selectedFarm;
  List<XFile> selectedImages = [];
  bool _isSubmitting = false;

  // Track which fields have been validated
  bool _cropTypeValidated = false;
  bool _farmerValidated = false;
  bool _farmAreaValidated = false;
  bool _yieldAmountValidated = false;

  final GlobalKey cropTypeFieldKey = GlobalKey();
  final GlobalKey farmerFieldKey = GlobalKey();
  final GlobalKey farmAreaFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.onLoadingStateChanged(false);
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (images.isNotEmpty) {
        setState(() {
          selectedImages.addAll(images);
          if (selectedImages.length > 5) {
            selectedImages = selectedImages.sublist(0, 5);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      rethrow;
    }
  }

  Widget _buildImagePreview() {
    if (selectedImages.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attached Images:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.file(
                      File(selectedImages[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        setState(() {
                          selectedImages.removeAt(index);
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsView<T extends Object>(
    BuildContext context,
    AutocompleteOnSelected<T> onSelected,
    Iterable<T> options,
    GlobalKey fieldKey,
    String Function(T) displayString,
  ) {
    final RenderBox? fieldRenderBox =
        fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final double fieldWidth = fieldRenderBox?.size.width ?? 250;

    return SizedBox(
      width: fieldWidth,
      child: Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4.0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: fieldWidth,
              maxHeight: 200,
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final T option = options.elementAt(index);
                return InkWell(
                  onTap: () {
                    onSelected(option);
                  },
                  child: Container(
                    width: fieldWidth,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      displayString(option),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _submitYield() async {
    // Mark all required fields as validated
    setState(() {
      _cropTypeValidated = true;
      _farmerValidated = true;
      _farmAreaValidated = true;
      _yieldAmountValidated = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      widget.onLoadingStateChanged(true);
    });

    try {
      final double yieldAmount =
          double.parse(yieldAmountController.text.trim());
      final double? areaHa = areaHaController.text.trim().isEmpty
          ? null
          : double.tryParse(areaHaController.text.trim());

      widget.onYieldAdded(
        selectedProduct!.id,
        selectedFarmer!.id,
        selectedFarm!.id,
        yieldAmount,
        areaHa,
        selectedDate,
        notesController.text,
        selectedImages,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          widget.onLoadingStateChanged(false);
        });
      }
    }
  }

  @override
  void dispose() {
    yieldAmountController.dispose();
    areaHaController.dispose();
    notesController.dispose();
    farmAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    const double fieldHeight = 56.0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crop Type Autocomplete
            SizedBox(
              height: fieldHeight,
              child: Autocomplete<Product>(
                key: cropTypeFieldKey,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return widget.products;
                  }
                  return widget.products.where((product) => product.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (Product product) {
                  setState(() {
                    selectedProduct = product;
                  });
                },
                displayStringForOption: (product) => product.name,
                optionsViewBuilder: (context, onSelected, options) {
                  return _buildOptionsView<Product>(
                    context,
                    onSelected,
                    options,
                    cropTypeFieldKey,
                    (product) => product.name,
                  );
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Crop Type *',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      errorStyle: const TextStyle(fontSize: 12),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select a crop type';
                      }
                      if (!widget.products.any((p) => p.name == value.trim())) {
                        return 'Please select a valid crop type';
                      }
                      return null;
                    },
                    autovalidateMode: _cropTypeValidated
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                  );
                },
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 16.0),

            // Farmer Autocomplete
            SizedBox(
              height: fieldHeight,
              child: Autocomplete<Farmer>(
                key: farmerFieldKey,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return widget.farmers;
                  }
                  return widget.farmers.where((farmer) => farmer.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (Farmer farmer) {
                  setState(() {
                    selectedFarmer = farmer;
                    selectedFarm = null;
                    farmAreaController.text = '';
                  });
                },
                displayStringForOption: (farmer) => farmer.name,
                optionsViewBuilder: (context, onSelected, options) {
                  return _buildOptionsView<Farmer>(
                    context,
                    onSelected,
                    options,
                    farmerFieldKey,
                    (farmer) => farmer.name,
                  );
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Farmer *',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      errorStyle: const TextStyle(fontSize: 12),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select a farmer';
                      }
                      if (!widget.farmers.any((f) => f.name == value.trim())) {
                        return 'Please select a valid farmer';
                      }
                      return null;
                    },
                    autovalidateMode: _farmerValidated
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                  );
                },
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 16.0),

            // Farm Area Autocomplete
            SizedBox(
              height: fieldHeight,
              child: Autocomplete<Farm>(
                key: farmAreaFieldKey,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (selectedFarmer == null) {
                    return const Iterable<Farm>.empty();
                  }
                  final farmsForFarmer = widget.farms
                      .where((farm) => farm.owner == selectedFarmer!.name);
                  if (textEditingValue.text.isEmpty) {
                    return farmsForFarmer;
                  }
                  return farmsForFarmer.where((farm) => farm.name
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (Farm farm) {
                  setState(() {
                    selectedFarm = farm;
                  });
                },
                displayStringForOption: (farm) => farm.name,
                optionsViewBuilder: (context, onSelected, options) {
                  return _buildOptionsView<Farm>(
                    context,
                    onSelected,
                    options,
                    farmAreaFieldKey,
                    (farm) => farm.name,
                  );
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  farmAreaController = textEditingController;
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Farm Area *',
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      hintText: selectedFarmer == null
                          ? 'Select a farmer first'
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      errorStyle: const TextStyle(fontSize: 12),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                      ),
                    ),
                    readOnly: selectedFarmer == null,
                    validator: (value) {
                      if (selectedFarmer == null) {
                        return 'Please select a farmer first';
                      }
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select a farm area';
                      }
                      if (!widget.farms.any((f) =>
                          f.name == value.trim() &&
                          f.owner == selectedFarmer!.name)) {
                        return 'Please select a valid farm area';
                      }
                      return null;
                    },
                    autovalidateMode: _farmAreaValidated
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                  );
                },
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 16.0),

            // Area (ha) - Optional
            SizedBox(
              height: fieldHeight,
              child: TextFormField(
                controller: areaHaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Area (ha) - Optional',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 16.0),

            // Yield Amount
            SizedBox(
              height: fieldHeight,
              child: TextFormField(
                controller: yieldAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Volume (mt | heads) *',
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  errorStyle: const TextStyle(fontSize: 12),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter yield amount';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
                autovalidateMode: _yieldAmountValidated
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 16.0),

            // Date Picker
            SizedBox(
              height: fieldHeight,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                      controller: TextEditingController(
                        text: "${selectedDate.toLocal()}".split(' ')[0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 16.0),

            // Notes
            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
            ),
            SizedBox(height: isSmallScreen ? 8.0 : 16.0),

            // Image Attachment
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonWidget(
                  btnText: 'Attach Images (Max 5)',
                  onTap: selectedImages.length >= 5 ? null : _pickImages,
                ),
                const SizedBox(height: 8),
                Text(
                  '${selectedImages.length}/5 images selected',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        selectedImages.length >= 5 ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                _buildImagePreview(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddYieldModalFooter extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final bool isLoading;

  const _AddYieldModalFooter({
    Key? key,
    required this.onSubmit,
    required this.onCancel,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 600 ? 10.0 : 20.0,
        vertical: 10.0,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: screenWidth < 600 ? 100 : 120,
              child: ButtonWidget(
                btnText: 'Cancel',
                textColor: FlarelineColors.darkBlackText,
                onTap: isLoading ? null : onCancel,
              ),
            ),
            SizedBox(width: screenWidth < 600 ? 10 : 20),
            SizedBox(
              width: screenWidth < 600 ? 100 : 120,
              child: ButtonWidget(
                btnText: isLoading ? 'Adding...' : 'Add Record',
                onTap: isLoading ? null : onSubmit,
                type: ButtonType.primary.type,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
