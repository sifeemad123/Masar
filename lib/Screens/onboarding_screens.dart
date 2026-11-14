import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masar/Screens/setup_screen.dart';
import 'package:masar/theme/AppColors.dart';

class _OnboardData {
  final IconData icon;
  final List<IconData> chips;
  final String title;
  final String desc;

  const _OnboardData({
    required this.icon,
    required this.chips,
    required this.title,
    required this.desc,
  });
}

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens>
    with SingleTickerProviderStateMixin {
  static const List<_OnboardData> _pages = [
    _OnboardData(
      icon: Icons.today_rounded,
      chips: [Icons.alarm_rounded, Icons.task_alt_rounded],
      title: "يومك في نظرة واحدة",
      desc: "مهامك ومواعيدك وتذكيراتك في مكان واحد، من غير ما تفتح كذا حاجة",
    ),
    _OnboardData(
      icon: Icons.water_drop_rounded,
      chips: [Icons.local_fire_department_rounded, Icons.trending_up_rounded],
      title: "عادات بتتراكم يوم ورا يوم",
      desc: "سجّل عاداتك اليومية وشوف السلسلة بتاعتك بتكبر قدامك",
    ),
    _OnboardData(
      icon: Icons.menu_book_rounded,
      chips: [Icons.sticky_note_2_rounded, Icons.emoji_events_rounded],
      title: "مذاكرتك مترتبة ومعاك",
      desc: "رتّب موادك ودروسك، واكتب ملاحظاتك لكل درس في مكانها",
    ),
  ];

  final PageController _pageController = PageController();
  final ValueNotifier<double> _page = ValueNotifier<double>(0);
  late final AnimationController _float;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        _page.value = _pageController.page!;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _page.dispose();
    _float.dispose();
    super.dispose();
  }

  bool get _isLast => _currentIndex == _pages.length - 1;

  void _goToSetup() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const SetupScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _next() {
    if (!_isLast) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goToSetup();
    }
  }

  void _skip() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  Widget _card({
    required Color color,
    Widget? child,
    double width = 230,
    double height = 190,
    bool shadow = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(30),
        boxShadow: shadow
            ? [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.14),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ]
            : null,
      ),
      child: Center(child: child),
    );
  }

  Widget _floatingChip({
    required IconData icon,
    required Alignment alignment,
    required double phase,
    required Color color,
  }) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, _) {
        final dy = math.sin((_float.value * math.pi) + phase) * 9;
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 26),
            ),
          ),
        );
      },
    );
  }

  Widget _illustration(_OnboardData data) {
    return SizedBox(
      width: 300,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) {
              final dy = math.sin(_float.value * math.pi) * 6;
              return Transform.translate(offset: Offset(0, dy), child: child);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: const Offset(-6, 12),
                  child: Transform.rotate(
                    angle: -0.07,
                    child: _card(color: AppColors.surfaceAlt),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(5, 6),
                  child: Transform.rotate(
                    angle: 0.04,
                    child: _card(color: AppColors.pearlDark),
                  ),
                ),
                _card(
                  color: AppColors.surface,
                  shadow: true,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [AppColors.accent, AppColors.accentDark],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      data.icon,
                      size: 48,
                      color: AppColors.onAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _floatingChip(
            icon: data.chips[0],
            alignment: const Alignment(0.95, -0.85),
            phase: 0,
            color: AppColors.warm,
          ),
          _floatingChip(
            icon: data.chips[1],
            alignment: const Alignment(-0.95, 0.85),
            phase: math.pi,
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _pageContent(int index) {
    final data = _pages[index];
    return ValueListenableBuilder<double>(
      valueListenable: _page,
      builder: (context, page, _) {
        final delta = (index - page);
        final distance = delta.abs().clamp(0.0, 1.0);
        final opacity = 1 - distance;
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: 1 - (distance * 0.18),
                  child: Transform.translate(
                    offset: Offset(delta * -60, 0),
                    child: _illustration(data),
                  ),
                ),
                const SizedBox(height: 36),
                Transform.translate(
                  offset: Offset(delta * -30, distance * 20),
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Transform.translate(
                  offset: Offset(delta * -20, distance * 30),
                  child: Text(
                    data.desc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _indicators() {
    return ValueListenableBuilder<double>(
      valueListenable: _page,
      builder: (context, page, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) {
            final t = (1 - (i - page).abs()).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10 + (t * 26),
              height: 10,
              decoration: BoxDecoration(
                color: Color.lerp(
                  AppColors.surface,
                  AppColors.accent,
                  t,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color.lerp(
                    AppColors.border,
                    AppColors.accent,
                    t,
                  )!,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _mainButton() {
    return GestureDetector(
      onTap: _next,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [AppColors.accent, AppColors.accentDark],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Text(
                _isLast ? "يلا نبدأ" : "التالي",
                key: ValueKey<bool>(_isLast),
                style: const TextStyle(
                  color: AppColors.onAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.onAccent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _isLast ? 0 : 1,
                        child: IgnorePointer(
                          ignoring: _isLast,
                          child: TextButton(
                            onPressed: _skip,
                            child: const Text(
                              "تخطي",
                              style: TextStyle(
                                color: AppColors.accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) => _pageContent(index),
                  ),
                ),
                _indicators(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 28, 30, 32),
                  child: _mainButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}