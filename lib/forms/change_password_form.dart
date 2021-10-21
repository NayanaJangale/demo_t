import 'package:flutter/material.dart';
import 'package:teachers/components/custom_dark_button.dart';
import 'package:teachers/components/custom_light_button.dart';
import 'package:teachers/components/custom_password_box.dart';

class ChangePasswordForm extends StatelessWidget {
  final String oldPasswordCaption,
      passwordCaption,
      confirmPasswordCaption,
      changeButtonCaption,
      cancelButtonCaption;
  final TextInputAction oldPasswordInputAction,
      passwordInputAction,
      confirmPasswordInputAction;
  final FocusNode oldPasswordFocusNode,
      passwordFocusNode,
      confirmPasswordFocusNode;

  final TextEditingController oldPasswordController,
      passwordController,
      confirmPasswordController;
  final Function onChangeButtonPressed,
      onPasswordSubmitted,
      onOldPasswordSubmitted,
      onCancelButtonPressed;

  ChangePasswordForm({
    this.oldPasswordCaption,
    this.passwordCaption,
    this.confirmPasswordCaption,
    this.changeButtonCaption,
    this.cancelButtonCaption,
    this.oldPasswordInputAction,
    this.passwordInputAction,
    this.confirmPasswordInputAction,
    this.oldPasswordFocusNode,
    this.passwordFocusNode,
    this.confirmPasswordFocusNode,
    this.oldPasswordController,
    this.passwordController,
    this.confirmPasswordController,
    this.onChangeButtonPressed,
    this.onPasswordSubmitted,
    this.onOldPasswordSubmitted,
    this.onCancelButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomPasswordBox(
            inputAction: oldPasswordInputAction,
            labelText: oldPasswordCaption,
            controller: oldPasswordController,
            focusNode: oldPasswordFocusNode,
            icon: Icons.lock_outline,
            keyboardType: TextInputType.text,
            colour: Theme.of(context).primaryColor,
            onFieldSubmitted: onOldPasswordSubmitted,
          ),
          SizedBox(
            height: 10.0,
          ),
          CustomPasswordBox(
            inputAction: passwordInputAction,
            labelText: passwordCaption,
            controller: passwordController,
            focusNode: passwordFocusNode,
            icon: Icons.lock,
            keyboardType: TextInputType.text,
            colour: Theme.of(context).primaryColor,
            onFieldSubmitted: onPasswordSubmitted,
          ),
          SizedBox(
            height: 10.0,
          ),
          CustomPasswordBox(
            inputAction: confirmPasswordInputAction,
            labelText: confirmPasswordCaption,
            controller: confirmPasswordController,
            focusNode: confirmPasswordFocusNode,
            icon: Icons.lock,
            keyboardType: TextInputType.text,
            colour: Theme.of(context).primaryColor,
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomDarkButton(
                  caption: changeButtonCaption,
                  onPressed: onChangeButtonPressed,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),

              Expanded(
                child: CustomLightButton(
                  caption: cancelButtonCaption,
                  onPressed: onCancelButtonPressed,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            'Enter your old, new and confirm password to change your password.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.left,
          )
        ],
      ),
    );
  }
}
