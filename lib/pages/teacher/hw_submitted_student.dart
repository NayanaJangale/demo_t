import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
import 'package:teachers/models/hw_submitted_stud.dart';
import 'package:teachers/models/period.dart';

import 'hw_submitted_photos_page.dart';

class HWSubmittedStudPage extends StatefulWidget {
  final List<Period> periods;
  final int hw_no;

  HWSubmittedStudPage({
    this.periods,
    this.hw_no,
  });

  @override
  _HWSubmittedStudPageState createState() => _HWSubmittedStudPageState();
}

class _HWSubmittedStudPageState extends State<HWSubmittedStudPage> {
  String periodtext,statusText;
  Period seletedPeriod;
  List<String> hwStatus = ['Submitted','Not Submitted'];

  bool isLoading;
  String loadingText,status;
  GlobalKey<ScaffoldState> _hsSubmittedStudPageGlobalKey;
  List<HWSubmittedStud> hwSubmittedStudList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    periodtext = widget.periods[0].class_name +" " + widget.periods[0].division_name +" - " + widget.periods[0].subject_name;
    seletedPeriod = widget.periods[0];
    statusText = hwStatus[0];
    status = "S";
    _hsSubmittedStudPageGlobalKey = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchHWSubmittedStud().then((result) {
      setState(() {
        hwSubmittedStudList = result;
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
        key: _hsSubmittedStudPageGlobalKey,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("HomeWork"),
            subtitle:
            AppTranslations.of(context).text("key_select_period_and_status"),
          ),
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
                    widget.periods.length>1 ? _showHomeWorkFor() : "";
                  },
                  child:Container(
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
                            AppTranslations.of(context).text("key_teacher_period"),
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              periodtext,
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
            Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
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
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              _showHomeWorkStatus();
                            },
                            child: Row(
                              children: <Widget>[
                                Text(
                                  AppTranslations.of(context).text("key_status"),
                                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    color: Theme.of(context).secondaryHeaderColor,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    statusText,
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
                        Container(
                          width: 1,
                          color: Theme.of(context).secondaryHeaderColor,
                          child: Text(''),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() async {
                              fetchHWSubmittedStud().then((result) {
                                setState(() {
                                  hwSubmittedStudList = result;
                                });
                              });
                            });
                          },
                          child: Text(
                            AppTranslations.of(context).text("key_show"),
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: hwSubmittedStudList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){

                      if(status == 'S'){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeWorkSubmittedPhotos(
                              hwSubmittedStud: hwSubmittedStudList[index],
                              hw_no: widget.hw_no,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              hwSubmittedStudList[index].stud_full_name,
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
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 0.0,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }

  void _showHomeWorkFor() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_period"),
        ),
        actions: List<Widget>.generate(
          widget.periods.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText:  widget.periods[i].class_name +" " + widget.periods[i].division_name +" - " + widget.periods[i].subject_name,
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                seletedPeriod = widget.periods[i];
                periodtext = widget.periods[i].class_name +" " + widget.periods[i].division_name +" - " + widget.periods[i].subject_name;
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showHomeWorkStatus() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        message: CustomCupertinoActionMessage(
          message: AppTranslations.of(context).text("key_select_status"),
        ),
        actions: List<Widget>.generate(
          hwStatus.length,
              (i) => CustomCupertinoActionSheetAction(
            actionText:  hwStatus[i],
            actionIndex: i,
            onActionPressed: () {
              setState(() {
                statusText = hwStatus[i];
                if(hwStatus[i] == "Submitted"){
                  status = "S";
                }else{
                  status = "N";
                }
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<List<HWSubmittedStud>> fetchHWSubmittedStud() async {
    List<HWSubmittedStud> hwSubmittedStud = [];
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {

        Map<String, dynamic> params = {
          "class_id":
          seletedPeriod.class_id.toString(),
          "division_id" : seletedPeriod.division_id.toString(),
          "hw_no" : widget.hw_no.toString(),
          "yr_no":AppData.getCurrentInstance().user.yr_no.toString(),
          "status":status,
          "brcode":AppData.getCurrentInstance().user.brcode.toString()
        };

        Uri fetchStudentUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                HWSubmittedStudUrls.GET_HW_Submitted_Stud,
            params);

          Response response = await get(fetchStudentUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          if (response.statusCode == HttpStatusCodes.NOT_FOUND) {
            FlushbarMessage.show(
              context,
              null,
              AppTranslations.of(context).text("key_students_not_found"),
              MessageTypes.ERROR,
            );

          } else {
            FlushbarMessage.show(
              context,
              null,
              response.body.toString(),
              MessageTypes.ERROR,
            );
          }
        } else {
          List responseData = json.decode(response.body);
          hwSubmittedStud = responseData
              .map((item) => HWSubmittedStud.fromMap(item))
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
    return hwSubmittedStud;
  }

}
