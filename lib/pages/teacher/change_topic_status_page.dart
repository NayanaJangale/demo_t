import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/syllabus_topic.dart';
import 'package:teachers/models/teacher_period.dart';
import 'package:teachers/models/user.dart';

class ChangeTopicStatusPage extends StatefulWidget {
  @override
  _ChangeTopicStatusPageState createState() => _ChangeTopicStatusPageState();
}

class _ChangeTopicStatusPageState extends State<ChangeTopicStatusPage> {
  bool _isLoading;
  String _loadingText;

  GlobalKey<ScaffoldState> _syllabusPageGK;
  String _subjectName;
  int _subjectId,classId;
  List<TeacherPeriod> _subjects = [];
  TeacherPeriod selectedSubject;
  List<SyllabusTopic> _syllabus = [];

  String msgKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this._syllabusPageGK = GlobalKey<ScaffoldState>();

    this._isLoading = false;
    this._loadingText = 'Loading . . .';

    this._subjectName = '';

    msgKey = "key_select_to_see_syllabus";

    fetchPeriods().then((result) {
      setState(() {
        this._subjects = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadingText = AppTranslations.of(context).text("key_loading");

    return CustomProgressHandler(
      isLoading: this._isLoading,
      loadingText: this._loadingText,
      child: Scaffold(
        key: _syllabusPageGK,
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_hi") +
                ' ' +
                StringHandlers.capitalizeWords(
                    AppData.getCurrentInstance().user.emp_name),
            subtitle: AppTranslations.of(context).text("key_your_syllabus"),
          ),
          elevation: 0.0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (selectedSubject != null) {
              fetchSyllabus().then((result) {
                setState(() {
                  _syllabus = result;
                });
              });
            } else {
              FlushbarMessage.show(
                context,
                null,
                AppTranslations.of(context).text("key_select_subject"),
                MessageTypes.WARNING,
              );
            }
          },
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    bottom: 8.0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (_subjects != null && _subjects.length > 0) {
                        showSubjects();
                      } else {
                        fetchPeriods().then((result) {
                          setState(() {
                            _subjects = result;
                          });
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.0,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                AppTranslations.of(context).text("key_subject"),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                              ),
                            ),
                            Text(
                              _subjectName,
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(
                child: _syllabus != null && _syllabus.length > 0
                    ? ListView.builder(
                        itemCount: _syllabus.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                            ),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30.0),
                                  topLeft: Radius.circular(3.0),
                                  bottomRight: Radius.circular(3.0),
                                  bottomLeft: Radius.circular(3.0),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            StringHandlers.capitalizeWords(
                                              _syllabus[index].topic_name,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        makePopupMenuButton(_syllabus[index]),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    _syllabus[index].details != null &&
                                            _syllabus[index].details != ''
                                        ? Text(
                                            StringHandlers.capitalizeWords(
                                              _syllabus[index].details,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          )
                                        : Container(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 12,
                                        bottom: 5,
                                        right: 14,
                                      ),
                                      child: Divider(
                                        height: 0,
                                        color: Colors.black12,
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          'Sessions: ' +
                                              _syllabus[index]
                                                  .no_of_sessions
                                                  .toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black45,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 14.0,
                                          ),
                                          child: Text(
                                            _syllabus[index].status,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: _syllabus[index]
                                                              .status ==
                                                          SyllabusTopic.PENDING
                                                      ? Colors.red
                                                      : _syllabus[index]
                                                                  .status ==
                                                              SyllabusTopic
                                                                  .ON_GOING
                                                          ? Colors.amber
                                                          : Colors.green,
                                                ),
                                          ),
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              AppTranslations.of(context).text(msgKey),
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container makePopupMenuButton(SyllabusTopic topic) => Container(
        child: Padding(
          padding: EdgeInsets.only(
            right: 0.0,
          ),
          child: topic.status == SyllabusTopic.COMPLETED
              ? PopupMenuButton<String>(
                  enabled: false,
                  icon: Icon(
                    Icons.check_circle_outline,
                    size: 25.0,
                    color: Colors.green,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: SyllabusTopic.PENDING,
                      child: Text(
                        SyllabusTopic.PENDING,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      topic.status = value;
                    });
                    updateTopicStatus(topic);
                  },
                )
              : PopupMenuButton<String>(
                  enabled: true,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: SyllabusTopic.PENDING,
                      child: Text(
                        SyllabusTopic.PENDING,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                    PopupMenuDivider(
                      height: 1.0,
                    ),
                    PopupMenuItem(
                      value: SyllabusTopic.ON_GOING,
                      child: Text(
                        SyllabusTopic.ON_GOING,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                    PopupMenuDivider(
                      height: 1.0,
                    ),
                    PopupMenuItem(
                      value: SyllabusTopic.COMPLETED,
                      child: Text(
                        SyllabusTopic.COMPLETED,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      topic.status = value;
                    });
                    updateTopicStatus(topic);
                  },
                ),
        ),
      );

  Future<List<TeacherPeriod>> fetchPeriods() async {
    List<TeacherPeriod> subject = [];
    try {
      setState(() {
        _isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no: user != null ? user.emp_no.toString() : "",
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              TeacherPeriodUrls.GET_TEACHER_PERIODS,
          params,
        );

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          List responseData = json.decode(response.body);
          subject =
              responseData.map((item) => TeacherPeriod.fromJson(item)).toList();
          bool syllabusOverlay = AppData.getCurrentInstance().preferences.getBool('syllabus_Overlay') ?? false;
          if(!syllabusOverlay){
            AppData.getCurrentInstance().preferences.setBool("syllabus_Overlay", true);
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
      _isLoading = false;
    });

    return subject;
  }


  Future<List<SyllabusTopic>> fetchSyllabus() async {
    List<SyllabusTopic> syllabus = [];
    try {
      setState(() {
        _isLoading = true;
        _loadingText = 'Loading . . .';
        msgKey = "key_loading_syllabus";
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "class_id": classId.toString(),
          "subject_id": _subjectId.toString(),
          "clientCode": AppData.getCurrentInstance().user.client_code,
          "brcode": AppData.getCurrentInstance().user.brcode,
          "UserNo": AppData.getCurrentInstance().user.user_no.toString(),
          "MacAddress": "MacAddress",
          "UserType": "Teacher",
          "ApplicationType": "ApplicationType",
          "AppVersion": "1.0",
        };

        Uri fetchTopicsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              SyllabusTopicUrls.GET_SUBJECT_SYLLABUS,
          params,
        );

        http.Response response = await http.get(fetchTopicsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.WARNING,
          );
          setState(() {
            msgKey = "key_select_to_see_syllabus";
          });
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            syllabus = responseData
                .map(
                  (item) => SyllabusTopic.fromMap(item),
                )
                .toList();
          });
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
        setState(() {
          msgKey = "key_check_internet";
        });
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      setState(() {
        msgKey = "key_api_error";
      });
    }

    setState(() {
      _isLoading = false;
    });

    return syllabus;
  }

  void updateTopicStatus(SyllabusTopic topic) async {
    try {
      setState(
        () {
          _isLoading = true;
        },
      );

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> param = {
          "class_id": AppData.getCurrentInstance().user.class_id.toString(),
          "subject_id": _subjectId.toString(),
          "clientCode": AppData.getCurrentInstance().user.client_code,
          "brcode": AppData.getCurrentInstance().user.brcode,
          "UserNo": AppData.getCurrentInstance().user.user_no.toString(),
          "MacAddress": "MacAddress",
          "UserType": "Teacher",
          "ApplicationType": "ApplicationType",
          "AppVersion": "1.0",
        };

        Uri updateTopicStatusUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              SyllabusTopicUrls.POST_UPDATE_SYLLABUS_STATUS,
        ).replace(
          queryParameters: param,
        );

        String jsonBody = json.encode(topic);
        print(jsonBody);

        http.Response response = await http.post(
          updateTopicStatusUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.WARNING,
          );
        } else {
          fetchSyllabus().then((result) {
            setState(() {
              _syllabus = result;
            });
          });
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
        setState(() {
          msgKey = "key_check_internet";
        });
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      setState(() {
        msgKey = "key_api_error";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void showSubjects() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_subject"),
        ),
        actions: List<Widget>.generate(
          _subjects.length,
          (index) => CustomCupertinoActionSheetAction(
            actionIndex: index,
            actionText:
                StringHandlers.capitalizeWords(_subjects[index].class_name+" "+_subjects[index].division_name+" : "+_subjects[index].subject_name),
            onActionPressed: () {
              setState(() {
                selectedSubject = _subjects[index];
                _subjectName = selectedSubject.subject_name;
                _subjectId = selectedSubject.subject_id;
                classId = selectedSubject.class_id;
              });
              fetchSyllabus().then((result) {
                setState(() {
                  _syllabus = result;
                });
              });
              Navigator.pop(context);
            },
          ),
        ),
        cancelButton: CupertinoActionSheetAction(
          child: Text(
            AppTranslations.of(context).text("key_cancel"),
            style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(AppTranslations.of(context).text("key_select_to_see_syllabus")),
    );
  }
}
