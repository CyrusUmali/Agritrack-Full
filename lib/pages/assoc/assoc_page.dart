import 'package:flareline/pages/assoc/assoc_bar_chart.dart';
import 'package:flareline/pages/assoc/assoc_bloc/assocs_bloc.dart';
import 'package:flareline/pages/assoc/assocs_kpi.dart';
import 'package:flareline/pages/assoc/assocs_table.dart';
import 'package:flareline/repositories/assocs_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/services/api_service.dart';

class AssocsPage extends LayoutWidget {
  const AssocsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Associations';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AssociationRepository(apiService: ApiService()),
      child: BlocProvider(
        create: (context) => AssocsBloc(
          associationRepository:
              RepositoryProvider.of<AssociationRepository>(context),
        )..add(LoadAssocs()),
        child: const _AssocsContent(),
      ),
    );
  }
}

class _AssocsContent extends StatelessWidget {
  const _AssocsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AssocKpi(),
        const SizedBox(height: 16),
        AssocsWidget(),
        const SizedBox(height: 16),
        AssocsBarChart(),
        const SizedBox(height: 16),
      ],
    );
  }
}
