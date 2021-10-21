import 'package:teachers/handlers/string_handlers.dart';

class ChapterVideoDetail {

  String video_url;
  String video_title;

  ChapterVideoDetail({
    this.video_url,
    this.video_title,
  });

  ChapterVideoDetail.fromJson(Map<String, dynamic> map) {
    video_url = map[ChapterVideoDetailFieldNames.video_url] ?? StringHandlers.NotAvailable;
    video_title = map[ChapterVideoDetailFieldNames.video_title] ?? StringHandlers.NotAvailable;
  }



  Map<String, dynamic> toJson() => <String, dynamic>{
    ChapterVideoDetailFieldNames.video_url: video_url,
    ChapterVideoDetailFieldNames.video_title: video_title,
  };
}

class ChapterVideoDetailFieldNames {
  static const String video_url = "video_url";
  static const String video_title = "video_title";
}

class ChapterVideoDetailUrls {
  static const String POST_CHAPTER_VIDEO = 'DigitalChapter/AddChapterVideo';

}
