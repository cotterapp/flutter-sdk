import 'package:cotter/cotter.dart';
import 'package:cotter/src/models/verifyStrings.dart';
import 'package:cotter/src/screens/verifyCodeScreen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class EmailInputScreen extends StatelessWidget {
  final Function onSuccess;
  final Function onError;
  final Cotter cotter;
  VerifyStrings strings;

  EmailInputScreen({
    @required this.onSuccess,
    @required this.onError,
    @required this.cotter,
  }) {
    strings = cotter.signInWithEmailUIStrings;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25)
            .add(EdgeInsets.only(top: 80)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.bottomLeft,
              child: Text(
                strings.inputTitle,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: cotter.colors.text,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            InputForm(
              onSuccess: onSuccess,
              onError: onError,
              cotter: cotter,
            ),
          ],
        ),
      ),
    );
  }
}

class InputForm extends StatefulWidget {
  final Function onSuccess;
  final Function onError;
  final Cotter cotter;
  InputForm(
      {@required this.onSuccess,
      @required this.onError,
      @required this.cotter});
  @override
  InputFormState createState() => InputFormState();
}

class InputFormState extends State<InputForm> {
  final _formKey = GlobalKey<FormState>();
  String pubKey = "nothing";
  String error = "";
  bool loading = false;
  bool _autovalidate = false;

  final inputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    inputController.addListener(_onInputChange);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputController.dispose();
    super.dispose();
  }

  void _setLoading(bool load) {
    setState(() {
      loading = load;
    });
  }

  void _onInputChange() {
    _setError('');
  }

  void sendEmail() async {
    _setError('');
    _setLoading(true);
    try {
      var email = inputController.text;
      var codeSent = await widget.cotter.sendEmailWithCode(email: email);
      if (codeSent) {
        _goToVerifyCode(email);
        _setLoading(false);
      } else {
        var resp = await widget.cotter.signInWithEmail(email: email);
        _onSuccess(resp);
        _setLoading(false);
      }
    } catch (e) {
      _setLoading(false);
      _onError(e);
    }
  }

  void _setError(e) {
    setState(() {
      error = e;
    });
  }

  void _onError(e) {
    _setError(e.toString());
    widget.onError(e.toString());
  }

  void _goToVerifyCode(String email) {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return VerifyCodeScreen(
        identifier: email,
        onSuccess: widget.onSuccess,
        onError: widget.onError,
        cotter: widget.cotter,
      );
    }));
  }

  void _onSuccess(Map<String, dynamic> resp) {
    widget.onSuccess(resp);
  }

  Widget _setButtonChild() {
    if (loading) {
      return SizedBox(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(widget.cotter.colors.grey),
        ),
        height: 13.0,
        width: 13.0,
      );
    } else {
      return Text("Next  \u2192");
    }
  }

  @override
  Widget build(BuildContext context) {
    Cotter.url = "http://localhost:1234/api/v0";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: "Email address",
                labelStyle: TextStyle(
                  fontSize: 17,
                  color: widget.cotter.colors.primary,
                ),
                errorStyle: TextStyle(
                  color: widget.cotter.colors.error,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.cotter.colors.primary,
                    width: 2,
                  ),
                ),
              ),
              controller: inputController,
              autovalidate: _autovalidate,
              validator: (value) {
                bool valid = EmailValidator.validate(value);
                if (!valid) {
                  return "Please enter a valid email";
                }
                return null;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            alignment: Alignment.centerRight,
            child: Text(error,
                style: TextStyle(color: widget.cotter.colors.error)),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.centerRight,
            child: ButtonTheme(
              child: MaterialButton(
                onPressed: loading
                    ? null
                    : () {
                        if (_formKey.currentState.validate()) {
                          sendEmail();
                        } else {
                          setState(() {
                            _autovalidate = true;
                          });
                        }
                      },
                child: _setButtonChild(),
                color: widget.cotter.colors.primary,
                textColor: widget.cotter.colors.textInvert,
                disabledColor: widget.cotter.colors.light,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
