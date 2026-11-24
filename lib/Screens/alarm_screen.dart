
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:masar/services/notifications_service.dart';
import 'package:masar/theme/AppColors.dart';

class AlarmScreen extends StatefulWidget {
  final int habitKey;

  const AlarmScreen({
    super.key,
    required this.habitKey,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with TickerProviderStateMixin {
  bool _loading = false;
  bool _completing = false;

  late AnimationController _pulseController;
  late AnimationController _entranceController;
  late AnimationController _rotationController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.96,
      end: 1.045,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();

    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {
            _currentTime = DateTime.now();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final hour = _currentTime.hour % 12 == 0
        ? 12
        : _currentTime.hour % 12;

    final minute = _currentTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String get _period =>
      _currentTime.hour >= 12 ? 'مساءً' : 'صباحًا';

  String get _formattedDate {
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return '${weekdays[_currentTime.weekday - 1]}، '
        '${_currentTime.day} ${months[_currentTime.month - 1]}';
  }

  Future<void> _handleAction({
    required bool complete,
  }) async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _completing = complete;
    });

    try {
      final service = NotificationsService();

      if (complete) {
        await service.completeHabitFromAlarm(widget.habitKey);
      } else {
        await service.snoozeHabitFromAlarm(widget.habitKey);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            complete
                ? 'حصلت مشكلة أثناء تسجيل إنجاز العادة'
                : 'حصلت مشكلة أثناء تأجيل المنبه',
            textAlign: TextAlign.center,
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.pearlLight,
                      AppColors.background,
                      Color(0xFFE3F0F1),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: -120,
              right: -100,
              child: _GlowCircle(
                color: AppColors.secondary.withOpacity(0.25),
                size: 300,
              ),
            ),

            Positioned(
              bottom: -140,
              left: -100,
              child: _GlowCircle(
                color: AppColors.warm.withOpacity(0.12),
                size: 300,
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 20,
                            ),
                            child: Column(
                              children: [
                                _buildHeader(),

                                SizedBox(
                                  height: screenHeight < 700 ? 22 : 38,
                                ),

                                _buildAlarmIcon(),

                                const SizedBox(height: 25),

                                _buildTime(),

                                const SizedBox(height: 10),

                                _buildDate(),

                                SizedBox(
                                  height: screenHeight < 700 ? 22 : 34,
                                ),

                                _buildMessage(),

                                SizedBox(
                                  height: screenHeight < 700 ? 25 : 38,
                                ),

                                _buildActions(),

                                const SizedBox(height: 24),

                                _buildFooter(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accentDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.route_rounded,
                color: AppColors.onAccent,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'MASAR',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                size: 15,
                color: AppColors.warmDark,
              ),
              SizedBox(width: 7),
              Text(
                'تذكير العادة',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _rotationController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: 210,
        height: 210,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 205,
              height: 205,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.09),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.2),
                ),
              ),
            ),

            RotationTransition(
              turns: _rotationController,
              child: SizedBox(
                width: 175,
                height: 175,
                child: CustomPaint(
                  painter: _OrbitPainter(),
                ),
              ),
            ),

            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.pearlDark,
                  ],
                ),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.13),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    blurRadius: 12,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent,
                        AppColors.accentDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.28),
                        blurRadius: 20,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alarm_rounded,
                    size: 57,
                    color: AppColors.onAccent,
                  ),
                ),
              ),
            ),

            const Positioned(
              top: 25,
              right: 32,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.warm,
                size: 19,
              ),
            ),

            const Positioned(
              bottom: 30,
              left: 28,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.secondaryDark,
                size: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTime() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _formattedTime,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 66,
              fontWeight: FontWeight.w300,
              letterSpacing: -3,
              height: 1.1,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            _period,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.calendar_today_rounded,
          size: 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Text(
          _formattedDate,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Column(
      children: [
        const Text(
          'حان وقت عادتك!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 29,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'كل خطوة صغيرة بتقربك من الشخص اللي '
              'بتحاول تكونه.\nخد وقتك وابدأ دلوقتي.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.9,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 17),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.spa_rounded,
                size: 16,
                color: AppColors.accent,
              ),
              SizedBox(width: 7),
              Text(
                'خطوة جديدة في طريقك',
                style: TextStyle(
                  color: AppColors.accentDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 62,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.accent,
                  AppColors.accentDark,
                ],
              ),
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.23),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => _handleAction(complete: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: AppColors.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _loading && _completing
                    ? const SizedBox(
                  key: ValueKey('complete-loading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.onAccent,
                  ),
                )
                    : const Row(
                  key: ValueKey('complete-content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 23,
                    ),
                    SizedBox(width: 11),
                    Text(
                      'أنجزت العادة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 13),

        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton(
            onPressed: _loading
                ? null
                : () => _handleAction(complete: false),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.surface.withOpacity(0.75),
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(
                color: AppColors.border,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _loading && !_completing
                  ? const SizedBox(
                key: ValueKey('snooze-loading'),
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.warmDark,
                ),
              )
                  : const Row(
                key: ValueKey('snooze-content'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.snooze_rounded,
                    color: AppColors.warmDark,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'تأجيل 5 دقائق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.favorite_rounded,
          color: AppColors.warm,
          size: 15,
        ),
        const SizedBox(width: 8),
        const Flexible(
          child: Text(
            'استمر.. أنت بتبني نسخة أفضل من نفسك',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..color = AppColors.secondaryDark.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      rect,
      -0.7,
      2.3,
      false,
      paint,
    );

    final dotPaint = Paint()
      ..color = AppColors.warm
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.32),
      4,
      dotPaint,
    );

    final secondDot = Paint()
      ..color = AppColors.secondaryDark
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.16, size.height * 0.68),
      3,
      secondDot,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
