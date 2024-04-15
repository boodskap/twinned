import 'package:flutter/material.dart';

class ValidatedTextField extends StatefulWidget {
  const ValidatedTextField(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.minLength});

  final String hintText;
  final TextEditingController controller;
  final int minLength;

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  final textFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      controller: widget.controller,
      focusNode: textFieldFocusNode,
      validator: (value) {
        if (value!.length < widget.minLength) {
          return "minimum ${widget.minLength} characters required";
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        floatingLabelBehavior:
            FloatingLabelBehavior.never, //Hides label on focus or if filled
        labelText: widget.hintText,
        filled: true, // Needed for adding a fill color
        fillColor: Colors.white,
        isDense: true, // Reduces height a bit
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Apply corner radius
        ),
        prefixIcon: const Icon(Icons.abc, size: 24),
      ),
    );
  }
}
