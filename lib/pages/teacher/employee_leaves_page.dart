import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_employee_leaves_item.dart';
import 'package:teachers/components/custom_leaves_application_item.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/employee_leaves.dart';
import 'package:teachers/models/leave_aplication.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/teacher/add_emplyee_leaves.dart';

class EmployeeLeavesPage extends StatefulWidget {
  @override
  _EmployeeLeavesPageState createState() => _EmployeeLeavesPageState();
}

class _EmployeeLeavesPageState extends State<EmployeeLeavesPage> {
  bool isLoading;
  String loadingText;
  GlobalKey<ScaffoldState> _employeeLeavesPageGlobalKey;
  List<EmployeeLeave> _employeeLeaves = [];
  List<LeaveApplication> _LeavesApplication = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _employeeLeavesPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchEmployeeLeaves().then((result) {
      setState(() {
        _employeeLeaves = result;
      });
    });

    fetchEmpAppliedLeaves().then((result) {
      setState(() {
        _LeavesApplication = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _employeeLeavesPageGlobalKey,
          appBar: AppBar(
            title: CustomAppBar(
              title: AppTranslations.of(context).text("key_hi") +
                  ' ' +
                  StringHandlers.capitalizeWords(
                      AppData.getCurrentInstance().user.emp_name),
              subtitle: AppTranslations.of(context).text("key_your_leave"),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEmployeeLeavesPage(),
                      // builder: (_) => SubjectsPage(),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              isScrollable: false,
              indicatorColor: Theme.of(context).secondaryHeaderColor,
              tabs: <Widget>[
                Tab(
                  text: AppTranslations.of(context).text("key_leave_summery"),
                ),
                Tab(
                  text: AppTranslations.of(context).text("key_applied_leave"),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              getEmployeeSummary(),
              getEmployeeAppliedLeaves(),
            ],
          ),
          backgroundColor: Colors.grey[200],
        ),
      ),
    );
  }

  Widget getEmployeeAppliedLeaves() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchEmpAppliedLeaves().then((result) {
          setState(() {
            _LeavesApplication = result;
          });
        });
      },
      child: _LeavesApplication != null && _LeavesApplication.length != 0
          ? ListView.builder(
              itemCount: _LeavesApplication.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomLeaveApplicationItem(
                  leave_type: _LeavesApplication[index].l_desc,
                  start_date: DateFormat('dd MMM ')
                      .format(_LeavesApplication[index].sdate),
                  end_date: DateFormat('dd MMM ')
                      .format(_LeavesApplication[index].edate),
                  apply_date: DateFormat('dd MMM ')
                      .format(_LeavesApplication[index].adate),
                  status: _LeavesApplication[index].status,
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
                        .text("key_applied_leave_not_found"),
                  );
                },
              ),
            ),
    );
  }

  Widget getEmployeeSummary() {
    return RefreshIndicator(
      onRefresh: () async {
        fetchEmployeeLeaves().then((result) {
          setState(() {
            _employeeLeaves = result;
          });
        });
      },
      child: _employeeLeaves != null && _employeeLeaves.length != 0
          ? ListView.builder(
              itemCount: _employeeLeaves.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomEmpLeavesItem(
                  leave_type: _employeeLeaves[index].l_desc,
                  leave_desc: _employeeLeaves[index].type_count.toString(),
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
                        .text("key_leave_summary_not_found"),
                  );
                },
              ),
            ),
    );
  }

  Future<List<EmployeeLeave>> fetchEmployeeLeaves() async {
    List<EmployeeLeave> employeeLeave = [];

    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              EmployeeLeaveUrls.GET_EMPLOYEE_LEAVES,
          {
            "report_date": DateTime.now().toIso8601String(),
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString()
            //  "report_date": "2017-12-24",
          },
        );

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          employeeLeave = responseData
              .map(
                (item) => EmployeeLeave.fromJson(item),
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

    return employeeLeave;
  }

  Future<List<LeaveApplication>> fetchEmpAppliedLeaves() async {
    List<LeaveApplication> employeeLeave = [];

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherAlbumsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              EmployeeLeaveUrls.GET_LEAVES_APPLICATION,
          {
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString()
            //  "report_date": "2017-12-24",
          },
        );

        http.Response response = await http.get(fetchteacherAlbumsUri);

        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.WARNING,
          );
        } else {
          List responseData = json.decode(response.body);
          employeeLeave = responseData
              .map(
                (item) => LeaveApplication.fromJson(item),
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

    return employeeLeave;
  }


}
