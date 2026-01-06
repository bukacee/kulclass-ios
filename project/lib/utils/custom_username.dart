import 'package:flutter/services.dart';

class RandomNumberFormatter extends TextInputFormatter {
  final RegExp _randomNumberRegex = RegExp(r'_(\d+)$'); // Matches "_123"

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue; // Allow normal deletion
    }

    String newText = newValue.text.replaceAll(' ', '_');

    // If text already has a random number at the end, don't modify it
    if (_randomNumberRegex.hasMatch(newText)) {
      return newValue;
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  /// Appends a random number only if it doesn't already exist
  String formatFinalText(String text, randomNumber) {
    if (text.isEmpty) return text;

    String newText = text.replaceAll(' ', '_');

    // If a random number is already appended, return as is
    if (_randomNumberRegex.hasMatch(newText)) {
      return newText;
    }

    // Append a random number between 0-99 only if it's not already added
    return '${newText}_$randomNumber';
  }
}
