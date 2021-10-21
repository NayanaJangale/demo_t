import 'package:teachers/handlers/string_handlers.dart';

class DigitalChapterDetail {

  int chapter_id;
  int video_id;
  String chapter_name;
  String video_title;
  String video_url;

  DigitalChapterDetail({
    this.chapter_id,
    this.video_id,
    this.chapter_name,
    this.video_title,
    this.video_url,
  });

  DigitalChapterDetail.fromJson(Map<String, dynamic> map) {
    chapter_id = map[DigitalChapterFieldNames.chapter_id] ?? 0;
    video_id = map[DigitalChapterFieldNames.video_id] ?? 0;
    chapter_name = map[DigitalChapterFieldNames.chapter_name] ?? StringHandlers.NotAvailable;

    video_title = map[DigitalChapterFieldNames.video_title] ?? StringHandlers.NotAvailable;
    video_url = map[DigitalChapterFieldNames.video_url] ?? StringHandlers.NotAvailable;

  }



  Map<String, dynamic> toJson() => <String, dynamic>{
    DigitalChapterFieldNames.chapter_id: chapter_id,
    DigitalChapterFieldNames.video_id: video_id,
    DigitalChapterFieldNames.chapter_name: chapter_name,
    DigitalChapterFieldNames.video_title: video_title,
    DigitalChapterFieldNames.video_url: video_url,
  };
}

class DigitalChapterFieldNames {
  static const String chapter_id = "chapter_id";
  static const String video_id = "video_id";
  static const String chapter_name = "chapter_name";
  static const String emp_no = "emp_no";
  static const String video_title = "video_title";
  static const String video_url = "video_url";
}

class DigitalChapterUrls {
  static const String GET_DIGITAL_CHAPTER = 'DigitalChapter/GetTeacherDigitalChapters';
}
