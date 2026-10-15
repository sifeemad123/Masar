import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/AppColors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String appVersion = "1.0.0";
  static const String developerName = "سيف";
  static const String developerEmail = "sifeemad12345@gmail.com";

  Future<void> _launchEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: developerEmail,
      query: 'subject=استفسار عن تطبيق مسار',
    );
    if (!await launchUrl(emailUri)) {
    }
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.overlay,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accentLight),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentLight, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "عن التطبيق",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // =========================
                // Logo & App Name
                // =========================
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.route_rounded,
                    color: AppColors.onAccent,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "مسار",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "الإصدار $appVersion",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "مسار هو رفيقك اليومي عشان تنظم حياتك.. تاسكاتك، عاداتك، ومذاكرتك في مكان واحد بسيط ومريح للعين",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 35),

                _sectionTitle("مميزات التطبيق"),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    spacing: 18,
                    children: [
                      _featureRow(Icons.today_outlined, "تنظيم التاسكات اليومية والمتابعة بتاعتها"),
                      _featureRow(Icons.track_changes, "متابعة العادات (Streaks)"),
                      _featureRow(Icons.menu_book_outlined, "إدارة المواد الدراسية والدروس"),
                      _featureRow(Icons.sticky_note_2_rounded, "تدوين ملاحظات لكل درس على حدة"),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                _sectionTitle("المطور"),
                const SizedBox(height: 15),
                _infoCard(
                  icon: Icons.code_rounded,
                  title: developerName,
                  subtitle: "Flutter Developer",
                ),
                const SizedBox(height: 15),
                _infoCard(
                  icon: Icons.email_outlined,
                  title: "تواصل معايا",
                  subtitle: developerEmail,
                  onTap: () => _launchEmail(context),
                ),

                const SizedBox(height: 35),

                Text(
                  "© ${DateTime.now().year} مسار. جميع الحقوق محفوظة",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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