import 'package:flutter/material.dart';

class CotterColors {
  static const Color defaultPrimary = Color(0xFF8650fa);
  static const Color defaultLight = Color(0x13000000);
  static const Color defaultDarker = Color(0x13000000);
  Color primary;
  Color light;
  Color darker;
  Color error;
  Color text;
  Color textInvert;
  Color grey;
  bool darkTheme;

  CotterColors({
    this.primary = const Color(0xFF8650fa),
    this.darkTheme = false,
  }) {
    this.light = const Color(0xFFF3F3F3);
    this.darker = const Color(0x13000000);
    this.error = const Color(0xFFF4416E);
    if (this.darkTheme) {
      this.text = Colors.white;
      this.textInvert = Colors.black;
      this.grey = Colors.white54;
    } else {
      this.text = Colors.black;
      this.textInvert = Colors.white;
      this.grey = Colors.grey;
    }
  }
}
