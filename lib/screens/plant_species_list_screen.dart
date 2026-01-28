import 'package:flutter/material.dart';
import '../models/plant_species.dart';
import '../services/plant_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';
import 'plant_care_guide_screen.dart';

class PlantSpeciesListScreen extends StatefulWidget {
  const PlantSpeciesListScreen({super.key});

  @override
  State<PlantSpeciesListScreen> createState() => _PlantSpeciesListScreenState();
}

class _PlantSpeciesListScreenState extends State<PlantSpeciesListScreen> {
  final PlantDatabaseService _databaseService = PlantDatabaseService();
  List<PlantSpecies> _allSpecies = [];
  List<PlantSpecies> _filteredSpecies = [];
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedDifficulty;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _databaseService.loadPlantSpecies();
    setState(() {
      _allSpecies = _databaseService.getAllSpecies();
      _filteredSpecies = _allSpecies;
      _isLoading = false;
    });
  }

  void _filterSpecies() {
    List<PlantSpecies> filtered = _allSpecies;

    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filtered = _databaseService.searchByName(_searchQuery);
    }

    // 카테고리 필터링
    if (_selectedCategory != null && _selectedCategory != '전체') {
      filtered = filtered.where((s) => s.category == _selectedCategory).toList();
    }

    // 난이도 필터링
    if (_selectedDifficulty != null && _selectedDifficulty != '전체') {
      filtered = filtered.where((s) => s.difficulty == _selectedDifficulty).toList();
    }

    setState(() {
      _filteredSpecies = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final categories = ['전체', ..._databaseService.getAllCategories()];
    final difficulties = ['전체', ..._databaseService.getAllDifficulties()];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('식물 선택'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 검색바
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: TextField(
              decoration: InputDecoration(
                hintText: '식물 이름 검색...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _filterSpecies();
              },
            ),
          ),

          // 필터 칩
          Container(
            color: AppTheme.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: AppTheme.spacingMedium,
                right: AppTheme.spacingMedium,
                bottom: AppTheme.spacingMedium,
              ),
              child: Row(
                children: [
                  // 카테고리 필터
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCategory ?? '전체',
                      underline: const SizedBox(),
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _filterSpecies();
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),

                  // 난이도 필터
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedDifficulty ?? '전체',
                      underline: const SizedBox(),
                      items: difficulties.map((difficulty) {
                        return DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                        _filterSpecies();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 결과 개수
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                Icon(Icons.eco, size: 18, color: AppTheme.primary),
                const SizedBox(width: AppTheme.spacingXSmall),
                Text(
                  '${_filteredSpecies.length}개의 식물',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 식물 목록
          Expanded(
            child: _filteredSpecies.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    title: '검색 결과가 없습니다',
                    subtitle: '다른 검색어로 시도해보세요',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMedium,
                      vertical: AppTheme.spacingSmall,
                    ),
                    itemCount: _filteredSpecies.length,
                    itemBuilder: (context, index) {
                      final species = _filteredSpecies[index];
                      return PlantSpeciesCard(
                        species: species,
                        onTap: () {
                          Navigator.pop(context, species);
                        },
                        onInfoTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlantCareGuideScreen(species: species),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PlantSpeciesCard extends StatelessWidget {
  final PlantSpecies species;
  final VoidCallback onTap;
  final VoidCallback onInfoTap;

  const PlantSpeciesCard({
    super.key,
    required this.species,
    required this.onTap,
    required this.onInfoTap,
  });

  BadgeType _getDifficultyBadgeType() {
    switch (species.difficulty) {
      case '매우 쉬움':
        return BadgeType.success;
      case '쉬움':
        return BadgeType.success;
      case '보통':
        return BadgeType.warning;
      case '어려움':
        return BadgeType.error;
      default:
        return BadgeType.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: AppCard(
        elevated: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                // 식물 아이콘
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primary.withOpacity(0.1),
                        AppTheme.primary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    size: 36,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMedium),

                // 식물 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름
                      Text(
                        species.commonName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 학명
                      Text(
                        species.scientificName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),

                      // 뱃지들
                      Wrap(
                        spacing: AppTheme.spacingXSmall,
                        runSpacing: AppTheme.spacingXSmall,
                        children: [
                          StatusBadge(
                            label: species.category,
                            type: BadgeType.neutral,
                          ),
                          StatusBadge(
                            label: species.difficulty,
                            type: _getDifficultyBadgeType(),
                          ),
                          if (species.isEdible == true)
                            StatusBadge(
                              label: '식용',
                              type: BadgeType.success,
                              icon: Icons.restaurant,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 정보 버튼
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.info_outline, color: AppTheme.info),
                    onPressed: onInfoTap,
                    tooltip: '케어 가이드 보기',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (species.category) {
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
