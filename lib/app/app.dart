import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../utils/constants.dart';
import 'theme.dart';

class RishtaAdsApp extends StatelessWidget {
  const RishtaAdsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
