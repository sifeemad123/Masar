
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/AppColors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.1.0';
  static const String developerName = 'سيف';
  static const String developerEmail = 'sifeemad12345@gmail.com';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // ANIMATIONS
  // ------------------------------------------------------------

  Widget _enter(int index, Widget child) {
    final start = (index * 0.075).clamp(0.0, 0.65);

    return AnimatedBuilder(
      animation: _controller,
      child: child,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(
          Interval(start, 1).transform(_controller.value),
        );

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // EMAIL
  // ------------------------------------------------------------

  Future<void> _launchEmail() async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: AboutScreen.developerEmail,
      queryParameters: {
        'subject': 'استفسار عن تطبيق مسار',
      },
    );

    try {
      final launched = await launchUrl(emailUri);

      if (!launched && mounted) {
        _showMessage('مش قادر أفتح تطبيق البريد الإلكتروني');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('حصلت مشكلة أثناء فتح البريد الإلكتروني');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.accentDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ------------------------------------------------------------
  // COMMON COMPONENTS
  // ------------------------------------------------------------

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(17),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // HERO
  // ------------------------------------------------------------

  Widget _hero() {
    return _enter(
      0,
      Container(
        height: 218,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.accentDark,
              AppColors.accent,
              Color(0xFF278F91),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.22),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: Stack(
            children: [
              // Decorative background
              Positioned(
                top: -70,
                left: -35,
                child: _circle(180, 0.07),
              ),
              Positioned(
                bottom: -90,
                right: -30,
                child: _circle(200, 0.07),
              ),
              Positioned(
                top: 65,
                right: 25,
                child: _circle(50, 0.08),
              ),

              Positioned(
                top: 18,
                left: 20,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white.withValues(alpha: 0.65),
                  size: 19,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 57,
                          height: 57,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(19),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.20),
                            ),
                          ),
                          child: const Icon(
                            Icons.explore_rounded,
                            color: Colors.white,
                            size: 31,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            'VERSION ${AboutScreen.appVersion}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    const Text(
                      'مسار',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'خطوة كل يوم.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Container(
                          width: 25,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'ORGANIZE YOUR DAY',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity + 0.04),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INTRO
  // ------------------------------------------------------------

  Widget _introCard() {
    return _enter(
      1,
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'عن مسار',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'OUR STORY',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              'مسار هو رفيقك اليومي لتنظيم وقتك وحياتك. '
                  'يجمع مهامك وعاداتك وموادك الدراسية في مكان واحد، '
                  'ويساعدك تتابع تقدمك وتكون أكثر تنظيمًا والتزامًا.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.85,
              ),
            ),

            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.065),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.water_drop_rounded,
                    color: AppColors.accent,
                    size: 17,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'كل يوم فرصة جديدة تخطو فيها خطوة لقدام.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FEATURES
  // ------------------------------------------------------------

  final List<_Feature> _features = const [
    _Feature(
      icon: Icons.task_alt_rounded,
      title: 'المهام اليومية',
      description: 'نظّم مهامك ومواعيدك وتابع إنجازك.',
    ),
    _Feature(
      icon: Icons.local_fire_department_rounded,
      title: 'العادات',
      description: 'تابع التزامك بعاداتك اليومية.',
    ),
    _Feature(
      icon: Icons.menu_book_rounded,
      title: 'المواد والدروس',
      description: 'اجمع موادك ودروسك في مكان واحد.',
    ),
    _Feature(
      icon: Icons.sticky_note_2_rounded,
      title: 'الملاحظات',
      description: 'احتفظ بملخصاتك لكل درس.',
    ),
    _Feature(
      icon: Icons.insights_rounded,
      title: 'التقدم اليومي',
      description: 'راقب تقدمك ومدى التزامك.',
    ),
  ];

  Widget _featureTile(_Feature feature, int index) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              feature.icon,
              color: AppColors.accent,
              size: 21,
            ),
          ),

          const Spacer(),

          Text(
            feature.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            feature.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuresGrid() {
    return _enter(
      3,
      LayoutBuilder(
        builder: (context, constraints) {
          final width = (constraints.maxWidth - 11) / 2;

          return Wrap(
            spacing: 11,
            runSpacing: 11,
            children: [
              for (int i = 0; i < _features.length; i++)
                SizedBox(
                  width: width,
                  height: 130,
                  child: _featureTile(_features[i], i),
                ),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // DEVELOPER
  // ------------------------------------------------------------

  Widget _developerCard() {
    return _enter(
      5,
      _card(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 53,
                  height: 53,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accentDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AboutScreen.developerName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Flutter Developer',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'DEVELOPER',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            Divider(
              height: 1,
              color: AppColors.divider,
            ),

            const SizedBox(height: 13),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _launchEmail,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 2,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 39,
                        height: 39,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ),

                      const SizedBox(width: 11),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تواصل مع المطور',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              AboutScreen.developerEmail,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.accent,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOTER
  // ------------------------------------------------------------

  Widget _footer() {
    return _enter(
      6,
      Column(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: AppColors.accent,
              size: 22,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'مسار — خطوة كل يوم',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '© ${DateTime.now().year} مسار. جميع الحقوق محفوظة',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                  child: _enter(
                    0,
                    Row(
                      children: [
                        Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).maybePop();
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 43,
                              height: 43,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.border,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textPrimary,
                                size: 17,
                              ),
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            'عن التطبيق',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        const SizedBox(width: 43),
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          12,
                          20,
                          35,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              _hero(),

                              const SizedBox(height: 17),

                              _introCard(),

                              const SizedBox(height: 27),

                              _enter(
                                2,
                                _sectionTitle(
                                  title: 'مميزات التطبيق',
                                  subtitle: 'كل أدواتك المهمة في مكان واحد',
                                  icon: Icons.auto_awesome_rounded,
                                ),
                              ),

                              const SizedBox(height: 13),

                              _featuresGrid(),

                              const SizedBox(height: 27),

                              _enter(
                                4,
                                _sectionTitle(
                                  title: 'المطور',
                                  subtitle: 'الشخص اللي ورا مسار',
                                  icon: Icons.terminal_rounded,
                                ),
                              ),

                              const SizedBox(height: 13),

                              _developerCard(),

                              const SizedBox(height: 32),

                              _footer(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
