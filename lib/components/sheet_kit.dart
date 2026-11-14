import 'package:flutter/material.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/theme/AppColors.dart';

/// Small building blocks shared by every bottom sheet in the app.

Widget sheetPickerTheme(BuildContext ctx, Widget? child) {
  final theme = Theme.of(ctx);
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
    ),
    child: child!,
  );
}

const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
);

Widget sheetLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Text(
    text,
    style: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  ),
);

InputDecoration sheetInputDecoration({String? hint}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.overlay,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.accent, 2),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 2),
  );
}

Widget sheetHeader({
  required IconData icon,
  required String title,
  required VoidCallback onClose,
}) {
  return Row(
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.accent, AppColors.accentDark],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.onAccent, size: 24),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      IconButton(
        onPressed: onClose,
        style: IconButton.styleFrom(backgroundColor: AppColors.overlay),
        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
      ),
    ],
  );
}

class PickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const PickerField({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.overlay,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GradientButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      haptic: true,
      child: Container(
        height: 58,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [AppColors.accent, AppColors.accentDark],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.onAccent,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}