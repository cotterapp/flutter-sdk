import 'dart:math';

import 'package:flutter/material.dart';

class CotterKeyboard extends StatefulWidget {
  final ValueChanged<String> onChange;
  final int length;
  final Color fontColor;
  final Color buttonColor;
  CotterKeyboard({
    @required this.onChange,
    @required this.length,
    this.fontColor = Colors.black87,
    this.buttonColor = Colors.white,
  });
  @override
  CotterKeyboardState createState() => CotterKeyboardState();
}

class CotterKeyboardState extends State<CotterKeyboard> {
  String value = "";
  double rowHeight = 60;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: rowHeight * 4 + rowHeight,
      child: GridView.count(
        primary: false,
        crossAxisCount: 3,
        children: _buildList(),
        childAspectRatio: width / 3 / rowHeight,
      ),
    );
  }

  List<Widget> _buildList() {
    List<Widget> lst = List.generate(9, (index) {
      return _buildButton((index + 1).toString(), 'number');
    });
    lst.add(_buildButton("", "none"));
    lst.add(_buildButton("0", "number"));
    lst.add(_buildButton("\u232B", "delete"));
    return lst;
  }

  void updateValue(val) {
    setState(() {
      value = val;
    });
    widget.onChange(val);
  }

  Widget _buildButton(String key, String type) {
    return Container(
      child: ButtonTheme(
        minWidth: double.infinity,
        child: MaterialButton(
          onPressed: type == 'none'
              ? null
              : () {
                  if (type == 'number') {
                    if (value.length < widget.length) {
                      updateValue(value + key);
                    }
                    return;
                  } else if (type == 'delete') {
                    updateValue(value.substring(0, max(value.length - 1, 0)));
                    return;
                  }
                },
          child: Text(
            key,
            style: TextStyle(fontSize: 18),
          ),
          color: widget.buttonColor,
          textColor: widget.fontColor,
          elevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          highlightElevation: 0,
          disabledElevation: 0,
          disabledColor: widget.buttonColor,
        ),
      ),
    );
  }
}
