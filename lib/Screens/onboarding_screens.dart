import 'package:flutter/material.dart';
import 'package:masar/Screens/setup_screen.dart';
import 'package:masar/theme/AppColors.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final List<Map<String, dynamic>> _screens = [
    {
      'icon': Icons.date_range_outlined,
      'title': Text(
        "يومك في نظرة واحدة",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 45,
          fontWeight: FontWeight.w900,
        ),
      ),
      'desc': Text(
        "مهامك ومواعيدك وتذكيراتك في مكان واحد، من غير ما تفتح كذا حاجة",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    },
    {
      'icon': Icons.water_drop,
      'title': Text(
        "عادات بتتراكم يوم ورا يوم",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 45,
          fontWeight: FontWeight.w900,
        ),
      ),
      'desc': Text(
        "سجّل عاداتك اليومية وشوف الستريك بتاعك بيكبر قدامك",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    },
    {
      'icon': Icons.check_circle_outline,
      'title': Text(
        "دقيقة بس، وتقفل يومك مرتاح",
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 45,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.center,
      ),
      'desc': Text(
        "جيك إن سريع آخر اليوم يورّيك التزمت بإيه ولا لأ",
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.center,
      ),
    },
  ];
  PageController _pageController = PageController();
  int currentScreen = 0;
  void _nextScreen() {
    if (currentScreen < _screens.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SetupScreen()),
      );
    }
  }

  Widget _card({Widget? child, Color? color}) {
    Color color2 = color ?? AppColors.surface;
    return Container(
      width: 240,
      height: 180,
      decoration: BoxDecoration(
        color: color2,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          2,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      child: Text(
                        "تخطي",
                        style: TextStyle(color: AppColors.accent, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentScreen = index;
                    });
                  },
                  itemCount: _screens.length,
                  itemBuilder: (context, index) {
                    final screen = _screens[index];
                    return Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 250,
                            height: 200,
                            child: Stack(
                              children: [
                                Transform.translate(
                                  offset: Offset(-3, 7),
                                  child: Transform.rotate(
                                    angle: -0.03,
                                    child: _card(color: AppColors.surfaceAlt),
                                  ),
                                ),
                                Transform.translate(
                                  offset: Offset(2, 4),
                                  child: Transform.rotate(
                                    angle: 0.015,
                                    child: _card(color: AppColors.surfaceAlt),
                                  ),
                                ),
                                _card(
                                  child: Icon(
                                    screen['icon'],
                                    size: 50,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          screen['title'],
                          SizedBox(height: 15),
                          screen['desc'],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_screens.length, (index) {
                    final isActive = currentScreen == index;
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: isActive ? 30 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accent
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.border),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      _nextScreen();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: currentScreen < _screens.length - 1
                        ? Text(
                            "التالي",
                            style: TextStyle(
                              color: AppColors.onAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : Text(
                            "يلا تبدأ",
                            style: TextStyle(
                              color: AppColors.onAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
