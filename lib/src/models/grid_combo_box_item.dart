import 'package:flutter/material.dart';

class GridComboBoxItem {
  String? value;
  String text;
  Color? color;
  String? input = "";
  Map<String, dynamic> extraData;

  GridComboBoxItem({
    required this.value,
    required this.text,
    this.color,
    this.input,
    this.extraData = const {},
  });
}
