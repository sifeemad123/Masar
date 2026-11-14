
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masar/components/subject_card.dart';
import 'package:masar/components/motion.dart';
import 'package:masar/models/subjects_model.dart';
import 'package:masar/providers/subjects_provider.dart';
import 'package:provider/provider.dart';

import '../components/dialogs.dart';
import '../components/empty_state.dart';
import '../theme/AppColors.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SubjectsModel> _filterSubjects(List<SubjectsModel> subjects) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return subjects;

    return subjects.where((subject) {
      return subject.subjectName.toLowerCase().contains(query) ||
          subject.subjectDescription.toLowerCase().contains(query) ||
          (subject.teacherName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _confirmDelete(SubjectsModel subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.5, end: 1),
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.danger,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'حذف المادة',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'هل تريد حذف مادة "${subject.subjectName}"؟\n'
                        'سيتم حذف الدروس المرتبطة بها أيضًا.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Pressable(
                          haptic: true,
                          pressedScale: 0.96,
                          onTap: () {
                            Navigator.pop(dialogContext, true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                'حذف المادة',
                                style: TextStyle(
                                  color: AppColors.onDanger,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Pressable(
                          haptic: true,
                          pressedScale: 0.96,
                          onTap: () => Navigator.pop(dialogContext, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Center(
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
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
        );
      },
    );

    if (confirmed != true || !mounted) return;

    Provider.of<SubjectsProvider>(
      context,
      listen: false,
    ).deleteSubject(subject: subject);

    if (!mounted) return;

    HapticFeedback.mediumImpact();

    Dialogs.success(
      context: context,
      message: 'تم حذف المادة بنجاح',
    );
  }

  Future<void> _showSubjectSheet({SubjectsModel? subject}) async {
    final isEditing = subject != null;

    final nameController = TextEditingController(
      text: subject?.subjectName ?? '',
    );
    final descriptionController = TextEditingController(
      text: subject?.subjectDescription ?? '',
    );
    final teacherController = TextEditingController(
      text: subject?.teacherName ?? '',
    );

    final formKey = GlobalKey<FormState>();

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        showDragHandle: false,
        builder: (sheetContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        FadeSlideIn(
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.accent,
                                      AppColors.accentDark,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Icon(
                                  isEditing
                                      ? Icons.edit_rounded
                                      : Icons.auto_stories_rounded,
                                  color: AppColors.onAccent,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isEditing
                                          ? 'تعديل المادة'
                                          : 'مادة جديدة',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      isEditing
                                          ? 'حدّث بيانات مادتك الدراسية'
                                          : 'أضف مادة جديدة إلى مسارك الدراسي',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Pressable(
                                haptic: true,
                                onTap: () => Navigator.pop(sheetContext),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceAlt,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        FadeSlideIn(
                          index: 1,
                          child: _buildField(
                            title: 'اسم المادة',
                            hint: 'مثال: Physics',
                            controller: nameController,
                            icon: Icons.menu_book_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال اسم المادة';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        FadeSlideIn(
                          index: 2,
                          child: _buildField(
                            title: 'وصف المادة',
                            hint: 'اكتب وصفًا بسيطًا للمادة',
                            controller: descriptionController,
                            icon: Icons.notes_rounded,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'يرجى إدخال وصف المادة';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        FadeSlideIn(
                          index: 3,
                          child: _buildField(
                            title: 'اسم المدرس',
                            hint: 'اختياري',
                            controller: teacherController,
                            icon: Icons.person_outline_rounded,
                          ),
                        ),

                        const SizedBox(height: 28),

                        FadeSlideIn(
                          index: 4,
                          child: Pressable(
                            haptic: true,
                            pressedScale: 0.97,
                            onTap: () {
                              if (!formKey.currentState!.validate()) {
                                HapticFeedback.mediumImpact();
                                return;
                              }

                              final provider = Provider.of<SubjectsProvider>(
                                context,
                                listen: false,
                              );

                              final teacher = teacherController.text.trim();

                              if (isEditing) {
                                provider.editSubject(
                                  subjectName: nameController.text.trim(),
                                  subjectDescription:
                                  descriptionController.text.trim(),
                                  subject: subject,
                                  teacherName:
                                  teacher.isEmpty ? null : teacher,
                                );
                              } else {
                                provider.createSubject(
                                  subjectName: nameController.text.trim(),
                                  subjectDescription:
                                  descriptionController.text.trim(),
                                  teacherName:
                                  teacher.isEmpty ? null : teacher,
                                );
                              }

                              Navigator.pop(sheetContext);

                              Dialogs.success(
                                context: context,
                                message: isEditing
                                    ? 'تم تعديل المادة بنجاح'
                                    : 'تمت إضافة المادة بنجاح',
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 17),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accentDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(17),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  isEditing
                                      ? 'حفظ التعديلات'
                                      : 'إضافة المادة',
                                  style: const TextStyle(
                                    color: AppColors.onAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      teacherController.dispose();
    }
  }

  Widget _buildField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
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
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: Icon(
              icon,
              color: AppColors.accent,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.pearl,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 1.6,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.danger,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int totalSubjects) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'موادي',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 29,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'كل موادك الدراسية في مكان واحد',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.15),
                        AppColors.secondary.withValues(alpha: 0.20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.accent,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          FadeSlideIn(
            index: 1,
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.accent,
                    AppColors.accentDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.19),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  PositionedDirectional(
                    end: -20,
                    top: -30,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.library_books_rounded,
                          color: AppColors.onAccent,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي المواد',
                              style: TextStyle(
                                color: AppColors.onAccent.withValues(
                                  alpha: 0.75,
                                ),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                            AnimatedCount(
                              value: totalSubjects,
                              suffix: ' مادة دراسية',
                              style: const TextStyle(
                                color: AppColors.onAccent,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.secondary,
                        size: 25,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return FadeSlideIn(
      index: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 17),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن مادة أو مدرس...',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.accent,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.textMuted,
              ),
            )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required bool isSearching}) {
    return EmptyState(
      icon: isSearching
          ? Icons.search_off_rounded
          : Icons.menu_book_outlined,
      title: isSearching ? 'مش لاقيين المادة دي' : 'لسه مفيش مواد!',
      subtitle: isSearching
          ? 'جرّب تبحث باسم مختلف أو بكلمة تانية'
          : 'ابدأ بإضافة موادك الدراسية واجمع دروسك وملاحظاتك في مكان واحد.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = context.watch<SubjectsProvider>().subjects;
    final filteredSubjects = _filterSubjects(subjects);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(subjects.length),
              _buildSearch(),

              if (filteredSubjects.isEmpty)
                Expanded(
                  child: _buildEmptyState(
                    isSearching: _searchQuery.isNotEmpty,
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 13),
                  child: FadeSlideIn(
                    index: 3,
                    child: Row(
                      children: [
                        const Text(
                          'قائمة المواد',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.23),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${filteredSubjects.length}',
                            style: const TextStyle(
                              color: AppColors.accentDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 110),
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = filteredSubjects[index];

                      return SubjectCard(
                        index: index,
                        subjectName: subject.subjectName,
                        subjectDescription: subject.subjectDescription,
                        subjectId: subject.id,
                        teacherName: subject.teacherName,
                        deleteFunction: (_) => _confirmDelete(subject),
                        editFunction: (_) => _showSubjectSheet(
                          subject: subject,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
