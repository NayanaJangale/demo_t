import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:teachers/app_data.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/components/chapter_card_view.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/class.dart';
import 'package:teachers/models/digital_chapter_master.dart';
import 'package:teachers/models/divison.dart';
import 'package:teachers/models/subject.dart';
import 'package:teachers/models/user.dart';

import 'add_video_page.dart';

class DigitalChapterPage extends StatefulWidget {
  @override
  _DigitalChapterPageState createState() => _DigitalChapterPageState();
}

class _DigitalChapterPageState extends State<DigitalChapterPage> {

  bool isLoading;
  String loadingText;
  GlobalKey<ScaffoldState> _digitalChapterPageGK;

  Subject selectedSubject;
  List<DigitalChapterMaster> _digitalChapters = [];
  List<Subject> teacherPeriods = [];
  List<Class> _classes = [];
  Class _selectedClass;
  Subject _selectedTeacherPeriod;
  List<Division> divisions = [];
  Division selectedDivision;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _digitalChapterPageGK = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchClasses().then((result) {
      setState(() {
        this._classes = result;
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
        key: _digitalChapterPageGK,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppTranslations.of(context).text("key_add_chapter_video"),
          ),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddVideoPage()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      bottom: 8.0,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (_classes != null && _classes.length > 0) {
                          showClassesList();
                        } else {
                          fetchClasses().then((result) {
                            setState(() {
                              this._classes = result;
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
                                  AppTranslations.of(context).text("key_class"),
                                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color:
                                    Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                _selectedClass != null
                                    ? _selectedClass.class_name
                                    : AppTranslations.of(context)
                                    .text("key_select_class"),
                                style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      bottom: 8.0,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (divisions!=null && divisions.length > 0){
                          showDivisions();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Theme.of(context).primaryColorLight,
                          ),
                          borderRadius: BorderRadius.circular(
                            5.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context)
                                    .text("key_division"),
                                style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color:
                                  Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  selectedDivision != null ? selectedDivision.division_name: AppTranslations.of(context)
                                      .text("key_select_division"),
                                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign:  TextAlign.end,
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
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      right: 12.0,
                      bottom: 8.0,
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (teacherPeriods != null && teacherPeriods.length > 0) {
                          showSubjectList();
                        } else {
                          if(selectedDivision!= null ){
                            fetchPeriods().then((result) {
                              setState(() {
                                this.teacherPeriods = result;
                              });
                            });
                          }else{
                            FlushbarMessage.show(
                              context,
                              "",
                              AppTranslations.of(context).text("key_select_division_first"),
                              MessageTypes.WARNING,
                            );

                          }

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
                                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color:
                                    Theme.of(context).secondaryHeaderColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                _selectedTeacherPeriod != null ? _selectedTeacherPeriod.subject_name : AppTranslations.of(context).text("key_select_subject"),
                                style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
            _digitalChapters != null && _digitalChapters.length > 0
                ? getChaptersView()
                : Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                AppTranslations.of(context)
                    .text("key_select_view_digi_chaps"),
                style: Theme.of(context).textTheme.bodyText2.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSubjectList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_subject"),
        ),
        actions: List<Widget>.generate(
          teacherPeriods.length,
              (index) => CustomCupertinoActionSheetAction(
            actionText: teacherPeriods[index].subject_name,
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                _selectedTeacherPeriod = teacherPeriods[index];
              });
              if(_selectedClass != null || _selectedTeacherPeriod != null){
                fetchChapterVideo().then((result) {
                  setState(() {
                    _digitalChapters = result;
                  });
                });
              }
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  Future<List<Division>> fetchDivision(int class_id) async {
    List<Division> divisions = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "class_id" : class_id.toString(),
          UserFieldNames.emp_no:
          AppData.getCurrentInstance().user.emp_no.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                DivisionUrls.Get_Emp_Classwise_Divisions,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            divisions =
                responseData.map((item) => Division.fromJson(item)).toList();
          });
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
    return divisions;
  }
  void showDivisions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
            message: AppTranslations.of(context).text("key_division")),
        actions: List<Widget>.generate(
          divisions.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: divisions[i].division_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                setState(() {
                  selectedDivision = divisions[i];
                });
                if(_selectedClass!=null){
                  fetchPeriods().then((result) {
                 setState(() {
                   this.teacherPeriods = result;
                 });
               });
                }
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  void showClassesList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_class"),
        ),
        actions: List<Widget>.generate(
          _classes.length,
              (index) => CustomCupertinoActionSheetAction(
            actionText: _classes[index].class_name,
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                _selectedClass = _classes[index];
              });
             if(_selectedClass!=null){
               fetchDivision(_selectedClass.class_id).then((result) {
                 setState(() {
                   divisions.clear();
                   divisions = result;
                   divisions.insert(
                       0, new Division(division_id: 0, division_name: "All"));
                 });
               });
               /*fetchPeriods().then((result) {
                 setState(() {
                   this.teacherPeriods = result;
                 });
               });*/
             }

              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
  Widget getChaptersView() {
    return Expanded(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          height: 0.0,
        ),
        itemCount: _digitalChapters.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    left: 3.0,
                    bottom: 3.0,
                  ),
                  child: Text(
                    _digitalChapters[index].chapter_name,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:  _digitalChapters[index].videos.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, rowIndex) {
                      return ChapterCardView(
                        video: _digitalChapters[index].videos[rowIndex],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<Class>> fetchClasses() async {
    List<Class> teacherClasses;
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no: user != null ? user.emp_no.toString() : "",
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                ClassUrls.GET_CLASSES_BY_SUBJECT,
            params);

        Response response = await get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.ERROR,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            teacherClasses = responseData
                .map((item) => Class.fromJson(item))
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

    return teacherClasses;
  }
  Future<List<Subject>> fetchPeriods() async {
    List<Subject> periods = [];
    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "class_id": _selectedClass.class_id.toString(),
          "division_id": selectedDivision.division_id.toString(),
          UserFieldNames.emp_no:
          AppData.getCurrentInstance().user.emp_no.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              SubjectUrls.GET_TEACHER_SUBJECTS,
          params,
        );

        Response response = await get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.INFORMATION,
          );
        } else {
          List responseData = json.decode(response.body);
          periods =
              responseData.map((item) => Subject.fromMap(item)).toList();
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

    return periods;
  }

  Future<List<DigitalChapterMaster>> fetchChapterVideo() async {
    List<DigitalChapterMaster> chapterVideo = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Uri fetchClassesUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              DigitalChapterUrls.GET_DIGITAL_CHAPTER,
        ).replace(queryParameters: {
          UserFieldNames.emp_no: user != null ? user.emp_no.toString() : "",
          "subject_id":_selectedTeacherPeriod.subject_id.toString(),
          "class_id":_selectedClass.class_id.toString(),
          "division_id":selectedDivision.division_id.toString(),
          "user_no":user != null ? user.user_no.toString() : "",
          "clientCode": user.client_code,
          "brcode": user.brcode,
          "UserType": "Teacher",
          "ApplicationType": "Teacher",
          "AppVersion": "1",
          "MacAddress": "xxxxxx",
        });

        Response response = await get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.ERROR,
          );
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            chapterVideo = responseData
                .map((item) => DigitalChapterMaster.fromJson(item))
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

    return chapterVideo;
  }
}
