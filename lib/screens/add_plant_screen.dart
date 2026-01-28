import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/plant.dart';
import '../models/plant_species.dart';
import '../providers/plant_provider.dart';
import 'plant_species_list_screen.dart';
import 'plant_care_guide_screen.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  PlantSpecies? _selectedSpecies;
  GrowthStage _selectedGrowthStage = GrowthStage.mature; // 기본값: 성숙
  int? _wateringFrequency;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectPlantSpecies() async {
    final result = await Navigator.push<PlantSpecies>(
      context,
      MaterialPageRoute(
        builder: (context) => const PlantSpeciesListScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSpecies = result;
        // 현재 계절에 맞는 물주기 주기 자동 설정
        _wateringFrequency = result.watering.season.getCurrentSeasonFrequency();
        // 식물 이름 자동 입력 (수정 가능)
        if (_nameController.text.isEmpty) {
          _nameController.text = result.commonName;
        }
      });
    }
  }

  void _viewCareGuide() {
    if (_selectedSpecies != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlantCareGuideScreen(species: _selectedSpecies!),
        ),
      );
    }
  }

  void _savePlant() {
    if (_formKey.currentState!.validate()) {
      if (_selectedSpecies == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('식물 종을 선택해주세요'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final now = DateTime.now();
      final nextWatering = now.add(Duration(days: _wateringFrequency!));

      final plant = Plant(
        name: _nameController.text,
        species: _selectedSpecies!.commonName,
        plantSpeciesId: _selectedSpecies!.id,
        growthStage: _selectedGrowthStage,
        wateringFrequency: _wateringFrequency!,
        lastWateredDate: now,
        nextWateringDate: nextWatering,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      context.read<PlantProvider>().addPlant(plant);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('식물이 추가되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('식물 추가'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 메시지
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '식물 종을 선택하면 자동으로 케어 정보가 설정됩니다',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 식물 종 선택 버튼
              OutlinedButton.icon(
                onPressed: _selectPlantSpecies,
                icon: const Icon(Icons.search),
                label: Text(
                  _selectedSpecies == null
                      ? '식물 종 선택하기'
                      : '선택됨: ${_selectedSpecies!.commonName}',
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: BorderSide(
                    color: _selectedSpecies == null
                        ? Colors.grey
                        : Colors.green,
                    width: 2,
                  ),
                ),
              ),

              // 선택된 식물 정보 표시
              if (_selectedSpecies != null) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(_selectedSpecies!.category),
                                size: 32,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedSpecies!.commonName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _selectedSpecies!.scientificName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      Chip(
                                        label: Text(
                                          _selectedSpecies!.category,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      Chip(
                                        label: Text(
                                          _selectedSpecies!.difficulty,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        padding: EdgeInsets.zero,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.water_drop,
                          '물주기',
                          '$_wateringFrequency일마다 (현재 계절 기준)',
                          Colors.blue,
                        ),
                        _buildInfoRow(
                          Icons.wb_sunny,
                          '햇빛',
                          _selectedSpecies!.light.requirement,
                          Colors.amber,
                        ),
                        _buildInfoRow(
                          Icons.thermostat,
                          '온도',
                          _selectedSpecies!.temperature.ideal,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _viewCareGuide,
                          icon: const Icon(Icons.menu_book),
                          label: const Text('상세 케어 가이드 보기'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 성장 단계 선택
              if (_selectedSpecies != null) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.trending_up, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              '현재 성장 단계',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '식물의 현재 상태를 선택하면 맞춤 케어 정보를 제공합니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: GrowthStage.values.map((stage) {
                            final isSelected = _selectedGrowthStage == stage;
                            return ChoiceChip(
                              label: Text(stage.displayName),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedGrowthStage = stage;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedGrowthStage.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedGrowthStage.description,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 식물 이름 (별명)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '식물 이름 (별명)',
                  hintText: '예: 거실 몬스테라',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '식물 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 물주기 주기 조정 (선택사항)
              if (_selectedSpecies != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              '물주기 주기 조정',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '환경에 따라 조정할 수 있습니다',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_wateringFrequency일마다',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: _wateringFrequency! > 1
                                      ? () {
                                          setState(() {
                                            _wateringFrequency = _wateringFrequency! - 1;
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _wateringFrequency = _wateringFrequency! + 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Slider(
                          value: _wateringFrequency!.toDouble(),
                          min: 1,
                          max: 30,
                          divisions: 29,
                          activeColor: Colors.blue,
                          label: '$_wateringFrequency일',
                          onChanged: (value) {
                            setState(() {
                              _wateringFrequency = value.round();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // 메모
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택사항)',
                  hintText: '식물의 위치나 특이사항을 적어보세요',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // 저장 버튼
              ElevatedButton(
                onPressed: _savePlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '식물 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
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
