import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class LightMeterService {
  static final LightMeterService _instance = LightMeterService._internal();
  factory LightMeterService() => _instance;
  LightMeterService._internal();

  CameraController? _controller;
  List<CameraDescription>? _cameras;

  // 카메라 초기화
  Future<void> initializeCamera() async {
    if (_controller != null && _controller!.value.isInitialized) {
      return; // 이미 초기화됨
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('사용 가능한 카메라가 없습니다');
      }

      // 후면 카메라 사용
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.low, // 낮은 해상도로 빠른 처리
        enableAudio: false,
      );

      await _controller!.initialize();
    } catch (e) {
      throw Exception('카메라 초기화 실패: $e');
    }
  }

  // 카메라 컨트롤러 가져오기
  CameraController? get controller => _controller;

  // 광량 측정 (Lux 추정)
  Future<double> measureLight() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('카메라가 초기화되지 않았습니다');
    }

    try {
      // 이미지 캡처
      final XFile imageFile = await _controller!.takePicture();
      final bytes = await imageFile.readAsBytes();

      // 이미지 디코딩
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('이미지 디코딩 실패');
      }

      // 이미지 밝기 계산 (평균 휘도)
      final brightness = _calculateAverageBrightness(image);

      // 밝기를 lux로 변환 (근사치)
      final lux = _brightnessToLux(brightness);

      return lux;
    } catch (e) {
      throw Exception('광량 측정 실패: $e');
    }
  }

  // 이미지의 평균 밝기 계산 (0-255)
  double _calculateAverageBrightness(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;

    // 샘플링: 10픽셀마다 하나씩만 측정 (성능 최적화)
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);

        // RGB를 휘도로 변환 (ITU-R BT.709 표준)
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final luminance = (0.2126 * r + 0.7152 * g + 0.0722 * b).round();

        totalBrightness += luminance;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalBrightness / pixelCount : 0;
  }

  // 밝기 값을 lux로 변환 (경험적 공식)
  // 참고: 이는 근사치이며, 실제 조도계만큼 정확하지 않습니다
  double _brightnessToLux(double brightness) {
    // 밝기 0-255를 lux 값으로 매핑
    // 로그 스케일 사용 (실제 조도는 로그 스케일)

    if (brightness < 10) {
      // 매우 어두움: 0-10 lux
      return brightness;
    } else if (brightness < 50) {
      // 어두움: 10-100 lux
      return 10 + (brightness - 10) * 2.25;
    } else if (brightness < 100) {
      // 보통: 100-500 lux
      return 100 + (brightness - 50) * 8;
    } else if (brightness < 150) {
      // 밝음: 500-2000 lux
      return 500 + (brightness - 100) * 30;
    } else if (brightness < 200) {
      // 매우 밝음: 2000-10000 lux
      return 2000 + (brightness - 150) * 160;
    } else {
      // 극도로 밝음: 10000+ lux (직사광선)
      return 10000 + (brightness - 200) * 400;
    }
  }

  // 광량 레벨 판단
  String getLightLevel(double lux) {
    if (lux < 50) {
      return '매우 어두움';
    } else if (lux < 200) {
      return '어두움';
    } else if (lux < 500) {
      return '약간 어두움';
    } else if (lux < 1000) {
      return '보통';
    } else if (lux < 5000) {
      return '밝음';
    } else if (lux < 10000) {
      return '매우 밝음';
    } else {
      return '직사광선';
    }
  }

  // 광량에 따른 적합한 식물 조언
  String getLightRecommendation(double lux) {
    if (lux < 200) {
      return '극저광 식물에 적합 (산세베리아, 아글라오네마)';
    } else if (lux < 500) {
      return '저광 식물에 적합 (스킨답서스, 필로덴드론)';
    } else if (lux < 1000) {
      return '중광 식물에 적합 (몬스테라, 관음죽)';
    } else if (lux < 5000) {
      return '고광 식물에 적합 (고무나무, 드라세나)';
    } else if (lux < 10000) {
      return '직사광선을 좋아하는 식물에 적합 (선인장, 다육식물)';
    } else {
      return '매우 강한 직사광선 - 대부분의 실내 식물에는 과함';
    }
  }

  // 카메라 해제
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
