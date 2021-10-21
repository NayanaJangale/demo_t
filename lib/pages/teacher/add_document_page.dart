import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_cupertino_action.dart';
import 'package:teachers/components/custom_cupertino_action_message.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/custom_text_box.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_request_methods.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/add_document.dart';
import 'package:teachers/models/divison.dart';
import 'package:teachers/models/document_type.dart';
import 'package:teachers/models/school_section.dart';
import 'package:teachers/models/teacher_class.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/documents_page.dart';

class AddDocumentPage extends StatefulWidget {
  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  GlobalKey<ScaffoldState> _addAlbumPageGK;
  bool isLoading;
  String loadingText;
  TextEditingController captionController;
  SchoolSection selectedSection;
  TeacherClass fromClass, toClass;
  List<TeacherClass> classes = [];
  List<SchoolSection> sections = [];
  List<Division> divisions = [];
  Division selectedDivision;
  List<DocumentType> docTypes = [];
  DocumentType selectedDocType;
  File selectedFile;
  String filename = '';
  TextEditingController linkController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _addAlbumPageGK = GlobalKey<ScaffoldState>();
    captionController = TextEditingController();
    linkController = TextEditingController();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    this.selectedDivision = Division(division_id: 0, division_name: "All");

    this.selectedSection = SchoolSection(
      section_id: AppData.getCurrentInstance().user.section_id,
      section_name: AppData.getCurrentInstance().user.section_name,
    );

    generateEmptyClasses();

    fetchSectionwiseClasses(selectedSection.section_id).then((result) {
      setState(() {
        this.classes = result;
        classes.insert(0, new TeacherClass(class_id: 0, class_name: "All"));
      });
    });
    fetchDivision(0).then((result) {
      setState(() {
        divisions.clear();
        divisions = result;
        divisions.insert(
            0, new Division(division_id: 0, division_name: "All"));
      });
    });
    fetchDocTypes().then((result) {
      setState(() {
        this.docTypes = result;
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
        key: _addAlbumPageGK,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_add_document"),
            subtitle: AppTranslations.of(context).text("key_section") +
                ': ' +
                selectedSection.section_name,
          ),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                if (sections != null && sections.length > 0) {
                  showSections();
                } else {
                  fetchSections().then((result) {
                    setState(() {
                      sections = result;
                     /* sections.insert(
                        0,
                        new SchoolSection(section_id: 0, section_name: "All"),
                      );*/
                    });
                    if (sections != null && sections.length > 0) showSections();
                  });
                }
              },
            ),
          ],
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
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        if (classes != null && classes.length > 0) {
                          showClasses('From');
                        } else {
                          fetchSectionwiseClasses(selectedSection.section_id)
                              .then((result) {
                            setState(() {
                              classes = result;
                            });

                            if (classes != null && classes.length > 0)
                              showClasses('From');
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
                              Text(
                                AppTranslations.of(context)
                                    .text("key_from_class"),
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
                                  fromClass.class_name,
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
                      onTap: () {
                        if(fromClass.class_id == 0){
                          classes.clear();
                          divisions.clear();
                          classes.add(TeacherClass(class_id: 0, class_name: "All"));
                          divisions.add(Division(division_id: 0, division_name: "All"));
                        }else {
                          fetchSectionwiseClasses(selectedSection.section_id)
                              .then((result) {
                            setState(() {
                              classes = result;
                              classes.insert(
                                  0, new TeacherClass(class_id: 0, class_name: "All"));
                            });

                          });
                          fetchDivision(0).then((result) {
                            setState(() {
                              divisions.clear();
                              divisions = result;
                              divisions.insert(
                                  0, new Division(division_id: 0, division_name: "All"));
                            });
                          });
                        }
                        if (classes != null && classes.length > 0)
                          showClasses('To');
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
                                    .text("key_to_class"),
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
                                  toClass.class_name,
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
                        showDivisions();
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
                                  selectedDivision.division_name,
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
                      onTap: () {
                        showDocTypes();
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
                                    .text("key_document_type"),
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
                                  selectedDocType != null
                                      ? selectedDocType.category_name
                                      : 'Document Type',
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
                child: Column(
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
                            .text("key_document_caption"),
                        controller: captionController,
                        icon: Icons.title,
                        keyboardType: TextInputType.text,
                        colour: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: CustomTextBox(
                        inputAction: TextInputAction.done,
                        onFieldSubmitted: (value) {},
                        labelText: AppTranslations.of(context)
                            .text("key_document_link"),
                        controller: linkController,
                        icon: Icons.link,
                        keyboardType: TextInputType.text,
                        colour: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: Container(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            loadAssets();
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
                                  Icons.camera_alt,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                AppTranslations.of(context)
                                    .text("key_select_document"),
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
                    Text(
                      filename,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor,
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
                  postDocument().then((res) {});
                  //postAlbum();
                }
              },
              child: Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      AppTranslations.of(context).text("key_post_document"),
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
    );
  }

  Future<void> loadAssets() async {

    FilePickerResult result = await FilePicker.platform.pickFiles();
    if(result != null) {
      selectedFile = File(result.files.single.path);
    }

    //selectedFile = await FilePicker.getFile();
    setState(() {
      filename = selectedFile.path.split('/').last;
    });
  }

  String getValidationMessage() {
    if (captionController.text == '') {
      return AppTranslations.of(context).text("key_document_caption");
    }

    if(selectedDocType == null || selectedDocType.category_id == null || selectedDocType.category_id == 0 ){
      return AppTranslations.of(context).text("key_select_document_category");
    }

    if(selectedFile == null || selectedFile == ""){
      return AppTranslations.of(context).text("key_select_document_file");
    }


    /*if (images.length == 0) {
      return AppTranslations.of(context).text("key_add_one_or_more_image");
    }*/

    return "";
  }

  Future<List<SchoolSection>> fetchSections() async {
    List<TeacherClass> classes = [];
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
                SchoolSectionUrls.GET_SCHOOL_SECTIONS,
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
            sections = responseData
                .map((item) => SchoolSection.fromJson(item))
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

    return sections;
  }

  Future<List<TeacherClass>> fetchSectionwiseClasses(int section_id) async {
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
          "section_id": section_id.toString()
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                TeacherClassUrls.GET_SECTION_CLASSES,
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

  void showClasses(String selectClassFor) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: selectClassFor == 'From'
              ? AppTranslations.of(context).text("key_select_from_class")
              : AppTranslations.of(context).text("key_select_to_class"),
        ),
        actions: List<Widget>.generate(
          classes.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText: classes[i].class_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                if (selectClassFor == 'From') {
                  setState(() {
                    fromClass = classes[i];
                    if(fromClass.class_id==0){
                      this.selectedDivision = Division(division_id: 0, division_name: "All");
                      this.toClass = TeacherClass(class_id: 0, class_name: "All");
                    }
                  });
                } else {
                  setState(() {
                    toClass = classes[i];
                    if (fromClass.class_id == toClass.class_id){
                      fetchDivision(fromClass.class_id).then((result) {
                        setState(() {
                          divisions.clear();
                          divisions = result;
                          divisions.insert(
                              0, new Division(division_id: 0, division_name: "All"));
                        });
                      });
                    }
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

  void showSections() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_school_section"),
        ),
        actions: List<Widget>.generate(
          sections.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: sections[i].section_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                setState(() {
                  selectedSection = sections[i];
                });
              });

              fetchSectionwiseClasses(selectedSection.section_id)
                  .then((result) {
                setState(() {
                  classes = result;

                  if (classes != null && classes.length > 0) {
                    fromClass = classes[0];
                    toClass = classes[0];
                  } else {
                    generateEmptyClasses();
                  }
                });
              });

              fetchDivision(0).then((result) {
                setState(() {
                  divisions.clear();
                  divisions = result;
                  divisions.insert(
                      0, new Division(division_id: 0, division_name: "All"));
                });
              });

              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
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
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void showDocTypes() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
            message: AppTranslations.of(context).text("key_document_type")),
        actions: List<Widget>.generate(
          docTypes.length,
          (i) => CustomCupertinoActionSheetAction(
            actionText: docTypes[i].category_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                setState(() {
                  selectedDocType = docTypes[i];
                });
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void generateEmptyClasses() {
    this.fromClass = TeacherClass(
      class_id: AppData.getCurrentInstance().user.class_id,
      class_name: AppData.getCurrentInstance().user.class_name,
      Section_id: AppData.getCurrentInstance().user.section_id,
      section_name: AppData.getCurrentInstance().user.section_name,
    );

    this.toClass = TeacherClass(
      class_id: AppData.getCurrentInstance().user.class_id,
      class_name: AppData.getCurrentInstance().user.class_name,
      Section_id: AppData.getCurrentInstance().user.section_id,
      section_name: AppData.getCurrentInstance().user.section_name,
    );
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
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                DivisionUrls.GET_BRANCHWISEDIVISIONS,
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

  Future<List<DocumentType>> fetchDocTypes() async {
    List<DocumentType> types = [];
    try {
      setState(() {
        isLoading = true;
      });

      /* String connectionStatus = await NetworkHandler.checkInternetConnection();
      if (connectionStatus == InternetConnection.CONNECTED) {*/

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          "UserNo": AppData.getCurrentInstance().user.user_no.toString(),
        };

        Uri fetchClassesUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                DocumentTypeUrls.GET_DOC_CATEGORIES,
            params);
        print(fetchClassesUri);
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
            types =
                responseData.map((item) => DocumentType.fromMap(item)).toList();
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
    return types;
  }

  Future<void> postDocument() async {
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        User user = AppData.getCurrentInstance().user;

        Map<String, dynamic> params = {
          "user_id": user != null ? user.user_id : "",
        };

        AddDocument document = AddDocument(
          caption: captionController.text,
          category_id: selectedDocType.category_id,
          classfrom: fromClass.class_id,
          classupto: toClass.class_id,
          div_id: selectedDivision.division_id,
          section_id: selectedSection.section_id,
          file_status: 'O',
          doc_link: linkController.text
        );

        Uri saveDocumentUri = Uri.parse(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              "Download/PostDocument",
        ).replace(queryParameters: {
          "clientCode": user.client_code,
          "brcode": user.brcode,
          UserFieldNames.user_no: AppData.getCurrentInstance().user != null
              ? AppData.getCurrentInstance().user.user_no.toString()
              : "",
          UserFieldNames.UserNo: AppData.getCurrentInstance().user != null
              ? AppData.getCurrentInstance().user.user_no.toString()
              : "",
          UserFieldNames.user_id: AppData.getCurrentInstance().user != null
              ? AppData.getCurrentInstance().user.user_id
              : "",
          "UserType": "Teacher",
          "ApplicationType": "Teacher",
          "AppVersion": "1",
          "MacAddress": "xxxxxx",
        });

        String jsonBody = json.encode(document);
        print(jsonBody);
        http.Response response = await http.post(
          saveDocumentUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: jsonBody,
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.CREATED) {
          // post Circular Image
          if (selectedFile != null) {
            var id = response.body;
            await postDocumentFile(int.parse(id));
          } else {


            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                message: Text(
                  AppTranslations.of(context).text("key_save_document"),
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
                        MaterialPageRoute(builder: (context) => DocumentsPage()),
                      );
                    },
                  )
                ],
              ),
            );
          }

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

  Future<void> postDocumentFile(int doc_id) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      final mimeTypeData =

          lookupMimeType(selectedFile.path).split('/');

      final file = await http.MultipartFile.fromPath(
        mimeTypeData[0],
        selectedFile.path,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ),
      );

      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            "Download/PostDocumentFile",
      ).replace(
        queryParameters: {
          'brcode': AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          'doc_id': doc_id.toString(),
          'content_type': file.contentType.toString(),
          'file_ext': "." + mimeTypeData[1],
          'file_type': mimeTypeData[0],
        },
      );

      final imageUploadRequest =
          http.MultipartRequest(HttpRequestMethods.POST, postUri);

      imageUploadRequest.fields['ext'] = mimeTypeData[1];
      imageUploadRequest.files.add(file);

      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == HttpStatusCodes.CREATED) {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            message: Text(
              response.body,
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
                    MaterialPageRoute(builder: (context) => DocumentsPage()),
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
