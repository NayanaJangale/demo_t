import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_message_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/homework.dart';
import 'package:teachers/models/hw_submitted_stud.dart';
import 'package:teachers/models/student.dart';
import 'package:teachers/models/submitted_hw_detail.dart';

import '../../app_data.dart';
import 'full_screen_image_page.dart';
import 'hw_submitted_student.dart';

class HomeWorkSubmittedPhotos extends StatefulWidget {

  final HWSubmittedStud hwSubmittedStud;
  final int hw_no;

  HomeWorkSubmittedPhotos({
    this.hwSubmittedStud,
    this.hw_no,
  });

  @override
  _HomeWorkSubmittedPhotosState createState() => _HomeWorkSubmittedPhotosState();
}

class _HomeWorkSubmittedPhotosState extends State<HomeWorkSubmittedPhotos> {

  GlobalKey<ScaffoldState> _hwSubmittedPhotosPageGK;
  bool isLoading;
  String loadingText;
  List<SubmittesHWDetail> submittedHWList = [];
  TextEditingController messageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.messageController = TextEditingController();
    _hwSubmittedPhotosPageGK = GlobalKey<ScaffoldState>();
    this.isLoading = false;
    this.loadingText = 'Loading . . .';

    fetchHWPhotos().then((result) {
      setState(() {
        submittedHWList = result;
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
        key: _hwSubmittedPhotosPageGK,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: CustomAppBar(
            title: AppTranslations.of(context).text("key_sub_hw"),
            subtitle:
            widget.hwSubmittedStud.stud_full_name,
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            fetchHWPhotos().then((result) {
              setState(() {
                submittedHWList = result != null ? result : [];
              });
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(3.0),
                  children: List<Widget>.generate(
                    submittedHWList.length,
                        (index) => getAlbumPhotoCard(submittedHWList[index], index),
                  ),
                ),
              ),
              CustomMessageBar(
                messageFieldController: this.messageController,
                isMediaOptionRequired: false,
                msgHint: AppTranslations.of(context).text("key_hw_remark"),
                onSendButtonPressed: () {
                  if (messageController.text == ''){
                    return AppTranslations.of(context).text("key_message_mandatory");
                  }else{
                   postHomeWorkRemark();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getImageUrl(SubmittesHWDetail submittesHWDetail) => NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
    if (connectionServerMsg != "key_check_internet") {
      return Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            SubmittesHWDetailUrls.GET_SubmittedHWPhoto,
      ).replace(queryParameters: {
        SubmittesHWDetailFieldNames.seq_no: submittesHWDetail.seq_no.toString(),
        SubmittesHWDetailFieldNames.ent_no: submittesHWDetail.ent_no.toString(),
        "brcode": AppData.getCurrentInstance().user.brcode,
        "clientCode": AppData.getCurrentInstance().user.client_code,
      }).toString();
    }
  });

  Widget getAlbumPhotoCard(SubmittesHWDetail submittesHWDetail, int index) {

    return FutureBuilder<String>(
        future: getImageUrl(submittesHWDetail),
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: CachedNetworkImage(
                imageUrl: snapshot.data.toString(),
                imageBuilder: (context, imageProvider) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      snapshot.data.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.only(
                      left: 50.0, right: 60.0, top: 60.0, bottom: 60.0),
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                errorWidget: (context, url, error) => Container(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImagePage(
                      dynamicObjects:  submittedHWList,
                      imageType: 'SubmittedHW',
                      photoIndex: index,
                    ),
                  ),
                );
              },
            ),
          );
        });


  }

  Future<List<SubmittesHWDetail>> fetchHWPhotos() async {
    List<SubmittesHWDetail> submittedHWs = [];

    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Uri fetchteacherhwUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              SubmittesHWDetailUrls.GET_SubmittedHWPhotos,
          {
            SubmittesHWDetailFieldNames.seq_no: widget.hwSubmittedStud.seq_no.toString(),
            "UserNo": AppData.getCurrentInstance().user.user_no.toString(),
          },
        );

        Response response = await get(fetchteacherhwUri);
        if (response.statusCode != HttpStatusCodes.OK) {
          FlushbarMessage.show(
            context,
            "",
            response.body,
            MessageTypes.ERROR,
          );
        } else {
          List responseData = json.decode(response.body);
          submittedHWs = responseData
              .map(
                (item) => SubmittesHWDetail.fromJson(item),
          )
              .toList();
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
      FlushbarMessage.show(
        context,
        null,
        AppTranslations.of(context).text("key_api_error"),
        MessageTypes.ERROR,
      );
    }

    setState(() {
      isLoading = false;
    });

    return submittedHWs;
  }

  Future<void> postHomeWorkRemark() async {
    try {
      setState(() {
        isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {

        Map<String, dynamic> params = {
          SubmittesHWDetailFieldNames.seq_no : widget.hwSubmittedStud.seq_no.toString(),
          StudentFieldNames.stud_no: widget.hwSubmittedStud.stud_no.toString(),
          HomeworkFieldNames.Homework_noConst: widget.hw_no.toString(),
          SubmittesHWDetailFieldNames.remark: messageController.text,
        };

        Uri saveStudRemarkUri = NetworkHandler.getUri(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                SubmittesHWDetailUrls.POST_UpdateStudRemark,
            params);

        Response response = await post(
          saveStudRemarkUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: '',
          encoding: Encoding.getByName("utf-8"),
        );

        if (response.statusCode == HttpStatusCodes.ACCEPTED) {
          showCupertinoModalPopup(
            context: context,
            builder: (BuildContext context) => CupertinoActionSheet(
              message: Text(
                AppTranslations.of(context).text("key_save_remark"),
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
                      MaterialPageRoute(builder: (context) => HWSubmittedStudPage()),
                    );
                  },
                )
              ],
            ),
          );
          setState(() {
            isLoading = false;
          });
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
}
