import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mounarch/Screen/Splash_Screen/splash_screen.dart';
import 'package:mounarch/Utils/routes.dart';
import 'package:mounarch/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> requestCameraPermission() async {
  // Request camera permission
  PermissionStatus status = await Permission.camera.request();

  // Check if the permission is granted
  if (status.isGranted) {
    // Permission is granted, you can open the camera
    log("Camera permission granted");
  } else if (status.isDenied) {
    // Permission denied, you can show a message to the user
    log("Camera permission denied");
    // Optionally, guide the user to the settings to enable the permission manually
    openAppSettings();
  } else if (status.isPermanentlyDenied) {
    // Permission is permanently denied, show a message to the user
    log("Camera permission permanently denied");
    openAppSettings(); // Direct user to app settings to enable the permission
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mounarch',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.pink.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        initialRoute: '/splash_screen',
        getPages: Routes.pages,
        // home: SplashScreen(),
      ),
    );
  }
}
