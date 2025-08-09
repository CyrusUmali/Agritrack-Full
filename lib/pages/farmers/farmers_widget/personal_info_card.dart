import 'package:flareline/core/models/assocs_model.dart';
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
  final List<Association> assocs;

  const PersonalInfoCard({
    super.key,
    required this.farmer,
    this.isMobile = false,
    required this.isEditing,
    required this.onFieldChanged,
    this.formKey,
    required this.barangayNames,
    required this.assocs,
  });

  @override
  State<PersonalInfoCard> createState() => _PersonalInfoCardState();
}

class _PersonalInfoCardState extends State<PersonalInfoCard> {
  late GlobalKey<FormState> _effectiveFormKey;
  final List<String> _sectors = ['Rice', 'Livestock', 'Fishery', 'Corn', 'HVC'];
  List<String> _assocOptions = [];
  String? _initialAssocValue; // To store the initial display value
  String? _selectedAssocValue; // To store the current selected value

  @override
  void initState() {
    super.initState();
    _effectiveFormKey = widget.formKey ?? GlobalKey<FormState>();

print('farmer:');
    print(widget.farmer);

    // Format options with "id: name"
    _assocOptions =
        widget.assocs.map((assoc) => '${assoc.id}: ${assoc.name}').toList();

    // Set initial display value (name only if available)
    if (widget.farmer['association'] != null) {
      _initialAssocValue = widget.farmer['association'];
      _selectedAssocValue =
          '${widget.farmer['associationId']}: ${widget.farmer['association']}';
    } else {
      _initialAssocValue = '---';
      _selectedAssocValue = '---';
    }
  }

  @override
  void didUpdateWidget(covariant PersonalInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assocs != oldWidget.assocs) {
      setState(() {
        _assocOptions =
            widget.assocs.map((assoc) => '${assoc.id}: ${assoc.name}').toList();
      });
    }
  }

  String getValue(String key) {
    final value = widget.farmer[key]?.toString();
    return (value == null || value.isEmpty) ? '---' : value;
  }




Widget _buildComboBoxField({
  required String label,
  required String value,
  required List<String> options,
  required Function(String) onChanged,
  bool isRequired = false,
  double? comboBoxHeight, // Optional height for the ComboBox
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
        selectedValue: value,
        onSelected: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        width: 200,
        height: comboBoxHeight, // Pass the optional height to the ComboBox
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





       Row(
              children: [
                Expanded(
                  child: DetailField(
                          label: 'Email',
                          value: getValue('email'),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: widget.isEditing
                      ? EditableField(
                          label: 'Contact*',
                          value: getValue('phone'),
                          onChanged: (value) {
                            widget.onFieldChanged(MapEntry('phone', value));
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
                          label: 'Contact',
                          value: getValue('phone'),
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
                      ? _buildComboBoxField(comboBoxHeight: 30,
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
                          options: _sectors,comboBoxHeight: 30,
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

            // Add Association field
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: widget.isEditing
                    ? _buildComboBoxField(
                        label: 'Association',
                        comboBoxHeight: 30,
                        value: _selectedAssocValue ?? '---',
                        options: _assocOptions,
                        onChanged: (value) {
                          setState(() {
                            _selectedAssocValue = value;
                          });
                          // Pass the entire formatted string to the parent
                          widget.onFieldChanged(MapEntry('association', value));
                          // Also update associationId if needed
                          if (value != '---') {
                            final id = value.split(':').first.trim();
                            widget
                                .onFieldChanged(MapEntry('associationId', id));
                          }
                        },
                      )
                    : DetailField(
                        label: 'Association',
                        value: _initialAssocValue ?? '---',
                      ),
              ),
              Expanded(
                child: widget.isEditing
                    ? _buildComboBoxField(
                      comboBoxHeight: 30,
                        label: 'Account Status',
                        value: getValue('accountStatus'),
                        options: const [
                          'Active',
                          'Pending',
                          'Inactive',
                        ],
                        onChanged: (value) {
                          widget
                              .onFieldChanged(MapEntry('accountStatus', value));
                        },
                      )
                    : DetailField(
                        label: 'Account Status',
                        value: getValue('accountStatus'),
                      ),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
