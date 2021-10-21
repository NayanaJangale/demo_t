import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_alert_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_attendance_item.dart';
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
import 'package:teachers/models/configuration.dart';
import 'package:teachers/models/student_attendance.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/teacher_period.dart';
import 'package:teachers/models/user.dart';

class MarkAttendancePage extends StatefulWidget {
  @override
  _MarkAttendancePageState createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  bool _isLoading;
  DateTime _selectedDate = DateTime.now();
  List<TeacherClass> _classes = [];
  List<TeacherPeriod> _subjects = [];
  List<StudentAttendance> _attendances = [];
  bool attendanceApproval = false;
  GlobalKey<ScaffoldState> _attendancePageGlobalKey;
  TeacherClass _selectedClass = TeacherClass(
    class_id: AppData.getCurrentInstance().user.class_id,
    division_id: AppData.getCurrentInstance().user.division_id,
    class_name: AppData.getCurrentInstance().user.class_name,
    division_name: AppData.getCurrentInstance().user.division_name,
  );

  TeacherPeriod _selectedPeriod = TeacherPeriod(
    class_id: 0,
    division_id: 0,
    class_name: "",
    division_name: "",
    subject_id: 0,
    subject_name: "",
  );

  List<String> _attendanceStatus = ['Present', 'Absent'];
  String _defaultAttendance = 'Present';
  String subtitle, attendanceType, loadingText;
  String msgKey;
  List<Configuration> _configurations = [];
  List<Configuration> _approvalConfigurations = [];
  String selectedAttendaceType = "";
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            disabledColor: Colors.orange,
            accentColor: Theme.of(context).primaryColor,
            dialogBackgroundColor: Colors.grey[200],
          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    msgKey = "key_loading_attendance";
    loadingText = 'Loading . .';
    this._isLoading = false;
    super.initState();
    _attendancePageGlobalKey = GlobalKey<ScaffoldState>();
    fetchConfiguration(ConfigurationGroups.Attendance).then((result) {
      setState(() {
        _configurations = result;
        Configuration conf = _configurations.firstWhere(
            (item) => item.confName == ConfigurationNames.SUBJECTWISE);
        selectedAttendaceType = conf != null && conf.confValue == "N"
            ? AttendanceConfigurationNames.Classwise
            : AttendanceConfigurationNames.Subjectwise;
        if (selectedAttendaceType == AttendanceConfigurationNames.Classwise) {
          fetchStudentAttendance("-1").then((result) {
            setState(() {
              _attendances = result;
            });
          });
        } else {
          fetchPeriods().then((result) {
            fetchStudentAttendance(result[0].subject_id.toString())
                .then((result) {
              setState(() {
                _attendances = result != null ? result : [];
              });
            });
            setState(() {
              _subjects = result;
              _selectedPeriod = _subjects[0];
              subtitle = AppTranslations.of(context).text("key_subject") +
                  ' ' +
                  _selectedPeriod.class_name +
                  ' ' +
                  _selectedPeriod.division_name +
                  _selectedPeriod.subject_name;
            });
          });
        }
      });
    });

    fetchConfiguration(ConfigurationGroups.PreviousDayAttendance).then((result) {
      setState(() {
        _approvalConfigurations = result;
        Configuration conf = _approvalConfigurations.firstWhere(
                (item) => item.confName == ConfigurationNames.Approval);
        attendanceApproval = conf != null && conf.confValue == "Y" ? true : false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedAttendaceType == AttendanceConfigurationNames.Classwise) {
      subtitle = AppTranslations.of(context).text("key_class") +
          _selectedClass.class_name +
          ' ' +
          _selectedClass.division_name;
    } else {
      if (_selectedPeriod.subject_name != "") {
        subtitle = AppTranslations.of(context).text("key_subject") +
            " " +
            _selectedPeriod.class_name +
            ' ' +
            _selectedPeriod.division_name +
            ' ' +
            _selectedPeriod.subject_name;
      } else {
        subtitle = AppTranslations.of(context).text("key_select_subject");
      }
    }
    return CustomProgressHandler(
      isLoading: this._isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _attendancePageGlobalKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_mark_attendance"),
            subtitle: subtitle,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () async {
                if (selectedAttendaceType ==
                    AttendanceConfigurationNames.Classwise) {
                  if (_classes != null && _classes.length > 0) {
                    showClassesList();
                  } else {
                    _classes = await fetchClasses();
                    if (_classes != null && _classes.length > 0) {
                      showClassesList();
                    }
                  }
                } else {
                  if (_subjects != null && _subjects.length > 0) {
                    showSubjects();
                  } else {
                    _subjects = await fetchPeriods();
                    if (_subjects != null && _subjects.length > 0) {
                      showSubjects();
                    }
                  }
                }
              },
            ),
          ],
          elevation: 0.0,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchConfiguration(ConfigurationGroups.Attendance).then((result) {
              setState(() {
                _configurations = result;
                Configuration conf = _configurations.firstWhere(
                    (item) => item.confName == ConfigurationNames.SUBJECTWISE);
                selectedAttendaceType = conf != null && conf.confValue == "N"
                    ? AttendanceConfigurationNames.Classwise
                    : AttendanceConfigurationNames.Subjectwise;
              });
            });
            String subID = selectedAttendaceType ==
                    AttendanceConfigurationNames.Classwise
                ? "-1"
                : _selectedPeriod != null ? _selectedPeriod.subject_id : "-1";
            fetchStudentAttendance(subID).then((result) {
              setState(() {
                _attendances = result;
              });
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 18.0,
                    right: 18.0,
                    bottom: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
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
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context).text("key_date"),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: Text(
                                    DateFormat('dd-MMM-yyyy')
                                        .format(_selectedDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8.0,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  child: Icon(
                                    Icons.date_range,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                color: Theme.of(context).secondaryHeaderColor,
                                child: Text(''),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() async {
                                    if (selectedAttendaceType ==
                                        AttendanceConfigurationNames
                                            .Subjectwise) {
                                      fetchStudentAttendance(_selectedPeriod
                                          .subject_id
                                          .toString())
                                          .then(
                                            (result) {
                                          setState(() {
                                            _attendances =
                                            result != null ? result : [];
                                          });
                                        },
                                      );
                                    } else {
                                      fetchStudentAttendance("-1").then(
                                            (result) {
                                          setState(() {
                                            _attendances =
                                            result != null ? result : [];
                                          });
                                        },
                                      );
                                    }
                                    _defaultAttendance = 'Present';
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    AppTranslations.of(context)
                                        .text("key_show"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showDefaultAttendances();
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
                                    AppTranslations.of(context)
                                        .text("key_default_attendance"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                  ),
                                ),
                                Text(
                                  _defaultAttendance == 'Present'
                                      ? AppTranslations.of(context)
                                          .text("key_present")
                                      : AppTranslations.of(context)
                                          .text("key_absent"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
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
                    ],
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    if (selectedAttendaceType ==
                        AttendanceConfigurationNames.Classwise) {
                      fetchStudentAttendance("-1").then(
                        (result) {
                          setState(() {
                            _attendances = result;
                          });
                        },
                      );
                    } else {
                      fetchStudentAttendance(
                              _selectedPeriod.subject_id.toString())
                          .then(
                        (result) {
                          setState(() {
                            _attendances = result;
                          });
                        },
                      );
                    }
                  },
                  child: _attendances != null && _attendances.length > 0
                      ? ListView.separated(
                          itemCount: _attendances.length,
                          itemBuilder: (BuildContext context, int index) {
                            return CustomAttendanceItem(
                              onItemTap: () {
                                setState(() {
                                  _attendances[index].at_status =
                                      _attendances[index].at_status == 'P'
                                          ? 'A'
                                          : 'P';
                                });
                              },
                              item: _attendances[index],
                              itemIndex: index,
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 55.0,
                                top: 0.0,
                                bottom: 0.0,
                              ),
                              child: Divider(
                                height: 0.0,
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
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.2,
                                        ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_attendances != null && _attendances.length > 0) {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CustomActionDialog(
                        message: AppTranslations.of(context)
                            .text("key_attendance_confirmation"),
                        // 'Do you really want to mark attendance?',
                        actionName: AppTranslations.of(context).text("key_yes"),
                        actionColor: Colors.green,
                        onActionTapped: () {
                          Navigator.pop(context);
                           DateFormat('dd-MM-yyyy').format(_selectedDate) == DateFormat('dd-MM-yyyy').format(DateTime.now())
                               ? saveStudentAttendances()
                               : attendanceApproval == true ? saveStudentAttendances(): FlushbarMessage.show(
                             context,
                             null,
                             AppTranslations.of(context)
                                 .text("key_previous_day_attendace"),
                             MessageTypes.WARNING,
                           );
                           },
                        onCancelTapped: () {
                          Navigator.pop(context);
                        },
                      ),
                    );
                  } else {
                    FlushbarMessage.show(
                      context,
                      null,
                      AppTranslations.of(context).text("key_load_attendance"),
                      MessageTypes.INFORMATION,
                    );
                  }
                },
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        AppTranslations.of(context).text("key_save_attendance"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveStudentAttendances() async {
    try {
      setState(() {
        _isLoading = true;
        loadingText = AppTranslations.of(context).text("key_saving_text");
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          StudentAttendanceFieldNames.yr_no:
              user != null ? user.yr_no.toString() : '0',
        };

        Uri saveAttendanceUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                StudentAttendanceUrls.PUT_STUDENT_ATTENDANCE,
            params);

        String strResponse = json.encode(_attendances);
        http.Response response = await http.post(
          saveAttendanceUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: json.encode(_attendances),
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          _attendances = [];
          FlushbarMessage.show(
            context,
            null,
            AppTranslations.of(context)
                .text("key_mark_attendance_successfully"),
            MessageTypes.INFORMATION,
          );
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.ERROR,
          );
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
      loadingText = AppTranslations.of(context).text("key_loading");
    });
  }

  Future<List<TeacherClass>> fetchClasses() async {
    List<TeacherClass> teacherClasses;
    try {
      setState(() {
        _isLoading = true;
        loadingText = AppTranslations.of(context).text("key_loading");
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
                TeacherClassUrls.GET_TEACHER_CLASSES,
            params);

        http.Response response = await http.get(fetchClassesUri);
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
                .map((item) => TeacherClass.fromJson(item))
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

    return teacherClasses;
  }

  Future<List<Configuration>> fetchConfiguration(String confGroup) async {
    List<Configuration> configurations = [];
    try {
      setState(() {
        _isLoading = true;
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
      _isLoading = false;
    });

    return configurations;
  }

  Future<List<StudentAttendance>> fetchStudentAttendance(
      String subjectID) async {
    List<StudentAttendance> studentAttendances = [];
    try {
      setState(() {
        _isLoading = true;
        loadingText = AppTranslations.of(context).text("key_loading");
      });
      Map<String, dynamic> params;

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        if (selectedAttendaceType == AttendanceConfigurationNames.Classwise) {
          User user = AppData.getCurrentInstance().user;
          params = {
            StudentAttendanceFieldNames.class_id:
                _selectedClass.class_id.toString(),
            StudentAttendanceFieldNames.division_id:
                _selectedClass.division_id.toString(),
            StudentAttendanceFieldNames.subject_id: subjectID.toString(),
            StudentAttendanceFieldNames.at_date:
                DateFormat("yyyy-MMM-dd").format(_selectedDate),
            StudentAttendanceFieldNames.yr_no: user.yr_no.toString(),
          };
        } else {
          User user = AppData.getCurrentInstance().user;
          params = {
            StudentAttendanceFieldNames.class_id:
                _selectedPeriod.class_id.toString(),
            StudentAttendanceFieldNames.division_id:
                _selectedPeriod.division_id.toString(),
            StudentAttendanceFieldNames.subject_id:
                subjectID.toString(),
            StudentAttendanceFieldNames.at_date:
                DateFormat("yyyy-MMM-dd").format(_selectedDate),
            StudentAttendanceFieldNames.yr_no: user.yr_no.toString(),
          };
        }
        Uri fetchStudentUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                StudentAttendanceUrls.GET_DIVISION_ATTENDANCE,
            params);

        http.Response response = await http.get(fetchStudentUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            AppTranslations.of(context).text("key_students_not_found"),
            MessageTypes.ERROR,
          );
        } else {
          List responseData = json.decode(response.body);
          studentAttendances = responseData
              .map((item) => StudentAttendance.fromMap(item))
              .toList();
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

    return studentAttendances;
  }

  void showDefaultAttendances() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message:
              AppTranslations.of(context).text("key_select_default_attendance"),
        ),
        actions: List<Widget>.generate(
          _attendanceStatus.length,
          (index) => CustomCupertinoActionSheetAction(
            actionIndex: index,
            actionText: _attendanceStatus[index] == 'Present'
                ? AppTranslations.of(context).text("key_present")
                : AppTranslations.of(context).text("key_absent"),
            onActionPressed: () {
              setState(() {
                _defaultAttendance = _attendanceStatus[index];

                for (StudentAttendance attendance in _attendances) {
                  attendance.at_status = _defaultAttendance.substring(0, 1);
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
            actionText: _classes[index].toString(),
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                _selectedClass = _classes[index];
                subtitle = AppTranslations.of(context).text("key_class") +
                    _selectedClass.class_name +
                    ' ' +
                    _selectedClass.division_name;

                fetchStudentAttendance("-1").then(
                  (result) {
                    setState(() {
                      _attendances = result != null ? result : [];
                    });
                  },
                );
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
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
            actionText: StringHandlers.capitalizeWords(
                _subjects[index].class_name +
                    " " +
                    _subjects[index].division_name +
                    " : " +
                    _subjects[index].subject_name),
            onActionPressed: () {
              setState(() {
                _selectedPeriod = _subjects[index];
                subtitle = AppTranslations.of(context).text("key_subject") +
                    ' ' +
                    _selectedPeriod.class_name +
                    ' ' +
                    _selectedPeriod.division_name +
                    _selectedPeriod.subject_name;

                fetchStudentAttendance(_selectedPeriod.subject_id.toString())
                    .then(
                  (result) {
                    setState(() {
                      _attendances = result != null ? result : [];
                    });
                  },
                );
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

  Future<List<TeacherPeriod>> fetchPeriods() async {
    List<TeacherPeriod> periods = [];
    try {
      setState(() {
        _isLoading = true;
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
          periods =
              responseData.map((item) => TeacherPeriod.fromJson(item)).toList();
          bool attendaceOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('attendace_overlay') ??
              false;

          if (!attendaceOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("attendace_overlay", true);
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

    return periods;
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_Click_here_for_subject")),
    );
  }
}
