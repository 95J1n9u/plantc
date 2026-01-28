import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/light_meter_service.dart';
import '../models/plant.dart';
import '../models/plant_species.dart';
import '../services/plant_database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';

class LightMeterScreen extends StatefulWidget {
  final Plant? plant; // 특정 식물 체크용 (선택사항)

  const LightMeterScreen({super.key, this.plant});

  @override
  State<LightMeterScreen> createState() => _LightMeterScreenState();
}

class _LightMeterScreenState extends State<LightMeterScreen> {
  final LightMeterService _lightMeter = LightMeterService();
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isMeasuring = false;
  double? _measuredLux;
  String? _error;
  PlantSpecies? _plantSpecies;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadPlantSpecies();
  }

  Future<void> _loadPlantSpecies() async {
    if (widget.plant?.plantSpeciesId != null) {
      _plantSpecies = PlantDatabaseService().getSpeciesById(widget.plant!.plantSpeciesId!);
      setState(() {});
    }
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
      _error = null;
    });

    try {
      await _lightMeter.initializeCamera();
      setState(() {
        _isInitialized = true;
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitializing = false;
      });
    }
  }

  Future<void> _measureLight() async {
    if (_isMeasuring) return;

    setState(() {
      _isMeasuring = true;
      _error = null;
    });

    try {
      final lux = await _lightMeter.measureLight();
      setState(() {
        _measuredLux = lux;
        _isMeasuring = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isMeasuring = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('측정 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _lightMeter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.plant != null ? '${widget.plant!.name} 광량 측정' : '광량계'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && !_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '카메라 초기화 실패',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('카메라 초기화 중...'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 카메라 프리뷰
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _lightMeter.controller!.value.aspectRatio,
                  child: CameraPreview(_lightMeter.controller!),
                ),
              ),
              // 가이드 오버레이
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.center_focus_strong,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              // 안내 텍스트
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '카메라를 측정하려는 위치로 향하게 하세요\n식물이 있는 곳의 빛을 측정합니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 측정 결과 및 컨트롤
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusXLarge),
                topRight: Radius.circular(AppTheme.radiusXLarge),
              ),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Column(
              children: [
                // 측정 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isMeasuring ? null : _measureLight,
                    icon: _isMeasuring
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.camera_alt),
                    label: Text(_isMeasuring ? '측정 중...' : '광량 측정하기'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLarge),

                // 측정 결과
                if (_measuredLux != null) ...[
                  Expanded(child: _buildResults()),
                ] else ...[
                  const Expanded(
                    child: Center(
                      child: Text(
                        '측정 버튼을 눌러 광량을 확인하세요',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_measuredLux == null) return const SizedBox();

    final lux = _measuredLux!;
    final level = _lightMeter.getLightLevel(lux);
    final recommendation = _lightMeter.getLightRecommendation(lux);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Lux 값 표시
          AppCard(
            elevated: true,
            color: AppTheme.success.withOpacity(0.05),
            child: Column(
              children: [
                Text(
                  '측정된 광량',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      lux.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Text(
                      'lux',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 일반 추천
          AppCard(
            color: AppTheme.info.withOpacity(0.05),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(Icons.lightbulb_outline, color: AppTheme.info, size: 20),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Text(
                    recommendation,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // 특정 식물에 대한 판단
          if (widget.plant != null && _plantSpecies != null) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            _buildPlantSpecificAdvice(lux),
          ],
        ],
      ),
    );
  }

  Widget _buildPlantSpecificAdvice(double lux) {
    if (_plantSpecies == null) return const SizedBox();

    final lightLevel = _plantSpecies!.light.level;
    bool isGood = false;
    String advice = '';
    Color bgColor = Colors.orange;
    IconData icon = Icons.warning;

    // 광량 레벨에 따른 적합성 판단
    if (lightLevel.contains('강한 직사광선') || lightLevel.contains('직사광')) {
      isGood = lux >= 5000;
      advice = isGood
          ? '이 위치는 ${widget.plant!.name}에게 완벽합니다!'
          : lux < 1000
              ? '너무 어둡습니다. 더 밝은 곳으로 옮겨주세요.'
              : '조금 더 밝은 곳이 좋습니다.';
    } else if (lightLevel.contains('밝은 간접광') || lightLevel.contains('밝은 빛')) {
      isGood = lux >= 1000 && lux < 10000;
      advice = isGood
          ? '이 위치는 ${widget.plant!.name}에게 완벽합니다!'
          : lux < 1000
              ? '조금 더 밝은 곳이 좋습니다.'
              : '직사광선이 너무 강합니다. 커튼으로 빛을 조절해주세요.';
    } else if (lightLevel.contains('중간') || lightLevel.contains('반음지')) {
      isGood = lux >= 500 && lux < 5000;
      advice = isGood
          ? '이 위치는 ${widget.plant!.name}에게 완벽합니다!'
          : lux < 500
              ? '너무 어둡습니다. 창가 쪽으로 옮겨주세요.'
              : '빛이 너무 강합니다. 창문에서 조금 떨어진 곳이 좋습니다.';
    } else {
      // 그늘, 낮은 광량
      isGood = lux >= 50 && lux < 1000;
      advice = isGood
          ? '이 위치는 ${widget.plant!.name}에게 완벽합니다!'
          : lux < 50
              ? '매우 어둡습니다. 인공 조명을 추가하세요.'
              : '빛이 강합니다. 창에서 더 떨어진 곳이나 그늘진 곳이 좋습니다.';
    }

    if (isGood) {
      bgColor = Colors.green;
      icon = Icons.check_circle;
    }

    return AppCard(
      elevated: true,
      color: bgColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: bgColor, size: 24),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plant!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: bgColor,
                          ),
                    ),
                    Text(
                      _plantSpecies!.commonName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advice,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Text(
                  '권장 조건: ${_plantSpecies!.light.requirement}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
