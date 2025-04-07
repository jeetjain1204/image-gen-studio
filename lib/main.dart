import 'dart:io';
import 'dart:typed_data';
import 'package:aadi/env_config.dart';
import 'package:aadi/firebase_options.dart';
import 'package:aadi/home_page.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/utils/crash_reporting_services.dart';
import 'package:aadi/utils/openai.dart';
import 'package:aadi/utils/performance_monitoring_services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvConfig.load();
  EnvConfig.validate();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  try {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        testDeviceIds: [
          '33BE2250B43518CCDA7DE426D04EE231'
        ], // Add your test device ID
      ),
    );
    print('AdMob initialized successfully');
  } catch (e) {
    print('Error initializing AdMob: $e');
  }

  await CrashReportingService.instance.initialize();

  await PerformanceMonitoringService.instance.initialize();

  await OpenAIService.instance.initialize(EnvConfig.openaiApiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aadi',
      theme: ThemeData(
        scaffoldBackgroundColor: white,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryDark2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: white,
          foregroundColor: primaryDark,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: primaryDark,
            fontSize: 22,
            letterSpacing: 1,
          ),
          iconTheme: IconThemeData(color: primaryDark, weight: 1),
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(iconColor: WidgetStatePropertyAll(primaryDark)),
        ),
        indicatorColor: primaryDark,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<Uint8List?> handleImageAndText(
  File? imageFile,
  String prompt,
  String style,
  String featureType,
) async {
  try {
    // Use the appropriate method based on whether an image is provided
    if (imageFile != null) {
      return await OpenAIService.instance.generateImageFromImageAndText(
        imageFile: imageFile,
        prompt: prompt,
        model: 'dall-e-2',
        size: '512x512',
        n: 1,
        isVariation: false,
      );
    } else {
      return await OpenAIService.instance.generateImageFromText(
        prompt: prompt,
        model: 'dall-e-2',
        size: '512x512',
        quality: 'standard',
        style: 'vivid',
        n: 1,
      );
    }
  } catch (e) {
    debugPrint('Error processing image and text: $e');
    return null;
  }
}
