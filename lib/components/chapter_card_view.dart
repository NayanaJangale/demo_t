import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:teachers/models/digital_chapter_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ChapterCardView extends StatelessWidget {
  ChapterCardView({
    this.video,
  });

  final DigitalChapterDetail video;
  String thumbnailurl = "http://img.youtube.com/vi/video_key/0.jpg";
  String imageUrl;

  @override
  Widget build(BuildContext context) {
    String videoid =
        YoutubePlayer.convertUrlToId(video.video_url, trimWhitespaces: true);

    imageUrl = thumbnailurl;
    imageUrl = imageUrl.replaceAll('video_key', videoid??"");
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _launchURL(video.video_url);
      },
      child: Card(
        color: Colors.white70,
        child: Container(
          width: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: imageUrl,
                imageBuilder: (context, imageProvider) => AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                placeholder: (context, url) => Padding(
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    top: 4.0,
                  ),
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
                errorWidget: (context, url, error) => AspectRatio(
                  aspectRatio: 16 / 9,
                  child:Icon(
                    Icons.videocam_off,
                    size: 70,
                    color: Colors.grey,
                  ), /*Image.asset(
                    'assets/images/attendance.png',
                    color: Colors.black45.withOpacity(0.5),
                    fit: BoxFit.cover,
                  ),*/
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Text(
                  video.video_title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ),
    );
  }

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
}
