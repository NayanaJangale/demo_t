import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/leave_type.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/teacher/employee_leaves_page.dart';

class AddEmployeeLeavesPage extends StatefulWidget {
  @override
  _AddEmployeeLeavesPage createState() => _AddEmployeeLeavesPage();
}

class _AddEmployeeLeavesPage extends State<AddEmployeeLeavesPage> {
  DateTime selectedFrom = DateTime.now();
  DateTime selectedUpto = DateTime.now();
  List<LeavesType> leavetype = [];
  GlobalKey<ScaffoldState> _addLeavesPageGlobalKey;
  bool isLoading;
  String loadingText;
  FocusNode remarkFocusNode;
  TextEditingController remarkController;
  File imgFile;
  String subtitle;
  LeavesType selectedLeaves;
  String _leavetype = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLeaveType().then(
      (result) => leavetype = result != null ? result : [],
    );
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _addLeavesPageGlobalKey = GlobalKey<ScaffoldState>();

    remarkFocusNode = FocusNode();
    remarkController = TextEditingController();
  }

  Future<Null> _selectDateFrom(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedFrom,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary
            ),
            disabledColor: Colors.orange,
            accentColor: Theme.of(context).primaryColor,
            dialogBackgroundColor:Colors.grey[200],

          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedFrom)
      setState(() {
        selectedFrom = picked;
      });
  }

  Future<Null> _selectDateUpto(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedUpto,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
            ),
            buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary
            ),
            disabledColor: Colors.orange,
            accentColor: Theme.of(context).primaryColor,
            dialogBackgroundColor:Colors.grey[200],

          ),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedUpto)
      setState(() {
        selectedUpto = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addLeavesPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_employee_leaves") ,
            subtitle: AppTranslations.of(context).text("key_apply_for_leaves"),
          ),
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showLeavesTypes();
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
                                      AppTranslations.of(context).text("key_selected_leaves"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Theme.of(context).primaryColor,
                                          ),
                                    ),
                                  ),
                                  Text(
                                    _leavetype,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          color: Colors.black45,
                                        ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                        top: 10.0,
                      ),
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
                          padding: const EdgeInsets.only(
                              left: 5.0, top: 5.0, bottom: 5.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                AppTranslations.of(context).text("key_leaves_from"),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat('dd-MMM-yyyy')
                                          .format(selectedFrom),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black45,
                                          ),
                                      textAlign: TextAlign.right,
                                    ),
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
                                    _selectDateFrom(context);
                                  },
                                  child: Icon(
                                    Icons.date_range,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                        top: 10.0,
                      ),
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
                          padding: const EdgeInsets.only(
                              left: 5.0, top: 5.0, bottom: 5.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                          AppTranslations.of(context).text("key_leave_upto"),
                                style:
                                    Theme.of(context).textTheme.bodyText2.copyWith(
                                          color: Theme.of(context).primaryColor,
                                        ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: Center(
                                    child: Text(
                                      DateFormat('dd-MMM-yyyy')
                                          .format(selectedUpto),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .copyWith(
                                            color: Colors.black45,
                                          ),
                                      textAlign: TextAlign.right,
                                    ),
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
                                    _selectDateUpto(context);
                                  },
                                  child: Icon(
                                    Icons.date_range,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: new TextField(
                        autofocus: true,
                        focusNode: remarkFocusNode,
                        controller: remarkController,
                        decoration: InputDecoration(
                            hintText: AppTranslations.of(context).text("key_remark"),
                            labelStyle: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: Theme.of(context).primaryColor)),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                String valMsg = getValidationMessage();
                if (valMsg != '') {
                  FlushbarMessage.show(
                    context,
                    null,
                    valMsg,
                    MessageTypes.INFORMATION,
                  );
                } else {
                  postEmployeeLeaves();
                }
              },
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_post_leaves"),
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
        ),
      ),
    );
  }

  void showLeavesTypes() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message:  AppTranslations.of(context).text("key_select_leaves"),
        ),
        actions: List<Widget>.generate(
          leavetype.length,
          (index) => CustomCupertinoActionSheetAction(
            actionText: leavetype[index].l_desc,
            actionIndex: index,
            onActionPressed: () {
              setState(() {
                selectedLeaves = leavetype[index];
                _leavetype = selectedLeaves.l_desc;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  String getValidationMessage() {
    if (remarkController.text == '')
      return AppTranslations.of(context).text("key_Remark_is_mandatory");

    if (selectedLeaves == null) {
      return AppTranslations.of(context).text("key_select_leave_type");
    }

    return '';
  }

  Future<List<LeavesType>> fetchLeaveType() async {
    List<LeavesType> leavetype;
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
                LeaveTypeUrls.GET_LEAVES_TYPE,
            params);

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );

          leavetype = null;
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            leavetype =
                responseData.map((item) => LeavesType.fromJson(item)).toList();
          });
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.INFORMATION,
        );

        leavetype = null;
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),

        MessageTypes.INFORMATION,
      );

      leavetype = null;
    }
    setState(() {
      isLoading = false;
    });

    return leavetype;
  }

  Future<void> postEmployeeLeaves() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Saving . . .';
      });

      /*  String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          UserFieldNames.emp_no:
              AppData.getCurrentInstance().user.emp_no.toString(),
          "sdate": DateFormat("yyyy-MMM-dd").format(selectedFrom),
          "edate": DateFormat("yyyy-MMM-dd").format(selectedUpto),
          "remark": remarkController.text,
          "l_tpcode": selectedLeaves.l_tpcode.toString(),
        };

        Uri saveemployeeleaveUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                LeaveTypeUrls.POST_EMPLOYEE_LEAVES,
            params);

        http.Response response = await http.post(
          saveemployeeleaveUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: '',
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          FlushbarMessage.show(
            context,
            null,
            AppTranslations.of(context).text("key_leave_added_successfully"),
            MessageTypes.INFORMATION,
          );
          _clearData();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmployeeLeavesPage(),
              // builder: (_) => SubjectsPage(),
            ),
          );
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.INFORMATION,
          );
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.INFORMATION,
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
      loadingText = 'Loading..';
    });
  }

  void _clearData() {
    remarkController.text = '';
  }
}
