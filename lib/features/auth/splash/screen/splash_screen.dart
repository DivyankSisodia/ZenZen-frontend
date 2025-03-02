import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/constants.dart';
import '../../../../utils/providers/theme_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use kIsWeb instead of Platform checks
    if (!kIsWeb) {
      // For mobile platforms
      context.goNamed(RoutesName.intro);
    } else {
      // For web platform
      Future.delayed(const Duration(seconds: 2), () {
        context.goNamed(RoutesName.intro);
      });
    }

    // Alternatively, you could simplify to just:
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, '/intro');
    // });
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme changes
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.black.withOpacity(0.4)
              : Colors.white.withOpacity(0.93),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 400,
              width: double.infinity,
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  isDarkMode
                      ? 'assets/images/logo_dark.png'
                      : 'assets/images/logo_light.png',
                ),
              ),
            ),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 10.0,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    fit: BoxFit.contain,
                    isDarkMode
                        ? 'assets/images/app_slogan_dark.png'
                        : 'assets/images/app_slogan_light.png',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
