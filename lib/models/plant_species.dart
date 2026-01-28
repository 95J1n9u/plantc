class PlantSpecies {
  final String id;
  final String commonName;
  final String scientificName;
  final List<String> otherNames;
  final String category;
  final String difficulty;
  final Toxicity toxicity;
  final Size size;
  final String growthRate;
  final String imageUrl;
  final bool? isEdible;
  final String? harvestTime;

  final Watering watering;
  final Light light;
  final Fertilizing fertilizing;
  final Temperature temperature;
  final Humidity humidity;
  final Soil soil;
  final Pruning pruning;
  final Repotting repotting;
  final List<CommonProblem> commonProblems;
  final CareGuide careGuide;
  final Harvest? harvest;
  final Map<String, GrowthStageGuide>? growthStageGuides; // 성장 단계별 가이드

  PlantSpecies({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.otherNames,
    required this.category,
    required this.difficulty,
    required this.toxicity,
    required this.size,
    required this.growthRate,
    required this.imageUrl,
    this.isEdible,
    this.harvestTime,
    required this.watering,
    required this.light,
    required this.fertilizing,
    required this.temperature,
    required this.humidity,
    required this.soil,
    required this.pruning,
    required this.repotting,
    required this.commonProblems,
    required this.careGuide,
    this.harvest,
    this.growthStageGuides,
  });

  factory PlantSpecies.fromJson(Map<String, dynamic> json) {
    return PlantSpecies(
      id: json['id'],
      commonName: json['commonName'],
      scientificName: json['scientificName'],
      otherNames: List<String>.from(json['otherNames']),
      category: json['category'],
      difficulty: json['difficulty'],
      toxicity: Toxicity.fromJson(json['toxicity']),
      size: Size.fromJson(json['size']),
      growthRate: json['growthRate'],
      imageUrl: json['imageUrl'],
      isEdible: json['isEdible'],
      harvestTime: json['harvestTime'],
      watering: Watering.fromJson(json['watering']),
      light: Light.fromJson(json['light']),
      fertilizing: Fertilizing.fromJson(json['fertilizing']),
      temperature: Temperature.fromJson(json['temperature']),
      humidity: Humidity.fromJson(json['humidity']),
      soil: Soil.fromJson(json['soil']),
      pruning: Pruning.fromJson(json['pruning']),
      repotting: Repotting.fromJson(json['repotting']),
      commonProblems: (json['commonProblems'] as List)
          .map((e) => CommonProblem.fromJson(e))
          .toList(),
      careGuide: CareGuide.fromJson(json['careGuide']),
      harvest: json['harvest'] != null ? Harvest.fromJson(json['harvest']) : null,
      growthStageGuides: json['growthStageGuides'] != null
          ? (json['growthStageGuides'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, GrowthStageGuide.fromJson(value)),
            )
          : null,
    );
  }
}

class Toxicity {
  final bool pets;
  final bool humans;
  final String description;

  Toxicity({
    required this.pets,
    required this.humans,
    required this.description,
  });

  factory Toxicity.fromJson(Map<String, dynamic> json) {
    return Toxicity(
      pets: json['pets'],
      humans: json['humans'],
      description: json['description'],
    );
  }
}

class Size {
  final String indoor;
  final String outdoor;

  Size({
    required this.indoor,
    required this.outdoor,
  });

  factory Size.fromJson(Map<String, dynamic> json) {
    return Size(
      indoor: json['indoor'],
      outdoor: json['outdoor'],
    );
  }
}

class Watering {
  final int frequency;
  final SeasonFrequency season;
  final String description;
  final String tips;

  Watering({
    required this.frequency,
    required this.season,
    required this.description,
    required this.tips,
  });

  factory Watering.fromJson(Map<String, dynamic> json) {
    return Watering(
      frequency: json['frequency'],
      season: SeasonFrequency.fromJson(json['season']),
      description: json['description'],
      tips: json['tips'],
    );
  }
}

class SeasonFrequency {
  final int spring;
  final int summer;
  final int fall;
  final int winter;

  SeasonFrequency({
    required this.spring,
    required this.summer,
    required this.fall,
    required this.winter,
  });

  factory SeasonFrequency.fromJson(Map<String, dynamic> json) {
    return SeasonFrequency(
      spring: json['spring'],
      summer: json['summer'],
      fall: json['fall'],
      winter: json['winter'],
    );
  }

  // 현재 계절에 맞는 주기 가져오기
  int getCurrentSeasonFrequency() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return spring;
    if (month >= 6 && month <= 8) return summer;
    if (month >= 9 && month <= 11) return fall;
    return winter;
  }
}

class Light {
  final String requirement;
  final String level;
  final String description;
  final String tips;

  Light({
    required this.requirement,
    required this.level,
    required this.description,
    required this.tips,
  });

  factory Light.fromJson(Map<String, dynamic> json) {
    return Light(
      requirement: json['requirement'],
      level: json['level'],
      description: json['description'],
      tips: json['tips'],
    );
  }
}

class Fertilizing {
  final int frequency;
  final SeasonFrequency season;
  final String type;
  final String description;
  final String tips;

  Fertilizing({
    required this.frequency,
    required this.season,
    required this.type,
    required this.description,
    required this.tips,
  });

  factory Fertilizing.fromJson(Map<String, dynamic> json) {
    return Fertilizing(
      frequency: json['frequency'],
      season: SeasonFrequency.fromJson(json['season']),
      type: json['type'],
      description: json['description'],
      tips: json['tips'],
    );
  }
}

class Temperature {
  final String ideal;
  final String min;
  final String max;
  final String description;

  Temperature({
    required this.ideal,
    required this.min,
    required this.max,
    required this.description,
  });

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      ideal: json['ideal'],
      min: json['min'],
      max: json['max'],
      description: json['description'],
    );
  }
}

class Humidity {
  final String level;
  final String description;
  final String tips;

  Humidity({
    required this.level,
    required this.description,
    required this.tips,
  });

  factory Humidity.fromJson(Map<String, dynamic> json) {
    return Humidity(
      level: json['level'],
      description: json['description'],
      tips: json['tips'],
    );
  }
}

class Soil {
  final String type;
  final String mix;
  final String ph;

  Soil({
    required this.type,
    required this.mix,
    required this.ph,
  });

  factory Soil.fromJson(Map<String, dynamic> json) {
    return Soil(
      type: json['type'],
      mix: json['mix'],
      ph: json['ph'],
    );
  }
}

class Pruning {
  final String frequency;
  final String description;
  final String bestTime;

  Pruning({
    required this.frequency,
    required this.description,
    required this.bestTime,
  });

  factory Pruning.fromJson(Map<String, dynamic> json) {
    return Pruning(
      frequency: json['frequency'],
      description: json['description'],
      bestTime: json['bestTime'],
    );
  }
}

class Repotting {
  final String frequency;
  final String bestTime;
  final List<String> signs;

  Repotting({
    required this.frequency,
    required this.bestTime,
    required this.signs,
  });

  factory Repotting.fromJson(Map<String, dynamic> json) {
    return Repotting(
      frequency: json['frequency'],
      bestTime: json['bestTime'],
      signs: List<String>.from(json['signs']),
    );
  }
}

class CommonProblem {
  final String symptom;
  final List<String> causes;
  final String solution;

  CommonProblem({
    required this.symptom,
    required this.causes,
    required this.solution,
  });

  factory CommonProblem.fromJson(Map<String, dynamic> json) {
    return CommonProblem(
      symptom: json['symptom'],
      causes: List<String>.from(json['causes']),
      solution: json['solution'],
    );
  }
}

class CareGuide {
  final String beginner;
  final String placement;
  final String specialTips;

  CareGuide({
    required this.beginner,
    required this.placement,
    required this.specialTips,
  });

  factory CareGuide.fromJson(Map<String, dynamic> json) {
    return CareGuide(
      beginner: json['beginner'],
      placement: json['placement'],
      specialTips: json['specialTips'],
    );
  }
}

class Harvest {
  final String when;
  final String how;
  final String frequency;
  final String? tips;

  Harvest({
    required this.when,
    required this.how,
    required this.frequency,
    this.tips,
  });

  factory Harvest.fromJson(Map<String, dynamic> json) {
    return Harvest(
      when: json['when'],
      how: json['how'],
      frequency: json['frequency'],
      tips: json['tips'],
    );
  }
}

class GrowthStageGuide {
  final String stageName;
  final String description;
  final int? wateringAdjustment; // 물주기 조정 (일 단위, null이면 변경 없음)
  final String wateringTips;
  final String careTips;
  final List<String> keyPoints;
  final String? expectedDuration; // 이 단계가 얼마나 지속되는지

  GrowthStageGuide({
    required this.stageName,
    required this.description,
    this.wateringAdjustment,
    required this.wateringTips,
    required this.careTips,
    required this.keyPoints,
    this.expectedDuration,
  });

  factory GrowthStageGuide.fromJson(Map<String, dynamic> json) {
    return GrowthStageGuide(
      stageName: json['stageName'],
      description: json['description'],
      wateringAdjustment: json['wateringAdjustment'],
      wateringTips: json['wateringTips'],
      careTips: json['careTips'],
      keyPoints: List<String>.from(json['keyPoints']),
      expectedDuration: json['expectedDuration'],
    );
  }
}
