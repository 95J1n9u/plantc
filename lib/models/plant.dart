// 식물 성장 단계
enum GrowthStage {
  seed('씨앗', '씨앗을 심은 단계'),
  germination('발아', '싹이 나는 중'),
  seedling('묘목', '어린 식물 단계'),
  vegetative('성장기', '잎과 줄기가 자라는 중'),
  mature('성숙', '다 자란 식물'),
  flowering('개화/결실', '꽃이 피거나 열매를 맺는 단계');

  final String displayName;
  final String description;
  const GrowthStage(this.displayName, this.description);

  static GrowthStage fromString(String value) {
    return GrowthStage.values.firstWhere(
      (stage) => stage.name == value,
      orElse: () => GrowthStage.mature,
    );
  }
}

class Plant {
  final int? id;
  final String name;
  final String species;
  final String? plantSpeciesId; // 식물 종 데이터베이스 ID (선택사항)
  final GrowthStage growthStage; // 현재 성장 단계
  final int wateringFrequency; // 물주기 주기 (일 단위)
  final DateTime lastWateredDate;
  final DateTime nextWateringDate;
  final String? imagePath;
  final String? notes;

  Plant({
    this.id,
    required this.name,
    required this.species,
    this.plantSpeciesId,
    this.growthStage = GrowthStage.mature, // 기본값: 성숙한 식물
    required this.wateringFrequency,
    required this.lastWateredDate,
    required this.nextWateringDate,
    this.imagePath,
    this.notes,
  });

  // JSON으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'plantSpeciesId': plantSpeciesId,
      'growthStage': growthStage.name,
      'wateringFrequency': wateringFrequency,
      'lastWateredDate': lastWateredDate.toIso8601String(),
      'nextWateringDate': nextWateringDate.toIso8601String(),
      'imagePath': imagePath,
      'notes': notes,
    };
  }

  // JSON에서 객체 생성
  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      plantSpeciesId: map['plantSpeciesId'],
      growthStage: map['growthStage'] != null
          ? GrowthStage.fromString(map['growthStage'])
          : GrowthStage.mature,
      wateringFrequency: map['wateringFrequency'],
      lastWateredDate: DateTime.parse(map['lastWateredDate']),
      nextWateringDate: DateTime.parse(map['nextWateringDate']),
      imagePath: map['imagePath'],
      notes: map['notes'],
    );
  }

  // 물 준 후 날짜 업데이트
  Plant copyWithWatered() {
    final now = DateTime.now();
    final nextDate = now.add(Duration(days: wateringFrequency));

    return Plant(
      id: id,
      name: name,
      species: species,
      plantSpeciesId: plantSpeciesId,
      growthStage: growthStage,
      wateringFrequency: wateringFrequency,
      lastWateredDate: now,
      nextWateringDate: nextDate,
      imagePath: imagePath,
      notes: notes,
    );
  }

  // 일반 복사 메서드
  Plant copyWith({
    int? id,
    String? name,
    String? species,
    String? plantSpeciesId,
    GrowthStage? growthStage,
    int? wateringFrequency,
    DateTime? lastWateredDate,
    DateTime? nextWateringDate,
    String? imagePath,
    String? notes,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      plantSpeciesId: plantSpeciesId ?? this.plantSpeciesId,
      growthStage: growthStage ?? this.growthStage,
      wateringFrequency: wateringFrequency ?? this.wateringFrequency,
      lastWateredDate: lastWateredDate ?? this.lastWateredDate,
      nextWateringDate: nextWateringDate ?? this.nextWateringDate,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
    );
  }

  // 물줄 날짜까지 남은 일수
  int get daysUntilWatering {
    final difference = nextWateringDate.difference(DateTime.now());
    return difference.inDays;
  }

  // 물 줘야 하는지 확인
  bool get needsWatering {
    return DateTime.now().isAfter(nextWateringDate);
  }
}
