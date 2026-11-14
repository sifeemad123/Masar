import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/Screens/main_screen.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();

  late final AnimationController _intro;
  bool _saving = false;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
    _nameController.addListener(() {
      final hasText = _nameController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Logic
  // ---------------------------------------------------------------

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final pref = await SharedPreferences.getInstance();
    await pref.setBool('isFirstTime', false);
    await pref.setString('userName', _nameController.text.trim());

    // small pause so the loading state feels intentional
    await Future.delayed(const Duration(milliseconds: 450));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.05, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------
  // Pieces
  // ---------------------------------------------------------------

  /// Staggered fade + slide up.
  Widget _stagger({
    required double begin,
    required double end,
    required Widget child,
  }) {
    final curved = CurvedAnimation(
      parent: _intro,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  Widget _logo() {
    final curved = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    return ScaleTransition(
      scale: Tween<double>(begin: 0.4, end: 1).animate(curved),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.accent, AppColors.accentDark],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.32),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Icon(
          Icons.route_rounded,
          size: 50,
          color: AppColors.onAccent,
        ),
      ),
    );
  }

  Widget _nameField() {
    final borderColor = _hasFocus ? AppColors.accent : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: _hasFocus ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: _hasFocus ? 0.16 : 0.06),
            blurRadius: _hasFocus ? 26 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        focusNode: _focusNode,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _submit(),
        maxLength: 24,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "من فضلك اكتب اسمك";
          }
          return null;
        },
        decoration: InputDecoration(
          counterText: "",
          hintText: "اكتب اسمك هنا",
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              _hasText ? Icons.check_circle_rounded : Icons.person_outline,
              key: ValueKey<bool>(_hasText),
              color: _hasText ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: const TextStyle(
            color: AppColors.danger,
            fontWeight: FontWeight.w600,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _startButton() {
    return GestureDetector(
      onTap: _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: _hasText
                ? const [AppColors.accent, AppColors.accentDark]
                : [
              AppColors.accent.withValues(alpha: 0.55),
              AppColors.accentDark.withValues(alpha: 0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: _hasText ? 0.3 : 0.0),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _saving
                ? const SizedBox(
              key: ValueKey('loading'),
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.onAccent,
                ),
              ),
            )
                : const Row(
              key: ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "يلا نبدأ",
                  style: TextStyle(
                    color: AppColors.onAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.onAccent,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
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
          child: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _logo(),
                      const SizedBox(height: 28),
                      _stagger(
                        begin: 0.25,
                        end: 0.6,
                        child: const Text(
                          "أهلاً بيك في مسار",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _stagger(
                        begin: 0.35,
                        end: 0.7,
                        child: const Text(
                          "نبدأ بالتعارف.. اسمك إيه؟",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _stagger(
                        begin: 0.5,
                        end: 0.85,
                        child: Form(
                          key: _formKey,
                          child: _nameField(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _stagger(
                        begin: 0.65,
                        end: 1.0,
                        child: _startButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}