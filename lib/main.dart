import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';


// app-wide exports
import 'core/app_export.dart';

// REAL notification service (the one we created)
import 'services/notification_service.dart';

// home
import 'presentation/dashboard_screen/dashboard_screen.dart';


// screens
import 'presentation/government_schemes_screen/government_schemes_screen.dart';
import 'presentation/weather_forecast_screen/weather_forecast_screen.dart';
import 'presentation/soil_analysis_screen/soil_analysis_screen.dart';
import 'presentation/crop_recommendations_screen/crop_recommendations_screen.dart';
import 'presentation/mandi_prices_screen/mandi_prices_screen.dart';
import 'presentation/profile_screen/profile_screen.dart';
import 'presentation/tasks_screen/tasks_screen.dart';
import 'presentation/farmer_registration_screen/farmer_registration_screen.dart';
import 'presentation/tasks_screen/add_task/add_task_screen.dart';
import 'presentation/auth/login_screen.dart';   // already imported by you?


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  // initialize REAL notifications
  await NotificationService.instance.init();

  // catch uncaught Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // ignore: avoid_print
    print('FlutterError: ${details.exceptionAsString()}');
  };

  runZonedGuarded(() {
    runApp(const CropWiseApp());
  }, (error, stack) {
    // ignore: avoid_print
    print('Uncaught zone error: $error\n$stack');
  });
}

class CropWiseApp extends StatelessWidget {
  const CropWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'CropWise',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,

          // 🔥 Use unified route table
          routes: AppRoutes.routes,

          // 🔥 Load dashboard as the initial route
          initialRoute: AppRoutes.dashboard,

          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Page not found')),
                body: Center(
                  child: Text('No route defined for "${settings.name}"'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
