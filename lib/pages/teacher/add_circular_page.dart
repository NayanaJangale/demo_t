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
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/circular.dart';
import 'package:teachers/models/configuration.dart';
import 'package:teachers/models/period.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/teacher_period.dart';
import 'package:teachers/models/user.dart';
import 'circular_page.dart';

class AddCircularPage extends StatefulWidget {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  _AddCircularPageState createState() => _AddCircularPageState();
}

class _AddCircularPageState extends State<AddCircularPage> {
  List<TeacherClass> teacherClasses = [];
  List<TeacherPeriod> teacherPeriods = [];
  List<String> menus = ['Camera', 'Gallery'];
  GlobalKey<ScaffoldState> _addCircularPageGlobalKey;
  bool isLoading;
  String loadingText,_extension,_fileName;
  FocusNode titleFocusNode, descriptionFocusNode;
  File imgFile;
  List<PlatformFile> _paths;
  String _directoryPath;
  bool _multiPick = true,  _loadingPath = false;
  FileType _pickingType = FileType.any;
  String selectedItem, subtitle;
  TeacherPeriod selectedPeriod;
  TeacherClass selectedClass;
  List<Configuration> _configurations = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchConfiguration(ConfigurationGroups.CircularFor).then((result) {
      setState(() {
        _configurations = result;
      });
    });

    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    _addCircularPageGlobalKey = GlobalKey<ScaffoldState>();

    titleFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();

    selectedClass = TeacherClass(
      class_id: AppData.getCurrentInstance().user.class_id,
      division_id: AppData.getCurrentInstance().user.division_id,
      class_name: AppData.getCurrentInstance().user.class_name,
      division_name: AppData.getCurrentInstance().user.division_name,
    );

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

    subtitle = selectedClass.class_name + ' ' + selectedClass.division_name;
    selectedItem = 'Teacher Class';
  }

  @override
  Widget build(BuildContext context) {
    loadingText = AppTranslations.of(context).text("key_loading");
    subtitle = '';
    if (selectedItem == 'Teacher Class') {
      for (TeacherClass tClass in teacherClasses) {
        if (tClass.isSelected) {
          if (subtitle != '') subtitle += ', ';
          subtitle += tClass.toString();
        }
      }
    } else {
      for (TeacherPeriod period in teacherPeriods) {
        if (period.isSelected) {
          if (subtitle != '') subtitle += ', ';
          subtitle += period.toString();
        }
      }
    }

    return CustomProgressHandler(
      isLoading: this.isLoading,
      loadingText: this.loadingText,
      child: Scaffold(
        key: _addCircularPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_add_circular"),
            subtitle:
                AppTranslations.of(context).text("key_add_circular_subtitle"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                _showCircularFor();
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
                    if (selectedItem == 'Teacher Class') {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return MultiSelectDialog(
                              message: AppTranslations.of(context)
                                  .text("key_select_multiple_classes"),
                              data: teacherClasses,
                              onOkayPressed: () {
                                setState(() {});
                              },
                            );
                          });
                    } else {
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
                          Text(
                            selectedItem == 'Teacher Class'
                                ? AppTranslations.of(context).text("key_class")
                                : AppTranslations.of(context)
                                    .text("key_period"),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 8.0,
                      ),
                      child: CustomTextBox(
                        inputAction: TextInputAction.next,
                        focusNode: titleFocusNode,
                        onFieldSubmitted: (value) {
                          this.titleFocusNode.unfocus();
                          FocusScope.of(context)
                              .requestFocus(this.descriptionFocusNode);
                        },
                        labelText: StringHandlers.capitalizeWords(
                          AppTranslations.of(context).text("key_title"),
                        ),
                        controller: widget.titleController,
                        icon: Icons.title,
                        keyboardType: TextInputType.text,
                        colour: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: CustomTextBox(
                        inputAction: TextInputAction.done,
                        focusNode: descriptionFocusNode,
                        onFieldSubmitted: (value) {
                          this.descriptionFocusNode.unfocus();
                        },
                        labelText: StringHandlers.capitalizeWords(
                          AppTranslations.of(context).text("key_description"),
                        ),
                        controller: widget.descriptionController,
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
                    /*Padding(
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
                                        .bodyText2
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
                  postCircular();
                }
              },
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_post_circular"),
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
    setState(() {
      widget.titleController = widget.titleController;
      widget.descriptionController = widget.descriptionController;
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
    if (widget.titleController.text == '')
      return AppTranslations.of(context).text("key_title_instruction");

    if (widget.descriptionController.text == '')
      return AppTranslations.of(context).text("key_description_instruction");

    if (selectedItem == 'Teacher Class') {
      if (teacherClasses.where((item) => item.isSelected == true).length == 0) {
        return AppTranslations.of(context).text("key_select_class_instruction");
      }
    } else {
      if (teacherPeriods.where((item) => item.isSelected == true).length == 0) {
        return AppTranslations.of(context)
            .text("key_select_period_instruction");
      }
    }

    return '';
  }

  void _showCircularFor() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_send_circular_to"),
        ),
        actions: List<Widget>.generate(
          _configurations.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: _configurations[i].confName,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                selectedItem = _configurations[i].confName == 'Class'
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

  Future<List<TeacherClass>> fetchClasses() async {
    List<TeacherClass> classes = [];
    try {
      setState(() {
        isLoading = true;
      });

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
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
            MessageTypes.INFORMATION,
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

      /*String connectionStatus = await NetworkHandler.checkInternetConnection();
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

  Future<void> postCircular() async {
    try {
      setState(() {
        isLoading = true;
        loadingText = AppTranslations.of(context).text("key_saving");
      });

      List<Period> filterPeriods = [];
      if (selectedItem == 'Teacher Class') {
        for (TeacherClass tClass in teacherClasses
            .where((item) => item.isSelected == true)
            .toList()) {
          filterPeriods.add(Period(
            class_id: tClass.class_id,
            division_id: tClass.division_id,
            subject_id: 0,
            section_id: tClass.Section_id,
          ));
        }
      } else {
        for (TeacherPeriod tPeriod in teacherPeriods
            .where((item) => item.isSelected == true)
            .toList()) {
          filterPeriods.add(Period(
            class_id: tPeriod.class_id,
            division_id: tPeriod.division_id,
            subject_id: tPeriod.subject_id,
            section_id: tPeriod.Section_id,
          ));
        }
      }

      Circular circular = Circular(
        circular_title: widget.titleController.text,
        circular_desc: widget.descriptionController.text,
        emp_no: AppData.getCurrentInstance().user.emp_no,
        brcode: AppData.getCurrentInstance().user.brcode,
        divisions: json.encode(filterPeriods),
      );
      circular.circular_for = "Students";


      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          "user_id": user != null ? user.user_id : "",
        };

        Uri saveCircularUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                CircularUrls.POST_TEACHER_CIRCULAR,
            params);

        String jsonBody = json.encode(circular);

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
            String number = response.body.toString();
            await postCircularFile(int.parse(response.body.toString()));
          } else {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                message: Text(
                  AppTranslations.of(context).text("key_save_circular"),
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
                        MaterialPageRoute(builder: (context) => CircularPage()),
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

  Future<void> postCircularImage(int circular_no) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Circular/PostCircularImage',
      ).replace(
        queryParameters: {
          'brcode': AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          'circular_no': circular_no.toString(),
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

        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              AppTranslations.of(context).text("key_save_circular"),
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
                    MaterialPageRoute(builder: (context) => CircularPage()),
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
        MessageTypes.WARNING,
      );
    }
  }
  Future<List<Configuration>> fetchConfiguration(String confGroup) async {
    List<Configuration> configurations = [];
    try {
      setState(() {
        isLoading = true;
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
              ConfigurationUrls.GET_CONFIGURATION_BY_VALUE,
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
      isLoading = false;
    });

    return configurations;
  }
  void _clearData() {
    widget.titleController.text = '';
    widget.descriptionController.text = '';
    imgFile = null;
  }
  Future<void> postCircularFile(int circular_no) async {
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
              "Circular/PostCircularFile?",
        ).replace(
          queryParameters: {
            'content_type': file.contentType.toString(),
            'brcode': AppData.getCurrentInstance().user.brcode,
            'clientCode': AppData.getCurrentInstance().user.client_code,
            'circular_no': circular_no.toString(),
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
              "Circular Save Successfully",
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
                    MaterialPageRoute(builder: (context) => CircularPage()),
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
