
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:masar/Screens/about_screen.dart';
import 'package:masar/Screens/onboarding_screens.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notifications_service.dart';

class MotivationMessage {
  final String text;
  final String category;

  const MotivationMessage({
    required this.text,
    required this.category,
  });
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;
  late final Animation<double> _backgroundAnimation;
  bool _motivationEnabled = false;
  bool _motivationLoading = true;

  int _messageIndex = 0;

  static const List<MotivationMessage> _messages = [
    MotivationMessage(
      text: 'مش مطلوب منك تنجز كل حاجة النهارده، المطلوب إنك تبدأ في الحاجة المهمة.',
      category: 'البداية',
    ),
    MotivationMessage(
      text: 'كل خطوة صغيرة بتاخدها النهارده بتفرق في المكان اللي هتوصله بكرة.',
      category: 'الاستمرارية',
    ),
    MotivationMessage(
      text: 'متستناش الوقت المثالي، ابدأ بالوقت والإمكانيات اللي عندك.',
      category: 'الانضباط',
    ),
    MotivationMessage(
      text: 'رتّب أولوياتك، وادي كل حاجة وقتها، ومتنساش تدي نفسك حقها.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'مش كل يوم هيكون مثالي، لكن كل يوم ممكن يكون فيه خطوة للأمام.',
      category: 'التقدم',
    ),
    MotivationMessage(
      text: 'الهدف الكبير مش محتاج خطوة كبيرة كل يوم، محتاج خطوات صغيرة مستمرة.',
      category: 'الطموح',
    ),
    MotivationMessage(
      text: 'لما تحس إنك مشتت، ارجع واسأل نفسك: إيه أهم حاجة أعملها دلوقتي؟',
      category: 'التركيز',
    ),
    MotivationMessage(
      text: 'متقيسش تقدمك بسرعة غيرك، قيسه بالمسافة اللي قطعتها أنت.',
      category: 'التطور',
    ),
    MotivationMessage(
      text: 'خطة بسيطة تلتزم بيها أحسن من خطة مثالية متبدأش فيها.',
      category: 'التخطيط',
    ),
    MotivationMessage(
      text: 'الراحة جزء من الرحلة، لكن خليها استراحة ترجعك لطريقك.',
      category: 'التوازن',
    ),
    MotivationMessage(
      text: 'كل مرة تلتزم فيها بوعد قطعته لنفسك، بتبني ثقة أكبر في نفسك.',
      category: 'الثقة',
    ),
    MotivationMessage(
      text: 'ابدأ بالموجود، اتعلم من التجربة، وطوّر طريقتك في الطريق.',
      category: 'التعلم',
    ),
    MotivationMessage(
      text: 'مش لازم تشوف النتيجة النهارده عشان يكون لمجهودك قيمة.',
      category: 'الصبر',
    ),
    MotivationMessage(
      text: 'خلي وقتك يروح للحاجات اللي تقرّبك من الحياة اللي بتسعى ليها.',
      category: 'الوقت',
    ),
    MotivationMessage(
      text: 'الإنجاز الحقيقي مش إنك تعمل كل حاجة، الإنجاز إنك تعرف تختار المهم.',
      category: 'الأولويات',
    ),
  ];

  MotivationMessage get _currentMessage => _messages[_messageIndex];

  Future<void> _loadMotivationPreference() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _motivationEnabled =
          prefs.getBool('motivationRemindersEnabled') ?? false;
      _motivationLoading = false;
    });
  }

  Future<void> _toggleMotivation(bool value) async {
    if (_motivationLoading) return;

    setState(() {
      _motivationEnabled = value;
      _motivationLoading = true;
    });

    try {
      await NotificationsService()
          .setMotivationalRemindersEnabled(value);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _motivationEnabled = !value;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حصلت مشكلة أثناء تحديث إعدادات التذكير'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _motivationLoading = false;
        });
      }
    }
  }

  Widget _motivationSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: _motivationEnabled
              ? AppColors.accent.withOpacity(0.35)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.accent,
            size: 25,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رسائل مسار التحفيزية',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'تذكيرات بسيطة تساعدك تحافظ على استمراريتك',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (_motivationLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: _motivationEnabled,
              activeTrackColor: AppColors.accent,
              onChanged: _toggleMotivation,
            ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    _messageIndex = Random().nextInt(_messages.length);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    _loadMotivationPreference();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _changeMessage() {
    if (_messages.length <= 1) return;

    int nextIndex;

    do {
      nextIndex = Random().nextInt(_messages.length);
    } while (nextIndex == _messageIndex);

    setState(() => _messageIndex = nextIndex);
  }

  Future<void> _shareMessage() async {
    final message =
        '“${_currentMessage.text}”\n\nرسالة تحفيزية من تطبيق مسار';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: 'رسالة من مسار',
      ),
    );
  }

  void _openAbout() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, animation, secondaryAnimation) =>
        const AboutScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.035, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _editName() async {
    final userDataProvider = context.read<UserDataProvider>();
    final currentName = userDataProvider.userName;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _EditNameDialog(
          initialName: currentName,
          onSave: (newName) {
            if (!mounted) return;

            userDataProvider.editUserName(
              userName: newName,
              context: this.context,
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    await Dialogs.confirm(
      context: context,
      title: 'حذف جميع البيانات؟',
      message:
      'سيتم حذف بياناتك المحفوظة في التطبيق، ولا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف البيانات',
      cancelText: 'إلغاء',
      danger: true,
      onConfirm: () {
        if (!mounted) return;

        context.read<UserDataProvider>().deleteAllData();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (_, animation, secondaryAnimation) =>
              const OnboardingScreens(),
              transitionsBuilder: (_, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: child,
                );
              },
            ),
                (route) => false,
          );
        });
      },
    );
  }

  Widget _animatedSection({
    required int index,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('settings_section_$index'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (index * 90)),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 21,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard(String userName) {
    final displayName =
    userName.trim().isEmpty ? 'مستخدم مسار' : userName.trim();

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.07),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.accent,
                  AppColors.secondaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.20),
                  blurRadius: 13,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              displayName.characters.first,
              style: const TextStyle(
                color: AppColors.onAccent,
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حسابك الشخصي',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                InkWell(
                  onTap: _editName,
                  borderRadius: BorderRadius.circular(9),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'تعديل الاسم',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.accent,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _motivationCard() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final animationValue = _backgroundAnimation.value;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.lerp(
                  AppColors.accent,
                  AppColors.secondaryDark,
                  animationValue * 0.18,
                )!,
                Color.lerp(
                  AppColors.accentDark,
                  AppColors.secondaryDark,
                  animationValue,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.20),
                blurRadius: 25,
                offset: const Offset(0, 11),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(21),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: AppColors.onAccent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.onAccent.withOpacity(0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.onAccent,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رسالة من مسار',
                        style: TextStyle(
                          color: AppColors.onAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'كلمة صغيرة ليومك',
                        style: TextStyle(
                          color: AppColors.onAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _motivationIconButton(
                  icon: Icons.share_outlined,
                  tooltip: 'مشاركة الرسالة',
                  onTap: _shareMessage,
                ),
              ],
            ),
            const SizedBox(height: 23),
            Row(
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  color: AppColors.secondaryLight,
                  size: 27,
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _currentMessage.category,
                    key: ValueKey(_currentMessage.category),
                    style: const TextStyle(
                      color: AppColors.secondaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.10),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _currentMessage.text,
                key: ValueKey(_messageIndex),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: AppColors.onAccent,
                  fontSize: 19,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 21),
            Container(
              height: 1,
              color: AppColors.onAccent.withOpacity(0.18),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.secondaryLight,
                  size: 18,
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'خطوتك الجاية تبدأ منك',
                    style: TextStyle(
                      color: AppColors.onAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _changeMessage,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.onAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'رسالة أخرى',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _motivationIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.onAccent.withOpacity(0.13),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              color: AppColors.onAccent,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool isDanger = false,
  }) {
    final color = iconColor ?? AppColors.accent;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.035),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDanger
                  ? AppColors.danger.withOpacity(0.20)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textMuted,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.water_drop_outlined,
            color: AppColors.secondaryDark,
            size: 21,
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
        const SizedBox(height: 4),
        const Text(
          'نظّم يومك، وقرّب خطوتك من هدفك',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<UserDataProvider>().userName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 23, 20, 35),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _animatedSection(
                        index: 0,
                        child: _sectionHeader(
                          title: 'الإعدادات',
                          subtitle: 'إدارة حسابك وتخصيص تجربتك في مسار',
                        ),
                      ),
                      const SizedBox(height: 25),

                      _animatedSection(
                        index: 1,
                        child: _profileCard(userName),
                      ),
                      const SizedBox(height: 25),

                      _animatedSection(
                        index: 2,
                        child: _motivationCard(),
                      ),
                      const SizedBox(height: 18),

                      _animatedSection(
                        index: 3,
                        child: _motivationSettingsCard(),
                      ),
                      const SizedBox(height: 31),

                      _animatedSection(
                        index: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(
                              'عام',
                              subtitle: 'معلومات عن التطبيق',
                            ),
                            _settingsTile(
                              icon: Icons.info_outline_rounded,
                              title: 'عن التطبيق',
                              subtitle: 'اعرف أكتر عن مسار وفكرته',
                              onTap: _openAbout,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      _animatedSection(
                        index: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(
                              'إدارة البيانات',
                              subtitle: 'التحكم في بياناتك المحفوظة',
                            ),
                            _settingsTile(
                              icon: Icons.delete_outline_rounded,
                              title: 'حذف جميع البيانات',
                              subtitle: 'حذف بياناتك المحفوظة من التطبيق',
                              iconColor: AppColors.danger,
                              isDanger: true,
                              onTap: _confirmDelete,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      _animatedSection(
                        index: 5,
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

// ============================================================
// Edit Name Dialog
// ============================================================

class _EditNameDialog extends StatefulWidget {
  final String initialName;
  final ValueChanged<String> onSave;

  const _EditNameDialog({
    required this.initialName,
    required this.onSave,
  });

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.initialName,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newName = _controller.text.trim();

    Navigator.of(context).pop();
    widget.onSave(newName);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(27),
        side: BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.secondaryDark,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.onAccent,
                      size: 29,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'تعديل الاسم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'اكتب الاسم اللي تحب يظهر في حسابك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 23),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 30,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اسمك',
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: AppColors.accent,
                      size: 21,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    counterStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.danger,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الاسم مينفعش يكون فاضي';
                    }

                    if (value.trim().length < 2) {
                      return 'اكتب اسم مكوّن من حرفين على الأقل';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                          minimumSize: const Size(0, 49),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.onAccent,
                          elevation: 0,
                          minimumSize: const Size(0, 49),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'حفظ التعديل',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
