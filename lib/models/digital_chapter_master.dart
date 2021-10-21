import 'package:teachers/handlers/string_handlers.dart';
import 'package:teachers/models/digital_chapter_detail.dart';

class DigitalChapterMaster {

  int chapter_id;
  String chapter_name;
  List<DigitalChapterDetail> videos;

  DigitalChapterMaster({
    this.chapter_id,
    this.chapter_name,
    this.videos
  });

  DigitalChapterMaster.fromJson(Map<String, dynamic> map) {
    chapter_id = map[DigitalChapterFieldNames.chapter_id] ?? 0;
    chapter_name = map[DigitalChapterFieldNames.chapter_name] ?? StringHandlers.NotAvailable;
    videos = map[DigitalChapterFieldNames.videos] != null
        ? (map[DigitalChapterFieldNames.videos] as List)
        .map((item) => DigitalChapterDetail.fromJson(item))
        .toList()
        : null;
  }



  Map<String, dynamic> toJson() => <String, dynamic>{
    DigitalChapterFieldNames.chapter_id: chapter_id,
    DigitalChapterFieldNames.chapter_name: chapter_name,
    DigitalChapterFieldNames.videos: videos,
  };
}

class DigitalChapterFieldNames {
  static const String chapter_id = "chapter_id";
  static const String chapter_name = "chapter_name";
  static const String videos = "videos";
}

class DigitalChapterUrls {
  static const String GET_DIGITAL_CHAPTER = 'DigitalChapter/GetTeacherDigitalChapters';
}
