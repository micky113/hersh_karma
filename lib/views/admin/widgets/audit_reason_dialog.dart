import 'package:flutter/material.dart';

class AuditReasonDialog extends StatefulWidget {
  final String title;
  final String actionLabel;
  final String prompt;
  final Color actionColor;
  final bool isDestructive;

  const AuditReasonDialog({
    super.key,
    required this.title,
    required this.actionLabel,
    this.prompt = 'Please provide an auditable justification for this decision:',
    this.actionColor = const Color(0xFF00B074),
    this.isDestructive = false,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String actionLabel,
    String? prompt,
    Color? actionColor,
    bool isDestructive = false,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AuditReasonDialog(
        title: title,
        actionLabel: actionLabel,
        prompt: prompt ?? 'Please provide an auditable justification for this decision:',
        actionColor: actionColor ?? (isDestructive ? Colors.red : const Color(0xFF00B074)),
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  State<AuditReasonDialog> createState() => _AuditReasonDialogState();
}

class _AuditReasonDialogState extends State<AuditReasonDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.actionColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.isDestructive ? Icons.warning_amber_rounded : Icons.gavel_rounded,
              color: widget.actionColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.prompt,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              autofocus: true,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g. Verified geotag and clear before/after plastic clearing evidence...',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: widget.actionColor, width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().length < 6) {
                  return 'Mandatory audit requirement: reason must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 12, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'This entry is immutably logged with your Admin ID and timestamp.',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.actionColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _reasonController.text.trim());
            }
          },
          child: Text(widget.actionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
