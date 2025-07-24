import 'package:flareline/core/models/user_model.dart';
import 'package:flareline/pages/toast/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../user_bloc/user_bloc.dart';

class UserInfoCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isMobile;

  const UserInfoCard({super.key, required this.user, this.isMobile = false});

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name'] ?? '');
    _contactController =
        TextEditingController(text: widget.user['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset controllers when exiting edit mode
        _nameController.text = widget.user['name'] ?? '';
        _contactController.text = widget.user['phone'] ?? '';
      }
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Get the current user data
      final updatedUser = Map<String, dynamic>.from(widget.user);

      // Update with new values
      updatedUser['name'] = _nameController.text;
      updatedUser['phone'] = _contactController.text;

      print(updatedUser);

      // Dispatch the UpdateUser event
      context.read<UserBloc>().add(UpdateUser(
            UserModel.fromJson(updatedUser),
          ));

      _toggleEdit();
    }
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required Widget value,
    IconData? icon,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: colors.onSurface.withOpacity(0.6)),
                const SizedBox(width: 8),
              ],
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? colors.primaryContainer
                  : colors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: isHighlighted
                  ? Border.all(color: colors.primary.withOpacity(0.2))
                  : null,
            ),
            child: value,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return _buildInfoRow(
      context,
      label: label,
      icon: icon,
      value: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
        validator: validator,
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return _buildInfoRow(
      context,
      label: label,
      icon: icon,
      value: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isCurrentUser = userProvider.user?.id == widget.user['id'];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UsersError) {
            ToastHelper.showErrorToast(
              state.message,
              context,
            );
          } else if (state is UserUpdated) {
            ToastHelper.showSuccessToast(
                'Profile updated successfully', context);
          }
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, color: colors.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Personal Information',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (isCurrentUser)
                        IconButton(
                          icon: Icon(_isEditing ? Icons.close : Icons.edit),
                          onPressed: _toggleEdit,
                          tooltip: _isEditing ? 'Cancel' : 'Edit',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing) ...[
                    _buildEditableField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    _buildReadOnlyField(
                      label: 'Email',
                      value: widget.user['email'] ?? 'N/A',
                      icon: Icons.email_outlined,
                    ),
                    _buildEditableField(
                      label: 'Contact Number',
                      controller: _contactController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saveChanges,
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ] else ...[
                    _buildReadOnlyField(
                      label: 'Full Name',
                      value: widget.user['name'] ?? 'N/A',
                      icon: Icons.person_outline,
                    ),
                    _buildReadOnlyField(
                      label: 'Email',
                      value: widget.user['email'] ?? 'N/A',
                      icon: Icons.email_outlined,
                    ),
                    _buildReadOnlyField(
                      label: 'Contact Number',
                      value: widget.user['phone'] ?? 'N/A',
                      icon: Icons.phone_outlined,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ));
  }
}
