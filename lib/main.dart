import 'package:aadi/configs/env_config.dart';
import 'package:aadi/configs/firebase_options.dart';
import 'package:aadi/pages/main_page.dart';
import 'package:aadi/provider/main_page_provider.dart';
import 'package:aadi/utils/colors.dart';
import 'package:aadi/utils/crash_reporting_services.dart';
import 'package:aadi/utils/openai.dart';
import 'package:aadi/utils/performance_monitoring_services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ENV
  await EnvConfig.load();
  EnvConfig.validate();

  // FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  await CrashReportingService.instance.initialize();
  await PerformanceMonitoringService.instance.initialize();

  // ADMOB
  try {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
        testDeviceIds: ['33BE2250B43518CCDA7DE426D04EE231'],
      ),
    );
  } catch (e) {
    print('Error initializing AdMob: $e');
  }

  // OPENAI
  await OpenAIService.instance.initialize(EnvConfig.openaiApiKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MainPageProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
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
      debugShowCheckedModeBanner: false,
      home: const MainPage(),
    );
  }
}
