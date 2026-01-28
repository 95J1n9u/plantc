import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/plant_provider.dart';
import 'screens/plant_list_screen.dart';
import 'services/notification_service.dart';
import 'services/plant_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 서비스 초기화
  await NotificationService.instance.initialize();

  // 식물 종 데이터베이스 로드
  await PlantDatabaseService().loadPlantSpecies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlantProvider(),
      child: MaterialApp(
        title: '식물 관리',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const PlantListScreen(),
      ),
    );
  }
}
