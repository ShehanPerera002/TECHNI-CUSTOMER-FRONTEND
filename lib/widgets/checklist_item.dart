import 'package:flutter/material.dart';

// reusable checklist item widget
class ChecklistItem extends StatelessWidget {
  final String text;

  const ChecklistItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.check_circle_outline),
      title: Text(text),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
    );
  }
}
