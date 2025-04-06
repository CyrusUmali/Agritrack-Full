import 'package:flareline/pages/users/add_user_modal.dart';
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
    // Create a farmer object from the data
    int id = int.tryParse(columnData.id ?? '0') ?? 0;
    final user = {
      'Username': 'User $id',
      'UserRole': 'Officer',
      'contact': 'farmer$id@example.com',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            print("Delete icon clicked for User $id");

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
                  viewModel.onFarmerDeleted!(id);
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
                              viewModel.onFarmerDeleted!(id);
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
            print("Arrow icon clicked for user $id");

            if (viewModel.onFarmerSelected != null) {
              viewModel.onFarmerSelected!(user);
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FarmersProfile(farmer: user),
              ),
            );
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
      var item = {
        'id': id.toString(),
        'Username': 'User $id',
        'UserRole': 'UserRole',
        'contact': 'farmer$id@example.com',
      };

      // Create regular cells
      var farmerNameCell = TableDataRowsTableDataRows()
        ..text = item['Username']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Username'
        ..id = item['id'];
      row.add(farmerNameCell);

      var sectorCell = TableDataRowsTableDataRows()
        ..text = item['UserRole']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'UserRole'
        ..id = item['id'];
      row.add(sectorCell);

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
