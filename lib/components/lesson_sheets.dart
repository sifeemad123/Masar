import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/sheet_kit.dart';
import 'package:masar/models/lesson_model.dart';
import 'package:masar/providers/lessons_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

/// Create / edit sheet + delete dialog for lessons.
class LessonSheets {
  LessonSheets._();

  /// Pass [lesson] to edit, leave it null to create a new one.
  static void show(
      BuildContext context, {
        required int subjectId,
        LessonModel? lesson,
      }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: sheetShape,
      builder: (sheetContext) => _LessonForm(
        rootContext: context,
        subjectId: subjectId,
        lesson: lesson,
      ),
    );
  }

  static Future<void> confirmDelete(BuildContext context, LessonModel lesson) {
    final provider = Provider.of<LessonsProvider>(context, listen: false);
    return Dialogs.confirm(
      context: context,
      title: 'حذف الدرس',
      message:
      'هتحذف درس "${lesson.lessonName}" بكل ملاحظاته، ومش هتقدر ترجعه تاني.',
      confirmText: 'حذف',
      danger: true,
      onConfirm: () {
        provider.deleteLesson(lesson: lesson, context: context);
        Dialogs.success(context: context, message: 'تم حذف الدرس بنجاح');
      },
    );
  }
}

class _LessonForm extends StatefulWidget {
  final BuildContext rootContext;
  final int subjectId;
  final LessonModel? lesson;

  const _LessonForm({
    required this.rootContext,
    required this.subjectId,
    this.lesson,
  });

  @override
  State<_LessonForm> createState() => _LessonFormState();
}

class _LessonFormState extends State<_LessonForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
  TextEditingController(text: widget.lesson?.lessonName ?? '');
  late final TextEditingController _description =
  TextEditingController(text: widget.lesson?.lessonDescription ?? '');

  bool get _editing => widget.lesson != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    final provider = context.read<LessonsProvider>();

    if (_editing) {
      provider.editLesson(
        lesson: widget.lesson!,
        lessonName: _name.text.trim(),
        lessonDescription: _description.text.trim(),
      );
    } else {
      provider.createLesson(
        lessonName: _name.text.trim(),
        lessonDescription: _description.text.trim(),
        subjectId: widget.subjectId,
      );
    }

    Navigator.pop(context);
    Dialogs.success(
      context: widget.rootContext,
      message: _editing ? 'تم تعديل الدرس بنجاح' : 'تمت إضافة الدرس بنجاح',
    );
  }

  TextStyle get _fieldStyle => const TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sheetHeader(
                  icon: _editing ? Icons.edit_rounded : Icons.layers_rounded,
                  title: _editing ? 'تعديل الدرس' : 'درس جديد',
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 26),
                sheetLabel('اسم الدرس'),
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  style: _fieldStyle,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'اكتب اسم الدرس' : null,
                  decoration:
                  sheetInputDecoration(hint: 'مثلاً: قوانين نيوتن').copyWith(
                    prefixIcon: const Icon(
                      Icons.bookmark_border_rounded,
                      color: AppColors.accent,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                sheetLabel('وصف الدرس'),
                TextFormField(
                  controller: _description,
                  textInputAction: TextInputAction.done,
                  minLines: 2,
                  maxLines: 3,
                  style: _fieldStyle,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'اكتب وصف الدرس' : null,
                  decoration:
                  sheetInputDecoration(hint: 'اكتب وصف بسيط للدرس').copyWith(
                    prefixIcon: const Icon(
                      Icons.notes_rounded,
                      color: AppColors.accent,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GradientButton(
                  text: _editing ? 'حفظ التعديل' : 'إضافة الدرس',
                  onTap: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}