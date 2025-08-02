import 'package:flareline/core/models/assocs_model.dart';
import 'package:flareline/pages/assoc/assoc_bloc/assocs_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class AssociationOverviewPanel extends StatefulWidget {
  final Association association;
  final bool isMobile;

  const AssociationOverviewPanel({
    super.key,
    required this.association,
    this.isMobile = false,
  });

  @override
  State<AssociationOverviewPanel> createState() =>
      _AssociationOverviewPanelState();
}

class _AssociationOverviewPanelState extends State<AssociationOverviewPanel> {
  late TextEditingController _descriptionController;
  late TextEditingController _nameController;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.association.description);
    _nameController = TextEditingController(text: widget.association.name);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset to original values when canceling edit
        _descriptionController.text = widget.association.description ?? '';
        _nameController.text = widget.association.name;
      }
    });
  }

  void _showSuccessToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void _showErrorToast(String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedAssociation = widget.association.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
      );

      try {
        context.read<AssocsBloc>().add(UpdateAssoc(updatedAssociation));
        _showSuccessToast('${widget.association.name} updated successfully!');
        _toggleEditMode();
      } catch (e) {
        _showErrorToast(
            'Failed to update ${widget.association.name}: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment_outlined),
                const SizedBox(width: 12),
                _isEditing
                    ? Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter association name',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      )
                    : Text(
                        '${widget.association.name} Overview',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: _toggleEditMode,
                  tooltip: _isEditing ? 'Cancel' : 'Edit',
                ),
                if (_isEditing) ...[
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _saveChanges,
                    tooltip: 'Save',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _isEditing
                ? _buildEditForm(context)
                : Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.badge_outlined,
                        label: 'Name',
                        value: widget.association.name,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        context,
                        icon: Icons.description_outlined,
                        label: 'Description',
                        value: widget.association.description ??
                            'No description available for this association.',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          Row(
            children: [
              Icon(Icons.badge_outlined,
                  size: 18, color: colors.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'NAME',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter association name...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          // Description Field
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 18, color: colors.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                'DESCRIPTION',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter association description...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
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
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isHighlighted ? colors.primaryContainer : colors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: isHighlighted
                ? Border.all(color: colors.primary.withOpacity(0.2))
                : null,
          ),
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isHighlighted
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
