import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/sheet_kit.dart';
import 'package:masar/models/subjects_model.dart';
import 'package:masar/providers/subjects_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

/// Create / edit sheet + delete dialog for subjects.
/// Used by the Subjects screen, the Subject details screen and the main "+".
class SubjectSheets {
  SubjectSheets._();

  /// Pass [subject] to edit, leave it null to create a new one.
  static void show(BuildContext context, {SubjectsModel? subject}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: sheetShape,
      builder: (sheetContext) =>
          _SubjectForm(rootContext: context, subject: subject),
    );
  }

  static Future<void> confirmDelete(
      BuildContext context,
      SubjectsModel subject, {
        VoidCallback? onDeleted,
      }) {
    final provider = Provider.of<SubjectsProvider>(context, listen: false);
    return Dialogs.confirm(
      context: context,
      title: 'حذف المادة',
      message:
      'هتحذف "${subject.subjectName}" بكل دروسها وملاحظاتها، ومش هتقدر ترجعها تاني.',
      confirmText: 'حذف',
      danger: true,
      onConfirm: () {
        provider.deleteSubject(subject: subject);
        onDeleted?.call();
        Dialogs.success(context: context, message: 'تم حذف المادة بنجاح');
      },
    );
  }
}

class _SubjectForm extends StatefulWidget {
  final BuildContext rootContext;
  final SubjectsModel? subject;

  const _SubjectForm({required this.rootContext, this.subject});

  @override
  State<_SubjectForm> createState() => _SubjectFormState();
}

class _SubjectFormState extends State<_SubjectForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
  TextEditingController(text: widget.subject?.subjectName ?? '');
  late final TextEditingController _description =
  TextEditingController(text: widget.subject?.subjectDescription ?? '');
  late final TextEditingController _teacher =
  TextEditingController(text: widget.subject?.teacherName ?? '');

  bool get _editing => widget.subject != null;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _teacher.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    final provider = context.read<SubjectsProvider>();
    final teacher = _teacher.text.trim();

    if (_editing) {
      provider.editSubject(
        subjectName: _name.text.trim(),
        subjectDescription: _description.text.trim(),
        subject: widget.subject!,
        teacherName: teacher.isEmpty ? null : teacher,
      );
    } else {
      provider.createSubject(
        subjectName: _name.text.trim(),
        subjectDescription: _description.text.trim(),
        teacherName: teacher.isEmpty ? null : teacher,
      );
    }

    Navigator.pop(context);
    Dialogs.success(
      context: widget.rootContext,
      message: _editing ? 'تم تعديل المادة بنجاح' : 'تمت إضافة المادة بنجاح',
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
                  icon: _editing
                      ? Icons.edit_rounded
                      : Icons.auto_stories_rounded,
                  title: _editing ? 'تعديل المادة' : 'مادة جديدة',
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 26),
                sheetLabel('اسم المادة'),
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  style: _fieldStyle,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'اكتب اسم المادة' : null,
                  decoration: sheetInputDecoration(hint: 'مثلاً: الفيزياء')
                      .copyWith(
                    prefixIcon: const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.accent,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                sheetLabel('وصف المادة'),
                TextFormField(
                  controller: _description,
                  textInputAction: TextInputAction.next,
                  minLines: 2,
                  maxLines: 3,
                  style: _fieldStyle,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'اكتب وصف المادة' : null,
                  decoration:
                  sheetInputDecoration(hint: 'مثلاً: الفصل الأول والتاني')
                      .copyWith(
                    prefixIcon: const Icon(
                      Icons.notes_rounded,
                      color: AppColors.accent,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                sheetLabel('اسم المدرس (اختياري)'),
                TextFormField(
                  controller: _teacher,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  style: _fieldStyle,
                  decoration: sheetInputDecoration(hint: 'اسم المدرس').copyWith(
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.accent,
                      size: 21,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GradientButton(
                  text: _editing ? 'حفظ التعديل' : 'إضافة المادة',
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