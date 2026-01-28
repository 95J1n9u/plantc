import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plant_species.dart';

class PlantDatabaseService {
  static final PlantDatabaseService _instance = PlantDatabaseService._internal();
  factory PlantDatabaseService() => _instance;
  PlantDatabaseService._internal();

  List<PlantSpecies>? _plantSpecies;
  bool _isLoaded = false;

  // 식물 종 데이터베이스 로드
  Future<void> loadPlantSpecies() async {
    if (_isLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString('assets/plants_database.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> plantsJson = jsonData['plants'];

      _plantSpecies = plantsJson.map((json) => PlantSpecies.fromJson(json)).toList();
      _isLoaded = true;
    } catch (e) {
      print('식물 데이터베이스 로드 실패: $e');
      _plantSpecies = [];
    }
  }

  // 모든 식물 종 가져오기
  List<PlantSpecies> getAllSpecies() {
    return _plantSpecies ?? [];
  }

  // ID로 식물 종 찾기
  PlantSpecies? getSpeciesById(String id) {
    if (_plantSpecies == null) return null;
    try {
      return _plantSpecies!.firstWhere((species) => species.id == id);
    } catch (e) {
      return null;
    }
  }

  // 이름으로 검색
  List<PlantSpecies> searchByName(String query) {
    if (_plantSpecies == null || query.isEmpty) return getAllSpecies();

    final lowerQuery = query.toLowerCase();
    return _plantSpecies!.where((species) {
      return species.commonName.toLowerCase().contains(lowerQuery) ||
          species.scientificName.toLowerCase().contains(lowerQuery) ||
          species.otherNames.any((name) => name.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // 카테고리별 필터링
  List<PlantSpecies> getSpeciesByCategory(String category) {
    if (_plantSpecies == null) return [];
    return _plantSpecies!.where((species) => species.category == category).toList();
  }

  // 난이도별 필터링
  List<PlantSpecies> getSpeciesByDifficulty(String difficulty) {
    if (_plantSpecies == null) return [];
    return _plantSpecies!.where((species) => species.difficulty == difficulty).toList();
  }

  // 식용 식물만 가져오기
  List<PlantSpecies> getEdibleSpecies() {
    if (_plantSpecies == null) return [];
    return _plantSpecies!.where((species) => species.isEdible == true).toList();
  }

  // 반려동물 안전한 식물만 가져오기
  List<PlantSpecies> getPetSafeSpecies() {
    if (_plantSpecies == null) return [];
    return _plantSpecies!.where((species) => !species.toxicity.pets).toList();
  }

  // 카테고리 목록 가져오기
  List<String> getAllCategories() {
    if (_plantSpecies == null) return [];
    return _plantSpecies!.map((s) => s.category).toSet().toList();
  }

  // 난이도 목록 가져오기
  List<String> getAllDifficulties() {
    if (_plantSpecies == null) return [];
    return _plantSpecies!.map((s) => s.difficulty).toSet().toList();
  }
}
