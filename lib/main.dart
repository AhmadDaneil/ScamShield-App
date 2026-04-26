import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/scan/scan_cubit.dart';
import 'cubits/history/history_cubit.dart';
import 'cubits/navigation/navigation_cubit.dart';
import 'services/model_service.dart';
import 'services/database_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final modelService    = ModelService();
  final databaseService = DatabaseService();
  await databaseService.init();

  if (!modelService.isLoaded) {
  await modelService.loadModel(); // only when needed
}

  runApp(ScamShieldApp(
    modelService: modelService,
    databaseService: databaseService,
  ));
}

class ScamShieldApp extends StatelessWidget {
  final ModelService modelService;
  final DatabaseService databaseService;

  const ScamShieldApp({
    super.key,
    required this.modelService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) => ScanCubit(
            modelService: modelService,
            databaseService: databaseService,
          ),
        ),
        BlocProvider(
          create: (_) => HistoryCubit(
            databaseService: databaseService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'ScamShield',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // ✅ Pass modelService directly to SplashScreen
        home: SplashScreen(modelService: modelService),
      ),
    );
  }
}