import 'package:flutter/material.dart';

import 'config/app_routes.dart';

import 'config/app_theme.dart';

/// Navigator key global agar lapisan non-widget (mis. interceptor Dio)
/// bisa melakukan navigasi — dipakai untuk redirect ke login saat 401.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class MarkUpApp extends StatelessWidget {
  const MarkUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mark-Up',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}