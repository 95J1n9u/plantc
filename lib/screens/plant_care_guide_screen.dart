import 'package:flutter/material.dart';
import '../models/plant_species.dart';
import '../models/plant.dart';

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
      appBar: AppBar(
        title: Text(widget.species.commonName),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
      height: 200,
      color: Colors.green[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 80,
            color: Colors.green[700],
          ),
          const SizedBox(height: 16),
          Text(
            widget.species.commonName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.species.scientificName,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기본 정보',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCareInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '케어 정보',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // 물주기
          _buildWateringCard(context),
          const SizedBox(height: 12),

          // 햇빛
          _buildCareCard(
            context,
            icon: Icons.wb_sunny,
            title: '햇빛',
            frequency: widget.species.light.requirement,
            description: widget.species.light.description,
            tips: widget.species.light.tips,
            color: Colors.amber,
          ),
          const SizedBox(height: 12),

          // 비료
          _buildFertilizingCard(context),
        ],
      ),
    );
  }

  Widget _buildEnvironmentInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '환경 조건',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.thermostat, '온도', widget.species.temperature.ideal),
          _buildInfoRow(Icons.opacity, '습도', widget.species.humidity.level),
          _buildInfoRow(Icons.grass, '흙', widget.species.soil.type),
          _buildInfoRow(Icons.content_cut, '가지치기', widget.species.pruning.frequency),
          _buildInfoRow(Icons.move_up, '분갈이', widget.species.repotting.frequency),
        ],
      ),
    );
  }

  Widget _buildProblems(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '흔한 문제 & 해결책',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...widget.species.commonProblems.map((problem) => _buildProblemCard(problem)),
        ],
      ),
    );
  }

  Widget _buildCareGuide(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '초보자 가이드',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.species.careGuide.beginner,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '추천 위치',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.species.careGuide.placement),
                  const SizedBox(height: 12),
                  const Text(
                    '특별 팁',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.species.careGuide.specialTips),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestInfo(BuildContext context) {
    final harvest = widget.species.harvest!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '수확 정보',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.schedule, '수확 시기', harvest.when),
                  _buildInfoRow(Icons.cut, '수확 방법', harvest.how),
                  _buildInfoRow(Icons.repeat, '수확 빈도', harvest.frequency),
                  if (harvest.tips != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tips_and_updates, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(harvest.tips!)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      frequency,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tips,
                      style: const TextStyle(fontSize: 12),
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

  Widget _buildWateringCard(BuildContext context) {
    final currentSeasonFrequency = widget.species.watering.season.getCurrentSeasonFrequency();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '물주기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$currentSeasonFrequency일마다 (현재 계절 기준)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.species.watering.description),
            const SizedBox(height: 12),

            // 계절별 물주기
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계절별 물주기 주기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.species.watering.tips,
                      style: const TextStyle(fontSize: 12),
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

  Widget _buildFertilizingCard(BuildContext context) {
    final currentSeasonFrequency = widget.species.fertilizing.season.getCurrentSeasonFrequency();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.brown, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '비료',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currentSeasonFrequency == 0
                        ? '비료 주지 않음 (현재 계절)'
                        : '$currentSeasonFrequency일마다 (현재 계절 기준)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${widget.species.fertilizing.description} (종류: ${widget.species.fertilizing.type})'),
            const SizedBox(height: 12),

            // 계절별 비료
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '계절별 비료 주기',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.species.fertilizing.tips,
                      style: const TextStyle(fontSize: 12),
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
          color: isCurrentSeason ? Colors.blue : Colors.grey,
        ),
        const SizedBox(height: 4),
        Text(
          season,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrentSeason ? FontWeight.bold : FontWeight.normal,
            color: isCurrentSeason ? Colors.blue : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isCurrentSeason ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            days == 0 ? 'X' : '${days}일',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isCurrentSeason ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProblemCard(CommonProblem problem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    problem.symptom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '원인: ${problem.causes.join(", ")}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      problem.solution,
                      style: const TextStyle(fontSize: 14),
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
