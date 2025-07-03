import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';

class YieldProfile extends LayoutWidget {
  const YieldProfile({super.key, required int yieldID});

  @override
  String breakTabTitle(BuildContext context) {
    return "Record Details";
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return CommonCard(
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context),

            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 600;
                  double formWidth = isMobile ? double.infinity : 800;
                  double spacing = isMobile ? 12.0 : 16.0;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: formWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product and Sector Information
                          _buildSectionTitle("Product Information", context,
                              icon: Icons.shopping_bag),
                          _buildResponsiveRow(
                            children: [
                              _buildTextField(
                                "Product Name",
                                "Enter product name",
                                isMobile,
                              ),
                              _buildDropdownField(
                                "Sector",
                                [
                                  "Agriculture",
                                  "Livestock",
                                  "Fishery",
                                  "Forestry"
                                ],
                                isMobile,
                              ),
                            ],
                            spacing: spacing,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: spacing),

                          // Farmer Information
                          _buildSectionTitle("Farmer Information", context,
                              icon: Icons.person),
                          _buildResponsiveRow(
                            children: [
                              _buildTextField(
                                "Farmer Name",
                                "Enter farmer name",
                                isMobile,
                              ),
                              _buildTextField(
                                "Contact Number",
                                "Enter contact number",
                                isMobile,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                            spacing: spacing,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: spacing),

                          // Farm Information
                          _buildSectionTitle("Farm Information", context,
                              icon: Icons.agriculture),
                          _buildResponsiveRow(
                            children: [
                              _buildTextField(
                                "Farm Name",
                                "Enter farm name",
                                isMobile,
                              ),
                              _buildTextField(
                                "Area used (Ha)",
                                "Enter area used",
                                isMobile,
                                keyboardType: TextInputType.number,
                                suffixText: 'ha',
                              ),
                            ],
                            spacing: spacing,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: spacing),
                          _buildResponsiveRow(
                            children: [
                              _buildTextField(
                                "Location",
                                "Enter farm location",
                                isMobile,
                              ),
                              _buildTextField(
                                "Region",
                                "Enter region",
                                isMobile,
                              ),
                            ],
                            spacing: spacing,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: spacing),

                          // Yield Information
                          _buildSectionTitle("Yield Information", context,
                              icon: Icons.assessment),
                          _buildResponsiveRow(
                            children: [
                              _buildTextField(
                                "Yield Amount",
                                '0.00',
                                isMobile,
                                keyboardType: TextInputType.number,
                                suffixText: 'kg',
                              ),
                              _buildDatePickerField(
                                "Harvest Date",
                                isMobile,
                              ),
                            ],
                            spacing: spacing,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: spacing),
                          _buildResponsiveRow(
                            children: [
                              _buildTextField(
                                "Value in (Php)",
                                '0.00',
                                isMobile,
                                keyboardType: TextInputType.number,
                                prefixText: '\₱',
                              ),
                            ],
                            spacing: spacing,
                            isMobile: isMobile,
                          ),
                          SizedBox(height: spacing),

                          // Documentation Section
                          _buildSectionTitle("Documentation", context,
                              icon: Icons.attach_file),
                          // _buildResponsiveRow(
                          //   children: [
                          //     _buildFileUploadSection(
                          //       title: "Upload images",
                          //       description: "Max 5 images",
                          //       fileTypes: "PNG, JPG (max 5MB each)",
                          //       icon: Icons.image,
                          //       isMobile: isMobile,
                          //       flex: isMobile ? null : 2,
                          //     ),
                          //     _buildFileUploadSection(
                          //       title: "Upload documents",
                          //       description: "Supporting documents",
                          //       fileTypes: "PDF, DOC (max 10MB each)",
                          //       icon: Icons.insert_drive_file,
                          //       isMobile: isMobile,
                          //     ),
                          //   ],

                          //   spacing: spacing,
                          //   isMobile: isMobile,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          // ),
                          SizedBox(height: spacing),

                          // Notes Section
                          _buildSectionTitle("Additional Information", context,
                              icon: Icons.note),
                          _buildNotesField(isMobile),
                          SizedBox(height: spacing * 1.5),

                          // Action Buttons
                          _buildActionButtons(isMobile, spacing),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            "Record Details",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context,
      {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow({
    required List<Widget> children,
    required double spacing,
    required bool isMobile,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    int? flex,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        children: children
            .map((child) => Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: child,
                ))
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .map((child) => Expanded(
                flex: flex ?? 1,
                child: Padding(
                  padding: EdgeInsets.only(right: spacing),
                  child: child,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    bool isMobile, {
    TextInputType? keyboardType,
    String? suffixText,
    String? prefixText,
  }) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: 12,
        ),
        prefixText: prefixText,
        suffixText: suffixText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Widget _buildDatePickerField(String label, bool isMobile) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: 'DD/MM/YYYY',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: 12,
        ),
        suffixIcon: Icon(Icons.calendar_today, size: 20),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      readOnly: true,
      onTap: () {
        // Show date picker
      },
    );
  }

  Widget _buildDropdownField(
      String label, List<String> options, bool isMobile) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: isMobile ? 14 : 16,
          horizontal: 12,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      isExpanded: true,
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        // Handle dropdown value change
      },
    );
  }

  // Widget _buildFileUploadSection({
  //   required String title,
  //   required String description,
  //   required String fileTypes,
  //   required IconData icon,
  //   required bool isMobile,
  //   int? flex,
  // }) {
  //   return Expanded(
  //     flex: flex ?? 1,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: TextStyle(
  //             fontSize: isMobile ? 12 : 14,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           description,
  //           style: TextStyle(
  //             fontSize: isMobile ? 10 : 12,
  //             color: Colors.grey.shade600,
  //           ),
  //         ),
  //         const SizedBox(height: 8),
  //         InkWell(
  //           onTap: () {
  //             // Handle file upload
  //           },
  //           borderRadius: BorderRadius.circular(8),
  //           child: Container(
  //             height: isMobile ? 100 : 120,
  //             width: double.infinity,
  //             decoration: BoxDecoration(
  //               border: Border.all(color: Colors.grey.shade300),
  //               borderRadius: BorderRadius.circular(8),
  //               color: Colors.grey.shade50,
  //             ),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Icon(icon,
  //                     size: isMobile ? 32 : 40, color: Colors.grey.shade400),
  //                 const SizedBox(height: 8),
  //                 Text(
  //                   "Tap to upload",
  //                   style: TextStyle(
  //                     color: Colors.grey.shade600,
  //                     fontSize: isMobile ? 12 : 14,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   fileTypes,
  //                   style: TextStyle(
  //                     color: Colors.grey.shade600,
  //                     fontSize: isMobile ? 10 : 12,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildNotesField(bool isMobile) {
    return TextField(
      maxLines: isMobile ? 3 : 5,
      decoration: InputDecoration(
        labelText: "Notes & Comments",
        hintText: "Enter any additional information about the yield...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile, double spacing) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 500),
        child: Row(
          children: [
            if (!isMobile) const Spacer(),
            Expanded(
              flex: isMobile ? 1 : 2,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Handle reject action
                },
                child: Text(
                  "REJECT",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              flex: isMobile ? 1 : 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Handle accept action
                },
                child: Text(
                  "ACCEPT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            ),
            if (!isMobile) const Spacer(),
          ],
        ),
      ),
    );
  }
}
