import 'package:flareline/pages/widget/combo_box.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import './section_header.dart';
import './detail_field.dart';
import './editable_field.dart';

class PersonalInfoCard extends StatefulWidget {
  final Map<String, dynamic> farmer;
  final bool isMobile;
  final bool isEditing;
  final ValueChanged<MapEntry<String, String>> onFieldChanged;
  final GlobalKey<FormState>? formKey;
  final List<String> barangayNames;

  const PersonalInfoCard({
    super.key,
    required this.farmer,
    this.isMobile = false,
    required this.isEditing,
    required this.onFieldChanged,
    this.formKey,
    required this.barangayNames,
  });

  @override
  State<PersonalInfoCard> createState() => _PersonalInfoCardState();
}

class _PersonalInfoCardState extends State<PersonalInfoCard> {
  late GlobalKey<FormState> _effectiveFormKey;
  final List<String> _sectors = ['Rice', 'Livestock', 'Fishery', 'Corn', 'HVC'];

  @override
  void initState() {
    super.initState();
    _effectiveFormKey = widget.formKey ?? GlobalKey<FormState>();
  }

  String getValue(String key) {
    final value = widget.farmer[key]?.toString();
    return (value == null || value.isEmpty) ? 'N/A' : value;
  }

  Widget _buildComboBoxField({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? '*' : ''}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        buildComboBox(
          context: context,
          hint: 'Select $label',
          options: options,
          selectedValue: value ?? 'Not Specified',

          onSelected: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          width: 200, // Takes full available width
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      child: Form(
        key: _effectiveFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
                title: 'Personal Information', icon: Icons.person),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: widget.isEditing
                      ? EditableField(
                          label: 'Surname*',
                          value: getValue('surname'),
                          onChanged: (value) {
                            widget.onFieldChanged(MapEntry('surname', value));
                            // Trigger validation after change
                            _effectiveFormKey.currentState?.validate();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Surname is required';
                            }
                            if (value.length > 50) {
                              return 'Maximum 50 characters allowed';
                            }
                            return null;
                          },
                        )
                      : DetailField(
                          label: 'Surname',
                          value: getValue('surname'),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: widget.isEditing
                      ? EditableField(
                          label: 'First Name*',
                          value: getValue('firstname'),
                          onChanged: (value) {
                            widget.onFieldChanged(MapEntry('firstname', value));
                            // Trigger validation after change
                            _effectiveFormKey.currentState?.validate();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'First name is required';
                            }
                            if (value.length > 50) {
                              return 'Maximum 50 characters allowed';
                            }
                            return null;
                          },
                        )
                      : DetailField(
                          label: 'First Name',
                          value: getValue('firstname'),
                        ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Middle Name, Extension, Gender
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: widget.isEditing
                      ? EditableField(
                          label: 'Middle Name',
                          value: getValue('middlename'),
                          onChanged: (value) {
                            widget
                                .onFieldChanged(MapEntry('middlename', value));
                            // Trigger validation after change
                            _effectiveFormKey.currentState?.validate();
                          },
                          validator: (value) {
                            if (value != null && value.length > 50) {
                              return 'Maximum 50 characters allowed';
                            }
                            return null;
                          },
                        )
                      : DetailField(
                          label: 'Middle Name',
                          value: getValue('middlename'),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: widget.isEditing
                      ? EditableField(
                          label: 'Extension',
                          value: getValue('extension'),
                          onChanged: (value) {
                            widget.onFieldChanged(MapEntry('extension', value));
                            // Trigger validation after change
                            _effectiveFormKey.currentState?.validate();
                          },
                        )
                      : DetailField(
                          label: 'Extension',
                          value: getValue('extension'),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: widget.isEditing
                      ? EditableField(
                          label: 'Sex*',
                          value: getValue('sex'),
                          onChanged: (value) {
                            widget.onFieldChanged(MapEntry('sex', value));
                            // Trigger validation after change
                            _effectiveFormKey.currentState?.validate();
                          },
                        )
                      : DetailField(
                          label: 'Sex',
                          value: getValue('sex'),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: widget.isEditing
                      ? _buildComboBoxField(
                          label: 'Barangay',
                          value: getValue('barangay'),
                          options: widget.barangayNames,
                          onChanged: (value) {
                            widget.onFieldChanged(MapEntry('barangay', value));
                          },
                          isRequired: true,
                        )
                      : DetailField(
                          label: 'Barangay',
                          value: getValue('barangay'),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: widget.isEditing
                      ? _buildComboBoxField(
                          label: 'Sector',
                          value: getValue('sector'),
                          options: _sectors,
                          onChanged: (value) {
                            widget.onFieldChanged(MapEntry('sector', value));
                          },
                          isRequired: true,
                        )
                      : DetailField(
                          label: 'Sector',
                          value: getValue('sector'),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
