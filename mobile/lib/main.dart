import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/presentation/screens/investment_input_screen.dart';
import 'package:mobile/src/presentation/screens/results_screen.dart';
import 'package:mobile/src/providers/tab_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AppRoot()));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: <Locale>[
        Locale('pt', 'BR'),
        Locale('en'),
      ],
      locale: Locale('pt', 'BR'),
      home: _HomeTabs(),
    );
  }
}

class _HomeTabs extends StatelessWidget {
  const _HomeTabs();

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: tabController,
      tabBar: CupertinoTabBar(items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.chart_bar), label: 'Simulador'),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.list_bullet), label: 'Resultados'),
      ]),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (BuildContext _) => const InvestmentInputScreen());
          case 1:
            return CupertinoTabView(builder: (BuildContext _) => const ResultsScreen());
          default:
            return CupertinoTabView(builder: (BuildContext _) => const InvestmentInputScreen());
        }
      },
      backgroundColor: CupertinoColors.systemBackground,
    );
  }
}
