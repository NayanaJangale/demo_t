import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_alert_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_homework_item.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/configuration.dart';
import 'package:teachers/models/homework.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/teacher/add_homework_page.dart';

class HomeworkPage extends StatefulWidget {
  @override
  _HomeworkPageState createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  bool isLoading;
  String loadingText;
  GlobalKey<ScaffoldState> _homeworkPageGlobalKey;
  List<Homework> _homeworks = [];
  List<Configuration> _configurations = [];
  bool homeworkApproval = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _homeworkPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    fetchConfiguration(ConfigurationGroups.ApprovedByManagement).then((result) {
      setState(() {
        _configurations = result;
        Configuration conf = _configurations.firstWhere(
                (item) => item.confName == ConfigurationNames.Homework);
        homeworkApproval = conf != null && conf.confValue == "Y" ? true : false;
        fetchHomework().then((result) {
          setState(() {
            _homeworks = result;
          });
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        key: _homeworkPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_hi") +
                ' ' +
                StringHandlers.capitalizeWords(
                  AppData.getCurrentInstance().user.emp_name,
                ),
            subtitle: AppTranslations.of(context).text("key_see_your_homework"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_new
              ),
              onPressed: () {
                Navigator.pop(
                    context, true); // It worked for me instead of above line
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddHomeworkPage()),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchConfiguration(ConfigurationGroups.ApprovedByManagement).then((result) {
              setState(() {
                _configurations = result;
                Configuration conf = _configurations.firstWhere(
                        (item) => item.confName == ConfigurationNames.Homework);
                homeworkApproval = conf != null && conf.confValue == "Y" ? true : false;
                fetchHomework().then((result) {
                  setState(() {
                    _homeworks = result;
                  });
                });
              });
            });
          },
          child: _homeworks != null && _homeworks.length > 0
              ? ListView.builder(
                  itemCount: _homeworks.length,
                  itemBuilder: (BuildContext context, int index) {

                    return CustomHomeworkItem(
                      networkPath: "",
                      onItemTap: () {
                        _deleteHomework(_homeworks[index].hw_no);
                      },
                      periods: _homeworks[index].periods,
                      homework: _homeworks[index],
                      approvalStatus:_homeworks[index].ApproveStatus =="P"?"Pending ":"Approved",
                      isVisibility : homeworkApproval,

                    );
                  },
                )
              : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: AppTranslations.of(context)
                      .text("key_homework_not_available"),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  Future<String> getImageUrl(Homework homework) =>  NetworkHandler.getServerWorkingUrl()
      .then((connectionServerMsg){
    if (connectionServerMsg != "key_check_internet"){
      return Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Homework/GetHomeworkImage',
      ).replace(queryParameters: {
        "hw_no": homework.hw_no.toString(),
        "clientCode":
        AppData.getCurrentInstance().user.client_code,
        "brcode": AppData.getCurrentInstance().user.brcode,
      }).toString();
    }
  });

  Future<List<Homework>> fetchHomework() async {
    List<Homework> homework = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchHomeworksUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              HomeworkUrls.GET_TEACHER_HOMEWORK,
          {
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.yr_no:
                AppData.getCurrentInstance().user.yr_no.toString(),
          },
        );

        http.Response response = await http.get(fetchHomeworksUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          homework = responseData
              .map(
                (item) => Homework.fromJson(item),
              )
              .toList();
          bool homeworkOverlay = AppData.getCurrentInstance().preferences.getBool('homework_overlay') ?? false;
          if(!homeworkOverlay){
            AppData.getCurrentInstance().preferences.setBool("homework_overlay", true);
            _showOverlay(context);
          }
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
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

    return homework;
  }
  Future<void> DeleteHomework(int hw_no) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing . .';
      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postDeleteHomeworkUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              HomeworkUrls.DELETE_TEACHER_HOMEWORK,
          {
            "hw_no": hw_no.toString(),
            UserFieldNames.emp_no:
            AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.yr_no:
            AppData.getCurrentInstance().user.yr_no.toString(),
            UserFieldNames.brcode:
            AppData.getCurrentInstance().user.brcode.toString(),
          },
        );
        http.Response response = await http.post(postDeleteHomeworkUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        if (response.statusCode == HttpStatusCodes.CREATED) {
          //TODO: Call login
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                AppTranslations.of(context).text("key_homework_deleted_successfully"),
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(
                      AppTranslations.of(context).text("key_ok"),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                      // It worked for me instead of above line
                      fetchHomework().then((result) {
                        setState(() {
                          _homeworks = result;
                        });
                      });
                    })
              ],
            ),
          );

        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.ERROR,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }
  void _deleteHomework(int hw_no) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          Navigator.pop(context);
          DeleteHomework(hw_no);
        },
        actionColor: Colors.red,
        message: AppTranslations.of(context).text("key_delete_homework"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }
  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(AppTranslations.of(context).text("key_Click_here_for_add_homework")),
    );
  }
  Future<List<Configuration>> fetchConfiguration(String confGroup) async {
    List<Configuration> configurations = [];
    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          ConfigurationFieldNames.ConfigurationGroup: confGroup,
          "stud_no": "1",
          "yr_no": "1",
          "brcode": AppData.getCurrentInstance().user.brcode,
        };

        Uri fetchSchoolsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              ConfigurationUrls.GET_CONFIGURATION_BY_GROUP,
          params,
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
              context, null, response.body, MessageTypes.WARNING);
        } else {
          List responseData = json.decode(response.body);
          configurations = responseData
              .map(
                (item) => Configuration.fromJson(item),
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

    return configurations;
  }
}
