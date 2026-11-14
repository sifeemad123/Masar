
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/AppColors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  static const String appVersion = '1.0.0';
  static const String developerName = 'سيف';
  static const String developerEmail = 'sifeemad12345@gmail.com';

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
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
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _entrance({
    required int index,
    required Widget child,
  }) {
    final begin = (index * 0.09).clamp(0.0, 0.65);

    return AnimatedBuilder(
      animation: _animation,
      child: child,
      builder: (context, child) {
        final progress = Interval(
          begin,
          1,
          curve: Curves.easeOutCubic,
        ).transform(_animation.value);

        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 39,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
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

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(23, 30, 23, 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.accent,
            AppColors.secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.19),
            blurRadius: 25,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.onAccent.withOpacity(0.15),
                    width: 1.2,
                  ),
                ),
              ),
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: AppColors.onAccent.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(29),
                  border: Border.all(
                    color: AppColors.onAccent.withOpacity(0.20),
                  ),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: AppColors.onAccent,
                  size: 52,
                ),
              ),
              Positioned(
                top: 2,
                right: 8,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondaryLight,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'مسار',
            style: TextStyle(
              color: AppColors.onAccent,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'خطوة كل يوم',
            style: TextStyle(
              color: AppColors.onAccent.withOpacity(0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: AppColors.onAccent.withOpacity(0.13),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.onAccent.withOpacity(0.16),
              ),
            ),
            child: const Text(
              'الإصدار ${AboutScreen.appVersion}',
              style: TextStyle(
                color: AppColors.onAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _introCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.accent,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
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
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'مسار هو رفيقك اليومي لتنظيم وقتك وحياتك. '
                'يجمع مهامك وعاداتك وموادك الدراسية في مكان واحد، '
                'ويساعدك تتابع تقدمك وتكون أكثر تنظيمًا والتزامًا.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.9,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _featureItem({
    required IconData icon,
    required String title,
    required String description,
    required int index,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 47,
          height: 47,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.09),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _featuresCard() {
    final features = [
      (
      Icons.task_alt_rounded,
      'إدارة المهام اليومية',
      'أضف مهامك وحدد مواعيدها وتابع إنجازك.',
      ),
      (
      Icons.local_fire_department_rounded,
      'متابعة العادات',
      'تابع التزامك بعاداتك اليومية وسلسلة إنجازك.',
      ),
      (
      Icons.menu_book_rounded,
      'المواد والدروس',
      'نظّم موادك الدراسية ودروسك في مكان واحد.',
      ),
      (
      Icons.sticky_note_2_rounded,
      'ملاحظات الدروس',
      'احتفظ بملخصاتك وملاحظاتك لكل درس.',
      ),
      (
      Icons.insights_rounded,
      'متابعة التقدم',
      'شوف مدى التزامك وتقدمك في تحقيق أهدافك.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < features.length; i++) ...[
            _featureItem(
              icon: features[i].$1,
              title: features[i].$2,
              description: features[i].$3,
              index: i,
            ),
            if (i != features.length - 1) ...[
              const SizedBox(height: 18),
              Divider(
                height: 1,
                color: AppColors.divider,
              ),
              const SizedBox(height: 18),
            ],
          ],
        ],
      ),
    );
  }

  Widget _developerCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.secondaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.code_rounded,
                  color: AppColors.onAccent,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
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
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Developer',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19),
          Divider(
            color: AppColors.divider,
            height: 1,
          ),
          const SizedBox(height: 15),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _launchEmail,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 3,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.09),
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
                              fontSize: 13,
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
                      Icons.open_in_new_rounded,
                      color: AppColors.textMuted,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.water_drop_outlined,
            color: AppColors.secondaryDark,
            size: 23,
          ),
        ),
        const SizedBox(height: 11),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'عن التطبيق',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textPrimary,
            size: 19,
          ),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 13, 20, 35),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _entrance(
                        index: 0,
                        child: _hero(),
                      ),
                      const SizedBox(height: 20),
                      _entrance(
                        index: 1,
                        child: _introCard(),
                      ),
                      const SizedBox(height: 30),
                      _entrance(
                        index: 2,
                        child: _sectionHeader(
                          title: 'مميزات التطبيق',
                          subtitle: 'كل أدواتك المهمة في مكان واحد',
                        ),
                      ),
                      const SizedBox(height: 15),
                      _entrance(
                        index: 3,
                        child: _featuresCard(),
                      ),
                      const SizedBox(height: 30),
                      _entrance(
                        index: 4,
                        child: _sectionHeader(
                          title: 'المطور',
                          subtitle: 'تعرف على صاحب مسار',
                        ),
                      ),
                      const SizedBox(height: 15),
                      _entrance(
                        index: 5,
                        child: _developerCard(),
                      ),
                      const SizedBox(height: 35),
                      _entrance(
                        index: 6,
                        child: _footer(),
                      ),
                    ],
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
