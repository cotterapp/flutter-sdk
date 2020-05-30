import 'package:flutter/material.dart';

class InputForm extends StatefulWidget {
  @override
  InputFormState createState() => InputFormState();
}

class InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();

  final inputController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextField(
        decoration: InputDecoration(
          labelText: "Email",
        ),
        controller: inputController,
      ),
    );
  }
}
