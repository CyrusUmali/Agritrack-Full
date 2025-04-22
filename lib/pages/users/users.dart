import 'dart:math';

import 'package:flareline/pages/users/add_user_modal.dart';
import 'package:flareline/pages/users/da_personel_profile.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/pages/farmers/farmer_profile.dart'; // Import the new widget
import 'package:flareline_uikit/components/buttons/button_widget.dart'; // Import the ButtonWidget
import 'package:flareline_uikit/core/theme/flareline_colors.dart'; // Import FlarelineColors

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => UsersState();
}

class UsersState extends State<Users> {
  Map<String, dynamic>? selectedFarmer;

  @override
  Widget build(BuildContext context) {
    return _channels();
  }

  _channels() {
    return ScreenTypeLayout.builder(
      desktop: _channelsWeb,
      mobile: _channelMobile,
      tablet: _channelMobile,
    );
  }

  Widget _channelsWeb(BuildContext context) {
    return SizedBox(
      height: 450,
      child: Column(
        children: [
          _buildSearchBar(), // Add the search bar here
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DataTableWidget(
                    onFarmerSelected: (farmer) {
                      setState(() {
                        selectedFarmer = farmer;
                      });
                    },
                  ),
                ),
                // const SizedBox(width: 16),
                // Expanded(
                //   flex: 1,
                //   child: FarmerDetailWidget(farmer: selectedFarmer),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelMobile(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(), // Add the search bar here
        const SizedBox(height: 16),
        SizedBox(
          height: 500,
          child: DataTableWidget(
            onFarmerSelected: (farmer) {
              setState(() {
                selectedFarmer = farmer;
              });
            },
          ),
        ),
      ],
    );
  }

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search Users...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              // Example data for the farmer
              String farmerName = "John Doe";
              String farmerId = "123";

              AddUserModal.show(
                context: context,
                onUserAdded:
                    (String name, String email, String password, String role) {
                  // Handle the new user data here
                  print('New User Added:');
                  print('Name: $name');
                  print('Email: $email');
                  print('Password: $password');
                  print('Role: $role');

                  // You can call your ViewModel or API here to save the user
                },
              );
            },
            child: const Text("Add User"),
          ),
        ],
      ),
    );
  }
}

class DataTableWidget extends TableWidget<FarmersViewModel> {
  final Function(Map<String, dynamic>)? onFarmerSelected;

  DataTableWidget({this.onFarmerSelected, Key? key}) : super(key: key) {
    print("DataTableWidget initialized");
  }

  @override
  FarmersViewModel viewModelBuilder(BuildContext context) {
    return FarmersViewModel(
      context,
      onFarmerSelected,
      (id) {
        print("Deleted User ID: $id");
        // Add logic to remove the farmer from the list or show a confirmation dialog
      },
    );
  }

  @override
  Widget actionWidgetsBuilder(BuildContext context,
      TableDataRowsTableDataRows columnData, FarmersViewModel viewModel) {
    // Get all the row data from the current table row
    final rowData = viewModel.tableDataEntity?.rows
        ?.firstWhere((row) => row.any((cell) => cell.id == columnData.id));

    // Extract the actual values from the table row
    final username = rowData
            ?.firstWhere((cell) => cell.columnName == 'Username',
                orElse: () => TableDataRowsTableDataRows()..text = '')
            ?.text ??
        '';

    final userRole = rowData
            ?.firstWhere((cell) => cell.columnName == 'UserRole',
                orElse: () => TableDataRowsTableDataRows()..text = '')
            ?.text ??
        '';

    final contact = rowData
            ?.firstWhere((cell) => cell.columnName == 'Contact',
                orElse: () => TableDataRowsTableDataRows()..text = '')
            ?.text ??
        '';

    // Create user object from the actual table data
    final user = {
      'id': columnData.id,
      'Username': username,
      'UserRole': userRole,
      'contact': contact,
    };

    // Parse the ID for use in delete operations
    final userId = int.tryParse(columnData.id ?? '0') ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            print("Delete icon clicked for User ${user['id']}");

            ModalDialog.show(
              context: context,
              title: 'Delete User',
              showTitle: true,
              showTitleDivider: true,
              modalType: ModalType.medium,
              onCancelTap: () {
                Navigator.of(context).pop(); // Close the modal
              },
              onSaveTap: () {
                // Perform the delete operation here
                if (viewModel.onFarmerDeleted != null) {
                  viewModel.onFarmerDeleted!(userId);
                }
                Navigator.of(context).pop(); // Close the modal
              },
              child: Center(
                child: Text(
                  'Are you sure you want to delete ${user['Username']}?',
                  textAlign: TextAlign.center,
                ),
              ),
              footer: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Cancel',
                          textColor: FlarelineColors.darkBlackText,
                          onTap: () {
                            Navigator.of(context).pop(); // Close the modal
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        child: ButtonWidget(
                          btnText: 'Delete',
                          onTap: () {
                            // Perform the delete operation here
                            if (viewModel.onFarmerDeleted != null) {
                              viewModel.onFarmerDeleted!(userId);
                            }
                            Navigator.of(context).pop(); // Close the modal
                          },
                          type: ButtonType.primary.type,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            print(
                "Navigating to profile for ${user['Username']} with role ${user['UserRole']}");

            if (viewModel.onFarmerSelected != null) {
              viewModel.onFarmerSelected!(user);
            }

            final role = (user['UserRole'] ?? '').toLowerCase();

            if (role.contains('officer') || role.contains('admin')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DAOfficerProfile(daUser: user),
                ),
              );
            } else if (role.contains('farmer')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmersProfile(farmer: user),
                ),
              );
            } else {
              // Default to officer profile if role not recognized
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DAOfficerProfile(daUser: user),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: _buildDesktopTable,
      mobile: _buildMobileTable,
      tablet: _buildMobileTable,
    );
  }

  Widget _buildDesktopTable(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 1000, // Set minimum width for desktop
        maxWidth: 1200, // Set maximum width for desktop
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1200, // Fixed width for desktop
          child: super.build(context),
        ),
      ),
    );
  }

  Widget _buildMobileTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width, // Full width on mobile
        ),
        child: SizedBox(
          width: 600, // Wider than mobile screen to enable scrolling
          child: super.build(context),
        ),
      ),
    );
  }
}

// Helper function to get weighted random role
String _getWeightedRandomRole(List<Map<String, dynamic>> roles) {
  // Calculate total weight
  int totalWeight = roles.fold(0, (sum, role) => sum + (role['weight'] as int));

  // Generate random number
  int random = Random().nextInt(totalWeight);
  int cumulativeWeight = 0;

  for (var role in roles) {
    cumulativeWeight += role['weight'] as int;
    if (random < cumulativeWeight) {
      return role['role'] as String;
    }
  }

  return 'Farmer'; // fallback
}

class FarmersViewModel extends BaseTableProvider {
  final Function(Map<String, dynamic>)? onFarmerSelected;
  final Function(int)? onFarmerDeleted; // Add this line

  @override
  String get TAG => 'FarmersViewModel';

  FarmersViewModel(super.context, this.onFarmerSelected,
      this.onFarmerDeleted); // Modify constructor

  @override
  Future loadData(BuildContext context) async {
    const headers = ["Username", "UserRole", "Contact", "Action"];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (int i = 0; i < 50; i++) {
      List<TableDataRowsTableDataRows> row = [];
      var id = i;

      // List of possible roles with weights for randomization
      final roles = [
        {'role': 'Admin', 'weight': 1},
        {'role': 'DA Officer', 'weight': 3},
        {'role': 'Farmer', 'weight': 10},
      ];

      // Generate weighted random role
      String randomRole = _getWeightedRandomRole(roles);

      var item = {
        'id': id.toString(),
        'Username': 'User $id',
        'UserRole': randomRole,
        'contact': 'user$id@example.com',
      };

      // Create regular cells
      var userNameCell = TableDataRowsTableDataRows()
        ..text = item['Username']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Username'
        ..id = item['id'];
      row.add(userNameCell);

      var roleCell = TableDataRowsTableDataRows()
        ..text = item['UserRole']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'UserRole'
        ..id = item['id'];
      row.add(roleCell);

      var contactCell = TableDataRowsTableDataRows()
        ..text = item['contact']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Contact'
        ..id = item['id'];
      row.add(contactCell);

      // Add action cell for the icon button
      var actionCell = TableDataRowsTableDataRows()
        ..text = ""
        ..dataType = CellDataType.ACTION.type
        ..columnName = 'Action'
        ..id = item['id'];
      row.add(actionCell);

      rows.add(row);
    }

    TableDataEntity tableData = TableDataEntity()
      ..headers = headers
      ..rows = rows;

    tableDataEntity = tableData;
  }
}
