import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_alert_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_list_divider.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/home_page.dart';
import 'package:teachers/pages/login_page.dart';

class SwitchAcountPage extends StatefulWidget {
  @override
  _SwitchAcountPageState createState() => _SwitchAcountPageState();
}

class _SwitchAcountPageState extends State<SwitchAcountPage> {
  bool isLoading = false;
  String loadingText;
  List<User> users = [];
  DBHandler _dbHandler;

  @override
  void initState() {
    setState(() {
      isLoading = true;
      loadingText = 'Loading...';
    });
    _dbHandler = DBHandler();
    _dbHandler.getUsersList().then((result) {
      setState(() {
        users = result;
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        appBar: AppBar(
          title: CustomAppBar(
            title: AppData.getCurrentInstance().user.emp_name,
            subtitle: AppTranslations.of(context).text("key_switch_account"),
          ),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              _dbHandler.getUsersList().then((result) {
                setState(() {
                  users = result;
                });
              });
            },
            child: _createBody()),
      ),
    );
  }

  Widget _createBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  switchAccount(users[index]);
                },
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  child: Text(
                    users[index].emp_name.substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  StringHandlers.capitalizeWords(users[index].emp_name),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  users[index].is_logged_in == 1
                      ? AppTranslations.of(context).text("key_signed_in")
                      : AppTranslations.of(context)
                          .text("key_account_available"),
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Colors.grey,
                ),
              );
            },
            separatorBuilder: (context, index) {
              return CustomListSeparator();
            },
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            createAccount();
          },
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Text(
                  AppTranslations.of(context).text("key_add_new_account"),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void switchAccount(User user) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          DBHandler().logout();
          AppData.getCurrentInstance().user = null;

          DBHandler().login(user).then((val) {});

          setState(() {
            AppData.getCurrentInstance().user = user;
          });

          Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
            (Route<dynamic> route) => false,
          );
        },
        actionColor: Colors.red,
        message:
            AppTranslations.of(context).text("key_switch_account_confirmation"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void createAccount() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          DBHandler().logout();
          AppData.getCurrentInstance().user = null;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (Route<dynamic> route) => false,
          );
        },
        actionColor: Colors.red,
        message:
            AppTranslations.of(context).text("key_add_account_confirmation"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
