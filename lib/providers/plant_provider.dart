import 'package:flutter/foundation.dart';
import '../models/plant.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class PlantProvider with ChangeNotifier {
  List<Plant> _plants = [];
  bool _isLoading = false;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;

  // 물 줘야 하는 식물 목록
  List<Plant> get plantsNeedingWater {
    return _plants.where((plant) => plant.needsWatering).toList();
  }

  // 식물 목록 불러오기
  Future<void> loadPlants() async {
    _isLoading = true;
    notifyListeners();

    try {
      _plants = await DatabaseService.instance.getAllPlants();
    } catch (e) {
      debugPrint('식물 목록 불러오기 실패: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 식물 추가
  Future<void> addPlant(Plant plant) async {
    try {
      final newPlant = await DatabaseService.instance.createPlant(plant);
      _plants.add(newPlant);

      // 알림 스케줄
      await NotificationService.instance.schedulePlantWateringNotification(newPlant);

      notifyListeners();
    } catch (e) {
      debugPrint('식물 추가 실패: $e');
    }
  }

  // 식물 정보 업데이트
  Future<void> updatePlant(Plant plant) async {
    try {
      await DatabaseService.instance.updatePlant(plant);
      final index = _plants.indexWhere((p) => p.id == plant.id);
      if (index != -1) {
        _plants[index] = plant;

        // 알림 업데이트
        await NotificationService.instance.schedulePlantWateringNotification(plant);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('식물 정보 업데이트 실패: $e');
    }
  }

  // 식물 삭제
  Future<void> deletePlant(int id) async {
    try {
      await DatabaseService.instance.deletePlant(id);
      _plants.removeWhere((plant) => plant.id == id);

      // 알림 취소
      await NotificationService.instance.cancelPlantNotification(id);

      notifyListeners();
    } catch (e) {
      debugPrint('식물 삭제 실패: $e');
    }
  }

  // 물 주기
  Future<void> waterPlant(int id) async {
    try {
      await DatabaseService.instance.waterPlant(id);
      final index = _plants.indexWhere((p) => p.id == id);
      if (index != -1) {
        _plants[index] = _plants[index].copyWithWatered();

        // 알림 다시 스케줄
        await NotificationService.instance.schedulePlantWateringNotification(_plants[index]);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('물 주기 업데이트 실패: $e');
    }
  }
}
