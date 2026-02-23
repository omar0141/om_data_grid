import 'package:flutter/material.dart';

/// Represents an item in a combo box grid column.
class OmGridComboBoxItem {
  /// The underlying value of the item.
  String? value;

  /// The display text of the item.
  String text;

  /// Optional color associated with the item.
  Color? color;

  /// Input string (used for filtering).
  String? input = "";

  /// Additional data associated with the item.
  Map<String, dynamic> extraData;

  /// Creates a [OmGridComboBoxItem].
  OmGridComboBoxItem({
    required this.value,
    required this.text,
    this.color,
    this.input,
    this.extraData = const {},
  });
}
