import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_text_box.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/multi_select_dialog.dart';
import 'package:teachers/constants/http_request_methods.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/homework.dart';
import 'package:teachers/models/period.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/teacher_period.dart';
import 'package:teachers/models/user.dart';
import 'homework_page.dart';

class AddHomeworkPage extends StatefulWidget {
  @override
  _AddHomeworkPageState createState() => _AddHomeworkPageState();
}

class _AddHomeworkPageState extends State<AddHomeworkPage> {
  List<TeacherPeriod> teacherPeriods = [];
  List<String> menus = ['Camera', 'Gallery'];
  DateTime selectedDate = DateTime.now();
  GlobalKey<ScaffoldState> _addHomeworkPageGlobalKey;
  bool isLoading,_loadingPath = false;
  String loadingText,_fileName,_extension;
  FocusNode titleFocusNode, descriptionFocusNode;
  TextEditingController descriptionController;
  File imgFile;
  List<String> circularFor = ['Period'];
  String selectedItem, subtitle;
  TeacherPeriod selectedPeriod;
  TeacherClass selectedClass;
  List<PlatformFile> _paths;
  String _directoryPath;
  bool _multiPick = true;
  FileType _pickingType = FileType.any;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
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
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _addHomeworkPageGlobalKey = GlobalKey<ScaffoldState>();

    titleFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();

    descriptionController = TextEditingController();

    selectedClass = TeacherClass(
      class_id: AppData.getCurrentInstance().user.class_id,
      division_id: AppData.getCurrentInstance().user.division_id,
      class_name: AppData.getCurrentInstance().user.class_name,
      division_name: AppData.getCurrentInstance().user.division_name,
    );

    fetchPeriods().then((result) {
      setState(() {
        teacherPeriods = result;
      });
    });

    subtitle = selectedClass.class_name + ' ' + selectedClass.division_name;
    selectedItem = 'Teacher Class';
  }

  @override
  Widget build(BuildContext context) {
    subtitle = '';

    for (TeacherPeriod period in teacherPeriods) {
      if (period.isSelected) {
        if (subtitle != '') subtitle += ', ';
        subtitle += period.toString();
      }
    }
    loadingText = AppTranslations.of(context).text("key_loading");

    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addHomeworkPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_add_homework"),
            subtitle:
                AppTranslations.of(context).text("key_add_homework_subtitle"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                _showHomeworkFor();
              },
            ),
          ],
          elevation: 0,
        ),
        body: Column(
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
                    showDialog(
                        context: context,
                        builder: (_) {
                          return MultiSelectDialog(
                            message: AppTranslations.of(context)
                                .text("key_select_multiple_periods"),
                            data: teacherPeriods,
                            onOkayPressed: () {
                              setState(() {});
                            },
                          );
                        });
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
                          Text(
                            selectedItem == 'Teacher Class'
                                ? AppTranslations.of(context).text("key_class")
                                : AppTranslations.of(context)
                                    .text("key_period"),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              subtitle,
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
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
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
                        padding: const EdgeInsets.only(
                            left: 5.0, top: 5.0, bottom: 5.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              AppTranslations.of(context)
                                  .text("key_submission_date"),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  .copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
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
                                      .format(selectedDate),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: CustomTextBox(
                        inputAction: TextInputAction.next,
                        focusNode: descriptionFocusNode,
                        onFieldSubmitted: (value) {
                          this.descriptionFocusNode.unfocus();
                        },
                        labelText:
                            AppTranslations.of(context).text("key_description"),
                        controller: descriptionController,
                        icon: Icons.description,
                        keyboardType: TextInputType.text,
                        colour: Theme.of(context).primaryColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, left: 20),
                        child: Row(
                         children: [
                           Icon(Icons.attach_file_outlined, size: 20,color: Theme.of(context).primaryColorDark,),
                           SizedBox(width: 10,),
                           GestureDetector(
                             onTap: (){
                               _openFileExplorer();
                             },
                             child: Text(
                               "Select Files / Images",
                               style: Theme.of(context).textTheme.bodyText2.copyWith(
                                   color: Theme.of(context).primaryColor,
                                   fontSize: 16,
                                   fontWeight: FontWeight.w500
                               ),
                               textAlign: TextAlign.start,
                             ),
                           ),
                           SizedBox(width: 10,),
                         ],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (BuildContext context) => _loadingPath
                          ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: const CircularProgressIndicator(),
                      )
                          : _directoryPath != null
                          ? ListTile(
                        title: const Text('Directory path'),
                        subtitle: Text(_directoryPath),
                      )
                          : _paths != null
                          ? Container(
                        padding: const EdgeInsets.only(bottom: 10.0,top: 10,left: 20),
                        height:
                        MediaQuery.of(context).size.height * 0.50,
                        child: Scrollbar(
                            child: ListView.separated(
                              itemCount:
                              _paths != null && _paths.isNotEmpty
                                  ? _paths.length
                                  : 1,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                final bool isMultiPath =
                                    _paths != null && _paths.isNotEmpty;
                                final String name = 'File $index: ' + (isMultiPath
                                        ? _paths.map((e) => e.name).toList()[index] : _fileName ?? '...');
                                final path = _paths.map((e) => e.path).toList()[index].toString();

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8, right: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Expanded(
                                       child: Text(
                                         name,
                                         style: Theme.of(context).textTheme.bodyText1.copyWith(
                                           color: Colors.black87,
                                           fontWeight: FontWeight.w500,
                                         ),
                                         overflow: TextOverflow.ellipsis,
                                       ),
                                     ),
                                     GestureDetector(
                                       behavior: HitTestBehavior.translucent,
                                         child: Icon(Icons.delete,color: Theme.of(context).primaryColor,),
                                       onTap: (){
                                         setState(() {
                                           _paths.removeAt(index);
                                         });
                                       },
                                     )
                                   ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                              const Divider(),
                            )),
                      )
                          : const SizedBox(),
                    ),
                    /*  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imgFile == null
                            ? Container(
                                color: Theme.of(context).secondaryHeaderColor,
                                child: Center(
                                  child: Text(
                                    AppTranslations.of(context)
                                        .text("key_image"),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              )
                            : Image.file(
                                imgFile,
                                fit: BoxFit.cover,
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
                        height: 0.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: Container(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              leading: menus[index] == 'Camera'
                                  ? Icon(
                                      Icons.camera_alt,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : Icon(
                                      Icons.photo,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              title: Text(
                                menus[index] == 'Camera'
                                    ? AppTranslations.of(context)
                                        .text("key_camera")
                                    : AppTranslations.of(context)
                                        .text("key_gallery"),
                                style:
                                    Theme.of(context).textTheme.bodyText1.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                              ),
                              onTap: () {
                                if (menus[index] == 'Camera') {
                                  _pickImage(ImageSource.camera)
                                      .then((result) {});
                                } else {
                                  _pickImage(ImageSource.gallery)
                                      .then((result) {});
                                }
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(
                                0.0,
                              ),
                              child: Divider(
                                height: 0.0,
                              ),
                            );
                          },
                          itemCount: menus.length,
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
                        height: 0.0,
                      ),
                    ),*/
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
                  postHomework();
                }
              },
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_post_homework"),
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
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
  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      print(_paths.first.extension);
      _fileName =
      _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });
  }
  Future _pickImage(ImageSource iSource) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile compressedImage = await imagePicker.getImage(
      source: iSource,
      imageQuality: 100,
    );
    //imageFile = await compressAndGetFile(imageFile);
    setState(() {
      descriptionController = descriptionController;
      this.imgFile = File(compressedImage.path);
    });
  }
  Future<File> compressAndGetFile(File file) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path,
      quality: 10,
      rotate: 0,
    );

    return result;
  }
  String getValidationMessage() {
    if (descriptionController.text == '')
      return AppTranslations.of(context).text("key_description_instruction");

    if (teacherPeriods.where((item) => item.isSelected == true).length == 0) {
      return AppTranslations.of(context).text("key_select_period_instruction");
    }

    return '';
  }
  void _showHomeworkFor() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_send_homework_to"),
        ),
        actions: List<Widget>.generate(
          circularFor.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: circularFor[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedItem = circularFor[i] == 'Class'
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
  Future<List<TeacherPeriod>> fetchPeriods() async {
    List<TeacherPeriod> periods = [];
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
  Future<void> postHomework() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Period> filterPeriods = [];

      for (TeacherPeriod tPeriod
          in teacherPeriods.where((item) => item.isSelected == true).toList()) {
        filterPeriods.add(Period(
            class_id: tPeriod.class_id,
            division_id: tPeriod.division_id,
            subject_id: tPeriod.subject_id,
            section_id: tPeriod.Section_id));
      }

      Homework homework = Homework(
        hw_desc: descriptionController.text,
        emp_no: AppData.getCurrentInstance().user.emp_no,
        brcode: AppData.getCurrentInstance().user.brcode,
        divisions: json.encode(filterPeriods),
        submission_dt: selectedDate,
      );

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          "user_id": user != null ? user.user_id : "",
        };

        Uri saveCircularUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                HomeworkUrls.POST_TEACHER_HOMEWORK,
            params);

        String jsonBody = json.encode(homework);

        http.Response response = await http.post(
          saveCircularUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          // post Circular Image
          if (_paths != null) {
            await postHomeworkFile(int.parse(response.body.toString()));

           // await postHomeworkImage(int.parse(response.body.toString()));
          } else {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                message: Text(
                  AppTranslations.of(context).text("key_save_homework"),
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
                        MaterialPageRoute(builder: (context) => HomeworkPage()),
                      );
                    },
                  )
                ],
              ),
            );
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
  Future<void> postHomeworkImage(int homework_no) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Homework/PostHomeworkImage',
      ).replace(
        queryParameters: {
          'brcode': AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          'hw_no': homework_no.toString(),
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
        /* FlushbarMessage.show(
          context,
          null,
          AppTranslations.of(context).text("key_save_homework"),
          MessageTypes.INFORMATION,
        );
        Navigator.pop(context);*/
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              AppTranslations.of(context).text("key_save_homework"),
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  AppTranslations.of(context).text("key_ok"),
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(
                      context, true); // It worked for me instead of above line
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeworkPage()),
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
          MessageTypes.ERROR,
        );
      }
    } else {
      FlushbarMessage.show(
        context,
        AppTranslations.of(context).text("key_no_internet"),
        AppTranslations.of(context).text("key_check_internet"),
        MessageTypes.ERROR,
      );
    }
  }
  void _clearData() {
    descriptionController.text = '';
    imgFile = null;
  }
  Future<void> postHomeworkFile(int homework_no) async {
    int saveHwCount = 0 ;
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      for(int i=0 ; i < _paths.length ; i++){
        final mimeTypeData =
        lookupMimeType(_paths[i].path).split('/');

        final file = await http.MultipartFile.fromPath(
          mimeTypeData[0],
          _paths[i].path,
          contentType: MediaType(
            mimeTypeData[0],
            mimeTypeData[1],
          ),
        );

        Uri postUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              "Homework/PostHomeworkFile",
        ).replace(
          queryParameters: {
            'content_type': file.contentType.toString(),
            'brcode': AppData.getCurrentInstance().user.brcode,
            'clientCode': AppData.getCurrentInstance().user.client_code,
            'hw_no': homework_no.toString(),
            'file_name': file.filename.toString(),
            'file_ext': "." + mimeTypeData[1],
            'file_type': mimeTypeData[0],
            'yr_no': AppData.getCurrentInstance().user.yr_no.toString(),
          },
        );

        final imageUploadRequest =
        http.MultipartRequest(HttpRequestMethods.POST, postUri);

        imageUploadRequest.fields['ext'] = mimeTypeData[1];
        imageUploadRequest.files.add(file);

        final streamedResponse = await imageUploadRequest.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == HttpStatusCodes.CREATED){
          saveHwCount ++;
        }
        response.body ;
      }
      if (saveHwCount == _paths.length) {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              "Homework Save Successfully",
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: Text(
                  AppTranslations.of(context).text("key_ok"),
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(
                      context, true);
                  _paths = null ;
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeworkPage()),
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
          MessageTypes.ERROR,
        );
      }
    } else {
      FlushbarMessage.show(
        context,
        null,
        'Please check your Internet Connection!',
        MessageTypes.ERROR,
      );
    }
  }
}
