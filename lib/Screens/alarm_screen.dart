
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

class _AlarmScreenState extends State<AlarmScreen> {
  bool _loading = false;

  Future<void> _completeHabit() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await NotificationsService()
          .completeHabitFromAlarm(widget.habitKey);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حصلت مشكلة أثناء تسجيل إنجاز العادة'),
        ),
      );
    }
  }

  Future<void> _snoozeHabit() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await NotificationsService()
          .snoozeHabitFromAlarm(widget.habitKey);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حصلت مشكلة أثناء تأجيل المنبه'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.alarm_rounded,
                    size: 100,
                    color: Colors.orange,
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    'حان وقت عادتك!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'خصص وقتك للحاجة اللي بتحاول تحافظ عليها كل يوم.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 55),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _completeHabit,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'أنجزت العادة',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _snoozeHabit,
                      icon: const Icon(Icons.snooze_rounded),
                      label: const Text(
                        'تأجيل 5 دقائق',
                        style: TextStyle(fontSize: 17),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white54,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  if (_loading) ...[
                    const SizedBox(height: 25),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
