import 'package:flutter/material.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key, required this.onDone});
  final Future<void> Function(String title, String description) onDone;

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _handleAddTask() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    try {
      await widget.onDone(title, desc);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add task: $e')),
        );
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.colorScheme.surface,
      title: Text(
        'Add Task',
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      // Simpler, safer content: fixed constraints + bounded TextFields
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // important: dialog hugs content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: fixed height for predictable layout
              SizedBox(
                height: 52,
                child: TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Title required' : null,
                ),
              ),
              const SizedBox(height: 12),

              // Description: bounded height so expands:true is safe
              SizedBox(
                height: 140, // fixed height prevents unbounded/zero-size issues
                child: TextFormField(
                  controller: _descCtrl,
                  expands: true,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true, // label at top
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 2,
          ),
          onPressed: _loading ? null : _handleAddTask,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
