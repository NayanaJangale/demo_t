import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:teachers/components/flushbar_message.dart';
import 'package:teachers/constants/http_request_methods.dart';
import 'package:teachers/constants/http_status_codes.dart';
import 'package:teachers/constants/message_types.dart';
import 'package:teachers/constants/project_settings.dart';
import 'package:teachers/handlers/network_handler.dart';
import 'package:teachers/localization/app_translations.dart';

import '../../app_data.dart';

class PostCircularImage extends StatefulWidget {
  @override
  _PostCircularImageState createState() => _PostCircularImageState();
}

class _PostCircularImageState extends State<PostCircularImage> {
  GlobalKey<ScaffoldState> postCircularImgPageGlobalState =
      GlobalKey<ScaffoldState>();
  File imgFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: postCircularImgPageGlobalState,
      appBar: AppBar(
        title: Text(
          AppTranslations.of(context).text("key_post_circular_image"),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: imgFile != null ? Image.file(imgFile) : Container(),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery).then((result) {});
                  },
                  child: Text(
                    AppTranslations.of(context).text("key_camera"),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    postCircularImage(74);
                  },
                  child: Text(
                    AppTranslations.of(context).text("key_post"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> postCircularImage(int circular_no) async {
    String connectionServerMsg = await NetworkHandler.getServerWorkingUrl();
    if (connectionServerMsg != "key_check_internet") {
      Uri postUri = Uri.parse(
        connectionServerMsg +
            ProjectSettings.rootUrl +
            'Message/PostMessageImage',
      ).replace(
        queryParameters: {
          'brcode': AppData.getCurrentInstance().user.brcode,
          'clientCode': AppData.getCurrentInstance().user.client_code,
          'MessageNo': circular_no.toString(),
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
        FlushbarMessage.show(
          context,
          null,
          AppTranslations.of(context).text("key_image_saved"),
          MessageTypes.INFORMATION,
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
        'No Internet',
        'Please check your Internet Connection!',
        MessageTypes.INFORMATION,
      );
    }
  }

  Future _pickImage(ImageSource iSource) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile compressedImage = await imagePicker.getImage(
      source: iSource,
      imageQuality: 100,
    );
    setState(() {

      this.imgFile = File(compressedImage.path);
    });
  }

  Future<File> comprressAndGetFile(File file) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path,
      quality: 10,
      rotate: 0,
    );

    return result;
  }
}
