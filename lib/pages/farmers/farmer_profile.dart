import 'dart:convert';

import 'package:flareline/core/models/assocs_model.dart';
import 'package:flareline/core/models/farmer_model.dart';
import 'package:flareline/pages/assoc/assoc_bloc/assocs_bloc.dart';
import 'package:flareline/pages/farmers/farmer/farmer_bloc.dart';
import 'package:flareline/pages/farmers/farmers_widget/personal_info_card.dart';
import 'package:flareline/pages/test/map_widget/stored_polygons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';
import './farmers_widget/household_info_card.dart';
import './farmers_widget/farm_profile_card.dart';
import 'package:http/http.dart' as http;
import './farmers_widget/emergency_contacts_card.dart';

class FarmersProfile extends LayoutWidget {
  final int farmerID;

  const FarmersProfile({super.key, required this.farmerID});

  @override
  String breakTabTitle(BuildContext context) => 'Farmer Profile';

  Widget _buildContent(BuildContext context, bool isMobile) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FarmerBloc(
            farmerRepository: context.read<FarmerBloc>().farmerRepository,
          )..add(GetFarmerById(farmerID)),
        ),
        BlocProvider(
          create: (context) => AssocsBloc(
            associationRepository:
                context.read<AssocsBloc>().associationRepository,
          )..add(LoadAssocs()),
        ),
      ],
      child: _FarmersProfileContent(isMobile: isMobile),
    );
  }

  @override
  Widget contentDesktopWidget(BuildContext context) =>
      _buildContent(context, false);
  @override
  Widget contentMobileWidget(BuildContext context) =>
      _buildContent(context, true);
}

class _FarmersProfileContent extends StatelessWidget {
  final bool isMobile;

  const _FarmersProfileContent({required this.isMobile});

  void _showToast(BuildContext context,
      {required String message, bool isError = false}) {
    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssocsBloc, AssocsState>(
      builder: (context, assocsState) {
        return BlocConsumer<FarmerBloc, FarmerState>(
          listener: (context, state) {
            if (state is FarmerUpdated) {
              _showToast(context, message: 'Farmer updated successfully');
            } else if (state is FarmersError) {
              _showToast(context, message: state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is FarmerLoaded) {
              return isMobile
                  ? FarmersProfileView(
                      farmer: state.farmer.toJson(),
                      isMobile: true,
                      assocs: assocsState is AssocsLoaded
                          ? assocsState.associations // Explicit cast
                          : <Association>[], // Empty list with proper type
                    )
                  : FarmersProfileView(
                      farmer: state.farmer.toJson(),
                      isMobile: false,
                      assocs: assocsState is AssocsLoaded
                          ? assocsState.associations // Explicit cast
                          : <Association>[], // Em
                    );
            } else if (state is FarmersError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}

abstract class _BaseFarmersProfileState<T extends StatefulWidget>
    extends State<T> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _selectedFarmIndex = 0;
  bool isEditing = false;
  late Map<String, dynamic> editedFarmer;
  late Map<String, dynamic> currentFarmer;
  late List<String> barangayNames;

  @override
  void initState() {
    super.initState();
    final widgetFarmer = (widget as dynamic).farmer;
    currentFarmer = Map.from(widgetFarmer);
    editedFarmer = Map.from(widgetFarmer);
    barangayNames = barangays.map((b) => b['name'] as String).toList();
  }

  Future<String?> uploadImageToCloudinary(XFile file) async {
    const cloudName = 'dk41ykxsq';
    const uploadPreset = 'my_upload_preset';
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..fields['upload_preset'] = uploadPreset;

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
      }
      throw Exception(
          'Upload failed: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> uploadAndUpdateImage(XFile file) async {
    try {
      final imageUrl = await uploadImageToCloudinary(file);
      if (imageUrl != null) {
        setState(() {
          editedFarmer['imageUrl'] = imageUrl;
          currentFarmer['imageUrl'] = imageUrl;
        });
      }
    } catch (e) {
      _showToast('Failed to upload image: ${e.toString()}', isError: true);
    }
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        editedFarmer = Map.from(currentFarmer);
      }
    });
  }

  void saveChanges() {
    if (_formKey.currentState?.validate() != true) {
      _showToast('Please fix all errors in the form', isError: true);
      return;
    }

    final updatedFarmer = Farmer.fromJson(editedFarmer);
    context.read<FarmerBloc>().add(UpdateFarmer(updatedFarmer));
  }

  void handleFieldChange(MapEntry<String, String> entry) {
    final numericFields = [
      'household_num',
      'male_members_num',
      'female_members_num',
    ];

    setState(() {
      if (numericFields.contains(entry.key)) {
        editedFarmer[entry.key] =
            entry.value.isEmpty ? null : int.tryParse(entry.value);
      } else {
        editedFarmer[entry.key] = entry.value;
      }
    });
  }

  void _showToast(String message, {bool isError = false}) {
    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}

class FarmersProfileView extends StatefulWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;
  final List<Association> assocs;

  const FarmersProfileView({
    super.key,
    required this.farmer,
    required this.isMobile,
    required this.assocs, // Add this line
  });

  @override
  State<FarmersProfileView> createState() => _FarmersProfileViewState();
}

class _FarmersProfileViewState
    extends _BaseFarmersProfileState<FarmersProfileView> {
  @override
  Widget build(BuildContext context) {
    final displayFarmer = isEditing ? editedFarmer : currentFarmer;

    return BlocListener<FarmerBloc, FarmerState>(
      listener: (context, state) {
        if (state is FarmerUpdated) {
          setState(() {
            isEditing = false;
            currentFarmer = state.farmer.toJson();
            editedFarmer = Map.from(currentFarmer);
          });
        }
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _ProfileHeader(
                  farmer: displayFarmer,
                  isMobile: widget.isMobile,
                  isEditing: isEditing,
                  onEdit: toggleEdit,
                  onSave: saveChanges,
                  onImageUpload: uploadAndUpdateImage,
                ),
                const SizedBox(height: 24),
                PersonalInfoCard(
                  farmer: displayFarmer,
                  isMobile: widget.isMobile,
                  isEditing: isEditing,
                  onFieldChanged: handleFieldChange,
                  barangayNames: barangayNames,
                  assocs: widget.assocs,
                ),
                const SizedBox(height: 16),
                HouseholdInfoCard(
                  farmer: displayFarmer,
                  isMobile: widget.isMobile,
                  isEditing: isEditing,
                  onFieldChanged: handleFieldChange,
                ),
                const SizedBox(height: 16),
                EmergencyContactsCard(
                  farmer: displayFarmer,
                  isMobile: widget.isMobile,
                  isEditing: isEditing,
                  onFieldChanged: handleFieldChange,
                ),
                const SizedBox(height: 16),
                FarmProfileCard(
                  farmer: displayFarmer,
                  isMobile: widget.isMobile,
                  selectedFarmIndex: _selectedFarmIndex,
                  onFarmSelected: (index) =>
                      setState(() => _selectedFarmIndex = index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final Function(XFile) onImageUpload;

  const _ProfileHeader({
    required this.farmer,
    this.isMobile = false,
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
    required this.onImageUpload,
  });

  Future<void> _pickAndUploadImage(BuildContext context) async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await onImageUpload(pickedFile);
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text('Failed to upload image: ${e.toString()}'),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          SizedBox(
            height: isMobile ? 150 : 200,
            width: double.infinity,
            child: Image.asset(
              'assets/cover/cover-01.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: isMobile ? 40 : 60,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 48 : 72,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    child: ClipOval(
                      child: _buildProfileImage(),
                    ),
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickAndUploadImage(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.edit,
                            size: isMobile ? 16 : 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                farmer['name'] ?? 'Unknown Farmer',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: isEditing
                ? FilledButton.tonal(
                    onPressed: onSave,
                    child: _buildButtonContent(Icons.save, 'Save Profile'),
                  )
                : FilledButton.tonal(
                    onPressed: onEdit,
                    child: _buildButtonContent(Icons.edit, 'Edit Profile'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContent(IconData icon, String text) {
    return isMobile
        ? Icon(icon)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(text),
            ],
          );
  }

  Widget _buildProfileImage() {
    final imageUrl = farmer['imageUrl'];
    final hasValidImage =
        imageUrl != null && imageUrl != '---' && imageUrl.toString().isNotEmpty;

    return hasValidImage
        ? Image.network(
            imageUrl,
            width: isMobile ? 80 : 120,
            height: isMobile ? 80 : 120,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(),
          )
        : _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Icon(
      Icons.person,
      size: isMobile ? 40 : 60,
      color: Colors.grey,
    );
  }
}
