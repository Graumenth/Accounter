import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'constants/app_colors.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/company_report/company_report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;

  const MyApp({
    super.key,
    required this.prefs,
  });

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late Locale _locale;

  @override
  void initState() {
    super.initState();

    final savedTheme = widget.prefs.getBool('theme_mode');
    if (savedTheme != null) {
      _isDarkMode = savedTheme;
    } else {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _isDarkMode = brightness == Brightness.dark;
    }

    final savedLocale = widget.prefs.getString('locale');
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    } else {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      _locale = systemLocale.languageCode == 'tr' ? const Locale('tr') : const Locale('en');
    }
  }

  void toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    await widget.prefs.setBool('theme_mode', isDark);
  }

  void setLocale(String localeCode) async {
    setState(() {
      _locale = Locale(localeCode);
    });
    await widget.prefs.setString('locale', localeCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accounter',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
      ],
      locale: _locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/statistics': (context) => const StatisticsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/company-report') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => CompanyReportScreen(
              companyId: args['companyId'],
              companyName: args['companyName'],
              startDate: args['startDate'],
              endDate: args['endDate'],
            ),
          );
        }
        return null;
      },
    );
  }
}