import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/student_fees.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/user.dart';

class StudentFeesPage extends StatefulWidget {
  @override
  _StudentFeesPageState createState() => _StudentFeesPageState();
}

class _StudentFeesPageState extends State<StudentFeesPage> {
  var isLoading = false;
  List<TeacherClass> classes = [];
  List<StudentFees> studFees = [];

  TeacherClass selectedClass = TeacherClass(
    class_id: AppData.getCurrentInstance().user.class_id,
    division_id: AppData.getCurrentInstance().user.division_id,
    class_name: AppData.getCurrentInstance().user.class_name,
    division_name: AppData.getCurrentInstance().user.division_name,
  );
  String loadingText = 'Loading..', subTitle = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    subTitle = selectedClass.class_name;

    fetchClasses().then(
      (result) {
        classes = result;
        fetchStudentFeesReport().then((result) {
          studFees = result;
        });
      },
    );


  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_students_fees"),
            subtitle:
                AppTranslations.of(context).text("key_students_fees_subtitle") +
                    subTitle,
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 18.0,
                  right: 18.0,
                  bottom: 15.0,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (classes != null && classes.length > 0) {
                      showClassesList();
                    } else {
                      fetchClasses().then((result) {
                        setState(() {
                          classes = result;
                          if (classes != null && classes.length > 0) {
                            showClassesList();
                          }
                        });
                      });
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
                          Expanded(
                            child: Text(
                              AppTranslations.of(context)
                                  .text("key_select_class"),
                              style: Theme.of(context).textTheme.bodyText1.copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                  ),
                            ),
                          ),
                          Text(
                            selectedClass.class_name,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(
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
            Expanded(
              child: _createBody(),
            )
          ],
        ),
      ),
    );
  }

  Widget _createBody() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchStudentFeesReport().then(
          (result) => studFees = result != null ? result : [],
        );
      },
      child: studFees != null && studFees.length != 0
          ? ListView(
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 10.0,
                    columnSpacing: 1.0,
                    columns: [
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
                        label: Text(
                          AppTranslations.of(context).text("key_school_fees"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_paid_fees"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_pending_fees"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_bus_fee"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_paid_fees"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          AppTranslations.of(context).text("key_pending_fees"),
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                    rows: studFees
                        .map(
                          ((element) => element.stud_fullname == 'TOTAL'
                              ? DataRow(
                                  selected: true,
                                  cells: <DataCell>[
                                    DataCell(
                                        Container(
                                          child: Text(
                                            element.stud_fullname,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          width: 200.0,
                                        ), onTap: () {
                                      _showDialog(element);
                                    }),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.totsch_fees != null
                                              ? element.totsch_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.paidsch_fees != null
                                              ? element.paidsch_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.pendingSch_fees != null
                                              ? element.pendingSch_fees
                                                  .toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.totbus_fees.toString() != null
                                              ? element.totbus_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.paidbus_fees != null
                                              ? element.paidbus_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.pendingbus_fees != null
                                              ? element.pendingbus_fees
                                                  .toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                  ],
                                )
                              : DataRow(
                                  cells: <DataCell>[
                                    DataCell(
                                        Container(
                                          child: Text(
                                            element.stud_fullname != null
                                                ? StringHandlers
                                                    .capitalizeWords(
                                                        element.stud_fullname)
                                                : '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          width: 200.0,
                                        ), onTap: () {
                                      _showDialog(element);
                                    }),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.totsch_fees != null
                                              ? element.totsch_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.paidsch_fees != null
                                              ? element.paidsch_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.pendingSch_fees != null
                                              ? element.pendingSch_fees
                                                  .toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.totbus_fees.toString() != null
                                              ? element.totbus_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.paidbus_fees != null
                                              ? element.paidbus_fees.toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(
                                          element.pendingbus_fees != null
                                              ? element.pendingbus_fees
                                                  .toString()
                                              : '0.0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      onTap: () {
                                        _showDialog(element);
                                      },
                                    ),
                                  ],
                                )),
                        )
                        .toList(),
                  ),
                ),
              ],
            )
          : Padding(
        padding: const EdgeInsets.only(top: 30),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return CustomDataNotFound(
              description: AppTranslations.of(context)
                  .text("key_fee_not_available"),
            );
          },
        ),
      ),
    );
  }

  Future<List<TeacherClass>> fetchClasses() async {
    List<TeacherClass> teacherClasses = [];
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
                TeacherClassUrls.GET_TEACHER_CLASSES,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
        } else {
          List responseData = json.decode(response.body);
          teacherClasses =
              responseData.map((item) => TeacherClass.fromJson(item)).toList();
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

  Future<List<StudentFees>> fetchStudentFeesReport() async {
    List<StudentFees> studentFees = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          "class_id": selectedClass.class_id.toString(),
          "division_id": selectedClass.division_id.toString(),
          "zero_filter": "Y",
          "yr_no": user.yr_no.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                StudentFeesUrls.GET_STUDENT_FEES_REPORT,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
        } else {
          setState(() {
            double sch_tot = 0,
                sch_paid = 0,
                sch_pending = 0,
                bus_tot = 0,
                bus_paid = 0,
                bus_pending = 0;

            List responseData = json.decode(response.body);
            for (int i = 0; i < responseData.length; i++) {
              studentFees.add(StudentFees.fromMap(responseData[i]));
              sch_tot = sch_tot + studentFees[i].totsch_fees;
              sch_paid = sch_paid + studentFees[i].paidsch_fees;
              sch_pending = sch_pending + studentFees[i].pendingSch_fees;
              bus_tot = bus_tot + studentFees[i].totbus_fees;
              bus_paid = bus_paid + studentFees[i].paidbus_fees;
              bus_pending = bus_pending + studentFees[i].pendingbus_fees;
            }
            StudentFees s = new StudentFees(
              stud_fullname: "TOTAL",
              totsch_fees: sch_tot,
              paidsch_fees: sch_paid,
              pendingSch_fees: sch_pending,
              totbus_fees: bus_tot,
              paidbus_fees: bus_paid,
              pendingbus_fees: bus_pending,
            );
            studentFees.add(s);
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

    return studentFees;
  }

  void showClassesList() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_class"),
        ),
        actions: List<Widget>.generate(
          classes.length,
          (index) => CustomCupertinoActionSheetAction(
            actionText: classes[index].toString(),
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                selectedClass = classes[index];
                subTitle = selectedClass.class_name;

                fetchStudentFeesReport().then(
                  (result) => studFees = result != null ? result : [],
                );
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showDialog(StudentFees studentFees) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  StringHandlers.capitalizeWords(studentFees.stud_fullname),
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Divider(
                height: 3.0,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text("key_school_fees"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        studentFees.totsch_fees != null
                            ? studentFees.totsch_fees.toString()
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 3.0,
                color: Colors.black12,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text("key_paid_fees"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        studentFees.paidsch_fees != null
                            ? studentFees.paidsch_fees.toString()
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 3.0,
                color: Colors.black12,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text("key_pending_fees"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.redAccent,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        studentFees.pendingSch_fees != null
                            ? studentFees.pendingSch_fees.toString()
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.redAccent,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 3.0,
                color: Colors.black12,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text("key_bus_fee"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        studentFees.totbus_fees != null
                            ? studentFees.totbus_fees.toString()
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 3.0,
                color: Colors.black12,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text("key_paid_fees"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        studentFees.paidbus_fees != null
                            ? studentFees.paidbus_fees.toString()
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 3.0,
                color: Colors.black12,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        AppTranslations.of(context).text("key_pending_fees"),
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.redAccent,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        studentFees.pendingbus_fees != null
                            ? studentFees.pendingbus_fees.toString()
                            : '0.0',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Colors.redAccent,
                            ),
                      ),
                    )
                  ],
                ),
              ),
              Divider(
                height: 3.0,
                color: Colors.black12,
              ),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.grey,
                ),
                child: Text(
                  AppTranslations.of(context).text("key_ok"),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
