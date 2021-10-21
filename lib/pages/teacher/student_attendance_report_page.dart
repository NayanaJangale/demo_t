import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/pdf_maker.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/mng_student_attendance_report.dart';

class StudentAttendanceReportPage extends StatefulWidget {
  @override
  _StudentAttendanceReportPageState createState() =>
      _StudentAttendanceReportPageState();
}

class _StudentAttendanceReportPageState
    extends State<StudentAttendanceReportPage> {
  bool isLoading;
  String loadingText;
  List<StudentAttendanceReport> studentAttendance = [];

  DateTime startDate = DateTime.now().add(
    Duration(days: -30),
  );
  DateTime endDate = DateTime.now();

  Future<Null> _selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
      if (endDate.isBefore(startDate)) {
        FlushbarMessage.show(
          context,
          '',
          AppTranslations.of(context).text("key_date_not_valid_for_report"),
          MessageTypes.ERROR,
        );
        setState(() {
          endDate = DateTime.now();
        });
      } else {
        fetchStudentAttendaceReport().then((result) {
          setState(() {
            studentAttendance = result;
          });
        });
      }
    }
  }

  Future<Null> _selectEndDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
      if (endDate.isBefore(startDate)) {
        FlushbarMessage.show(
          context,
          '',
          AppTranslations.of(context).text("key_date_not_valid_for_report"),
          MessageTypes.ERROR,
        );
        setState(() {
          endDate = DateTime.now();
        });
      } else {
        fetchStudentAttendaceReport().then((result) {
          setState(() {
            studentAttendance = result;
          });
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchStudentAttendaceReport().then((result) {
      setState(() {
        studentAttendance = result;
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
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_student_attendance"),
            subtitle: AppTranslations.of(context)
                .text("key_student_attendance_report"),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchStudentAttendaceReport().then((result) {
              setState(() {
                studentAttendance = result;
              });
            });
          },
          child:studentAttendance != null && studentAttendance.length != 0?Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              getInputWidgets(context),
              getDataBody(),
              studentAttendance != null && studentAttendance.length != 0
                  ? getDownloadsButton()
                  : Text(''),
            ],
          ):Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return CustomDataNotFound(
                  description: AppTranslations.of(context)
                      .text("key_student_attendance_repoet_not_available"),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget getInputWidgets(BuildContext context) {
    return Container(
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
              color: Theme.of(context).primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 40.0,
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
                          Text(
                            AppTranslations.of(context).text("key_start_date"),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Text(
                                DateFormat('dd-MMM-yyyy').format(startDate),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
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
                                _selectStartDate(context);
                              },
                              child: Icon(
                                Icons.date_range,
                                color: Colors.white,
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
                  Container(
                    height: 40.0,
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
                          Text(
                            AppTranslations.of(context).text("key_end_date"),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Text(
                                DateFormat('dd-MMM-yyyy').format(endDate),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
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
                                _selectEndDate(context);
                              },
                              child: Icon(
                                Icons.date_range,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getDataBody() {
    int count = 0;
    return studentAttendance != null && studentAttendance.length != 0
        ? Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 40,
                    dataRowHeight: 40,
                    columns: [
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_index_number"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_student_name"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        numeric: true,
                        label: Text(
                          AppTranslations.of(context).text("key_present"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        numeric: true,
                        label: Text(
                          AppTranslations.of(context).text("key_absent"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        numeric: true,
                        label: Text(
                          AppTranslations.of(context).text("key_week"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                    rows: new List<DataRow>.generate(
                      studentAttendance.length,
                      (int index) {
                        count++;
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                studentAttendance[index].ROLL_NO.toString(),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            DataCell(
                              Text(
                                StringHandlers.capitalizeWords(
                                    studentAttendance[index].STUD_FULLNAME),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                            ),
                            DataCell(
                              Text(
                                studentAttendance[index].TOT_PDAYS.toString(),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            DataCell(
                              Text(
                                studentAttendance[index].TOT_ADAYS.toString(),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            DataCell(
                              Text(
                                studentAttendance[index].TOT_WDAYS.toString(),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  AppTranslations.of(context)
                      .text("key_student_attendance_not_available"),
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                ),
              );
            },
          );
  }

  Widget getDownloadsButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        bool isCreated = false;
        PDFMaker.createPdf(
          AppData.getCurrentInstance().user.class_name,
          'Student Attendance Report',
          studentAttendance,
        ).then((val) {
          setState(() {
            isCreated = val;
          });
        });
      },
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              AppTranslations.of(context)
                  .text("key_student_attendance_download"),
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ),
    );
  }
  Future<List<StudentAttendanceReport>> fetchStudentAttendaceReport() async {
    List<StudentAttendanceReport> studAttendace = [];

    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        var formatter = new DateFormat('yyyy-MM-dd');

        Uri fetchStudentAttendanceReportUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              StudentAttendanceReportUrls.GET_STUDENT_ATTENDANCE_REPORT,
          {
            "SDT": formatter.format(startDate),
            "EDT": formatter.format(endDate),
            "CLASS_ID": AppData.getCurrentInstance().user.class_id.toString(),
            "DIV_ID": AppData.getCurrentInstance().user.division_id.toString(),
          },
        );

        http.Response response =
            await http.get(fetchStudentAttendanceReportUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            '',
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          int cnt = 0;
          studAttendace = responseData
              .map(
                (item) => StudentAttendanceReport.fromMap(item),
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
        MessageTypes.ERROR,
      );
    }

    setState(() {
      isLoading = false;
    });

    return studAttendace;
  }
}
