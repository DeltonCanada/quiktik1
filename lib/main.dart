import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'utils/app_localizations.dart';
import 'services/location_data_service.dart';
import 'services/queue_service.dart';
import 'services/favorites_service.dart';

void main() {
  // Initialize location data service
  LocationDataService().initializeData();
  runApp(const QuikTikApp());
}

class QuikTikApp extends StatefulWidget {
  const QuikTikApp({super.key});

  @override
  State<QuikTikApp> createState() => _QuikTikAppState();
}

class _QuikTikAppState extends State<QuikTikApp> {
  Locale _locale = const Locale('en', 'US');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        Provider(create: (_) => QueueService()),
      ],
      child: MaterialApp(
        title: 'QuikTik',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF1E88E5),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US'), Locale('fr', 'FR')],
        home: WelcomeScreen(onLocaleChange: _setLocale),
      ),
    );
  }
}
