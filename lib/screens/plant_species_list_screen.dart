import 'package:flutter/material.dart';
import '../models/plant_species.dart';
import '../services/plant_database_service.dart';
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = ['전체', ..._databaseService.getAllCategories()];
    final difficulties = ['전체', ..._databaseService.getAllDifficulties()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('식물 선택'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '식물 이름 검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // 카테고리 필터
                DropdownButton<String>(
                  value: _selectedCategory ?? '전체',
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
                const SizedBox(width: 16),

                // 난이도 필터
                DropdownButton<String>(
                  value: _selectedDifficulty ?? '전체',
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
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 결과 개수
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredSpecies.length}개의 식물',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 식물 목록
          Expanded(
            child: _filteredSpecies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '검색 결과가 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
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

  Color _getDifficultyColor() {
    switch (species.difficulty) {
      case '매우 쉬움':
        return Colors.green;
      case '쉬움':
        return Colors.lightGreen;
      case '보통':
        return Colors.orange;
      case '어려움':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 식물 이미지 플레이스홀더
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  size: 40,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(width: 16),

              // 식물 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이름
                    Text(
                      species.commonName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 학명
                    Text(
                      species.scientificName,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 칩들
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // 카테고리
                        Chip(
                          label: Text(
                            species.category,
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        // 난이도
                        Chip(
                          label: Text(
                            species.difficulty,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: _getDifficultyColor().withOpacity(0.2),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        // 식용 표시
                        if (species.isEdible == true)
                          const Chip(
                            label: Text(
                              '식용',
                              style: TextStyle(fontSize: 11),
                            ),
                            backgroundColor: Color(0xFFE8F5E9),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 정보 버튼
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: onInfoTap,
                tooltip: '케어 가이드 보기',
              ),
            ],
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
