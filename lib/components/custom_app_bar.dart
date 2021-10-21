import 'package:flutter/material.dart';
class CustomAppBar extends StatefulWidget {
  final String title, subtitle;

  const CustomAppBar({
    this.title,
    this.subtitle,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          this.widget.title,
          style: Theme.of(context)
              .appBarTheme
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white),
        ),
        Text(
          this.widget.subtitle,
          style: Theme.of(context)
              .appBarTheme
              .textTheme
              .subtitle1
              .copyWith(color: Colors.white,
          fontSize: 14),
        ),
      ],
    );
  }
}
