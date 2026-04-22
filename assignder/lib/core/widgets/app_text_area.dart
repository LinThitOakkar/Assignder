import 'package:flutter/material.dart';

class AppTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool enabled;

  const AppTextArea({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 4,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        alignLabelWithHint: true,
      ),
    );
  }
}
