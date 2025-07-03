import 'package:flareline/core/models/farms_model.dart';
import 'package:flareline/core/models/yield_model.dart';
import 'package:flareline/pages/farms/farm_widgets/farm_recent_yield.dart';
import 'package:flareline/pages/farms/farm_widgets/recent_yield.dart';
import 'package:flareline/repositories/farm_repository.dart';
import 'package:flutter/material.dart';
import 'package:flareline/pages/layout.dart';
import 'package:flareline_uikit/components/card/common_card.dart';
import 'package:flareline/pages/farms/farm_widgets/farm_info_card.dart';
import 'package:flareline/pages/farms/farm_widgets/farm_map_card.dart';
import 'package:flareline/pages/farms/farm_widgets/farm_products_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flareline/pages/farms/farm_bloc/farm_bloc.dart';
import 'package:flareline/pages/yields/yield_bloc/yield_bloc.dart';
import 'package:toastification/toastification.dart';

class FarmProfile extends LayoutWidget {
  final int farmId;

  const FarmProfile({super.key, required this.farmId});

  @override
  String breakTabTitle(BuildContext context) {
    return 'Farm Profile';
  }

  @override
  Widget contentDesktopWidget(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FarmBloc(
            farmRepository: context.read<FarmBloc>().farmRepository,
          )..add(GetFarmById(farmId)),
        ),
        BlocProvider(
          create: (context) => YieldBloc(
            yieldRepository: context.read<YieldBloc>().yieldRepository,
          )..add(GetYieldByFarmId(farmId)),
        )
      ],
      child: const FarmProfileDesktop(),
    );
  }

  @override
  Widget contentMobileWidget(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FarmBloc(
            farmRepository: context.read<FarmBloc>().farmRepository,
          )..add(GetFarmById(farmId)),
        ),
        BlocProvider(
          create: (context) => YieldBloc(
            yieldRepository: context.read<YieldBloc>().yieldRepository,
          )..add(GetYieldByFarmId(farmId)),
        )
      ],
      child: const FarmProfileMobile(),
    );
  }
}

class FarmProfileDesktop extends StatelessWidget {
  const FarmProfileDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmBloc, FarmState>(
      listener: (context, state) {
        if (state is FarmsLoaded && state.message != null) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message!),
            autoCloseDuration: const Duration(seconds: 5),
          );
        }
        if (state is FarmsError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            autoCloseDuration: const Duration(seconds: 5),
          );
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final farmState = context.watch<FarmBloc>().state;
    final yieldState = context.watch<YieldBloc>().state;

    // Show loading if either farm or yield data is loading
    if (farmState is FarmsLoading || yieldState is YieldsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error states
    if (farmState is FarmsError) {
      return Center(child: Text('Error loading farm: ${farmState.message}'));
    }

    if (yieldState is YieldsError) {
      return Center(child: Text('Error loading yields: ${yieldState.message}'));
    }

    // Only proceed if both data are loaded
    if (farmState is! FarmLoaded || yieldState is! YieldsLoaded) {
      return const Center(child: Text('Unexpected state'));
    }

    final transformedFarm = transformFarmData(farmState, yieldState);
    final hasProducts = transformedFarm['products'] != null &&
        (transformedFarm['products'] as List).isNotEmpty;
    final hasYields = yieldState.yields.isNotEmpty;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map and Farm Info side by side
            CommonCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: FarmInfoCard(
                        farm: transformedFarm,
                        onSave: (updatedData) {
                          final updatedFarm = Farm(
                            id: farmState.farm.id,
                            name: updatedData['farmName'],
                            sectorId: updatedData['sectorId'],
                            barangay: updatedData['barangayName'],
                            farmerId: updatedData['farmerId'],
                            updatedAt: DateTime.now(),
                            products: updatedData['products'],
                          );
                          context.read<FarmBloc>().add(UpdateFarm(updatedFarm));
                        },
                      ),
                    ),
                    const VerticalDivider(
                      thickness: 1,
                      width: 12,
                      color: Color.fromARGB(255, 186, 185, 185),
                    ),
                    Expanded(
                      flex: 3,
                      child: FarmMapCard(farm: transformedFarm),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (hasProducts || hasYields) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasProducts)
                    Expanded(
                      flex: 7,
                      child: FarmProductsCard(farm: transformedFarm),
                    ),
                  if (hasProducts && hasYields) const SizedBox(width: 24),
                  if (hasYields)
                    Expanded(
                      flex: 3,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 300,
                          maxHeight: 500,
                          minWidth: 300,
                          maxWidth: 400,
                        ),
                        child: RecentYieldWidget(
                          yields: yieldState.yields,
                          isLoading: false,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class FarmProfileMobile extends StatelessWidget {
  const FarmProfileMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmBloc, FarmState>(
      listener: (context, state) {
        if (state is FarmsLoaded && state.message != null) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(state.message!),
            autoCloseDuration: const Duration(seconds: 5),
          );
        }
        if (state is FarmsError) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(state.message),
            autoCloseDuration: const Duration(seconds: 5),
          );
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final farmState = context.watch<FarmBloc>().state;
    final yieldState = context.watch<YieldBloc>().state;

    // Show loading if either farm or yield data is loading
    if (farmState is FarmsLoading || yieldState is YieldsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error states
    if (farmState is FarmsError) {
      return Center(child: Text('Error loading farm: ${farmState.message}'));
    }

    if (yieldState is YieldsError) {
      return Center(child: Text('Error loading yields: ${yieldState.message}'));
    }

    // Only proceed if both data are loaded
    if (farmState is! FarmLoaded || yieldState is! YieldsLoaded) {
      return const Center(child: Text('Unexpected state'));
    }

    final transformedFarm = transformFarmData(farmState, yieldState);
    final hasProducts = transformedFarm['products'] != null &&
        (transformedFarm['products'] as List).isNotEmpty;
    final hasYields = yieldState.yields.isNotEmpty;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FarmMapCard(farm: transformedFarm, isMobile: true),
            const SizedBox(height: 16),
            FarmInfoCard(
              farm: transformedFarm,
              onSave: (updatedData) {
                final updatedFarm = Farm(
                  id: farmState.farm.id,
                  name: updatedData['farmName'],
                  sector: updatedData['sector'],
                  barangay: updatedData['barangay'],
                  farmerId: updatedData['farmerId'],
                  createdAt: farmState.farm.createdAt,
                  updatedAt: DateTime.now(),
                );
                context.read<FarmBloc>().add(UpdateFarm(updatedFarm));
              },
            ),
            const SizedBox(height: 16),
            if (hasProducts) ...[
              FarmProductsCard(farm: transformedFarm, isMobile: true),
              const SizedBox(height: 16),
            ],
            if (hasYields)
              SizedBox(
                height: 350,
                width: 630,
                child: RecentYieldWidget(
                  yields: yieldState.yields,
                  isLoading: false,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> transformFarmData(
    FarmState farmState, YieldState yieldState) {
  // Default/fallback values
  Map<String, dynamic> transformedFarm = {
    'farmName': 'Unknown Farm',
    'farmOwner': 'Unknown Owner',
    'establishedYear': 'Unknown',
    'farmSize': 0.0,
    'sector': 'Unknown',
    'barangay': 'Unknown',
    'municipality': 'Unknown',
    'province': 'Unknown',
    'vertices': '0, 0',
    'products': [],
    'hectare': '8.884',
    'created_at': '2025-06-18T08:09:09.000Z',
    'farmerId': null,
    'sectorId': null,
    'barangayName': null,
  };

  // Transform farm data if loaded
  if (farmState is FarmLoaded) {
    transformedFarm = {
      'farmName': farmState.farm.name ?? 'Unknown Farm',
      'farmOwner': farmState.farm.owner ?? 'Unknown Owner',
      'establishedYear': farmState.farm.createdAt?.year.toString() ?? 'Unknown',
      'farmSize': farmState.farm.hectare ?? 0.0,
      'sector': farmState.farm.sector ?? 'Unknown',
      'barangay': farmState.farm.barangay ?? 'Unknown',
      'municipality': 'San Pablo',
      'province': 'Laguna',
      'vertices': farmState.farm.vertices ?? '0, 0',
      'products': [],
      'hectare': farmState.farm.hectare ?? 'hectare: 8.884',
      'created_at': farmState.farm.createdAt ?? '2025-06-18T08:09:09.000Z',
      'farmerId': farmState.farm.farmerId,
      'barangayName': farmState.farm.barangay,
    };
  }

  // Transform yield data if loaded
  if (yieldState is YieldsLoaded) {
    final productMap = <String, List<Map<String, dynamic>>>{};

    for (var yield in yieldState.yields) {
      final productName = yield.productName ?? 'Unknown Product';
      if (!productMap.containsKey(productName)) {
        productMap[productName] = [];
      }

      final harvestMonth = yield.harvestDate?.month ?? DateTime.now().month;
      final monthly = List.filled(12, 0.0);
      if (harvestMonth >= 1 && harvestMonth <= 12) {
        monthly[harvestMonth - 1] = yield.volume?.toDouble() ?? 0.0;
      }

      productMap[productName]!.add({
        'year': yield.harvestDate?.year ?? DateTime.now().year,
        'total': yield.volume?.toDouble() ?? 0.0,
        'monthly': monthly,
      });
    }

    transformedFarm['products'] = productMap.entries
        .map((entry) => {
              'name': entry.key,
              'yields': entry.value,
            })
        .toList();
  }

  return transformedFarm;
}
