import 'dart:math';

import 'package:cotter/src/helper/colors.dart';
import 'package:flutter/material.dart';

class CotterCodeInput extends StatelessWidget {
  final String value;
  final int length;
  final Color fontColor;
  final Color pinColor;
  CotterCodeInput({
    @required this.value,
    @required this.length,
    this.fontColor = CotterColors.defaultPrimary,
    this.pinColor = CotterColors.defaultDarker,
  });

  @override
  Widget build(BuildContext context) {
    var val = this.value.substring(0, min(this.value.length, this.length));
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          this.length,
          (index) => Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            width: 40,
            height: 55,
            margin: EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: pinColor,
            ),
            child: Center(
              child: Text(
                index < val.length ? val[index] : '•',
                style: TextStyle(
                  fontSize: 25,
                  color: index < val.length
                      ? fontColor
                      : CotterColors.defaultDarker,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
