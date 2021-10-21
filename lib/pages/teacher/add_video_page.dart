import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_text_box.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/chapter_video.dart';
import 'package:teachers/models/chapter_video_detail.dart';
import 'package:teachers/models/class.dart';
import 'package:teachers/models/divison.dart';
import 'package:teachers/models/subject.dart';
import 'package:teachers/models/user.dart';

import 'digital_chapter_page.dart';

class AddVideoPage extends StatefulWidget {
  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  GlobalKey<ScaffoldState> _addVideoPageGK;
  bool isLoading;
  String loadingText;
  List<Division> divisions = [];
  Division selectedDivision;
  List<Class> _classes = [];
  List<Subject> teacherPeriods = [];

  Class _selectedClass;
  Subject _selectedTeacherPeriod;

  TextEditingController titleController;
  TextEditingController nameController;
  TextEditingController urlController;
  var urlConrollers = <TextEditingController>[];
  List<ChapterVideoDetail> videos = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _addVideoPageGK = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    titleController = TextEditingController();
    nameController = TextEditingController();
    urlController = TextEditingController();
    fetchClasses().then((result) {
      _classes = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addVideoPageGK,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppTranslations.of(context).text("key_add_chapter_video"),
          ),
          elevation: 0.0,
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          showClassesList();
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
                                  AppTranslations.of(context).text("key_class"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    _selectedClass != null
                                        ? _selectedClass.class_name
                                        : AppTranslations.of(context)
                                            .text("key_select_class"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
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
                      SizedBox(
                        height: 5.0,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if(divisions !=null && divisions.length > 0 ){
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
                                    selectedDivision != null ? selectedDivision.division_name:AppTranslations.of(context)
                                        .text("key_select_division"),
                                    style:  Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                      color: Colors.white,
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
                      SizedBox(
                        height: 5.0,
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (teacherPeriods != null && teacherPeriods.length > 0) {
                            showSubjectList();
                          } else {
                            if(selectedDivision!= null){
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
                                      .text("key_subject"),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .copyWith(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    _selectedTeacherPeriod != null
                                        ? _selectedTeacherPeriod.subject_name
                                        : AppTranslations.of(context)
                                            .text("key_select_subject"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: CustomTextBox(
                          inputAction: TextInputAction.done,
                          onFieldSubmitted: (value) {},
                          labelText: AppTranslations.of(context)
                              .text("key_chapter_name"),
                          controller: nameController,
                          icon: Icons.description,
                          keyboardType: TextInputType.text,
                          colour: Theme.of(context).primaryColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 8.0,
                        ),
                        child: Container(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              showAlert();
                            },
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 15.0,
                                    top: 15.0,
                                    right: 15.0,
                                    bottom: 15.0,
                                  ),
                                  child: Icon(
                                    Icons.video_call,
                                    size: 30,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Text(
                                  AppTranslations.of(context)
                                      .text("key_add_one_or_more_video"),
                                  style:
                                  Theme.of(context).textTheme.bodyText1.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 0.0,
                          bottom: 0.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        child: Divider(
                          color: Colors.black54,
                          height: 0.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                          top: 8.0,
                        ),
                        child: ListView.separated(
                          primary: false,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 20.0,
                              color: Colors.grey,
                            );
                          },
                          itemCount: videos.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right:8.0),
                                      child: Icon(
                                        Icons.title,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      videos[index].video_title,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(right:8.0),
                                      child: Icon(
                                        Icons.description,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      videos[index].video_url,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        )
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
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
                      MessageTypes.ERROR,
                    );
                  } else {
                    postChapterVideo();
                  }
                },
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        AppTranslations.of(context)
                            .text("key_upload_chapter_video"),
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
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

  String getValidationMessage() {

    if (_selectedClass == null) {
      return AppTranslations.of(context).text("key_select_class_instruction");
    }

    if (_selectedTeacherPeriod == null) {
      return AppTranslations.of(context).text("key_select_subject_instruction");
    }

    if (nameController.text == '') {
      return AppTranslations.of(context).text("key_chapter_name_instruction");
    }

    if (videos == null || videos.length ==0) {
      return AppTranslations.of(context).text("key_title_and_url_instruction");
    }

    return "";
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
              }
              Navigator.pop(context);
            },
          ),
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
              Navigator.pop(context);
            },
          ),
        ),
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

  Future<void> postChapterVideo() async {

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        ChapterVideo chapterVideo = ChapterVideo(
          chapter_name: nameController.text.toString(),
          class_id: _selectedClass.class_id,
          division_id: selectedDivision.division_id,
          emp_no: user.emp_no,
          subject_id: _selectedTeacherPeriod.subject_id,
          videos: json.encode(videos),
        );

        Map<String, dynamic> params = {};

        Uri saveChapterVideoUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              "DigitalChapter/AddChapterVideo",
          params,
        );

        String jsonBody = json.encode(chapterVideo);

        print(jsonBody);
        http.Response response = await http.post(
          saveChapterVideoUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          // post Circular Image
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                AppTranslations.of(context).text("key_save_chapter_video"),
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
                      MaterialPageRoute(
                          builder: (context) => DigitalChapterPage()),
                    );
                  },
                )
              ],
            ),
          );

          //  _clearData();
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

  Future<List<Subject>> fetchPeriods() async {
    List<Subject> periods = [];
    try {
      setState(() {
        isLoading = true;
      });


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;
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
  void showAlert() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Wrap(
              children: <Widget>[
                CustomTextBox(
                  inputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {},
                  labelText: AppTranslations.of(context).text("key_title"),
                  controller: titleController,
                  icon: Icons.title,
                  keyboardType: TextInputType.text,
                  colour: Theme.of(context).primaryColor,
                ),
                CustomTextBox(
                  inputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {},
                  labelText: "url",
                  controller: urlController,
                  icon: Icons.description,
                  keyboardType: TextInputType.text,
                  colour: Theme.of(context).primaryColor,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'OK',
                  style: Theme.of(context).textTheme.button.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                onPressed: () {
                    setState(() {
                      Pattern pattern = r'^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$';
                      RegExp regex = new RegExp(pattern);
                      if(titleController.text.toString() == "" || urlController.text.toString() == ""){
                        FlushbarMessage.show(
                          this.context,
                          null,
                          AppTranslations.of(context).text("key_title_and_url_instruction"),
                          MessageTypes.INFORMATION,
                        );
                        Navigator.pop(context);
                      }else if (!regex.hasMatch(urlController.text)){
                        FlushbarMessage.show(
                          this.context,
                          null,
                          AppTranslations.of(context).text("key_video_url_not_proper"),
                          MessageTypes.WARNING,
                        );
                        Navigator.pop(context);
                      } else{
                        if( urlController.text.toString().startsWith("http"))
                        videos.add(new ChapterVideoDetail(
                            video_url: urlController.text.toString(),
                            video_title: titleController.text.toString(),
                        ));
                      }
                    });
                    Navigator.pop(context);
                  titleController.text = '';
                  urlController.text = '';

                },
              ),
            ],
          );
        });
  }

}
