import 'package:cotter/cotter.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class VerifyCodeScreen extends StatelessWidget {
  String identifier;
  Function onSuccess;
  Function onError;
  final Cotter cotter;
  VerifyCodeScreen({
    @required this.identifier,
    @required this.onSuccess,
    @required this.onError,
    @required this.cotter,
  });
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VerifyCodeInput(
        identifier: this.identifier,
        onSuccess: this.onSuccess,
        onError: this.onError,
        cotter: cotter,
      ),
    );
  }
}

class VerifyCodeInput extends StatefulWidget {
  String identifier = '';
  Function onSuccess;
  Function onError;
  final Cotter cotter;
  VerifyCodeInput({
    @required this.identifier,
    @required this.onSuccess,
    @required this.onError,
    @required this.cotter,
  });
  @override
  VerifyCodeInputState createState() => VerifyCodeInputState();
}

class VerifyCodeInputState extends State<VerifyCodeInput> {
  String value = '';
  int length = 6;
  String error = '';
  bool loading = false;

  void _setLoading(bool load) {
    setState(() {
      loading = load;
    });
  }

  @override
  Widget build(BuildContext context) {
    void onChange(val) {
      _setError('');
      setState(() {
        value = val;
      });
    }

    Cotter.url = "http://localhost:1234/api/v0";
    var strings = widget.cotter.signInWithEmailUIStrings;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Text(
                              strings.verifyCodeTitle,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Text(strings.verifyCodeText),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              widget.identifier,
                              style: TextStyle(
                                  color: widget.cotter.colors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: CotterCodeInput(
                        length: this.length,
                        value: this.value,
                        fontColor: widget.cotter.colors.primary,
                        pinColor: widget.cotter.colors.light,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: widget.cotter.colors.light,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      alignment: Alignment.topCenter,
                      child: Text(
                        error,
                        style: TextStyle(
                          color: widget.cotter.colors.error,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      alignment: Alignment.centerRight,
                      child: ButtonTheme(
                        child: MaterialButton(
                          onPressed: value.length == this.length && !loading
                              ? () {
                                  _submitCode(context, value);
                                }
                              : null,
                          child: _setButtonChild(),
                          color: widget.cotter.colors.primary,
                          textColor: widget.cotter.colors.textInvert,
                          disabledColor: widget.cotter.colors.light,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 20),
              child: CotterKeyboard(onChange: onChange, length: this.length),
            )
          ],
        ),
      ),
    );
  }

  void _onSuccess(Map<String, dynamic> resp) {
    widget.onSuccess(resp);
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

  void _submitCode(BuildContext context, String code) async {
    _setError('');
    _setLoading(true);
    try {
      var resp = await widget.cotter
          .signInWithEmail(email: widget.identifier, code: code);
      _setLoading(false);
      _onSuccess(resp);
    } catch (e) {
      _setLoading(false);
      _onError(e);
    }
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
}
