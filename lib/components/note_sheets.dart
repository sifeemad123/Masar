import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/dialogs.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/components/note_card.dart';
import 'package:masar/components/sheet_kit.dart';
import 'package:masar/models/notes_model.dart';
import 'package:masar/providers/notes_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';

const List<Color> kNoteColors = [
  Color(0xFFF1E9DF), // Paper
  Color(0xFFE4D5C3), // Sand
  Color(0xFFD2BFA8), // Beige
  Color(0xFFFFF3B0), // Lemon
  Color(0xFFFFD166), // Sunflower
  Color(0xFFFFB4A2), // Peach
  Color(0xFFE76F51), // Coral
  Color(0xFFF4A261), // Orange
  Color(0xFF83C5BE), // Seafoam
  Color(0xFF2A9D8F), // Teal
  Color(0xFF00A6A6), // Aqua
  Color(0xFF48CAE4), // Sky
  Color(0xFF5E9FB3), // Ocean Blue
  Color(0xFF9B5DE5), // Purple
  Color(0xFFE85D75), // Rose
  Color(0xFFD8A56A), // Amber
  Color(0xFFC98B72), // Terracotta
  Color(0xFFB85C50), // Brick
  Color(0xFFA3AD91), // Sage
  Color(0xFF7F9670), // Olive
  Color(0xFF8D9EAA), // Dusty Blue
  Color(0xFF9A8797), // Mauve
  Color(0xFF443C35), // Leather
  Color(0xFF353331), // Charcoal
];

/// Create / edit sheet, details sheet and delete dialog for notes + summaries.
class NoteSheets {
  NoteSheets._();

  /// Pass [note] to edit, leave it null to create a new one.
  /// Pass [isSummary] = true to create a lesson summary.
  static void show(
      BuildContext context, {
        required int lessonId,
        NotesModel? note,
        bool isSummary = false,
      }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: sheetShape,
      builder: (sheetContext) => _NoteForm(
        rootContext: context,
        lessonId: lessonId,
        note: note,
        isSummary: note?.isSummary ?? isSummary,
      ),
    );
  }

  static Future<void> confirmDelete(BuildContext context, NotesModel note) {
    final provider = Provider.of<NotesProvider>(context, listen: false);
    final what = note.isSummary ? 'الملخص' : 'الملاحظة';
    return Dialogs.confirm(
      context: context,
      title: 'حذف $what',
      message: 'هتحذف "${note.noteName}" ومش هتقدر ترجعها تاني.',
      confirmText: 'حذف',
      danger: true,
      onConfirm: () {
        provider.deleteNote(note: note);
        Dialogs.success(context: context, message: 'تم حذف $what بنجاح');
      },
    );
  }

  /// Full note / summary.
  static void details(
      BuildContext context,
      NotesModel note, {
        required VoidCallback onEdit,
      }) {
    final isSummary = note.isSummary;
    final color = isSummary ? AppColors.surface : note.noteColor;
    final text = isSummary ? AppColors.textPrimary : noteTextColor(color);
    final secondary =
    isSummary ? AppColors.textSecondary : noteSecondaryColor(color);
    final desc = note.noteDescription.trim();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: color,
      shape: sheetShape,
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: text.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (isSummary) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 15,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'ملخص الدرس',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  note.noteName,
                  style: TextStyle(
                    color: text,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 3,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isSummary
                        ? AppColors.accent.withValues(alpha: 0.4)
                        : text.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    desc,
                    style: TextStyle(
                      color: secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SelectableText(
                      note.noteContent,
                      style: TextStyle(
                        color: text,
                        fontSize: 17,
                        height: 1.75,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Pressable(
                        haptic: true,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          onEdit();
                        },
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: text.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, color: text, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'تعديل',
                                style: TextStyle(
                                  color: text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Pressable(
                        haptic: true,
                        onTap: () => shareNote(
                          sheetContext,
                          name: note.noteName,
                          description: note.noteDescription,
                          content: note.noteContent,
                          isSummary: isSummary,
                        ),
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: text,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.share_outlined,
                                  color: color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'مشاركة',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoteForm extends StatefulWidget {
  final BuildContext rootContext;
  final int lessonId;
  final NotesModel? note;
  final bool isSummary;

  const _NoteForm({
    required this.rootContext,
    required this.lessonId,
    required this.isSummary,
    this.note,
  });

  @override
  State<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<_NoteForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name = TextEditingController(
    text: widget.note?.noteName ?? (widget.isSummary ? 'ملخص الدرس' : ''),
  );
  late final TextEditingController _description =
  TextEditingController(text: widget.note?.noteDescription ?? '');
  late final TextEditingController _content =
  TextEditingController(text: widget.note?.noteContent ?? '');
  late Color _color = widget.note?.noteColor ?? kNoteColors.first;

  bool get _editing => widget.note != null;
  bool get _summary => widget.isSummary;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _content.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    final provider = context.read<NotesProvider>();

    // الملخص له لون ثابت ومالوش وصف
    final color = _summary ? AppColors.accent : _color;
    final description = _summary ? '' : _description.text.trim();

    if (_editing) {
      provider.editNote(
        note: widget.note!,
        noteName: _name.text.trim(),
        noteDescription: description,
        noteContent: _content.text.trim(),
        noteColor: color,
      );
    } else {
      provider.createNote(
        lessonId: widget.lessonId,
        noteName: _name.text.trim(),
        noteDescription: description,
        noteContent: _content.text.trim(),
        noteColor: color,
        isSummary: _summary,
      );
    }

    final what = _summary ? 'الملخص' : 'الملاحظة';

    Navigator.pop(context);
    Dialogs.success(
      context: widget.rootContext,
      message: _editing ? 'تم تعديل $what بنجاح' : 'تمت إضافة $what بنجاح',
    );
  }

  TextStyle get _fieldStyle => const TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
  );

  Widget _colorPicker() {
    return SizedBox(
      height: 58,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: kNoteColors.length,
        itemBuilder: (context, i) {
          final c = kNoteColors[i];
          final selected = c == _color;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _color = c);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutBack,
              width: 44,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.accent : AppColors.border,
                  width: selected ? 3 : 1,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : const [],
              ),
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.check_rounded,
                  size: 22,
                  color: noteTextColor(c),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contentText = _summary ? AppColors.textPrimary : noteTextColor(_color);

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
                      : (_summary
                      ? Icons.auto_stories_rounded
                      : Icons.sticky_note_2_rounded),
                  title: _summary
                      ? (_editing ? 'تعديل الملخص' : 'ملخص جديد')
                      : (_editing ? 'تعديل الملاحظة' : 'ملاحظة جديدة'),
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 26),
                sheetLabel(_summary ? 'عنوان الملخص' : 'عنوان الملاحظة'),
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  style: _fieldStyle,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (_summary ? 'اكتب عنوان الملخص' : 'اكتب عنوان الملاحظة')
                      : null,
                  decoration: sheetInputDecoration(
                    hint: _summary ? 'مثلاً: ملخص قوانين نيوتن' : 'مثلاً: القانون التاني',
                  ).copyWith(
                    prefixIcon: const Icon(
                      Icons.title_rounded,
                      color: AppColors.accent,
                      size: 21,
                    ),
                  ),
                ),
                if (!_summary) ...[
                  const SizedBox(height: 22),
                  sheetLabel('وصف الملاحظة'),
                  TextFormField(
                    controller: _description,
                    textInputAction: TextInputAction.next,
                    style: _fieldStyle,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'اكتب وصف الملاحظة'
                        : null,
                    decoration: sheetInputDecoration(hint: 'وصف مختصر')
                        .copyWith(
                      prefixIcon: const Icon(
                        Icons.notes_rounded,
                        color: AppColors.accent,
                        size: 21,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                sheetLabel(_summary ? 'ملخص الدرس' : 'محتوى الملاحظة'),
                TextFormField(
                  controller: _content,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  minLines: 6,
                  maxLines: null,
                  cursorColor: contentText,
                  style: TextStyle(
                    color: contentText,
                    fontSize: 16,
                    height: 1.7,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (_summary
                      ? 'اكتب ملخص الدرس'
                      : 'مينفعش تسيب محتوى الملاحظة فاضي')
                      : null,
                  decoration: sheetInputDecoration(
                    hint: _summary
                        ? 'لخّص أهم نقاط الدرس بأسلوبك...'
                        : 'اكتب محتوى الملاحظة هنا',
                  ).copyWith(
                    fillColor: _summary ? AppColors.surfaceAlt : _color,
                    hintStyle: TextStyle(
                      color: _summary
                          ? AppColors.textMuted
                          : contentText.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                if (!_summary) ...[
                  const SizedBox(height: 22),
                  sheetLabel('لون الملاحظة'),
                  _colorPicker(),
                ],
                const SizedBox(height: 26),
                GradientButton(
                  text: _summary
                      ? (_editing ? 'حفظ التعديل' : 'حفظ الملخص')
                      : (_editing ? 'حفظ التعديل' : 'إضافة الملاحظة'),
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