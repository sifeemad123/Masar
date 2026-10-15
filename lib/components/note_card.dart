import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masar/providers/user_data_provider.dart';
import 'package:masar/theme/AppColors.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class NoteCard extends StatelessWidget {
  final String noteName;
  final String noteDescription;
  final String noteContnet;
  final Color noteColor;
  final void Function(BuildContext) onDelete;
  final void Function(BuildContext) onEdit;
  const NoteCard({
    super.key,
    required this.noteName,
    required this.noteDescription,
    required this.noteContnet,
    required this.noteColor,
    required this.onDelete, required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Automatically choose readable text color
    final bool isLightNote = noteColor.computeLuminance() > 0.55;

    final Color textColor = isLightNote
        ? const Color(0xFF12343B) // Deep teal
        : const Color(0xFFF8FAF9); // Soft white

    final Color secondaryTextColor = isLightNote
        ? const Color(0xFF49676B)
        : const Color(0xFFD5DFDD);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Transform.rotate(
        angle: -0.015,
        child: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: onDelete,
                icon: Icons.delete_outline_rounded,
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              SlidableAction(
                onPressed: onEdit,
                icon: Icons.edit_rounded,
                backgroundColor: AppColors.accentDark,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),

          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: noteColor,
              borderRadius: BorderRadius.circular(6),

              border: Border.all(
                color: isLightNote
                    ? Colors.black.withOpacity(0.06)
                    : Colors.white.withOpacity(0.08),
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(2, 6),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noteName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  height: 2,
                  width: 42,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  noteDescription,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  noteContnet,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      color: textColor,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () async {
                        final text = '”${noteName}“\n\n${noteDescription}\n\n${noteContnet}\n\nمن ${Provider.of<UserDataProvider>(context, listen: false).userName}\n\nمن تطبيق مسار';

                        await SharePlus.instance.share(
                          ShareParams(
                              text: text,
                              subject: "تطبيق مسار"
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.share_outlined,
                        color: textColor,
                        size: 28,
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