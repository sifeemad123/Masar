import 'package:flutter/material.dart';
import 'package:masar/Screens/home_screen.dart';
import 'package:masar/Screens/main_screen.dart';
import 'package:masar/Screens/onboarding_screens.dart';
import 'package:masar/Screens/setup_screen.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _firstTime = true;
  Future<void> _isFirstTime() async {
    final pref = await SharedPreferences.getInstance();
    final isFirstTime = pref.getBool('isFirstTime') ?? true;
    setState(() {
      _firstTime = isFirstTime;
    });
    Future.delayed(Duration(seconds: 3), () {
      if (!mounted) return;
      if (_firstTime) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OnboardingScreens()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 100),
            duration: Duration(seconds: 2),
            curve: Curves.ease,
            builder: (context, value, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: value,
                      height: value,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(75),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        size: value * 0.50,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(height: 25),
                    Text(
                      "مسار",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: value * 0.50,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "يومك... مظبوط",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: value * 0.20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 25),
                    Row(
                      spacing: 15,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: value * 0.10,
                          height: value * 0.10,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.border),
                          ),
                        ),
                        Container(
                          width: value * 0.10,
                          height: value * 0.10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.border),
                          ),
                        ),
                        Container(
                          width: value * 0.10,
                          height: value * 0.10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.border),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
