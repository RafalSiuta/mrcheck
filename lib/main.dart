import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mrcash/screens/mainscreen.dart';
import 'package:mrcash/screens/settingsscreen.dart';
import 'package:mrcash/utils/routes/custom_route.dart';
import 'package:provider/provider.dart';
import 'providers/cashprovider.dart';
import 'providers/settingsprovider.dart';
import 'providers/walletprovider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pl_PL';
  await initializeDateFormatting('pl_PL', null);

  Future<int> getAndroidVersion() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  final int androidVersion = await getAndroidVersion();

  if (Platform.isAndroid && androidVersion >= 35) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: null,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } else {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const Color ink = Color(0xFF0F0F0F);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, CashProvider>(
          create: (context) =>
              CashProvider(settings: context.read<SettingsProvider>()),
          update: (context, settings, previous) =>
              (previous?..updateSettings(settings)) ??
              CashProvider(settings: settings),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, WalletProvider>(
          create: (context) =>
              WalletProvider(settings: context.read<SettingsProvider>()),
          update: (context, settings, previous) =>
              (previous?..updateSettings(settings)) ??
              WalletProvider(settings: settings),
        ),
      ],
      child: MaterialApp(
        title: 'MrCash',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xfff5f5f5),
          textTheme: TextTheme(
            headlineLarge: GoogleFonts.exo2(
              textStyle: TextStyle(
                color: ink,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            headlineMedium: GoogleFonts.exo2(
              textStyle: TextStyle(
                fontSize: 18,
                color: ink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            labelMedium: GoogleFonts.exo2(
              textStyle: TextStyle(
                fontSize: 12,
                color: ink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            bodyMedium: GoogleFonts.exo2(
              textStyle: TextStyle(
                fontSize: 12,
                color: ink,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: ink,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: ink,
              side: const BorderSide(color: ink),
            ),
          ),
          splashColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          focusColor: Colors.transparent,
          cardTheme: const CardThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0.5,
          ),
          cardColor: Colors.white,
          navigationRailTheme: NavigationRailThemeData(
            labelType: NavigationRailLabelType.all,
            elevation: 0,
            groupAlignment: -0.2,
            useIndicator: true,
            indicatorColor: Colors.transparent,
            selectedIconTheme: const IconThemeData(
              color: ink,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Colors.grey,
            ),
            selectedLabelTextStyle: GoogleFonts.exo2(
              textStyle: const TextStyle(
                fontSize: 18,
                color: ink,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.none,
              ),
            ),
            unselectedLabelTextStyle: GoogleFonts.exo2(
              textStyle: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w300,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          iconTheme: const IconThemeData(
            color: ink,
            size: 18,
          ),
          switchTheme: SwitchThemeData(
            trackColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return ink;
              }
              return Colors.grey;
            }),
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            thumbColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey;
              }
              return Colors.white;
            }),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: ink,
            foregroundColor: ink,
            elevation: 0.2,
            splashColor: Colors.transparent,
            iconSize: 18,
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (route) => onGenerateRoute(route),
      ),
    );
  }

  static CustomPageRoute onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return CustomPageRoute(
            child: const Main(),
            settings: settings,
            direction: AxisDirection.left);

      case "/settings":
        return CustomPageRoute(
            child: const SettingsScreen(),
            settings: settings,
            direction: AxisDirection.left);
      default:
        return CustomPageRoute(
            child: const Main(),
            settings: settings,
            direction: AxisDirection.left);
    }
  }
}
