import 'package:cotter/cotter.dart';
import 'package:cotter/src/models/approveRequestStrings.dart';
import 'package:flutter/material.dart';

class ApproveRequest extends StatefulWidget {
  final Cotter cotter;
  ApproveRequestStrings strings;
  ApproveRequest({
    @required this.cotter,
  });
  @override
  ApproveRequestState createState() => ApproveRequestState();
}

class ApproveRequestState extends State<ApproveRequest> {
  @override
  Widget build(BuildContext context) {
    ApproveRequestStrings strings = widget.cotter.approveRequestStrings;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          color: widget.cotter.colors.text,
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Image(
                        image: AssetImage(
                          strings.logoPath,
                          package: 'cotter',
                        ),
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        strings.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        strings.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.cotter.colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(3),
                      child: OutlineButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: Text(strings.approve),
                        color: widget.cotter.colors.success,
                        textColor: widget.cotter.colors.success,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(3),
                      child: OutlineButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: Text(strings.reject),
                        color: widget.cotter.colors.error,
                        textColor: widget.cotter.colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
