import 'package:flutter/material.dart';

double screenHeightSize(double size, BuildContext context) {
  return size * MediaQuery.of(context).size.height / 650.0;
}

double screenWidthSize(double size, BuildContext context) {
  return size * MediaQuery.of(context).size.width / 400.0;
}

Widget screenAppBar(String screenName) {
  return AppBar(
    title: Text(
      screenName,
      style: new TextStyle(
        fontFamily: 'Billabong',
        fontSize: 34,
      ),
    ),
    backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
    elevation: 0,
  );
}

Widget mySnackBar(BuildContext context, String msg) {
  return SnackBar(
    content: Text(msg),
    backgroundColor: Theme.of(context).accentColor,
    duration: Duration(seconds: 1),
  );
}

class MyButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Color color;
  final EdgeInsets padding;

  MyButton({this.text, this.onPressed, this.color, this.padding});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: (color != null) ? color : Theme.of(context).primaryColor,
      highlightColor: Theme.of(context).accentColor,
      disabledColor: Theme.of(context).primaryColor,
      child: Padding(
        padding: (padding != null) ? padding : EdgeInsets.all(15.0),
        child: Text((text != null) ? text : "Button"),
      ),
      onPressed: onPressed,
    );
  }
}
