import 'dart:convert';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:teachers/app_data.dart';
import 'package:teachers/components/custom_app_bar.dart';
import 'package:teachers/components/custom_progress_handler.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/localization/app_translations.dart';
import 'package:teachers/models/configuration.dart';
import 'package:teachers/models/newsletter.dart';
import 'package:teachers/models/user.dart';
import 'package:teachers/pages/teacher/add_newsletter_page.dart';
import 'package:teachers/pages/teacher/full_screen_image_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;

class NewsletterPage extends StatefulWidget {
  @override
  _NewsletterPageState createState() => _NewsletterPageState();
}

class _NewsletterPageState extends State<NewsletterPage> {
  bool _isLoading;
  String _loadingText;
  Uri uri;
  bool newsfeedApproval = false;

  List<Newsletter> _newsletter = [];
  GlobalKey<ScaffoldState> _newsletterPageGlobalKey;
  List<Configuration> _approvalConfigurations = [];
  String _thumbnail_url = "http://img.youtube.com/vi/video_key/0.jpg";

  @override
  void initState() {
    // TODO: implement initState
    this._isLoading = false;
    this._loadingText = 'Loading . . .';
    super.initState();
    _newsletterPageGlobalKey = GlobalKey<ScaffoldState>();
    fetchNewsletter().then((result) {
      setState(() {
        _newsletter = result;
      });
    });
    NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
      if (connectionServerMsg != "key_check_internet") {
        setState(() {
          uri = Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Users/GetClientPhoto',
          ).replace(queryParameters: {
            "clientCode": AppData.getCurrentInstance().user.client_code,
            "brcode": AppData.getCurrentInstance().user.brcode,
          });
        });
      }
    });
    fetchConfiguration(ConfigurationGroups.AddNewsfeed).then((result) {
      setState(() {
        _approvalConfigurations = result;
        if(_approvalConfigurations != null && _approvalConfigurations.length > 0 ){
          Configuration conf = _approvalConfigurations.firstWhere(
                  (item) => item.confName == ConfigurationNames.TeacherApp);
          newsfeedApproval = conf != null && conf.confValue == "Y" ? true : false;
        }

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressHandler(
      isLoading: this._isLoading,
      loadingText: this._loadingText,
      child: Scaffold(
        key: _newsletterPageGlobalKey,
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            leading: Row(
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 50,
                  height: 40,
                  child: Image.network(
                    uri.toString(),
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            title: CustomAppBar(
              title: AppTranslations.of(context).text("key_hi") +
                  ' ' +
                  StringHandlers.capitalizeWords(
                      AppData.getCurrentInstance().user.emp_name),
              subtitle: AppTranslations.of(context).text("key_welcometo") +
                      " " +
                      AppData.getCurrentInstance().user.clientName ??
                  "",
            ),
            actions: <Widget>[
              newsfeedApproval == true ?IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () {
                  Navigator.pop(context, true);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddNewslwtterPage()),
                  );
                },
              ):Container(),

            ],
            elevation: 0.0,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              fetchNewsletter().then((result) {
                setState(() {
                  _newsletter = result;
                });
              });
            },
            child: _newsletter != null && _newsletter.length > 0
                ? Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: ListView.builder(
                      itemCount: _newsletter.length,
                      itemBuilder: (BuildContext context, int index) {
                        String video_id = "";
                        String imageUrl = '';
                        if (_newsletter[index].video_url != null &&
                            _newsletter[index].video_url != '') {
                          video_id = YoutubePlayer.convertUrlToId(
                              _newsletter[index].video_url,
                              trimWhitespaces: true);
                          if (video_id != null && video_id != "") {
                            imageUrl = _thumbnail_url;
                            imageUrl =
                                imageUrl.replaceAll('video_key', video_id);
                          }
                        }
                        return _newsletter[index].video_url != null &&
                                _newsletter[index].video_url != ''
                            ? GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  _launchURL(_newsletter[index].video_url);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5.0,
                                    right: 5.0,
                                  ),
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 4.0,
                                              ),
                                              child: LinearProgressIndicator(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .secondaryHeaderColor,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: <Widget>[
                                              Icon(
                                                FontAwesomeIcons.youtube,
                                                color: Colors.red,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _newsletter[index].NewsTitle,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .copyWith(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(
                                                _newsletter[index].NewsDate),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Container(
                                            child: Text(
                                              _newsletter[index].NewsDesc,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : FutureBuilder<String>(
                                future: getImageUrl(_newsletter[index]),
                                builder:
                                    (context, AsyncSnapshot<String> snapshot) {
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Card(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    FullScreenImagePage(
                                                  dynamicObjects: _newsletter,
                                                  imageType: 'Newsletter',
                                                  photoIndex: 0,
                                                ),
                                              ),
                                            );
                                          },
                                          child: CachedNetworkImage(
                                            imageUrl: snapshot.data != null
                                                ? snapshot.data.toString()
                                                : '',
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: Image.network(
                                                  snapshot.data != null
                                                      ? snapshot.data.toString()
                                                      : '',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8, right: 8, top: 4),
                                              child: LinearProgressIndicator(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .secondaryHeaderColor,
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          child: Text(
                                            _newsletter[index].NewsTitle,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Text(
                                            DateFormat('yyyy-MM-dd').format(
                                                _newsletter[index].NewsDate),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8.0,
                                              bottom: 8.0),
                                          child: Text(
                                            _newsletter[index].NewsDesc,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2
                                                .copyWith(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    )),
                                  );
                                });
                      },
                    ),
                  )
                : Padding(
                padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 4),
                child:  AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                          AppTranslations.of(context).text("key_dear") +
                          AppData.getCurrentInstance().user.emp_name +
                          " " +
                          AppTranslations.of(context).text("key_welcometo") +
                          AppData.getCurrentInstance().user.clientName +
                          AppTranslations.of(context)
                              .text("key_teacher_welcome_instruction"),
                      textStyle: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Quicksand',
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,

                      ),
                    ),
                  ],
                  //     speed: const Duration(milliseconds: 2000),
                  totalRepeatCount: 4,
                  pause: const Duration(milliseconds: 1000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                )
            )
          )
      ),
    );
  }


  Future<List<Newsletter>> fetchNewsletter() async {
    List<Newsletter> newsletter = [];
    try {
      setState(() {
        _isLoading = true;
      });

      String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
      if (connectionServerMsg != "key_check_internet") {
        Map<String, dynamic> params = {
          UserFieldNames.yr_no: AppData.getCurrentInstance().user.yr_no.toString(),
          UserFieldNames.brcode:
              AppData.getCurrentInstance().user.brcode.toString(),
          "UserNo": AppData.getCurrentInstance().user.user_no.toString(),
        };

        Uri fetchSchoolsUri = NetworkHandler.getUri(
          connectionServerMsg +
              ProjectSettings.rootUrl +
              NewsletterUrls.GetNewsFeed,
          params,
        );

        http.Response response = await http.get(fetchSchoolsUri);
        if (response.statusCode != HttpStatusCodes.OK) {
         /* FlushbarMessage.show(
              context, null, response.body, MessageTypes.WARNING);*/
        } else {
          setState(() {
            List responseData = json.decode(response.body);
            newsletter = responseData
                .map(
                  (item) => Newsletter.fromMap(item),
                )
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
      _isLoading = false;
    });

    return newsletter;
  }

  Future<String> getImageUrl(Newsletter newsletter) =>
      NetworkHandler.getServerWorkingUrl().then((connectionServerMsg) {
        if (connectionServerMsg != "key_check_internet") {
          return Uri.parse(
            connectionServerMsg +
                ProjectSettings.rootUrl +
                'Video/GetNewsFeedImage',
          ).replace(queryParameters: {
            "NewsId": newsletter.NewsId.toString(),
            UserFieldNames.brcode: AppData.getCurrentInstance().user.brcode,
            "clientCode": AppData.getCurrentInstance().user.client_code,
          }).toString();
        }
      });

  _launchURL(String url) async {
    if (Platform.isIOS) {
      url = url.replaceAll('https://', '');
      url = url.replaceAll('http://', '');

      if (await canLaunch('youtube://' + url)) {
        await launch('youtube://' + url, forceSafariVC: false);
      } else {
        if (await canLaunch('https://' + url)) {
          await launch('https://' + url);
        } else {
          throw 'Could not launch https://' + url;
        }
      }
    } else {
      print(url);
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }
  Future<List<Configuration>> fetchConfiguration(String confGroup) async {
    List<Configuration> configurations = [];
    try {
      setState(() {
        _isLoading = true;
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
      _isLoading = false;
    });

    return configurations;
  }
}
