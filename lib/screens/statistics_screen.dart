import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plant_provider.dart';
import '../models/plant.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          if (plantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final plants = plantProvider.plants;

          if (plants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  Text(
                    '아직 식물이 없습니다',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    '식물을 추가하면 통계를 확인할 수 있어요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          // 통계 계산
          final totalPlants = plants.length;
          final plantsNeedingWater = plants.where((p) => p.needsWatering).length;
          final thisWeekWatering = plants.where((p) {
            final daysUntil = p.daysUntilWatering;
            return daysUntil <= 7 && daysUntil >= 0;
          }).length;

          // 성장 단계별 분포
          final growthStageDistribution = <GrowthStage, int>{};
          for (var plant in plants) {
            growthStageDistribution[plant.growthStage] =
                (growthStageDistribution[plant.growthStage] ?? 0) + 1;
          }

          // 종류별 분포 (상위 5개)
          final speciesDistribution = <String, int>{};
          for (var plant in plants) {
            speciesDistribution[plant.species] =
                (speciesDistribution[plant.species] ?? 0) + 1;
          }
          final topSpecies = speciesDistribution.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // 평균 물주기 주기
          final avgWateringFrequency =
              plants.map((p) => p.wateringFrequency).reduce((a, b) => a + b) /
                  plants.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 요약 카드들
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.eco,
                        iconColor: AppTheme.success,
                        title: '총 식물',
                        value: '$totalPlants개',
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.water_drop,
                        iconColor: plantsNeedingWater > 0
                            ? AppTheme.error
                            : AppTheme.info,
                        title: '물 필요',
                        value: '$plantsNeedingWater개',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.calendar_today,
                        iconColor: AppTheme.warning,
                        title: '이번 주',
                        value: '$thisWeekWatering개',
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        icon: Icons.schedule,
                        iconColor: AppTheme.primary,
                        title: '평균 주기',
                        value: '${avgWateringFrequency.toStringAsFixed(1)}일',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                // 성장 단계 분포
                Text(
                  '성장 단계별 분포',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                AppCard(
                  child: Column(
                    children: growthStageDistribution.entries.map((entry) {
                      final percentage = (entry.value / totalPlants * 100);
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppTheme.spacingSmall),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.key.displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${entry.value}개 (${percentage.toStringAsFixed(0)}%)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: AppTheme.success.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.success),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                // 종류별 분포
                Text(
                  '인기 식물 종류',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                AppCard(
                  child: Column(
                    children: topSpecies.take(5).map((entry) {
                      final percentage = (entry.value / totalPlants * 100);
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppTheme.spacingSmall),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.value}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMedium),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLarge),

                // 물주기 정보
                Text(
                  '물주기 정보',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                AppCard(
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.check_circle,
                        iconColor: AppTheme.success,
                        title: '물주기 완료',
                        value: '${totalPlants - plantsNeedingWater}개',
                      ),
                      const Divider(height: AppTheme.spacingLarge),
                      _buildInfoRow(
                        context,
                        icon: Icons.schedule,
                        iconColor: AppTheme.warning,
                        title: '곧 물줄 식물 (7일 이내)',
                        value: '$thisWeekWatering개',
                      ),
                      const Divider(height: AppTheme.spacingLarge),
                      _buildInfoRow(
                        context,
                        icon: Icons.error_outline,
                        iconColor: AppTheme.error,
                        title: '물 주기 놓친 식물',
                        value: '$plantsNeedingWater개',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return AppCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}
