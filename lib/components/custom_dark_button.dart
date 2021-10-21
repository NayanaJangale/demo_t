import 'package:flutter/material.dart';
import 'package:teachers/themes/button_styles.dart';

class CustomDarkButton extends StatelessWidget {
  final String caption;
  final Function onPressed;

  const CustomDarkButton({
    this.caption,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: this.onPressed,
     /* padding: const EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),*/
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        onPrimary: Colors.white,
        onSurface: Colors.grey,
      ),
      child: Container(
        width: double.infinity,
      //  decoration: SoftCampusButtonStyles.getDarkButtonDecoration(context),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              caption,
              style: SoftCampusButtonStyles.getDarkButtonTextStyle(context),
            ),
          ),
        ),
      ),
    );
  }
}
