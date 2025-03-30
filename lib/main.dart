// ignore_for_file: deprecated_member_use, must_be_immutable, depend_on_referenced_packages

import 'package:device_preview/device_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:zenzen/config/router/app_router.dart';
// ignore: unused_import
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/firebase_options.dart';
import 'data/local/service/user_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => ProviderScope(child: MyApp()), // Wrap your app
  //   ),
  // );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      routerConfig: RouteConfig.returnRouter(),
      title: 'Flutter Demo',
      // theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),

      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        // Add other locales your app supports
      ],
    );
  }
}
