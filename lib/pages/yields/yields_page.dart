import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline/pages/yields/yield_kpi.dart';
import 'package:flareline/pages/yields/yields_table.dart';
import 'package:flareline/repositories/yield_repository.dart';
import 'package:flareline/services/api_service.dart';

class YieldsPage extends LayoutWidget {
  const YieldsPage({super.key});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Yields';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return RepositoryProvider(
      create: (context) => YieldRepository(apiService: ApiService()),
      child: BlocProvider(
        create: (context) => YieldBloc(
          yieldRepository: RepositoryProvider.of<YieldRepository>(context),
        )..add(LoadYields()),
        child: Builder(
          builder: (context) {
            return const _YieldsContent();
          },
        ),
      ),
    );
  }
}

// Stateful widget to manage the selected year
class _YieldsContent extends StatefulWidget {
  const _YieldsContent();

  @override
  State<_YieldsContent> createState() => _YieldsContentState();
}

class _YieldsContentState extends State<_YieldsContent> {
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const YieldKpi(),
        const SizedBox(height: 16),
        YieldsWidget(),
        const SizedBox(height: 16),
      ],
    );
  }
}
