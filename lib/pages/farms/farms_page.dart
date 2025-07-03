import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/farms/farms_kpi.dart';
import 'package:flareline/pages/farms/farms_table.dart';
import 'package:flareline/repositories/farm_repository.dart';
import 'package:flareline/services/api_service.dart';

class FarmsPage extends LayoutWidget {
  const FarmsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Farms';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return RepositoryProvider(
      create: (context) => FarmRepository(apiService: ApiService()),
      child: BlocProvider(
        create: (context) => FarmBloc(
          farmRepository: RepositoryProvider.of<FarmRepository>(context),
        )..add(LoadFarms()),
        child: Builder(
          builder: (context) {
            return Column(
              children: [
                const FarmKpi(),
                const SizedBox(height: 16),
                const FarmsTableWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
