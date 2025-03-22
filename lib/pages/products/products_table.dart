import 'package:flareline/pages/products/add_product_modal.dart';
import 'package:flareline/pages/products/product_profile.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:flutter/material.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ProductsTable extends StatefulWidget {
  const ProductsTable({super.key});

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  Map<String, dynamic>? selectedProduct;
  String searchQuery = ''; // To store the search query
  String selectedType = "All"; // To store the selected filter type

  @override
  Widget build(BuildContext context) {
    return _products();
  }

  _products() {
    return ScreenTypeLayout.builder(
      desktop: _productsWeb,
      mobile: _productsMobile,
      tablet: _productsMobile,
    );
  }

  Widget _productsWeb(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Column(
        children: [
          // Add the ProductFilterWidget here
          ProductFilterWidget(
            onSearchChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
            onFilterChanged: (type) {
              setState(() {
                selectedType = type;
              });
            },
            onAddProductPressed: () {
              // Handle Add Product functionality
              print("Add Product button pressed");

              AddProductModal.show(
                context: context,
                onProductAdded: (
                  String name,
                  String description,
                  String category,
                ) {
                  // You can call your ViewModel or API here to save the user
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DataTableWidget(
                    searchQuery: searchQuery,
                    filterType: selectedType,
                    onProductSelected: (product) {
                      setState(() {
                        selectedProduct = product;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productsMobile(BuildContext context) {
    return Column(
      children: [
        // Add the ProductFilterWidget here
        ProductFilterWidget(
          onSearchChanged: (query) {
            setState(() {
              searchQuery = query;
            });
          },
          onFilterChanged: (type) {
            setState(() {
              selectedType = type;
            });
          },
          onAddProductPressed: () {
            // Handle Add Product functionality
            print("Add Product button pressed");
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 380,
          child: DataTableWidget(
            searchQuery: searchQuery,
            filterType: selectedType,
            onProductSelected: (product) {
              setState(() {
                selectedProduct = product;
              });
            },
          ),
        ),
      ],
    );
  }
}

class DataTableWidget extends TableWidget<ProductsViewModel> {
  final String searchQuery;
  final String filterType;
  final Function(Map<String, dynamic>)? onProductSelected;

  DataTableWidget({
    required this.searchQuery,
    required this.filterType,
    this.onProductSelected,
    Key? key,
  }) : super(key: key);

  @override
  ProductsViewModel viewModelBuilder(BuildContext context) {
    return ProductsViewModel(
      context,
      onProductSelected,
      (id) {
        print("Deleted Product ID: $id");
      },
      searchQuery: searchQuery,
      filterType: filterType,
    );
  }

  @override
  Widget actionWidgetsBuilder(BuildContext context,
      TableDataRowsTableDataRows columnData, ProductsViewModel viewModel) {
    // Create a product object from the data
    int id = int.tryParse(columnData.id ?? '0') ?? 0;
    final product = {
      'productName': 'Product $id',
      'type': 'Type $id',
      'description': 'Description for Product $id',
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            print("Delete icon clicked for Product $id");

            ModalDialog.show(
                context: context,
                title: 'Delete Product',
                showTitle: true,
                showTitleDivider: true,
                modalType: ModalType.medium,
                onCancelTap: () {
                  Navigator.of(context).pop(); // Close the modal
                },
                onSaveTap: () {
                  // Perform the delete operation here
                  if (viewModel.onProductDeleted != null) {
                    viewModel.onProductDeleted!(id);
                  }
                  Navigator.of(context).pop(); // Close the modal
                },
                child: Center(
                  child: Text(
                    'Are you sure you want to delete ${product['productName']}?',
                    textAlign:
                        TextAlign.center, // Optional: Center-align the text
                  ),
                ),
                footer: Padding(
                  // Add padding to the footer
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0), // Adjust padding as needed
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ensure the Row takes only the space it needs
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
                              if (viewModel.onProductDeleted != null) {
                                viewModel.onProductDeleted!(id);
                              }
                              Navigator.of(context).pop(); // Close the modal
                            },
                            type: ButtonType.primary.type,
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            print("Arrow icon clicked for Product $id");

            if (viewModel.onProductSelected != null) {
              viewModel.onProductSelected!(product);
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductProfile(product: product),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
            ),
            child: SizedBox(
              width: 1200,
              child: super.build(context),
            ),
          ),
        );
      },
    );
  }
}

class ProductsViewModel extends BaseTableProvider {
  final Function(Map<String, dynamic>)? onProductSelected;
  final Function(int)? onProductDeleted;
  final String searchQuery;
  final String filterType;

  ProductsViewModel(
    super.context,
    this.onProductSelected,
    this.onProductDeleted, {
    required this.searchQuery,
    required this.filterType,
  });

  @override
  Future loadData(BuildContext context) async {
    const headers = ["Product Name", "Type", "Description", "Action"];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (int i = 0; i < 50; i++) {
      var id = i;
      var item = {
        'id': id.toString(),
        'productName': 'Product $id',
        'type': 'Type $id',
        'description': 'Description for Product $id',
      };

      // Apply search and filter logic
      if (searchQuery.isNotEmpty &&
          !item['productName']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        continue; // Skip if the product name doesn't match the search query
      }

      if (filterType != "All" && item['type'] != filterType) {
        continue; // Skip if the product type doesn't match the filter
      }

      // Add the product to the rows
      List<TableDataRowsTableDataRows> row = [];
      // ... (add cells to the row as before)
// Create regular cells
      var productNameCell = TableDataRowsTableDataRows()
        ..text = item['productName']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Product Name'
        ..id = item['id'];
      row.add(productNameCell);

      var typeCell = TableDataRowsTableDataRows()
        ..text = item['type']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Type'
        ..id = item['id'];
      row.add(typeCell);

      var descriptionCell = TableDataRowsTableDataRows()
        ..text = item['description']
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Description'
        ..id = item['id'];
      row.add(descriptionCell);

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

class ProductFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String) onFilterChanged;
  final VoidCallback onAddProductPressed;

  const ProductFilterWidget({
    super.key,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onAddProductPressed,
  });

  @override
  State<ProductFilterWidget> createState() => _ProductFilterWidgetState();
}

class _ProductFilterWidgetState extends State<ProductFilterWidget> {
  String selectedType = "All"; // Default filter option

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          onChanged: (value) {
            widget
                .onSearchChanged(value); // Notify parent of search query change
          },
        ),
        const SizedBox(height: 10), // Spacing between search and filter

        // Filter Dropdown and Add Button in a Row
        Row(
          children: [
            // Filter Dropdown
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Filter',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                items: [
                  "All",
                  "Rice",
                  "Livestock",
                  "Fishery",
                  "Corn",
                  "High Value Crop",
                  "Organic",
                  "Etc"
                ]
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                  widget.onFilterChanged(
                      value!); // Notify parent of filter change
                },
              ),
            ),
            const SizedBox(width: 10), // Spacing between filter and add button

            // Add Product Button
            ElevatedButton.icon(
              onPressed: widget.onAddProductPressed,
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
            ),
          ],
        ),
      ],
    );
  }
}
