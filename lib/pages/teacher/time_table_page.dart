import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/teacher_time_table.dart';
import 'package:teachers/models/user.dart';

class TimeTablePage extends StatefulWidget {
  @override
  _TimeTablePageState createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  GlobalKey<ScaffoldState> _timeTablePageGlobalKey;
  bool isLoading;
  String loadingText;

  List<String> days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  List<TeacherTimeTable> teacherTimeTable = [];

  Random random = new Random();
  int index = 0;

  List<Color> freePeriodColors;
  List<Color> busyPeriodColors;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _timeTablePageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchTimeTable().then((result) {
      setState(() {
        teacherTimeTable = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: DefaultTabController(
        length: 6,
        initialIndex: DateTime.now().weekday - 1,
        child: Scaffold(
          key: _timeTablePageGlobalKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: CustomAppBar(
              title: AppTranslations.of(context).text("key_timetable"),
              subtitle: AppTranslations.of(context).text("key_your_timetable"),
            ),
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Theme.of(context).secondaryHeaderColor,
              tabs: List<Widget>.generate(
                days.length,
                (i) => Tab(
                  text: AppTranslations.of(context).text("key_${days[i]}"),
                ),
              ),
            ),
            elevation: 0,
          ),
          body: TabBarView(
            children: List<Widget>.generate(
              days.length,
              (i) => getPeriodList(days[i]),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<TeacherTimeTable>> fetchTimeTable() async {
    List<TeacherTimeTable> timeTable = [];
    try {
      setState(() {
        this.isLoading = true;
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
              TeacherTimeTableUrls.GET_TEACHER_TIMETABLE,
          params,
        );
        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          timeTable = responseData
              .map((item) => TeacherTimeTable.fromJson(item))
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
    return timeTable;
  }

  Widget getPeriodList(String day) {
    String periodTitle = '', periodTime = '', periodClass = '';
    return RefreshIndicator(
      onRefresh: () async {
        fetchTimeTable().then((result) {
          setState(() {
            teacherTimeTable = result;
          });
        });
      },
      child: teacherTimeTable != null && teacherTimeTable.length != 0
          ? ListView.separated(
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 30.0,
                    top: 0.0,
                    bottom: 0.0,
                  ),
                  child: Divider(
                    height: 0.0,
                  ),
                );
              },
              itemCount: teacherTimeTable.length,
              itemBuilder: (BuildContext context, int index) {
                freePeriodColors = [
                  Colors.green[300],
                  Colors.green[400],
                  Colors.green,
                ];
                busyPeriodColors = [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).accentColor,
                  Theme.of(context).primaryColor,
                ];
                switch (day) {
                  case "SUN":
                    Map<String, dynamic> periodData =
                        getTitleAndClass(teacherTimeTable[index].Sunday);
                    periodTitle = periodData['periodTitle'];
                    periodClass = periodData['periodClass'];
                    break;
                  case "MON":
                    Map<String, dynamic> periodData =
                        getTitleAndClass(teacherTimeTable[index].Monday);
                    periodTitle = periodData['periodTitle'];
                    periodClass = periodData['periodClass'];
                    break;
                  case "TUE":
                    Map<String, dynamic> periodData =
                        getTitleAndClass(teacherTimeTable[index].Tuesday);
                    periodTitle = periodData['periodTitle'];
                    periodClass = periodData['periodClass'];
                    break;
                  case "WED":
                    Map<String, dynamic> periodData =
                        getTitleAndClass(teacherTimeTable[index].Wednesday);
                    periodTitle = periodData['periodTitle'];
                    periodClass = periodData['periodClass'];
                    break;
                  case "THU":
                    Map<String, dynamic> periodData =
                        getTitleAndClass(teacherTimeTable[index].Thursday);
                    periodTitle = periodData['periodTitle'];
                    periodClass = periodData['periodClass'];
                    break;
                  case "FRI":
                    Map<String, dynamic> periodData =
                        getTitleAndClass(teacherTimeTable[index].Friday);
                    periodTitle = periodData['periodTitle'];
                    periodClass = periodData['periodClass'];
                    break;
                  case "SAT":
                    Map<String, dynamic> periodData =
                        getTitleAndClass(teacherTimeTable[index].Saturday);
                    periodTitle = periodData['periodTitle'];
                    periodClass = periodData['periodClass'];
                    break;
                  default:
                    periodClass = '';
                    periodTitle = 'Free Period';
                    break;
                }
                periodTime = '${teacherTimeTable[index].period_desc}';

                return Padding(
                  padding: const EdgeInsets.only(
                    top: 6,
                    bottom: 9,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                                right: 15.0,
                              ),
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(''),
                                ),
                                width: 4.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    // 10% of the width, so there are ten blinds.
                                    colors: periodTitle != 'Free Period'
                                        ? busyPeriodColors
                                        : freePeriodColors,
                                    // whitish to gray
                                    tileMode: TileMode
                                        .repeated, // repeats the gradient over the canvas
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          StringHandlers.capitalizeWords(
                                              periodTitle),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .copyWith(
                                                color:
                                                    periodTitle != 'Free Period'
                                                        ? Colors.black87
                                                        : Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        periodClass,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2
                                            .copyWith(
                                              color:
                                                  periodTitle != 'Free Period'
                                                      ? Colors.black87
                                                      : Colors.black45,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      periodTitle != 'Free Period'
                                          ? Icon(
                                              Icons.navigate_next,
                                              color: Colors.grey,
                                            )
                                          : Text(''),
                                    ],
                                  ),
                                  Text(
                                    periodTime,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: periodTitle != 'Free Period'
                                              ? Colors.black54
                                              : Colors.black45,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                        .text("key_timetable_not_available"),
                  );
                },
              ),
            ),
    );
  }

  getTitleAndClass(String rawPeriodData) {
    String periodTitle, periodClass;
    if (rawPeriodData != null && rawPeriodData.trim() != '') {
      if (rawPeriodData.contains(':')) {
        periodTitle = rawPeriodData.split(':')[0];
        periodClass = rawPeriodData.split(':')[1];
      } else {
        periodTitle = rawPeriodData;
        periodClass = '';
      }
    } else {
      periodTitle = 'Free Period';
      periodClass = '';
    }

    return {
      'periodTitle': periodTitle,
      'periodClass': periodClass,
    };
  }
}
