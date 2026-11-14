import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masar/Screens/main_screen.dart';
import 'package:masar/Screens/onboarding_screens.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entrance sequence (runs once)
  late final AnimationController _intro;
  // Ambient loop (rings + loader dots)
  late final AnimationController _loop;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoTurn;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    CurvedAnimation interval(double begin, double end, Curve curve) =>
        CurvedAnimation(
          parent: _intro,
          curve: Interval(begin, end, curve: curve),
        );

    _logoScale = Tween<double>(begin: 0.3, end: 1).animate(
      interval(0.0, 0.5, Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      interval(0.0, 0.2, Curves.easeOut),
    );
    _logoTurn = Tween<double>(begin: -0.08, end: 0).animate(
      interval(0.0, 0.5, Curves.easeOutCubic),
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      interval(0.4, 0.7, Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(interval(0.4, 0.7, Curves.easeOutCubic));

    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      interval(0.58, 0.85, Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(interval(0.58, 0.85, Curves.easeOutCubic));

    _loaderOpacity = Tween<double>(begin: 0, end: 1).animate(
      interval(0.78, 1.0, Curves.easeOut),
    );

    _intro.forward();
    _goNext();
  }

  Future<void> _goNext() async {
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      Future.delayed(const Duration(milliseconds: 3000)),
    ]);
    final pref = results.first as SharedPreferences;
    final isFirstTime = pref.getBool('isFirstTime') ?? true;

    if (!mounted) return;

    final Widget next =
    isFirstTime ? const OnboardingScreens() : const MainScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.04, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  Widget _blob({
    required double size,
    required Color color,
    required Alignment alignment,
    double phase = 0,
  }) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final t = _loop.value * 2 * math.pi + phase;
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(math.sin(t) * 14, math.cos(t) * 14),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.35),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pulseRing(double offset) {
    return AnimatedBuilder(
      animation: _loop,
      builder: (context, _) {
        final v = (_loop.value + offset) % 1.0;
        final scale = 1 + v * 0.9;
        final opacity = (1 - v) * 0.35;
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _logo() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _pulseRing(0.0),
          _pulseRing(0.5),
          FadeTransition(
            opacity: _logoOpacity,
            child: RotationTransition(
              turns: _logoTurn,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [AppColors.accent, AppColors.accentDark],
                    ),
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    size: 62,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loaderDots() {
    return FadeTransition(
      opacity: _loaderOpacity,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final wave =
              math.sin((_loop.value * 2 * math.pi) - (i * 0.9));
              final t = (wave + 1) / 2; // 0..1
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 8 + t * 6,
                height: 8,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    AppColors.accentLight,
                    AppColors.accent,
                    t,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.pearlLight,
              AppColors.background,
              AppColors.pearlDark,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _blob(
              size: 320,
              color: AppColors.secondary,
              alignment: const Alignment(-1.1, -0.9),
            ),
            _blob(
              size: 280,
              color: AppColors.warm,
              alignment: const Alignment(1.2, 0.95),
              phase: math.pi,
            ),
            SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    _logo(),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleOpacity,
                        child: const Text(
                          "مسار",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineOpacity,
                        child: const Text(
                          "يومك... مظبوط",
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                    _loaderDots(),
                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}