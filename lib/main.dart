import 'package:cognitiveroulletegame/data/colors_game_notifier.dart';
import 'package:cognitiveroulletegame/data/game_notifier.dart';
import 'package:cognitiveroulletegame/data/level_notifier.dart';
import 'package:cognitiveroulletegame/data/player_notifier.dart';
import 'package:cognitiveroulletegame/data/player_progress_notifier.dart';
import 'package:cognitiveroulletegame/data/user_notifier.dart';
import 'package:cognitiveroulletegame/firebase_secondary_options.dart';
import 'package:cognitiveroulletegame/pages/diviner_page.dart';
import 'package:cognitiveroulletegame/pages/home_page.dart';
import 'package:cognitiveroulletegame/pages/initial_loading_screen.dart';
import 'package:cognitiveroulletegame/pages/on_boarding_page.dart';
import 'package:cognitiveroulletegame/services/image_cache_service.dart';
import 'package:cognitiveroulletegame/services/snackbar_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:cognitiveroulletegame/services/sync_service.dart';
import 'package:cognitiveroulletegame/shared/user_preferences.dart';
import 'firebase_primary_options.dart';

import 'package:cognitiveroulletegame/data/database_helper.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await UserPreferences().initPreferences();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Firebase.initializeApp(
    name: 'esp32colores',
    options: FirebaseSecondaryOptions.currentPlatform,
  );

  SyncService syncService = SyncService();
  await syncService.syncLevelData();
  await syncService.syncGameData();
  await syncService.syncColorsGameData();
  await syncService.syncPlayerData();
  await syncService.syncPlayerProgressData();

  DatabaseHelper dbHelper = DatabaseHelper.instance;

  await dbHelper.database;
  await dbHelper.sendDataToBackend('levels');
  await dbHelper.sendDataToBackend('player_progress');
  await dbHelper.sendDataToBackend('games');
  await dbHelper.sendDataToBackend('colors_games');

  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();

  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final userPreferences = UserPreferences();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  MainApp({super.key}) {
    snackbarService.init(_scaffoldMessengerKey);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserNotifier()..init()),
        ChangeNotifierProvider(create: (context) => PlayerNotifier()..init()),
        ChangeNotifierProvider(create: (context) => LevelNotifier()..init()),
        ChangeNotifierProvider(
            create: (context) => PlayerProgressNotifier()..init()),
        ChangeNotifierProvider(create: (context) => GameNotifier()..init()),
        ChangeNotifierProvider(
            create: (context) => ColorsGameNotifier()..init()),
        // ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (context) => ImageCacheService()..init()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: _scaffoldMessengerKey,
        // theme: ThemeData().copyWith(useMaterial3: true),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff2C60FF),
            surface: const Color(0xffE4F3FA),
          ),
        ),
        // themeMode: theme.isLightTheme ? ThemeMode.light : ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: !userPreferences.areImagesDownloaded
            ? const InitialLoadingScreen()
            : const OnBoardingPage(),
        routes: {
          '/homepage': (context) => const HomePage(),
          '/divinerpage': (context) => const DivinerPage(),
        },
      ),
    );
  }
}
