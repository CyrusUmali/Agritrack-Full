import 'package:flareline/core/models/product_model.dart';
import 'package:flareline/pages/products/product/product_filter_widget.dart';
import 'package:flareline/pages/widget/network_error.dart';
import 'package:flareline/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flareline/pages/products/product/product_bloc.dart';
import 'package:flareline/pages/products/product_profile.dart';
import 'package:flareline_uikit/components/buttons/button_widget.dart';
import 'package:flareline_uikit/components/modal/modal_dialog.dart';
import 'package:flareline_uikit/components/tables/table_widget.dart';
import 'package:flareline_uikit/entity/table_data_entity.dart';
import 'package:flareline_uikit/core/theme/flareline_colors.dart';
import 'package:toastification/toastification.dart';

class ProductsTable extends StatelessWidget {
  const ProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      desktop: (context) => _productsWeb(context),
      mobile: (context) => _productsMobile(context),
      tablet: (context) => _productsMobile(context),
    );
  }

  Widget _productsWeb(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (previous, current) {
        print(
            'State change: ${previous.runtimeType} -> ${current.runtimeType}');
        print('Equal: ${previous == current}');
        return current is ProductsLoaded || current is ProductsError;
      },
      listener: (context, state) {
        print('Received state: ${state.runtimeType}');
        if (state is ProductsLoaded && state.message != null) {
          print('Message received: ${state.message}');
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message!),
            alignment: Alignment.topRight,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (state is ProductsError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            alignment: Alignment.topRight,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      child: SizedBox(
        height: 600,
        child: Column(
          children: [
            const ProductFilterWidget(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductsError) {
                    // return Center(child: Text(state.message));

                    return NetworkErrorWidget(
                      error: state.message,
                      onRetry: () {
                        // Trigger your retry logic here
                        context.read<ProductBloc>().add(LoadProducts());
                      },
                    );
                  } else if (state is ProductsLoaded) {
                    if (state.products.isEmpty) {
                      return _buildNoResultsWidget();
                    }
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DataTableWidget(
                            key: ValueKey(
                                'products_table_${state.products.length}'),
                            products: state.products,
                          ),
                        ),
                      ],
                    );
                  }
                  return _buildNoResultsWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productsMobile(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductsLoaded && state.message != null) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message!),
            alignment: Alignment.topRight,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );
        } else if (state is ProductsError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            alignment: Alignment.topRight,
            showProgressBar: false,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      child: Column(
        children: [
          const ProductFilterWidget(),
          const SizedBox(height: 16),
          SizedBox(
            height: 700,
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductsError) {
                  // return Center(child: Text(state.message));

                  return NetworkErrorWidget(
                    error: state.message,
                    onRetry: () {
                      // Trigger your retry logic here
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                  );
                } else if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return _buildNoResultsWidget();
                  }
                  return DataTableWidget(
                    key: ValueKey('products_table_${state.products.length}'),
                    products: state.products,
                  );
                }
                return _buildNoResultsWidget();
              },
            ),
          ),
        ],
      ),
    );
  }

// Add this new helper widget
  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.disabled_by_default,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class DataTableWidget extends TableWidget<ProductsViewModel> {
  final List<Product> products;

  DataTableWidget({
    required this.products,
    Key? key,
  }) : super(key: key);

  @override
  ProductsViewModel viewModelBuilder(BuildContext context) {
    return ProductsViewModel(context, products);
  }

  @override
  Widget headerBuilder(
      BuildContext context, String headerName, ProductsViewModel viewModel) {
    if (headerName == 'Action') {
      return Text(headerName);
    }

    return InkWell(
      onTap: () {
        context.read<ProductBloc>().add(SortProducts(headerName));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              headerName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductsLoaded) {
                final bloc = context.read<ProductBloc>();
                return Icon(
                  bloc.sortColumn == headerName
                      ? (bloc.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: bloc.sortColumn == headerName
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                );
              }
              return const Icon(Icons.unfold_more,
                  size: 16, color: Colors.grey);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget actionWidgetsBuilder(
    BuildContext context,
    TableDataRowsTableDataRows columnData,
    ProductsViewModel viewModel,
  ) {
    final product = viewModel.products.firstWhere(
      (p) => p.id.toString() == columnData.id,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFarmer = userProvider.isFarmer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isFarmer)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              ModalDialog.show(
                context: context,
                title: 'Delete Product',
                showTitle: true,
                showTitleDivider: true,
                modalType: ModalType.medium,
                onCancelTap: () => Navigator.of(context).pop(),
                onSaveTap: () {
                  context.read<ProductBloc>().add(DeleteProduct(product.id));
                  Navigator.of(context).pop();
                },
                child: Center(
                  child: Text(
                    'Are you sure you want to delete ${product.name}?',
                    textAlign: TextAlign.center,
                  ),
                ),
                footer: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          child: ButtonWidget(
                            btnText: 'Cancel',
                            textColor: FlarelineColors.darkBlackText,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 120,
                          child: ButtonWidget(
                            btnText: 'Delete',
                            onTap: () {
                              context
                                  .read<ProductBloc>()
                                  .add(DeleteProduct(product.id));
                              Navigator.of(context).pop();
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductProfile(
                    product: product), // Lowercase 'p' in parameter
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
      desktop: (context) => _buildDesktopTable(),
      mobile: (context) => _buildMobileTable(context),
      tablet: (context) => _buildMobileTable(context),
    );
  }

  Widget _buildDesktopTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double tableWidth = constraints.maxWidth > 1200
            ? 1200
            : constraints.maxWidth > 800
                ? constraints.maxWidth * 0.9
                : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: SizedBox(
              width: tableWidth,
              child: super.build(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 800,
        child: super.build(context),
      ),
    );
  }
}

class ProductsViewModel extends BaseTableProvider {
  final List<Product> products;

  ProductsViewModel(
    super.context,
    this.products,
  );

  @override
  Future loadData(BuildContext context) async {
    const headers = ["Product", "Sector", "Description", "Action"];

    List<List<TableDataRowsTableDataRows>> rows = [];

    for (final product in products) {
      List<TableDataRowsTableDataRows> row = [];

      // Product name with image
      var productCell = TableDataRowsTableDataRows()
        ..text = product.name
        ..imageUrl = product.imageUrl
        ..dataType = CellDataType.IMAGE_TEXT.type
        ..columnName = 'Product'
        ..id = product.id.toString();
      row.add(productCell);

      // Sector
      var sectorCell = TableDataRowsTableDataRows()
        ..text = product.sector
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Sector'
        ..id = product.id.toString();
      row.add(sectorCell);

      var descCell = TableDataRowsTableDataRows()
        ..text = product.description
        ..dataType = CellDataType.TEXT.type
        ..columnName = 'Description'
        ..id = product.id.toString();
      row.add(descCell);

      // Action
      var actionCell = TableDataRowsTableDataRows()
        ..text = ""
        ..dataType = CellDataType.ACTION.type
        ..columnName = 'Action'
        ..id = product.id.toString();
      row.add(actionCell);

      rows.add(row);
    }

    TableDataEntity tableData = TableDataEntity()
      ..headers = headers
      ..rows = rows;

    tableDataEntity = tableData;
  }
}
