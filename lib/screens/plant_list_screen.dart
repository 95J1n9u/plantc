import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/plant_provider.dart';
import '../models/plant.dart';
import '../models/plant_species.dart';
import '../services/plant_database_service.dart';
import 'add_plant_screen.dart';

class PlantListScreen extends StatefulWidget {
  const PlantListScreen({super.key});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<PlantProvider>().loadPlants(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 식물들'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PlantProvider>(
        builder: (context, plantProvider, child) {
          if (plantProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (plantProvider.plants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.eco,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '아직 등록된 식물이 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '+ 버튼을 눌러 식물을 추가해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: plantProvider.plants.length,
            itemBuilder: (context, index) {
              final plant = plantProvider.plants[index];
              return PlantCard(plant: plant);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPlantScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    final daysUntil = plant.daysUntilWatering;
    final needsWater = plant.needsWatering;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: needsWater ? Colors.red[100] : Colors.green[100],
          radius: 30,
          child: Icon(
            Icons.local_florist,
            color: needsWater ? Colors.red : Colors.green,
            size: 30,
          ),
        ),
        title: Text(
          plant.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  plant.species,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plant.growthStage.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.water_drop,
                  size: 16,
                  color: needsWater ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  needsWater
                      ? '물 주세요! (${daysUntil.abs()}일 지남)'
                      : daysUntil == 0
                          ? '오늘 물 주기'
                          : '$daysUntil일 후 물 주기',
                  style: TextStyle(
                    fontSize: 13,
                    color: needsWater ? Colors.red : Colors.grey[700],
                    fontWeight: needsWater ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '마지막 물 준 날짜: ${DateFormat('yyyy-MM-dd').format(plant.lastWateredDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.water_drop_outlined, color: Colors.blue),
          iconSize: 30,
          onPressed: () {
            _showWaterConfirmDialog(context, plant);
          },
        ),
        onTap: () {
          _showPlantDetails(context, plant);
        },
      ),
    );
  }

  void _showWaterConfirmDialog(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('물 주기'),
          content: Text('${plant.name}에 물을 주셨나요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PlantProvider>().waterPlant(plant.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${plant.name}에 물을 주었습니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showPlantDetails(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(plant.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('종류: ${plant.species}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('현재 성장 단계: '),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        plant.growthStage.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showGrowthStageChangeDialog(context, plant);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('성장 단계 변경'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text('물주기 주기: ${plant.wateringFrequency}일'),
                const SizedBox(height: 8),
                Text(
                  '마지막 물 준 날짜: ${DateFormat('yyyy-MM-dd').format(plant.lastWateredDate)}',
                ),
                const SizedBox(height: 8),
                Text(
                  '다음 물줄 날짜: ${DateFormat('yyyy-MM-dd').format(plant.nextWateringDate)}',
                ),
                if (plant.notes != null && plant.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    '메모:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(plant.notes!),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmDialog(context, plant);
              },
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void _showGrowthStageChangeDialog(BuildContext context, Plant plant) {
    GrowthStage selectedStage = plant.growthStage;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('성장 단계 변경'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '식물의 현재 상태를 선택하세요',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: GrowthStage.values.map((stage) {
                        final isSelected = selectedStage == stage;
                        return ChoiceChip(
                          label: Text(stage.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedStage = stage;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
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
                            selectedStage.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedStage.description,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updatePlantGrowthStage(context, plant, selectedStage);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('변경'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updatePlantGrowthStage(BuildContext context, Plant plant, GrowthStage newStage) {
    if (plant.growthStage == newStage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('이미 같은 성장 단계입니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 식물 종 정보 가져오기
    final species = plant.plantSpeciesId != null
        ? PlantDatabaseService().getSpeciesById(plant.plantSpeciesId!)
        : null;

    if (species == null) {
      // 종 정보가 없으면 성장 단계만 변경
      final updatedPlant = plant.copyWith(growthStage: newStage);
      context.read<PlantProvider>().updatePlant(updatedPlant);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${plant.name}의 성장 단계가 ${newStage.displayName}(으)로 변경되었습니다'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // 기본 물주기 주기 계산 (현재 계절 기준)
    int newWateringFrequency = species.watering.season.getCurrentSeasonFrequency();

    // 성장 단계별 조정 적용
    if (species.growthStageGuides != null) {
      final guide = species.growthStageGuides![newStage.name];
      if (guide != null && guide.wateringAdjustment != null) {
        newWateringFrequency += guide.wateringAdjustment!;
        // 최소 1일 보장
        if (newWateringFrequency < 1) newWateringFrequency = 1;
      }
    }

    // 다음 물주기 날짜 재계산
    final now = DateTime.now();
    final daysSinceLastWatering = now.difference(plant.lastWateredDate).inDays;

    // 새로운 주기에 따른 다음 물주기 날짜
    final nextWateringDate = plant.lastWateredDate.add(Duration(days: newWateringFrequency));

    // 식물 정보 업데이트
    final updatedPlant = plant.copyWith(
      growthStage: newStage,
      wateringFrequency: newWateringFrequency,
      nextWateringDate: nextWateringDate,
    );

    context.read<PlantProvider>().updatePlant(updatedPlant);

    // 물주기 주기가 변경되었는지 확인
    final frequencyChanged = plant.wateringFrequency != newWateringFrequency;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          frequencyChanged
              ? '${plant.name}의 성장 단계가 ${newStage.displayName}(으)로 변경되었습니다\n물주기 주기: ${plant.wateringFrequency}일 → $newWateringFrequency일'
              : '${plant.name}의 성장 단계가 ${newStage.displayName}(으)로 변경되었습니다',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Plant plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('식물 삭제'),
          content: Text('${plant.name}을(를) 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PlantProvider>().deletePlant(plant.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${plant.name}을(를) 삭제했습니다'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
