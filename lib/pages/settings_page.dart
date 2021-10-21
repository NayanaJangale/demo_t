import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_alert_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_cupertino_icon_action.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/internet_connection.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_locales.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/database_handler.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/localization/application.dart';
import 'package:teachers/models/academic_year.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/change_password_page.dart';
import 'package:teachers/pages/login_page.dart';
import 'package:teachers/pages/teacher/switch_acount_page.dart';
import 'package:teachers/themes/app_settings_change_notifier.dart';
import 'package:teachers/themes/menu_type.dart';
import 'package:teachers/themes/theme_constants.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  GlobalKey<ScaffoldState> _settingsPageGK;
  String selectedThemeName,
      selectedMenuType,
      selectedLocale = 'en',
      selectedAcademicYear;

  AppSettingsChangeNotifier _appSettingsChangeNotifier;

  bool isLoading;
  String loadingText;
  List<AcademicYear> academicYears = [];
  User user;
  DBHandler _dbHandler;

  @override
  void initState() {
    isLoading = false;
    loadingText = 'Loading . . .';
    _dbHandler = DBHandler();

    fetchAcademicYear().then((res) {
      setState(() {
        academicYears = res;
      });
    });

    if (AppData.getCurrentInstance().preferences != null) {
      selectedThemeName =
          AppData.getCurrentInstance().preferences.getString('theme') ??
              ThemeNames.Purple;

      AppData.getCurrentInstance().preferences.getString('menuType') ==
              MenuTitles.List
          ? selectedMenuType = MenuTitles.List
          : selectedMenuType = MenuTitles.Grid;

      selectedLocale =
          AppData.getCurrentInstance().preferences.getString('locale') ?? 'en';
      user = AppData.getCurrentInstance().user;
      selectedAcademicYear = AppData.getCurrentInstance().user.academic_year;
    } else {
      selectedThemeName = ThemeNames.Purple;
      selectedMenuType = MenuTitles.Grid;
      selectedLocale = 'en';
    }

    application.onLocaleChanged = onLocaleChange;
    super.initState();
    _settingsPageGK = GlobalKey<ScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    _appSettingsChangeNotifier =
        Provider.of<AppSettingsChangeNotifier>(context);

    AppData.getCurrentInstance().preferences.getString('menuType') ==
            MenuTitles.List
        ? selectedMenuType = AppTranslations.of(context).text("key_list")
        : selectedMenuType = AppTranslations.of(context).text("key_grid");

    return CustomProgressHandler(
        isLoading: this.isLoading,
        loadingText: this.loadingText,
      child: Scaffold(
        key: _settingsPageGK,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_hi") +
                ' ' +
                StringHandlers.capitalizeWords(
                    AppData.getCurrentInstance().user.emp_name),
            subtitle: AppTranslations.of(context).text("key_app_settings"),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey.withOpacity(0.2),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    AppTranslations.of(context).text("key_appearance"),
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    AppTranslations.of(context).text("key_theme"),
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    themeColors.length,
                        (index) => getThemeColor(
                      themeColors[index],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5.0,
                ),
                child: Divider(
                  height: 0.0,
                  color: Colors.black12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showLocaleList();
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            AppTranslations.of(context).text("key_language"),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            selectedLocale == 'en' ? 'English' : 'मराठी',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5.0,
                ),
                child: Divider(
                  height: 0.0,
                  color: Colors.black12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showMenuTypeList();
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            AppTranslations.of(context).text("key_menu_type"),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            selectedMenuType,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 3.0,
              ),
              Container(
                color: Colors.grey.withOpacity(0.2),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    AppTranslations.of(context).text("key_account"),
                    style: Theme.of(context).textTheme.subhead.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  showAcademicYearList();
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            AppTranslations.of(context).text("key_academic_year"),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            selectedAcademicYear ?? "",
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
             /* Padding(
                padding: const EdgeInsets.only(
                  top: 5.0,
                ),
                child: Divider(
                  height: 0.0,
                  color: Colors.black12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SwitchAcountPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            AppTranslations.of(context)
                                .text("key_switch_account"),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/
              Padding(
                padding: const EdgeInsets.only(
                  top: 5.0,
                ),
                child: Divider(
                  height: 0.0,
                  color: Colors.black12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            AppTranslations.of(context)
                                .text("key_change_password"),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5.0,
                ),
                child: Divider(
                  height: 0.0,
                  color: Colors.black12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _logout();
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, bottom: 10.0, top: 10.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            AppTranslations.of(context).text("key_logout"),
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.navigate_next,
                          color: Colors.black45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 5.0,
                ),
                child: Divider(
                  height: 0.0,
                  color: Colors.black12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getThemeColor(ThemeColor themeColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedThemeName = themeColor.caption;

          ThemeData themeData;
          switch (selectedThemeName) {
            case ThemeNames.Purple:
              themeData = ThemeConfig.purpleThemeData(context);
              break;
            case ThemeNames.Blue:
              themeData = ThemeConfig.blueThemeData(context);
              break;
            case ThemeNames.Teal:
              themeData = ThemeConfig.tealThemeData(context);
              break;
            case ThemeNames.Amber:
              themeData = ThemeConfig.amberThemeData(context);
              break;
          }
          _appSettingsChangeNotifier.setTheme(selectedThemeName, themeData);

          AppData.getCurrentInstance()
              .preferences
              .setString('theme', selectedThemeName);
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: themeColor.color,
              radius: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                themeColor.caption == selectedThemeName
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
                color: themeColor.caption == selectedThemeName
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).secondaryHeaderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMenuTypeList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_menu_type"),
        ),
        actions: List<Widget>.generate(
          menuTypes.length,
          (index) => CustomCupertinoIconAction(
            isImage: false,
            iconData: menuTypes[index].icon,
            actionText: AppTranslations.of(context)
                .text("key_${menuTypes[index].typeTitle}"),
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                selectedMenuType = menuTypes[index].typeTitle;
                AppData.getCurrentInstance()
                    .preferences
                    .setString('menuType', selectedMenuType);

                selectedMenuType = AppTranslations.of(context)
                    .text("key_${menuTypes[index].typeTitle}");
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showLocaleList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_app_language"),
        ),
        actions: List<Widget>.generate(
          projectLocales.length,
          (index) => CustomCupertinoIconAction(
            isImage: true,
            imagePath: projectLocales[index].image,
            actionText: projectLocales[index].title,
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                _appSettingsChangeNotifier.setLocale(
                  Locale(projectLocales[index].lanaguageCode),
                );
                selectedLocale = projectLocales[index].lanaguageCode;

                AppData.getCurrentInstance()
                    .preferences
                    .setString('locale', selectedLocale);
              });

              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> onLocaleChange(Locale locale) async {
    setState(() {
      AppTranslations.load(locale);
    });
  }

  List<Widget> getThemeMenuTypeList(BuildContext context) {
    List<Widget> menuItems = [];

    for (int i = 0; i < menuTypes.length; i++) {
      menuItems.add(
        GestureDetector(
          onTap: () {
            showMenuTypeList();
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(menuTypes[i].typeTitle),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    menuTypes[i].icon,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return menuItems;
  }

  void _logout() {
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
        message: AppTranslations.of(context).text("key_logout_confirmation"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void showAcademicYearList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_academic_year"),
        ),
        actions: List<Widget>.generate(
          academicYears.length,
          (index) => CustomCupertinoActionSheetAction(
            actionIndex: index,
            actionText: academicYears[index].yr_desc,
            onActionPressed: () async {
              setState(() {
                selectedAcademicYear = academicYears[index].yr_desc;
                user.yr_no = academicYears[index].yr_no;
                user.academic_year = academicYears[index].yr_desc;
              });
              user = await _dbHandler.updateUser(user);
              if (user != null) {
                AppData.getCurrentInstance().user = user;
                Navigator.pop(context);
              } else {
                FlushbarMessage.show(
                  context,
                  null,
                  'Not able to perform local login!',
                  MessageTypes.ERROR,
                );
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Future<List<AcademicYear>> fetchAcademicYear() async {
    List<AcademicYear> academicYears = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {
        String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
        if (connectionServerMsg != "key_check_internet") {
          Map<String, dynamic> params = {
            "clientCode": AppData.getCurrentInstance().user != null
                ? AppData.getCurrentInstance().user.client_code.toString()
                : "",
          };
          Uri fetchSchoolsUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                "Teacher/GetAcademicYears",
            params,
          );

          Response response = await get(fetchSchoolsUri);
          if (response.statusCode != HttpStatusCodes.OK) {
            FlushbarMessage.show(
                context, null, response.body, MessageTypes.WARNING);
          } else {
            List responseData = json.decode(response.body);
            academicYears = responseData
                .map(
                  (item) => AcademicYear.fromJson(item),
            )
                .toList();
          }
        } else {
          FlushbarMessage.show(
            context,
            AppTranslations.of(context).text("key_no_internet"),
            AppTranslations.of(context).text("key_check_internet"),
            MessageTypes.WARNING,
          );
        }
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
    }

    setState(() {
      isLoading = false;
    });

    return academicYears;
  }
}
