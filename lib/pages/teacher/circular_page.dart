import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_alert_dialog.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_circular_item.dart';
import 'package:teachers/components/custom_data_not_found.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/components/overlay_for_select_page.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/circular.dart';
import 'package:teachers/models/configuration.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/teacher/add_circular_page.dart';

class CircularPage extends StatefulWidget {
  @override
  _CircularPageState createState() => _CircularPageState();
}

class _CircularPageState extends State<CircularPage> {
  bool isLoading;
  String loadingText;
  GlobalKey<ScaffoldState> _circularPageGlobalKey;
  List<Circular> _circulars = [];
  String msgKey;
  List<Configuration> _configurations = [];
  bool circularApproval = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _circularPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';
    msgKey = "key_loading_circulars";

    fetchConfiguration(ConfigurationGroups.ApprovedByManagement).then((result) {
      setState(() {
        _configurations = result;
        Configuration conf = _configurations
            .firstWhere((item) => item.confName == ConfigurationNames.Circular);
        circularApproval = conf != null && conf.confValue == "Y" ? true : false;
        fetchCirculars().then((result) {
          setState(() {
            _circulars = result;
          });
        });
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
        backgroundColor: Colors.grey[200],
        key: _circularPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_hi") +
                ' ' +
                StringHandlers.capitalizeWords(
                  AppData.getCurrentInstance().user.emp_name,
                ),
            subtitle:
                AppTranslations.of(context).text("key_see_your_circulars"),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () {
                Navigator.pop(context, true);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCircularPage()),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchConfiguration(ConfigurationGroups.ApprovedByManagement)
                .then((result) {
              setState(() {
                _configurations = result;
                Configuration conf = _configurations.firstWhere(
                    (item) => item.confName == ConfigurationNames.Circular);
                circularApproval =
                    conf != null && conf.confValue == "Y" ? true : false;
                fetchCirculars().then((result) {
                  setState(() {
                    _circulars = result;
                  });
                });
              });
            });
          },
          child: _circulars != null && _circulars.length != 0
              ? ListView.builder(
                  itemCount: _circulars.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomCircularItem(
                        networkPath: "",
                        onItemTap: () {
                          _deleteCircular(_circulars[index].circular_no);
                        },
                        periods: _circulars[index].periods,
                        circular: _circulars[index],
                        circularFrom: _circulars[index].emp_name,
                        isVisibility: circularApproval,
                        approvalStatus:
                        _circulars[index].ApproveStatus == "P"
                            ? "Pending "
                            : "Approved");
                  },
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (BuildContext context, int index) {
                      return CustomDataNotFound(
                        description: AppTranslations.of(context)
                            .text("key_circulars_not_available"),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Future<String> getImageUrl(Circular circular) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Circular/GetCircularImage',
          ).replace(queryParameters: {
            "circular_no": circular.circular_no.toString(),
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          }).toString();
        }
      });

  Future<List<Circular>> fetchCirculars() async {
    List<Circular> circulars = [];

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchCircularsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              CircularUrls.GET_TEACHER_CIRCULARS,
          {
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString(),
          },
        );

        http.Response response = await http.get(fetchCircularsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            null,
            response.body,
            MessageTypes.ERROR,
          );
          setState(() {
            msgKey = "key_circulars_not_available";
          });
        } else {
          List responseData = json.decode(response.body);
          circulars = responseData
              .map(
                (item) => Circular.fromJson(item),
              )
              .toList();
          bool circularOverlay = AppData.getCurrentInstance()
                  .preferences
                  .getBool('circular_overlay') ??
              false;
          if (!circularOverlay) {
            AppData.getCurrentInstance()
                .preferences
                .setBool("circular_overlay", true);
            _showOverlay(context);
          }
        }
      } else {
        FlushbarMessage.show(
          context,
          AppTranslations.of(context).text("key_no_internet"),
          AppTranslations.of(context).text("key_check_internet"),
          MessageTypes.WARNING,
        );
        setState(() {
          msgKey = "key_check_internet";
        });
      }
    } catch (e) {
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.WARNING,
      );
      setState(() {
        msgKey = "key_api_error";
      });
    }

    setState(() {
      isLoading = false;
    });

    return circulars;
  }

  Future<void> DeleteCircular(int circularNo) async {
    try {
      setState(() {
        isLoading = true;
        loadingText = 'Processing . .';
      });
      //TODO: Call change password Api here

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri postDeleteHomeworkUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              CircularUrls.DELETE_TEACHER_CIRCULAR,
          {
            "circular_no": circularNo.toString(),
            UserFieldNames.emp_no:
                AppData.getCurrentInstance().user.emp_no.toString(),
            UserFieldNames.yr_no:
                AppData.getCurrentInstance().user.yr_no.toString(),
            UserFieldNames.brcode:
                AppData.getCurrentInstance().user.brcode.toString(),
          },
        );
        http.Response response = await http.post(postDeleteHomeworkUri);
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        if (response.statusCode == HttpStatusCodes.CREATED) {
          //TODO: Call login
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                AppTranslations.of(context)
                    .text("key_circular_deleted_successfully"),
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text(
                      AppTranslations.of(context).text("key_ok"),
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                      // It worked for me instead of above line
                      fetchCirculars().then((result) {
                        setState(() {
                          _circulars = result;
                        });
                      });
                    })
              ],
            ),
          );
        } else {
          FlushbarMessage.show(
            context,
            null,
            response.body,
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
    } catch (e) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
      print(e);
    }
  }

  void _deleteCircular(int circularNo) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CustomActionDialog(
        actionName: AppTranslations.of(context).text("key_yes"),
        onActionTapped: () {
          Navigator.pop(context);
          DeleteCircular(circularNo);
        },
        actionColor: Colors.red,
        message: AppTranslations.of(context).text("key_delete_circular"),
        onCancelTapped: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    Navigator.of(context).push(
      OverlayForSelectPage(
          AppTranslations.of(context).text("key_Click_here_for_add_circular")),
    );
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
              ConfigurationUrls.GET_CONFIGURATION_BY_GROUP,
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
}
