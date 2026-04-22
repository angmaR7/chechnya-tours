import 'package:flutter/material.dart';

import '../core/navigation/app_navigator.dart';
import 'routes.dart';
import 'theme.dart';

class ChechnyaToursApp extends StatelessWidget {
  const ChechnyaToursApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chechnya Tours',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}