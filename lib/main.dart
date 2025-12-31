import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrcash/screens/mainscreen.dart';
import 'package:mrcash/screens/settingsscreen.dart';
import 'package:mrcash/utils/routes/custom_route.dart';
import 'package:provider/provider.dart';
import 'providers/cashprovider.dart';
import 'providers/settingsprovider.dart';
import 'providers/walletprovider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
            headlineLarge: GoogleFonts.exo2(
                textStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 32,
                    fontWeight: FontWeight.w600
                )),
            headlineMedium: GoogleFonts.exo2(
              textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none),
            ),
            labelMedium: GoogleFonts.exo2(
              textStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none),
            ),
            bodyMedium: GoogleFonts.exo2(
              textStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none),
            ),
          ),
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          focusColor: Colors.transparent,
          cardTheme: CardThemeData(
            surfaceTintColor: Colors.white70,
            elevation: 0.5,

          ),
          navigationRailTheme: NavigationRailThemeData(
            labelType: NavigationRailLabelType.all,
            elevation: 0,
            groupAlignment: -0.2,
            useIndicator: true,
            indicatorColor: Colors.transparent,
            selectedIconTheme: IconThemeData(
              color: Colors.amber
            ),
            unselectedIconTheme: IconThemeData(
              color: Colors.grey
            ),
            selectedLabelTextStyle: GoogleFonts.exo2(
              textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none),
            ),
            unselectedLabelTextStyle: GoogleFonts.exo2(
              textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w300,
                  decoration: TextDecoration.none),
            )
          ),
          iconTheme: IconThemeData(
            color: Colors.black54,
            size: 18
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.transparent,
              elevation: 0.2,
              splashColor: Colors.transparent,
              iconSize: 18,

          )
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
