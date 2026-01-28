import 'package:flutter/material.dart';
import '../models/plant_species.dart';
import '../models/plant.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';

class PlantCareGuideScreen extends StatefulWidget {
  final PlantSpecies species;
  final GrowthStage? currentGrowthStage; // 선택적 파라미터

  const PlantCareGuideScreen({
    super.key,
    required this.species,
    this.currentGrowthStage,
  });

  @override
  State<PlantCareGuideScreen> createState() => _PlantCareGuideScreenState();
}

class _PlantCareGuideScreenState extends State<PlantCareGuideScreen> {
  late GrowthStage _selectedGrowthStage;

  @override
  void initState() {
    super.initState();
    _selectedGrowthStage = widget.currentGrowthStage ?? GrowthStage.mature;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.species.commonName),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 이미지 및 기본 정보
            _buildHeader(context),

            // 기본 정보
            _buildBasicInfo(context),

            const Divider(height: 32),

            // 케어 정보
            _buildCareInfo(context),

            const Divider(height: 32),

            // 환경 정보
            _buildEnvironmentInfo(context),

            const Divider(height: 32),

            // 문제 해결
            _buildProblems(context),

            const Divider(height: 32),

            // 케어 가이드
            _buildCareGuide(context),

            // 수확 정보 (식용 식물인 경우)
            if (widget.species.isEdible == true && widget.species.harvest != null) ...[
              const Divider(height: 32),
              _buildHarvestInfo(context),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.background,
          ],
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withOpacity(0.2),
                  AppTheme.primary.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getCategoryIcon(),
              size: 64,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            widget.species.commonName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXSmall),
          Text(
            widget.species.scientificName,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: AppCard(
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primary, size: 24),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(
                  '기본 정보',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildInfoRow(Icons.category, '카테고리', widget.species.category),
            _buildInfoRow(Icons.signal_cellular_alt, '난이도', widget.species.difficulty),
            _buildInfoRow(Icons.speed, '성장 속도', widget.species.growthRate),
            _buildInfoRow(Icons.height, '크기 (실내)', widget.species.size.indoor),
            if (widget.species.isEdible == true)
              _buildInfoRow(Icons.restaurant, '식용', '예 (${widget.species.harvestTime ?? "수확 가능"})'),
            _buildInfoRow(
              Icons.pets,
              '반려동물',
              widget.species.toxicity.pets ? '독성 있음 ⚠️' : '안전',
            ),
            if (widget.species.toxicity.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 40, top: 4),
                child: Text(
                  widget.species.toxicity.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCareInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: AppTheme.info, size: 24),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                '케어 정보',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 물주기
          _buildWateringCard(context),
          const SizedBox(height: AppTheme.spacingMedium),

          // 햇빛
          _buildCareCard(
            context,
            icon: Icons.wb_sunny,
            title: '햇빛',
            frequency: widget.species.light.requirement,
            description: widget.species.light.description,
            tips: widget.species.light.tips,
            color: AppTheme.warning,
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 비료
          _buildFertilizingCard(context),
        ],
      ),
    );
  }

  Widget _buildEnvironmentInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: AppCard(
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, color: AppTheme.error, size: 24),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(
                  '환경 조건',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildInfoRow(Icons.thermostat, '온도', widget.species.temperature.ideal),
            _buildInfoRow(Icons.opacity, '습도', widget.species.humidity.level),
            _buildInfoRow(Icons.grass, '흙', widget.species.soil.type),
            _buildInfoRow(Icons.content_cut, '가지치기', widget.species.pruning.frequency),
            _buildInfoRow(Icons.move_up, '분갈이', widget.species.repotting.frequency),
          ],
        ),
      ),
    );
  }

  Widget _buildProblems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 24),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                '흔한 문제 & 해결책',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...widget.species.commonProblems.map((problem) => _buildProblemCard(problem)),
        ],
      ),
    );
  }

  Widget _buildCareGuide(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppTheme.success, size: 24),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                '초보자 가이드',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          AppCard(
            elevated: true,
            color: AppTheme.success.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.species.careGuide.beginner,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                const Text(
                  '추천 위치',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  widget.species.careGuide.placement,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                const Text(
                  '특별 팁',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXSmall),
                Text(
                  widget.species.careGuide.specialTips,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestInfo(BuildContext context) {
    final harvest = widget.species.harvest!;
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture, color: AppTheme.warning, size: 24),
              const SizedBox(width: AppTheme.spacingSmall),
              Text(
                '수확 정보',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          AppCard(
            elevated: true,
            color: AppTheme.warning.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.schedule, '수확 시기', harvest.when),
                _buildInfoRow(Icons.cut, '수확 방법', harvest.how),
                _buildInfoRow(Icons.repeat, '수확 빈도', harvest.frequency),
                if (harvest.tips != null) ...[
                  const SizedBox(height: AppTheme.spacingMedium),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(
                        color: AppTheme.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          size: 20,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: AppTheme.spacingSmall),
                        Expanded(
                          child: Text(
                            harvest.tips!,
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String frequency,
    required String description,
    required String tips,
    required Color color,
  }) {
    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      frequency,
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: color),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    tips,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWateringCard(BuildContext context) {
    final currentSeasonFrequency = widget.species.watering.season.getCurrentSeasonFrequency();
    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(Icons.water_drop, color: AppTheme.info, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '물주기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$currentSeasonFrequency일마다 (현재 계절 기준)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            widget.species.watering.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 계절별 물주기
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.info.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '계절별 물주기 주기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSeasonChip('봄', widget.species.watering.season.spring, Icons.local_florist),
                    _buildSeasonChip('여름', widget.species.watering.season.summer, Icons.wb_sunny),
                    _buildSeasonChip('가을', widget.species.watering.season.fall, Icons.eco),
                    _buildSeasonChip('겨울', widget.species.watering.season.winter, Icons.ac_unit),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.info.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.info),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    widget.species.watering.tips,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizingCard(BuildContext context) {
    final currentSeasonFrequency = widget.species.fertilizing.season.getCurrentSeasonFrequency();
    const fertilizeColor = Color(0xFF8D6E63); // Brown color
    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: fertilizeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(Icons.science, color: fertilizeColor, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '비료',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentSeasonFrequency == 0
                        ? '비료 주지 않음 (현재 계절)'
                        : '$currentSeasonFrequency일마다 (현재 계절 기준)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: fertilizeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            '${widget.species.fertilizing.description} (종류: ${widget.species.fertilizing.type})',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 계절별 비료
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: fertilizeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: fertilizeColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '계절별 비료 주기',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSeasonChip('봄', widget.species.fertilizing.season.spring, Icons.local_florist),
                    _buildSeasonChip('여름', widget.species.fertilizing.season.summer, Icons.wb_sunny),
                    _buildSeasonChip('가을', widget.species.fertilizing.season.fall, Icons.eco),
                    _buildSeasonChip('겨울', widget.species.fertilizing.season.winter, Icons.ac_unit),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: fertilizeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: fertilizeColor.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: fertilizeColor),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    widget.species.fertilizing.tips,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonChip(String season, int days, IconData icon) {
    final month = DateTime.now().month;
    bool isCurrentSeason = false;

    if (season == '봄' && month >= 3 && month <= 5) isCurrentSeason = true;
    if (season == '여름' && month >= 6 && month <= 8) isCurrentSeason = true;
    if (season == '가을' && month >= 9 && month <= 11) isCurrentSeason = true;
    if (season == '겨울' && (month == 12 || month <= 2)) isCurrentSeason = true;

    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isCurrentSeason ? AppTheme.primary : AppTheme.textSecondary,
        ),
        const SizedBox(height: 4),
        Text(
          season,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrentSeason ? FontWeight.bold : FontWeight.normal,
            color: isCurrentSeason ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isCurrentSeason ? AppTheme.primary : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            days == 0 ? 'X' : '${days}일',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isCurrentSeason ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProblemCard(CommonProblem problem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: AppCard(
        elevated: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    Icons.warning_amber,
                    color: AppTheme.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    problem.symptom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              '원인: ${problem.causes.join(", ")}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Text(
                      problem.solution,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.species.category) {
      case '관엽식물':
        return Icons.eco;
      case '다육식물':
        return Icons.spa;
      case '개화식물':
        return Icons.local_florist;
      case '채소':
        return Icons.agriculture;
      case '허브':
        return Icons.grass;
      default:
        return Icons.yard;
    }
  }
}
