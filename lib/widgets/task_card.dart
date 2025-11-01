import 'package:flutter/material.dart';
import 'package:task_manager_app/models/task_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onDelete});
  final TaskModel task;
  final VoidCallback? onDelete;

  static final List<Color> _cardColors = [
    const Color(0xFFFFF9C4), // pastel yellow
    const Color(0xFFC8E6C9), // pastel green
    const Color(0xFFBBDEFB), // pastel blue
    const Color(0xFFFFCDD2), // pastel red
    const Color(0xFFD1C4E9), // pastel purple
    const Color(0xFFFFE0B2), // pastel orange
  ];

  Color get randomColor {
    final index = (task.id ?? task.title.hashCode).abs() % _cardColors.length;
    return _cardColors[index];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate adaptive background with clean alpha values
    final base = randomColor;
    final alpha = isDark ? 0.65 : 0.95;
    final bgColor = Color.fromARGB(
      (alpha * 255).round(),
      (base.r * 255).round() & 0xff,
      (base.g * 255).round() & 0xff,
      (base.b * 255).round() & 0xff,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(
              ((isDark ? 0.3 : 0.08) * 255).round(),
              0,
              0,
              0,
            ),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: onDelete,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Let height adjust to content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        softWrap: true,
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        color: isDark
                            ? Colors.white70
                            : const Color.fromARGB(160, 0, 0, 0),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Description text
                if (task.description.trim().isNotEmpty)
                  Text(
                    task.description,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      height: 1.25,
                      fontSize: 14,
                    ),
                    softWrap: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
