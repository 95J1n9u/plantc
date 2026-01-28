import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/plant.dart';
import '../models/plant_species.dart';
import '../providers/plant_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/status_badge.dart';
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
  final _imagePicker = ImagePicker();

  PlantSpecies? _selectedSpecies;
  GrowthStage _selectedGrowthStage = GrowthStage.mature; // 기본값: 성숙
  int? _wateringFrequency;
  XFile? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('사진을 불러올 수 없습니다: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사진 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _saveImagePermanently(XFile image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedImage = File('${appDir.path}/$fileName');
      await File(image.path).copy(savedImage.path);
      return savedImage.path;
    } catch (e) {
      return null;
    }
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
        // 현재 계절 및 성장 단계에 맞는 물주기 주기 자동 설정
        _updateWateringFrequency();
        // 식물 이름 자동 입력 (수정 가능)
        if (_nameController.text.isEmpty) {
          _nameController.text = result.commonName;
        }
      });
    }
  }

  // 성장 단계에 따라 물주기 주기 계산
  void _updateWateringFrequency() {
    if (_selectedSpecies == null) return;

    // 기본 물주기 (현재 계절 기준)
    int baseFrequency = _selectedSpecies!.watering.season.getCurrentSeasonFrequency();

    // 성장 단계별 조정 적용
    if (_selectedSpecies!.growthStageGuides != null) {
      final guide = _selectedSpecies!.growthStageGuides![_selectedGrowthStage.name];
      if (guide != null && guide.wateringAdjustment != null) {
        baseFrequency += guide.wateringAdjustment!;
        // 최소 1일 보장
        if (baseFrequency < 1) baseFrequency = 1;
      }
    }

    _wateringFrequency = baseFrequency;
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

  Future<void> _savePlant() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSpecies == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('식물 종을 선택해주세요')),
              ],
            ),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }

      // 이미지 저장
      String? imagePath;
      if (_selectedImage != null) {
        imagePath = await _saveImagePermanently(_selectedImage!);
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
        imagePath: imagePath,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      context.read<PlantProvider>().addPlant(plant);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('식물이 추가되었습니다!')),
            ],
          ),
          backgroundColor: AppTheme.success,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('식물 추가'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 메시지
              AppCard(
                color: AppTheme.info.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.info),
                    const SizedBox(width: AppTheme.spacingMedium),
                    const Expanded(
                      child: Text(
                        '식물 종을 선택하면 자동으로 케어 정보가 설정됩니다',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // 식물 종 선택 버튼
              ElevatedButton.icon(
                onPressed: _selectPlantSpecies,
                icon: const Icon(Icons.search),
                label: Text(
                  _selectedSpecies == null
                      ? '식물 종 선택하기'
                      : _selectedSpecies!.commonName,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedSpecies == null
                      ? AppTheme.secondary
                      : AppTheme.success,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),

              // 선택된 식물 정보 표시
              if (_selectedSpecies != null) ...[
                const SizedBox(height: AppTheme.spacingMedium),
                AppCard(
                  elevated: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            ),
                            child: Icon(
                              _getCategoryIcon(_selectedSpecies!.category),
                              size: 32,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedSpecies!.commonName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedSpecies!.scientificName,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingSmall),
                                Wrap(
                                  spacing: AppTheme.spacingSmall,
                                  runSpacing: AppTheme.spacingSmall,
                                  children: [
                                    StatusBadge(
                                      label: _selectedSpecies!.category,
                                      type: BadgeType.neutral,
                                    ),
                                    StatusBadge(
                                      label: _selectedSpecies!.difficulty,
                                      type: BadgeType.info,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      const Divider(),
                      const SizedBox(height: AppTheme.spacingMedium),
                      _buildInfoRow(
                        Icons.water_drop,
                        '물주기',
                        '$_wateringFrequency일마다',
                        AppTheme.info,
                      ),
                      _buildInfoRow(
                        Icons.wb_sunny,
                        '햇빛',
                        _selectedSpecies!.light.requirement,
                        AppTheme.warning,
                      ),
                      _buildInfoRow(
                        Icons.thermostat,
                        '온도',
                        _selectedSpecies!.temperature.ideal,
                        AppTheme.error,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      OutlinedButton.icon(
                        onPressed: _viewCareGuide,
                        icon: const Icon(Icons.menu_book),
                        label: const Text('상세 케어 가이드 보기'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingLarge),

              // 사진 추가
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_camera, color: AppTheme.primary),
                        const SizedBox(width: AppTheme.spacingSmall),
                        Text(
                          '식물 사진 (선택사항)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    if (_selectedImage != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: Image.file(
                              File(_selectedImage!.path),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      OutlinedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('사진 변경'),
                      ),
                    ] else ...[
                      OutlinedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('사진 추가하기'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // 성장 단계 선택
              if (_selectedSpecies != null) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: AppTheme.success),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            '현재 성장 단계',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        '식물의 현재 상태를 선택하면 맞춤 케어 정보를 제공합니다',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Wrap(
                        spacing: AppTheme.spacingSmall,
                        runSpacing: AppTheme.spacingSmall,
                        children: GrowthStage.values.map((stage) {
                          final isSelected = _selectedGrowthStage == stage;
                          return ChoiceChip(
                            label: Text(stage.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedGrowthStage = stage;
                                  _updateWateringFrequency();
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingMedium),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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
                const SizedBox(height: AppTheme.spacingMedium),
              ],

              // 식물 이름 (별명)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '식물 이름 (별명)',
                  hintText: '예: 거실 몬스테라',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '식물 이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // 물주기 주기 조정 (선택사항)
              if (_selectedSpecies != null)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: AppTheme.info),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Text(
                            '물주기 주기 조정',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        '환경에 따라 조정할 수 있습니다',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Center(
                        child: Text(
                          '$_wateringFrequency일마다',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.info,
                          ),
                        ),
                      ),
                      Slider(
                        value: _wateringFrequency!.toDouble(),
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '$_wateringFrequency일',
                        onChanged: (value) {
                          setState(() {
                            _wateringFrequency = value.round();
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1일', style: Theme.of(context).textTheme.bodySmall),
                          Text('30일', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppTheme.spacingMedium),

              // 메모
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택사항)',
                  hintText: '식물의 위치나 특이사항을 적어보세요',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // 저장 버튼
              ElevatedButton.icon(
                onPressed: _savePlant,
                icon: const Icon(Icons.add),
                label: const Text('식물 추가'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXSmall),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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
