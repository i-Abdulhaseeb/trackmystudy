import 'dart:async';

import 'package:flutter/material.dart';

class NameEditDialog extends StatefulWidget {
  const NameEditDialog({
    super.key,
    required this.title,
    required this.initial,
    required this.onSave,
  });
  final String title;
  final String initial;
  final FutureOr<void> Function(String) onSave;
  @override
  State<NameEditDialog> createState() => _NameEditDialogState();
}

class _NameEditDialogState extends State<NameEditDialog> {
  late final controller = TextEditingController(text: widget.initial);
  String? error;
  bool busy = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final value = controller.text.trim();
      if (value.isEmpty) throw ArgumentError('Enter a name.');
      await widget.onSave(value);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 420,
      child: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 180,
        decoration: InputDecoration(
          labelText: 'Name',
          errorText: error,
          errorMaxLines: 3,
        ),
        onSubmitted: (_) => submit(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: busy ? null : submit, child: const Text('Save')),
    ],
  );
}
