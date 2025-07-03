import 'package:flareline/pages/products/profile_widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline/core/models/product_model.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProductHeader extends StatefulWidget {
  final Product item;
  final Function(Product)? onProductUpdated; // Add this callback

  const ProductHeader({
    super.key,
    required this.item,
    this.onProductUpdated, // Add this parameter
  });

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}

class _ProductHeaderState extends State<ProductHeader>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedSector;
  bool _isEditing = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Cloudinary related state
  html.File? _selectedImage;
  String? _newImageUrl;
  bool _isUploading = false;

  // Cloudinary configuration
  static const _cloudName = 'dk41ykxsq';
  static const _uploadPreset = 'my_upload_preset';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController =
        TextEditingController(text: widget.item.description);
    _selectedSector = widget.item.sector;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        // Reset values when canceling edit
        _nameController.text = widget.item.name;
        _descriptionController.text = widget.item.description ?? '';
        _selectedSector = widget.item.sector;
        _newImageUrl = null;
        _isUploading = false;
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });

        final imageUrl = await _uploadImageToCloudinary(pickedFile);

        setState(() {
          _newImageUrl = imageUrl;
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() => _isUploading = false);
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text('Image upload failed: ${e.toString()}'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  Future<String?> _uploadImageToCloudinary(XFile file) async {
    final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = _uploadPreset;

      if (kIsWeb) {
        final fileBytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: file.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
        ));
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 && jsonResponse['secure_url'] != null) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception(
            'Upload failed: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  void _submitChanges() {
    if (_nameController.text.trim().isEmpty) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text('Product name cannot be empty'),
        description: const Text('Please enter a valid product name'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
        showProgressBar: true,
      );
      return;
    }

    if (_isUploading) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: const Text('Please wait for image to upload'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 4),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create the updated product object
    final updatedProduct = Product(
      id: widget.item.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      sector: _selectedSector,
      imageUrl: _newImageUrl ?? widget.item.imageUrl,
      // Include any other fields from the original product
      // ...widget.item.toJson(),
    );

    context.read<ProductBloc>().add(
          EditProduct(
            id: widget.item.id!,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedSector,
            imageUrl: _newImageUrl ?? widget.item.imageUrl,
          ),
        );

    // Call the callback if it exists
    if (widget.onProductUpdated != null) {
      widget.onProductUpdated!(updatedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductsLoaded && state.message != null) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message!),
            // description: const Text('Product updated successfully'),
            alignment: Alignment.topRight,
            autoCloseDuration: const Duration(seconds: 4),
            showProgressBar: true,
          );
          setState(() {
            _isEditing = false;
            _isLoading = false;
            _newImageUrl = null;
          });
          _animationController.reverse();
        } else if (state is ProductsError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            // description: const Text('Failed to update product'),
            alignment: Alignment.topRight,
            autoCloseDuration: const Duration(seconds: 4),
            showProgressBar: true,
          );
          setState(() => _isLoading = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CommonCard(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceVariant.withOpacity(0.3),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, colorScheme),
                  const SizedBox(height: 24),
                  _buildContent(theme, colorScheme),
                  const SizedBox(height: 24),
                  _buildEditControls(colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Text(
                'Product Details',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (_isEditing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  'Edit Mode',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        if (isTablet) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(theme, colorScheme),
              const SizedBox(width: 32),
              Expanded(
                child: _buildProductInfo(theme, colorScheme),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildProductImage(theme, colorScheme),
              const SizedBox(height: 24),
              _buildProductInfo(theme, colorScheme),
            ],
          );
        }
      },
    );
  }

  Widget _buildProductImage(ThemeData theme, ColorScheme colorScheme) {
    return Hero(
      tag: 'product_image_${widget.item.id}',
      child: GestureDetector(
        onTap: _isEditing ? _pickAndUploadImage : null,
        child: Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surfaceVariant,
                colorScheme.surfaceVariant.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                if (_isUploading)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  )
                else
                  FadeInImage(
                    placeholder: const AssetImage('assets/placeholder.png'),
                    image: NetworkImage(_newImageUrl ??
                        widget.item.imageUrl ??
                        'https://static.toiimg.com/photo/67882583.cms'),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.errorContainer,
                            colorScheme.errorContainer.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: colorScheme.onErrorContainer,
                        size: 32,
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change image',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
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
      ),
    );
  }

  Widget _buildProductInfo(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !_isEditing
              ? _buildDisplayName(theme, colorScheme)
              : _buildEditName(theme, colorScheme),
        ),
        const SizedBox(height: 16),

        // Product Description
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !_isEditing
              ? _buildDisplayDescription(theme, colorScheme)
              : _buildEditDescription(theme, colorScheme),
        ),
        const SizedBox(height: 20),

        // Sector Information
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: !_isEditing
              ? _buildDisplaySector(theme, colorScheme)
              : _buildEditSector(theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildDisplayName(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('display_name'),
      child: Text(
        widget.item.name,
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildEditName(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('edit_name'),
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: 'Product Name',
          prefixIcon: Icon(Icons.label_outline, color: colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDisplayDescription(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('display_description'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.description_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.item.description?.isNotEmpty == true
                  ? widget.item.description!
                  : 'No description available',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: widget.item.description?.isNotEmpty == true
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDescription(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('edit_description'),
      child: TextFormField(
        controller: _descriptionController,
        decoration: InputDecoration(
          labelText: 'Description',
          prefixIcon:
              Icon(Icons.description_outlined, color: colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        maxLines: 4,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildDisplaySector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('display_sector'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sector',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.secondaryContainer,
                  colorScheme.secondaryContainer.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getSectorIcon(widget.item.sector),
                  color: colorScheme.onSecondaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.item.sector,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditSector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      key: const ValueKey('edit_sector'),
      child: DropdownButtonFormField<String>(
        value: _selectedSector,
        decoration: InputDecoration(
          labelText: 'Sector',
          prefixIcon: Icon(Icons.category_outlined, color: colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: [
          _buildDropdownItem('Rice', Icons.rice_bowl_outlined),
          _buildDropdownItem('Corn', Icons.agriculture_outlined),
          _buildDropdownItem('HVC', Icons.local_florist_outlined),
          _buildDropdownItem('Livestock', Icons.pets_outlined),
          _buildDropdownItem('Fishery', Icons.set_meal_outlined),
          _buildDropdownItem('Organic', Icons.eco_outlined),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedSector = value);
          }
        },
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, IconData icon) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }

  IconData _getSectorIcon(String sector) {
    switch (sector) {
      case 'Rice':
        return Icons.rice_bowl_outlined;
      case 'Corn':
        return Icons.agriculture_outlined;
      case 'HVC':
        return Icons.local_florist_outlined;
      case 'Livestock':
        return Icons.pets_outlined;
      case 'Fishery':
        return Icons.set_meal_outlined;
      case 'Organic':
        return Icons.eco_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildEditControls(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_isEditing) ...[
            TextButton.icon(
              onPressed: _isLoading ? null : _toggleEditing,
              icon: const Icon(Icons.close_outlined),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
          ],
          FilledButton.icon(
            onPressed: _isLoading
                ? null
                : _isEditing
                    ? _submitChanges
                    : _toggleEditing,
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined),
            label: Text(_isEditing
                ? _isLoading
                    ? 'Saving...'
                    : 'Save Changes'
                : 'Edit Product'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
