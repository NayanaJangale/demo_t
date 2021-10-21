import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_message_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_select_item.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/list_filter_bar.dart';
import 'package:teachers/constants/http_request_methods.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/message.dart';
import 'package:teachers/models/student.dart';
import 'package:teachers/models/student_attendance.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/teacher_period.dart';
import 'package:teachers/models/user.dart';

import 'messages_page.dart';

class SendMessageToParent extends StatefulWidget {
  @override
  _SendMessageToParentState createState() => _SendMessageToParentState();
}

class _SendMessageToParentState extends State<SendMessageToParent> {
  GlobalKey<ScaffoldState> _sendMessageToParentPageGlobalKey;
  List<TeacherClass> teacherClasses = [];
  List<TeacherPeriod> teacherPeriods = [];
  TeacherClass selectedClass;
  TeacherPeriod selectedPeriod;
  String subtitle, loadingText, selectedItem;
  bool isLoading,isSelected = false;
  List<String> messageFor = ['Class', 'Period'];
  List<Student> students = [];
  List<Student> filteredList;
  TextEditingController filterController, messageController;
  String filter;
  File imgFile;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _sendMessageToParentPageGlobalKey = GlobalKey<ScaffoldState>();

    fetchClasses().then((result) {
      setState(() {
        teacherClasses = result;
      });
    });

    fetchPeriods().then((result) {
      setState(() {
        teacherPeriods = result;
      });
    });

    fetchStudents().then((result) {
      setState(() {
        students = result;
      });
    });

    selectedClass = TeacherClass(
      class_id: AppData.getCurrentInstance().user.class_id,
      division_id: AppData.getCurrentInstance().user.division_id,
      class_name: AppData.getCurrentInstance().user.class_name,
      division_name: AppData.getCurrentInstance().user.division_name,
    );

    subtitle = selectedClass.class_name + ' ' + selectedClass.division_name;
    selectedItem = 'Teacher Class';

    messageController = TextEditingController();
    filterController = TextEditingController();
    filterController.addListener(() {
      setState(() {
        filter = filterController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    filteredList = students.where((item) {
      if (filter == null || filter == '')
        return true;
      else {
        return item.stud_fullname.toLowerCase().contains(filter.toLowerCase());
      }
    }).toList();

    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _sendMessageToParentPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_send_message"),
            subtitle: selectedItem == 'Teacher Class'
                ? AppTranslations.of(context).text("key_teacher_class")
                : AppTranslations.of(context).text("key_teacher_period"),
          ),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () async {
                showMessageFor();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (selectedItem == 'Teacher Class') {
                        if (teacherClasses != null &&
                            teacherClasses.length > 0) {
                          showClassActions();
                        } else {
                          fetchClasses().then((result) {
                            setState(() {
                              teacherClasses = result;
                            });
                            showClassActions();
                          });
                        }
                      } else {
                        if (teacherPeriods != null &&
                            teacherPeriods.length > 0) {
                          showPeriodActions();
                        } else {
                          fetchPeriods().then((result) {
                            setState(() {
                              teacherPeriods = result;
                            });
                            showPeriodActions();
                          });
                        }
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
                                selectedItem == 'Teacher Class'
                                    ? AppTranslations.of(context)
                                    .text("key_class")
                                    : AppTranslations.of(context)
                                    .text("key_period"),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(
                                  color:
                                  Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                            Text(
                              subtitle,
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
              ListFilterBar(
                searchFieldController: this.filterController,
                onCloseButtonTap: () {
                  setState(() {
                    filterController.text = '';
                  });
                },
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){
                  setState(() {
                    isSelected = !isSelected;
                    for (Student student in students) {
                      student.isSelected = isSelected;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                          right: 10.0,
                          top: 3.0,
                          bottom: 3.0,
                        ),
                        child: Icon(
                          Icons.check_box,
                          color: this.isSelected
                              ? Theme.of(context).accentColor
                              : Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Select All",
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3.0,
                          bottom: 3.0,
                        ),
                        child: Icon(
                          Icons.navigate_next,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filteredList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomSelectItem(
                      isSelected: filteredList[index].isSelected,
                      onItemTap: () {
                        setState(() {
                          filteredList[index].isSelected =
                          !filteredList[index].isSelected;
                        });
                      },
                      itemTitle: StringHandlers.capitalizeWords(
                          filteredList[index].stud_fullname),
                      itemIndex: index,
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 40.0,
                        top: 0.0,
                        bottom: 0.0,
                      ),
                      child: Divider(
                        height: 0.0,
                      ),
                    );
                  },
                ),
              ),
              CustomMessageBar(
                messageFieldController: this.messageController,
                isMediaOptionRequired: true,
                msgHint: AppTranslations.of(context).text("key_type_message"),
                onSendButtonPressed: () {
                  String valMsg = getValidationMessage();
                  if (valMsg != '') {
                    FlushbarMessage.show(
                      context,
                      null,
                      valMsg,
                      MessageTypes.INFORMATION,
                    );
                  } else {
                    postMessage();
                  }
                },
                onMediaSelected: (result) {
                  messageController = messageController;
                  imgFile = result;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<TeacherClass>> fetchClasses() async {
    List<TeacherClass> classes = [];
    try {
      setState(() {
        isLoading = true;
      });

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
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
          setState(() {
            List responseData = json.decode(response.body);
            classes = responseData
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

    return classes;
  }

  Future<List<TeacherPeriod>> fetchPeriods() async {
    List<TeacherPeriod> periods = [];
    try {
      setState(() {
        isLoading = true;
      });

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
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
            MessageTypes.ERROR,
          );
        } else {
          List responseData = json.decode(response.body);
          periods =
              responseData.map((item) => TeacherPeriod.fromJson(item)).toList();
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

  Future<List<Student>> fetchStudents() async {
    setState(() {
      isLoading = true;
    });

    List<Student> students = [];
    try {
      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
        Map<String, dynamic> params = {
          UserFieldNames.emp_no: user != null ? user.emp_no.toString() : "",
          UserFieldNames.class_id: selectedItem == 'Teacher Class'
              ? (selectedClass != null ? selectedClass.class_id.toString() : "")
              : (selectedPeriod != null
              ? selectedPeriod.class_id.toString()
              : ""),
          UserFieldNames.division_id: selectedItem == 'Teacher Class'
              ? (selectedClass != null
              ? selectedClass.division_id.toString()
              : "")
              : (selectedPeriod != null
              ? selectedPeriod.division_id.toString()
              : ""),
          UserFieldNames.yr_no: user != null ? user.yr_no.toString() : "",
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              StudentUrls.GET_DIVISION_STUDENTS,
          params,
        );

        http.Response response = await http.get(fetchClassesUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body.toString(),
            MessageTypes.ERROR,
          );
        } else {
          List responseData = json.decode(response.body);
          students =
              responseData.map((item) => Student.fromJson(item)).toList();
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

    return students;
  }

  Future<void> postMessage() async {
    try {
      setState(() {
        isLoading = true;
      });

      String studentNos = '';
      for (int i = 0; i < filteredList.length; i++) {
        if (filteredList[i].isSelected) {
          if (studentNos != '') studentNos += ',';
          studentNos = studentNos + filteredList[i].stud_no.toString();
        }
      }

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          UserFieldNames.user_id: user != null ? user.user_id : "",
          "MessageFor": 'Parent',
          UserFieldNames.emp_no: user.emp_no.toString(),
          "MessageContent": messageController.text,
          "RecipientNos": studentNos,
           StudentAttendanceFieldNames.yr_no: user.yr_no.toString(),
        };

        Uri saveMessageUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                MessageUrls.POST_TEACHER_MESSAGE,
            params);

        http.Response response = await http.post(
          saveMessageUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: '',
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          // post Message Image
          if (imgFile != null) {
            await postMessageImage(
              int.parse(
                response.body.toString(),
              ),
            );
          } else {
            /* FlushbarMessage.show(
              context,
              null,
              AppTranslations.of(context).text("key_save_message"),
              MessageTypes.INFORMATION,
            );*/
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                message: Text(
                  AppTranslations.of(context).text("key_save_message"),
                  style: TextStyle(fontSize: 18),
                ),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: Text(
                      AppTranslations.of(context).text("key_ok"),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context,
                          true); // It worked for me instead of above line
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MessagePage()),
                      );
                    },
                  )
                ],
              ),
            );
            setState(() {
              isLoading = false;
            });
          }
          _clearData();
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
  }

  Future<void> postMessageImage(int MessageNo) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Message/PostMessageImage',
      ).replace(
        queryParameters: {
          UserFieldNames.brcode: AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          MessageFieldNames.MessageNo: MessageNo.toString(),
        },
      );

      final mimeTypeData =
      lookupMimeType(imgFile.path, headerBytes: [0xFF, 0xD8]).split('/');

      final imageUploadRequest =
      http.MultipartRequest(HttpRequestMethods.POST, postUri);

      final file = await http.MultipartFile.fromPath(
        'image',
        imgFile.path,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ),
      );

      imageUploadRequest.fields['ext'] = mimeTypeData[1];
      imageUploadRequest.files.add(file);

      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == HttpStatusCodes.CREATED) {
        /*FlushbarMessage.show(
          context,
          null,
          AppTranslations.of(context).text("key_save_message"),
          MessageTypes.ERROR,
        );
        Navigator.pop(context);*/
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              AppTranslations.of(context).text("key_save_message"),
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  AppTranslations.of(context).text("key_ok"),
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(context,
                      true); // It worked for me instead of above line
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MessagePage()),
                  );
                },
              )
            ],
          ),
        );
      } else {
        FlushbarMessage.show(
          context,
          null,
          AppTranslations.of(context).text("key_image_not_saved"),
          MessageTypes.INFORMATION,
        );
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

  String getValidationMessage() {
    if (messageController.text == '')
      return AppTranslations.of(context).text("key_message_mandatory");

    if (selectedItem == 'Teacher Class') {
      if (filteredList.where((item) => item.isSelected == true).length == 0) {
        return AppTranslations.of(context).text("key_select_class_instruction");
      }
    } else {
      if (filteredList.where((item) => item.isSelected == true).length == 0) {
        return AppTranslations.of(context)
            .text("key_select_period_instruction");
      }
    }

    return '';
  }

  void showMessageFor() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_send_message_to"),
        ),
        actions: List<Widget>.generate(
          messageFor.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: messageFor[i] == 'Class'
                ? AppTranslations.of(context).text("key_class")
                : AppTranslations.of(context).text("key_period"),
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedItem = messageFor[i] == 'Class'
                    ? 'Teacher Class'
                    : 'Teacher Period';

                if (selectedItem == 'Teacher Class') {
                  subtitle = selectedClass != null
                      ? selectedClass.class_name +
                      ' ' +
                      selectedClass.division_name
                      : '';
                } else {
                  subtitle = selectedPeriod != null
                      ? selectedPeriod.class_name +
                      ' ' +
                      selectedPeriod.division_name +
                      ': ' +
                      selectedPeriod.subject_name
                      : '';
                }
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showClassActions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_class"),
        ),
        actions: List<Widget>.generate(
          teacherClasses.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: teacherClasses[i].toString(),
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedClass = teacherClasses[i];
                subtitle = teacherClasses[i].toString();
                fetchStudents().then((result) {
                  setState(() {
                    students = result;
                  });
                });
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showPeriodActions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_period"),
        ),
        actions: List<Widget>.generate(
          teacherPeriods.length,
              (i) => CustomCupertinoActionSheetAction(
            actionIndex: i,
            actionText: teacherPeriods[i].toString(),
            onActionPressed: () {
              setState(() {
                selectedPeriod = teacherPeriods[i];
                subtitle = teacherPeriods[i].toString();
                fetchStudents().then((result) {
                  setState(() {
                    students = result;
                  });
                });
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _clearData() {
    setState(() {
      messageController.text = '';
      imgFile = null;
      for (Student student in students) {
        student.isSelected = false;
      }
    });
  }
}
