import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabelTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  int? maxLines;
  bool? readOnlyVal;
  TextStyle? style;
  Widget? suffixIcon;
  List<TextInputFormatter>? inputFormatters;

  LabelTextField({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines,
    this.readOnlyVal,
    this.style,
    this.inputFormatters,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnlyVal ?? false,
      maxLines: maxLines,
      controller: controller,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        labelText: label,
      ),
      style: style,
    );
  }
}
